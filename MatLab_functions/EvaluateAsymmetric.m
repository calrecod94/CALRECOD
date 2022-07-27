function [maxef,diagramaInteraccion,efficiency,cp_axis,cxy]=...
    EvaluateAsymmetric(load_conditions,npoints,position,b,h,...
    fy,fdpc,beta,E,number_rebars_sup,number_rebars_inf,number_rebars_left,...
    number_rebars_right,rebarAvailable,dispositionRebar)

%------------------------------------------------------------------------
% Syntax:
% [maxef,diagramaInteraccion,efficiency,cp_axis,cxy]=...
%   EvaluateAsymmetric(load_conditions,npoints,position,b,h,...
%   fy,fdpc,beta,E,number_rebars_sup,number_rebars_inf,number_rebars_left,...
%   number_rebars_right,rebarAvailable,dispositionRebar)
%
%------------------------------------------------------------------------
% PURPOSE: To compute the interaction diagram of an asymmetrically 
% reinforced cross-section design option.
% 
% OUTPUT: maxef:                is the critical structural efficiency 
%                               according to the load conditions applied
%
%         diagramaInteraccion:  is the array containing the interaction 
%                               diagram data
%
%         efficiency:           is the resume table of structural efficiency
%                               analysis for each load condition
%
%         cp_axis:              are the central plastic locations for each
%                               axis direction of the cross-section: [CPx,CPy]
%
%         cxy:                  are neutral axis depth values for each axis 
%                               direction of the cross-section
%
% INPUT:  b,h:                  cross-section initial dimensions
%
%         RebarAvailable:       rebar database consisting of an array of 
%                               size [7,3] by default in format: 
%                               [#rebar,diam,unit-weight]
%
%         number_rebars_sup,
%         number_rebars_inf,
%         number_rebars_left,
%         number_rebars_right:  number of rebars to placed on each of the 
%                               cross-section boundaries
%
%         dispositionRebar:     are the local rebar coordinates
%
%         position:             are the variables to optimize in the PSO 
%                               algorithms. In this case: op1,op2,op3,op4
%                               as a vector of size [1,4] which are the
%                               resultant types of rebar for each of the 
%                               four cross-section boundaries (upper 
%                               boundary, lower boundary, left side and 
%                               right side, respectively)
%
%         load_conditions:      are the load conditions: vector of size 
%                               [nloads,4] in format [nload,Pu,Mux,Muy]
%
%         npoints:              number of points to be computed for the
%                               definition of the interaction diagram
%
%------------------------------------------------------------------------
% LAST MODIFIED: L.F.Veduzco    2022-02-05
%                Faculty of Engineering
%                Autonomous University of Queretaro
%------------------------------------------------------------------------
if npoints<3
    disp('Error: the number of points for the Interaction Diagram must be 3 or higher');
    return;
end
cp_axis=[];

op1=position(1);
op2=position(2);
op3=position(3);
op4=position(4);

diagramaInteraccion=zeros(npoints,9);
c_vector=zeros(npoints,2);

dimensionesColumna=[b h];

h=dimensionesColumna(2);
b=dimensionesColumna(1);

act=number_rebars_sup*(rebarAvailable(op1,2)^2*pi/4)+...
    number_rebars_inf*(rebarAvailable(op2,2)^2*pi/4)+...
    number_rebars_left*(rebarAvailable(op3,2)^2*pi/4)+...
    number_rebars_right*(rebarAvailable(op4,2)^2*pi/4);

nv1=number_rebars_sup;
nv2=number_rebars_inf;
nv3=number_rebars_left;
nv4=number_rebars_right;

nv=nv1+nv2+nv3+nv4;

arregloVar=zeros(nv,1);
for i=1:nv1
    arregloVar(i)=op1;
end

for i=1:nv2
    arregloVar(nv1+i)=op2;
end

for i=1:nv3
    arregloVar(nv1+nv2+i)=op3;
end

for i=1:nv4
    arregloVar(nv1+nv2+nv3+i)=op4;
end

rebar=[dispositionRebar(:,1) dispositionRebar(:,2)];

%%%%%%%%%%%%%%%%%%%%%%%% INTERACTION DIAGRAMS %%%%%%%%%%%%%%%%%%%%%%%
    
poc=(act*fy+fdpc*(b*h-act))*0.001;
pot=act*fy*0.001;
df=(poc+pot)/(npoints-1);
dfi=0.1/(npoints-1);

diagramaInteraccion(1,1)=-poc;
diagramaInteraccion(npoints,1)=pot;
diagramaInteraccion(1,2)=0;
diagramaInteraccion(1,6)=0.0;

c_vector(1,:)=4*h;
c_vector(npoints,:)=0;

ea=0.001;

for sentido=1:2
    if (sentido==2)
       h=dimensionesColumna(1);
       b=dimensionesColumna(2);
       dispositionRebar(:,1)=-rebar(:,2);
       dispositionRebar(:,2)=rebar(:,1);
    end
    % Plastic Center ____________________________________
    [cp]=PlastiCenterAxis(fy,fdpc,b,h,dispositionRebar,arregloVar,...
                            rebarAvailable);
    cp_axis=[cp_axis,cp];
   
    diagramaInteraccion(1,4*sentido-1)=0.65*-poc;
    diagramaInteraccion(1,4*sentido)=0;
    for i=1:npoints-1
        diagramaInteraccion(i+1,1)=-poc+i*df;
        cUno=0.001; 
        cDos=4*h;
        fr=diagramaInteraccion(i+1,1);

        [raiz]=bisectionMrVarAsymm(cUno,cDos,fr,E,h,b,fdpc,beta,ea,nv,...
            number_rebars_sup,number_rebars_inf,number_rebars_left,...
            number_rebars_right,rebarAvailable,op1,op2,op3,op4,...
            dispositionRebar,cp);

        diagramaInteraccion(i+1,4*sentido-2)=raiz(3);
        c_vector(i+1,sentido)=raiz(1);

        %%%%%%%%%%%%%%% Reduced diagramas %%%%%%%%%%%%%%%%%%%%
        diagramaInteraccion(i+1,4*sentido-1)=(0.65+i*dfi)*diagramaInteraccion(i+1,1);
        diagramaInteraccion(i+1,4*sentido)=(0.65+i*dfi)*diagramaInteraccion(i+1,4*sentido-2);
                                                          
        %%%%%%%%%%%%%%%%%%%%%%%%% Eccentricities %%%%%%%%%%%%%%%%%%%%%%%%%%

        diagramaInteraccion(i+1,4*sentido+1)=diagramaInteraccion(i+1,4*sentido)/...
                                         diagramaInteraccion(i+1,4*sentido-1);
    end

    diagramaInteraccion(npoints,4*sentido-1)=0.75*pot;
    diagramaInteraccion(npoints,4*sentido)=0;
    diagramaInteraccion(npoints,4*sentido-2)=0;
    diagramaInteraccion(npoints,4*sentido-2)=0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%% Efficiency %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[maxef,efficiency,cxy]=effRecColsBinarySearch(diagramaInteraccion,...
                                    load_conditions,pot,poc,c_vector);
       