function [Mr_col,h,Inertia_xy_modif,bestArea,bestCost,bestdiagram,...
    bestdiagram2,bestnv,bestEf,bestArrangement,bestDisposition,nv4,...
    bestcxy,bestCP,bestCFA]=Asym2pack4Diam(b,h,rec,act,npdiag,fdpc,beta1,...
    fy,load_conditions,RebarAvailable,wac,height,...
    condition_cracking,ductility,puCostCardBuild,dataCFA)

%-------------------------------------------------------------------------
% Syntax:
% [Mr_col,h,Inertia_xy_modif,bestArea,bestCost,bestdiagram,...
%  bestdiagram2,bestnv,bestEf,bestArrangement,bestDisposition,nv4,...
%  bestcxy,bestCP,bestCFA]=Asym2pack4Diam(b,h,rec,act,npuntos,fdpc,beta1,...
%  fy,load_conditions,RebarAvailable,wac,height,...
%  condition_cracking,ductility,puCostCardBuild,dataCFA)
%
%-------------------------------------------------------------------------
% SYSTEM OF UNITS: SI - (Kg,cm)
%                  US - (lb,in)
%-------------------------------------------------------------------------
% PURPOSE: To determine an optimal arrangement of rebars asymmetrically 
% distributed over a column cross-section in packages of two rebars. A max
% of four rebar diameters are allowed.
% 
% NOTE: The structural efficiency of each rebar design is determined with
% the Inverse Load method (Bresler's formula) and the Contour Load method.
% Thus, only one interaction diagram is computed for the whole given set of
% load conditions, for each rebar design.
%
% OUTPUT: Mr_col:               are the final resistant bending moment for
%                               both axis directions of the optimal designed 
%                               cross-section
%
%         h:                    modified cross-section height in case it is
%                               modified through the optimization process to
%                               comply the given restrictions of min separation
%                               of rebars
%
%         Inertia_xy_modif:     momentum of inertia of the bar reinforced
%                               cross-section for both axis directions, by 
%                               the computation of the cracking mechanisms 
%                               according to the parameter condition_cracking
%
%         bestArea:             is the optimal rebar area
%
%         bestCost:             is the cost of the optimal design option
%
%         nv4:                  is the number of rebars at each boundary of
%                               the column cross-section corresponding to
%                               the optimal rebar design option
%
%         bestnv:               is the total number of rebars over the 
%                               cross-section corresponding to the optimal
%                               design option
%
%         bestEf:               is the critical structural efficiency 
%                               corresponding to the optimal rebar design
%                               against the critical load condition
%
%         bestArrangement:      is the list of rebar type of each rebar: 
%                               size [nbars,1] (a number from 1 to 7 by 
%                               default)
%
%         best_disposicion:     is an array containing the local coordinates 
%                               of position of each rebar over the cross-
%                               section corresponding to the optimal rebar
%                               design option
%
%         bestdiagram:          is the interaction diagram data of the 
%                               optimal rebar design (considering only 
%                               positive bending moments)
%
%         bestdiagram2:         is the interaction diagram data of the 
%                               optimal rebar design (considering only 
%                               negative bending moments)
%
%         bestcxy:              is a vector containing the neutral axis 
%                               depth values corresponding to the most 
%                               critical load condition for each of the 
%                               two cross-section axis
%
%         bestCP:               is a vector containing the Plastic Center
%                               depth values for each of the two 
%                               cross-section axis (considering the 
%                               asymmetry of the reinforcement)
%
% INPUT:  rec:                  concrete cover of cross-section for both 
%                               axis direction: [coverX,coverY]
%
%         act:                  optima ISR reinforcement area
%
%         npdiag:               number of points to compute for the 
%                               interaction diagram
%
%         load_conditions:      load conditions for the column cross section:
%                               size = [nload,4] in format [nload,Pu,Mux,Muy]
%
%         fdpc:                 is the f'c reduced with the factor 0.85 
%                               according to the ACI 318-19 code
%
%         beta1:                is determined as specified by code (see 
%                               Documentation)
%
%         condition_cracking:   parameter that indicates which cross-section
%                               cracking mechanism will be consider, either 
%                               Cracked or Non-cracked. If the condition 
%                               Non-cracked is set, then the cracking 
%                               mechanism will be neglected by all means
%
%         ductility:            is a parameter that indicates which 
%                               ductility demand is required for the 
%                               reinforcement designs. A number between 
%                               1 to 3 (see Documentation)
%
%         puCostCardBuild:      is a vector containing the parameters
%                               required for the calculation of the unit
%                               cost of a rebar design with a 
%                               "unitCostCardColsRec"
%
%------------------------------------------------------------------------
% LAST MODIFIED: L.F.Veduzco    2023-02-05
% Copyright (c)  Faculty of Engineering
%                Autonomous University of Queretaro, Mexico
%------------------------------------------------------------------------
fc=fdpc/0.85;

E=fy/0.0021; % yield stress of reinforcing steel
pccb=puCostCardBuild;
pu_col_sym=unitCostCardColsRec(pccb(1),pccb(2),pccb(3),...
                                 pccb(4),pccb(5),pccb(6),pccb(7));

bp=b-2*rec(1);
hp=h-2*rec(2);
            
ndiam=length(RebarAvailable(:,1));
noptions=0;
while noptions==0
    bestArea=inf;
    for i=1:ndiam % for each type of rebar
        op=i;
        
        ov=RebarAvailable(i,1);
        dv=RebarAvailable(i,2);
        av=(dv)^2*pi/4;

        nv=1;
        ast=av*nv;
        while(ast<act)
            nv=nv+1;
            ast=av*nv;
        end
        if (mod(nv,2)~=0)
            nv=nv+1;
            ast=av*nv;
        end
        % Min rebar separation:
        if fc<2000 % units: kg,cm
            sepMin=max([1.5*2.54, 3/2*dv]);
        else       % units: lb,in
            sepMin=max([1.5, 3/2*dv]);
        end
        
        % There is a limit of the number of rebars that can be laid out
        % on each boundary of the cross-section, for each type of rebar
        maxVarillasSup=2*(fix((bp)/(sepMin+2*dv)))+2;
        maxVarillasCos=2*(fix((hp)/(sepMin+2*dv)));

        minVarillasSup=0.5*(nv-2*maxVarillasCos);
        if (minVarillasSup<2)
            minVarillasSup=2;
        end
        
        if (2*maxVarillasSup+2*maxVarillasCos<nv)
            continue;
        elseif (2*maxVarillasSup<nv)
            continue;
        else
            
            for type=minVarillasSup:maxVarillasSup
                varSup=type;
                varCos=0.5*(nv-2*varSup);

                [disposicion_varillado]=RebarDisposition2packSym(b,...
                                        h,rec,dv,nv,varCos,varSup);
                if nv~=length(disposicion_varillado)
                    break;
                end
                nvxy=[varSup varCos];
                arraySymOriginal=[varSup varSup varCos varCos];
                
                % Asymmetrical design with only one rebar diameter
                % in packs of two
                [av4_1,nv4_1,relyEffList,arregloVar1,bestDisposition1,...
                 bestnv1,bestMr1,bestEf1,bestcxy1,bestCP1,bestasbar1,...
                 bestdiagram11,bestdiagram12,bestCost1,bestCFA1]=asym1typeRebar2pack...
                 (fdpc,fy,nvxy,arraySymOriginal,b,h,rec,RebarAvailable,op,av,...
                 npdiag,height,wac,load_conditions,ductility,beta1,...
                 puCostCardBuild,dataCFA);
            
                if isempty(nv4_1)==0
                    % Asymmetrical design with as many as 4 types of rebar
                    % asymmetrical also in number of rebars:
                    [av4_2,relyEffList,bestasbar2,bestEf2,bestdiagram21,...
                    bestdiagram22,arregloVar2,bestDisposition2,bestMr2,...
                    bestcxy2,bestCP2,bestCost2,bestCFA2]=asymSym4Diam...
                    (bestDisposition1,op,nv4_1,RebarAvailable,rec,b,h,...
                    fy,fdpc,beta1,E,height,wac,load_conditions,...
                    npdiag,ductility,puCostCardBuild,dataCFA);

                    bestnv2=bestnv1;
                    nv4_2=nv4_1;
                    
                else
                    bestasbar2=[];
                end
                if isempty(bestasbar2)==0 && isempty(bestasbar1)==0
                    if bestasbar2<bestasbar1
                        if bestasbar2<bestArea
                            noptions=noptions+1;
                            bestCFA=bestCFA2;
                            bestdiagram=bestdiagram21;
                            bestdiagram2=bestdiagram22;
                            bestDisposition=bestDisposition2;
                            bestArrangement=arregloVar2;
                            bestArea=bestasbar2;
                            bestCost=bestCost2;
                            bestEf=bestEf2;
                            bestMr=bestMr2;
                            bestnv=bestnv2;
                            nv4=nv4_2;
                            av4=av4_2;
                            bestcxy=bestcxy2;
                            bestCP=bestCP2;
                            
                            vx1Ec=nv4(1);
                            vx2Ec=nv4(2); 
                            vy1Ec=nv4(3);
                            vy2Ec=nv4(4);

                            av1Ec=av4(1); 
                            av2Ec=av4(2); 
                            av3Ec=av4(3);
                            av4Ec=av4(4);
                        end
                    elseif bestasbar1<=bestasbar2
                        if bestasbar1<bestArea
                            noptions=noptions+1;
                            
                            bestdiagram=bestdiagram11;
                            bestdiagram2=bestdiagram12;
                            bestDisposition=bestDisposition1;
                            bestArrangement=arregloVar1;
                            bestArea=bestasbar1;
                            bestCost=bestCost1;
                            bestEf=bestEf1;
                            bestMr=bestMr1;
                            bestnv=bestnv1;
                            nv4=nv4_1;
                            av4=av4_1;
                            bestcxy=bestcxy1;
                            bestCP=bestCP1;
                            bestCFA=bestCFA1;
                            
                            vx1Ec=nv4(1);
                            vx2Ec=nv4(2); 
                            vy1Ec=nv4(3);
                            vy2Ec=nv4(4);

                            av1Ec=av4(1); 
                            av2Ec=av4(2); 
                            av3Ec=av4(3);
                            av4Ec=av4(4);
                        end
                    end
                    
                elseif isempty(bestasbar2)==1 && isempty(bestasbar1)==0
                    if bestasbar1<bestArea
                        noptions=noptions+1;
                        
                        bestdiagram=bestdiagram11;
                        bestdiagram2=bestdiagram12;
                        bestDisposition=bestDisposition1;
                        bestArrangement=arregloVar1;
                        bestArea=bestasbar1;
                        bestCost=bestCost1;
                        bestEf=bestEf1;
                        bestMr=bestMr1;
                        bestnv=bestnv1;
                        nv4=nv4_1;
                        av4=av4_1;
                        bestcxy=bestcxy1;
                        bestCP=bestCP1;
                        bestCFA=bestCFA1;
                        
                        vx1Ec=nv4(1);
                        vx2Ec=nv4(2); 
                        vy1Ec=nv4(3);
                        vy2Ec=nv4(4);

                        av1Ec=av4(1); 
                        av2Ec=av4(2); 
                        av3Ec=av4(3);
                        av4Ec=av4(4);
                    end
                elseif isempty(bestasbar2)==1 && isempty(bestasbar1)==1
                    continue;
                end
                   
            end
        end
    end
    
    if noptions==0
        fprintf('\nThe columns cross-section dimensions are too small\n');
        fprintf('for this rebar prototype Asym-2pack-4Diam.\n');

        bestdiagram=[];
        bestdiagram2=[];
        bestDisposition=[];
        bestArrangement=[];
        bestArea=[];
        bestCost=[];
        bestEf=[];
        Mr_col=[];
        bestnv=[];
        nv4=[];
        bestcxy=[];
        bestCFA=[];
        bestCP=[];
        Inertia_xy_modif=[];
        break;
    else
        Mr_col=bestMr;
            
        %%% Computation of cross-section's modified inertia

        % computation of reinforcing area on each cross-section's boundary
        area_vx1=vx1Ec*av1Ec; 
        area_vx2=vx2Ec*av2Ec; 
        area_vy1=vy1Ec*av3Ec;
        area_vy2=vy2Ec*av4Ec;

        % equivalent ISR's width for each of the four cross-section
        % boundaries
        t1_var=area_vx1/(b-2*rec(1));
        t2_var=area_vx2/(b-2*rec(1));
        t3_var=area_vy1/(h-2*rec(2));
        t4_var=area_vy2/(h-2*rec(2));

        % Max load eccentricities on each cross-section's axis
        [pu,imaxP]=max(abs(load_conditions(:,2)));
        pu=sign(load_conditions(imaxP,2))*pu;
        mux=max(abs(load_conditions(:,3)));
        muy=max(abs(load_conditions(:,4)));

        excentricity_x=abs(mux/pu);
        excentricity_y=abs(muy/pu);
        eccentricity_xy=[excentricity_x,excentricity_y];

        [Inertia_xy_modif,Atransfxy]=CrackingColumnsAsym(h,b,fdpc,rec,...
            eccentricity_xy,t1_var,t2_var,t3_var,t4_var,pu,bestcxy,...
            condition_cracking,bestCP);
    end
end