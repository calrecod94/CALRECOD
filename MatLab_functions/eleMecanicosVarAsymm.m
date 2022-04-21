function [eMecVar]=eleMecanicosVarAsymm(dispositionRebar,nv,number_rebars_sup,...
    number_rebars_inf,number_rebars_left,number_rebars_right,rebarAvailable,...
    op1,op2,op3,op4,b,h,c,fdpc,E,beta,cp)
   
%------------------------------------------------------------------------
% Syntax:
% [eMecVar]=eleMecanicosVarAsymm(dispositionRebar,nv,number_rebars_sup,...
%   number_rebars_inf,number_rebars_left,number_rebars_right,rebarAvailable,...
%   op1,op2,op3,op4,b,h,c,fdpc,E,beta,cp)
%
%------------------------------------------------------------------------
% PURPOSE: To compute the sum of resistant forces of an asymmetrically 
% reinforced column cross-section considering the distribution of rebars 
% over the cross-section and concrete zone in compression.
% 
% OUTPUT: eMecVar:              vector that contains the output [Fs,Ms;
%                                                                Fc,Mc]
%
% INPUT:  E:                    Elasticity modulus of steel (4200 Kg/cm^2)
%
%         b,h:                  cross-section dimensions
%
%         fdpc:                 is the f'c reduced with the factor 0.85 
%                               according to code
%
%         beta:                 is determined as stablished by code 
%                               (in units Kg,cm), (see Documentation)
%
%         nv:                   is the number of rebars to be placed over
%                               the cross-section
%
%         number_rebars_sup,
%         number_rebars_inf,
%         number_rebars_left,
%         number_rebars_right:  are the number of rebars to be placed for 
%                               each of the cross-section boundaries
%
%         dispositionRebar:     are the local coordinates of rebars over 
%                               the cross-section
%
%         rebarAvailable:       data base of commercial available rebars. 
%                               An array of size [7,3] by default; in format 
%                               [#rebar,diam,unit-weight]
%
%         op1,op2,op3,op4:      types of rebar to be placed for each of the
%                               four boundaries of the cross-section 
%                               (upper boundary, lower boundary, left 
%                               boundary and right boundary)
%
%         cp:                   Plastic Center location for each axis
%                               direction of the column cross-section
%
%------------------------------------------------------------------------
% LAST MODIFIED: L.F.Veduzco    2022-02-05
%                Faculty of Engineering
%                Autonomous University of Queretaro
%------------------------------------------------------------------------

coordy_cp=0.5*h-cp;
eMecVarillado=zeros(nv,9);

eMecVarillado(:,2)=dispositionRebar(:,1);
eMecVarillado(:,3)=dispositionRebar(:,2);

sumaM=0;
sumaF=0;
  
dv1=rebarAvailable(op1,2);
av1=dv1^2*pi/4;

dv2=rebarAvailable(op2,2);
av2=dv2^2*pi/4;

dv3=rebarAvailable(op3,2);
av3=dv3^2*pi/4;

dv4=rebarAvailable(op4,2);
av4=dv4^2*pi/4;
for i=1:nv
    % Superior rebars______________________________
    if i<=number_rebars_sup(op1)
        
        eMecVarillado(i,1)=rebarAvailable(op1,1);
        av=av1;
        eMecVarillado(i,5)=av;
    elseif i<=(number_rebars_sup(op1)+number_rebars_inf(op2)) &&...
            i>(number_rebars_sup(op1))
        
        eMecVarillado(i,1)=rebarAvailable(op2,1);
        av=av2;
        eMecVarillado(i,5)=av;
        
    elseif i<=(number_rebars_sup(op1)+number_rebars_inf(op2)+...
                number_rebars_left(op3)) &&...
            i>(number_rebars_sup(op1)+number_rebars_inf(op2))
        
        eMecVarillado(i,1)=rebarAvailable(op3,1);
        av=av3;
        eMecVarillado(i,5)=av;
        
     elseif i<=(number_rebars_sup(op1)+number_rebars_inf(op2)+...
                number_rebars_left(op3)+number_rebars_right(op4)) &&...
            i>(number_rebars_sup(op1)+number_rebars_inf(op2)+...
            number_rebars_left(op3))
        
        eMecVarillado(i,1)=rebarAvailable(op4,1);
        av=av4;
        eMecVarillado(i,5)=av;   
        
    end
    eMecVarillado(i,4)=0.5*h-eMecVarillado(i,3); % to calculate eps
    
    eMecVarillado(i,6)=0.003/c*(eMecVarillado(i,4)-c);
    if (eMecVarillado(i,6)<-0.0021)
        eMecVarillado(i,6)=-0.0021;
    elseif(eMecVarillado(i,6)>0.0021)
        eMecVarillado(i,6)=0.0021;
    end
    eMecVarillado(i,7)=eMecVarillado(i,6)*E;
    eMecVarillado(i,8)=eMecVarillado(i,7)*av*0.001;
    eMecVarillado(i,9)=eMecVarillado(i,8)*(coordy_cp-eMecVarillado(i,3))*0.01;
    
    sumaF=sumaF+eMecVarillado(i,8);
    sumaM=sumaM+eMecVarillado(i,9);
end

a=beta*c;
elemConc=casoConcreto(a,fdpc,b,h);
eMecVar=[sumaF sumaM;
    elemConc(1) elemConc(2)];

end