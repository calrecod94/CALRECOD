function [diagramaInteraccion,cvector,poc,pot]=DiagramsAsymmetricRebar...
    (npoints,rebarcombo,b,h,fy,fdpc,beta,E,nRebarsTop,...
    nRebarsBot,nRebarsLeft,nRebarsRight,rebarAvailable,...
    dispositionRebar)

%------------------------------------------------------------------------
% Syntax:
% [diagramaInteraccion,cvector,poc,pot]=DiagramsAsymmetricRebar...
% (npoints,rebarcombo,b,h,fy,fdpc,beta,E,nRebarsTop,...
% nRebarsBot,nRebarsLeft,nRebarsRight,rebarAvailable,...
% dispositionRebar)
%
%-------------------------------------------------------------------------
% SYSTEM OF UNITS: Any.
%
%------------------------------------------------------------------------
% PURPOSE: To compute the interaction diagram of an asymmetrically 
% reinforced cross-section design option.
% 
% OUTPUT: diagramaInteraccion:  is the array containing the interaction 
%                               diagram data for both cross-section's axis:
%
%                  [P,MRx,FR*P,FR*MRx,ec-x,MRy,FR*P,FR*MRy,ecc-y]
%
%         cvector:              are neutral axis depth values for each axis 
%                               direction of the cross-section corresponding 
%                               to each of the interaction diagram points
%
%         poc,pot:              is the max resistance in compression of the
%                               cross-section and the max resistance in 
%                               tension, respectively
%
% INPUT:  b,h:                  cross-section initial dimensions
%
%         RebarAvailable:       rebar database consisting of an array of 
%                               size [7,3] by default in format: 
%                               [#rebar,diam,unit-weight]
%
%         nRebarsTop,
%         nRebarsBot,
%         nRebarsLeft,
%         nRebarsRight:         number of rebars to placed on each of the 
%                               cross-section boundaries
%
%         dispositionRebar:     are the local rebar coordinates
%
%         rebarcombo:           Are the combination of types of rebar to be 
%                               placed over the cross-section (as indices
%                               referring to their place in the 
%                               "RebarAvailable" array). In this case: 
%                               a vector [op1,op2,op3,op4] of size [1,4] 
%                               referring to the type of rebar on each of
%                               four cross-section boundaries (upper 
%                               boundary, lower boundary, left side and 
%                               right side, respectively)
%
%         npoints:              number of points to be computed for the
%                               definition of the interaction diagram
%
%------------------------------------------------------------------------
% LAST MODIFIED: L.F.Veduzco    2023-02-05
% Copyright (c)  Faculty of Engineering
%                Autonomous University of Queretaro, Mexico
%------------------------------------------------------------------------
if npoints<3
    disp('Error: the number of points for the Interaction Diagram must be 3 or higher');
    return;
end

cpaxis=[];

op1=rebarcombo(1);
op2=rebarcombo(2);
op3=rebarcombo(3);
op4=rebarcombo(4);

diagramaInteraccion=zeros(npoints,9);
cvector=zeros(npoints,2);

dimensionesColumna=[b h];

h=dimensionesColumna(2);
b=dimensionesColumna(1);

act=nRebarsTop*(rebarAvailable(op1,2)^2*pi/4)+...
    nRebarsBot*(rebarAvailable(op2,2)^2*pi/4)+...
    nRebarsLeft*(rebarAvailable(op3,2)^2*pi/4)+...
    nRebarsRight*(rebarAvailable(op4,2)^2*pi/4);

nv1=nRebarsTop;
nv2=nRebarsBot;
nv3=nRebarsLeft;
nv4=nRebarsRight;

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
    
poc=(act*fy+fdpc*(b*h-act));
pot=act*fy;
df=(poc+pot)/(npoints-1);
dfi=0.1/(npoints-1);

diagramaInteraccion(1,1)=-poc;
diagramaInteraccion(npoints,1)=pot;
diagramaInteraccion(1,2)=0;
diagramaInteraccion(1,6)=0;

cvector(1,:)=4*h;
cvector(npoints,:)=0;

ea=0.001;

for sentido=1:2
    if (sentido==2)
       h=dimensionesColumna(1);
       b=dimensionesColumna(2);
       dispositionRebar(:,1)=rebar(:,2);
       dispositionRebar(:,2)=-rebar(:,1);
    end
    % Plastic Center 
    [cp]=PlastiCenterAxis(fy,fdpc,b,h,dispositionRebar,arregloVar,...
                            rebarAvailable);
    cpaxis=[cpaxis,cp];
    diagramaInteraccion(1,4*sentido-1)=0.65*-poc;
    diagramaInteraccion(1,4*sentido)=0;
    for i=1:npoints-1
        diagramaInteraccion(i+1,1)=-poc+i*df;
        cUno=0.001; 
        cDos=4*h;
        fr=diagramaInteraccion(i+1,1);

        [raiz]=bisectionMrVarAsymm(cUno,cDos,fr,E,h,b,fdpc,beta,ea,nv,...
            nRebarsTop,nRebarsBot,nRebarsLeft,...
            nRebarsRight,rebarAvailable,op1,op2,op3,op4,...
            dispositionRebar,cp);

        diagramaInteraccion(i+1,4*sentido-2)=raiz(3);
        cvector(i+1,sentido)=raiz(1);

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