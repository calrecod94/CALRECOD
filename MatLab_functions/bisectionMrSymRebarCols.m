function [root]=bisectionMrSymRebarCols(cUno,cDos,fr,E,h,b,fdpc,beta1,...
                             ea,nv,ov,av,rebar_disposition)

%------------------------------------------------------------------------
% Syntax:
% [raiz]=bisectionMrSymRebarCols(cUno,cDos,fr,E,h,b,fdpc,beta1,...
%           ea,nv,ov,av,rebar_disposition)
%
%------------------------------------------------------------------------
% PURPOSE: To determine the neutral axis depth, axial and bending resistance
% from the interaction diagram of a reinforced concrete column cross-section
% for each for its points with the aid of the bisection root method.
% 
% OUTPUT: root:                 is a vector containing the neutral axis 
%                               depth, axial resistant force and bending
%                               resistance of a reinforced column
%                               cross-section as [c,FR,MR]
%
% INPUT:  cUno,cDos:            are the initial values of the neutral axis
%                               to commence iterations
%
%         fr:                   is the axial force resistance corresponding
%                               to the bending moment resistance for which
%                               the equilibrium condition sum F=0 is 
%                               established to extract its corresponding 
%                               bending moment resistance and neutral axis
%                               depth from the interaction diagram
%
%         E:                    Elasticity modulus of steel (4200 Kg/cm^2)
%
%         b,h:                  cross-section dimensions
%
%         fdpc:                 is the f'c reduced with the factor 0.85 
%                               according to code
%
%         beta1:                is determined as stablished by code (see
%                               Documentation)
%
%         ea:                   is the approximation error to terminate the
%                               root bisection method
%
%         nv:                   is the number of rebars to be placed over
%                               the cross-section
%
%         ov,av:                are the type of rebar in eighth of inches 
%                               (ov/8 in) and the cross-section area of each
%                               rebar in cm^2 equal to pi/4(ov/8(2.54))^2
%
%         rebar_disposition:    are the local coordinates of rebars over 
%                               the cross-section
%
%------------------------------------------------------------------------
% LAST MODIFIED: L.F.Veduzco    2022-02-05
%                Faculty of Engineering
%                Autonomous University of Queretaro
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%% f(l) %%%%%%%%%%%%%%%%%%%%%

[eMecVar]=eleMecanicosRebarCols(rebar_disposition,nv,ov,av,b,h,...
                                      cUno,fdpc,E,beta1);
                              
frt=eMecVar(1,1)+eMecVar(2,1);
raizUno=fr-frt;

%%%%%%%%%%%%%%%%%%%%%% f(u) %%%%%%%%%%%%%%%%%%%%%%% 
[eMecVar]=eleMecanicosRebarCols(rebar_disposition,nv,ov,av,b,h,...
                                      cDos,fdpc,E,beta1);
frt=eMecVar(1,1)+eMecVar(2,1);
raizDos=fr-frt;

%%%%%%%%%%%%%%%%%%%%%% f(xr) %%%%%%%%%%%%%%%%%%%%%%
c=cDos-(raizDos*(cUno-cDos)/(raizUno-raizDos));

[eMecVar]=eleMecanicosRebarCols(rebar_disposition,nv,ov,av,b,h,...
                                      c,fdpc,E,beta1);
frt=eMecVar(1,1)+eMecVar(2,1);
raizc=fr-frt;

%%%%%%%%%%%%%% inicia ciclo %%%%%%%%%%%%%%%%%%%%%%%
ituno=0;
itdos=0;

cu=cDos;
es=abs((c-cu)/c);
while(es>ea)

    if((raizUno*raizc)<0)
        cDos=c;
        [eMecVar]=eleMecanicosRebarCols(rebar_disposition,nv,ov,av,b,h,...
                                          cDos,fdpc,E,beta1);
        frt=eMecVar(1,1)+eMecVar(2,1);
        raizDos=fr-frt;

        ituno=ituno+1;

    elseif((raizUno*raizc)>0)
        cUno=c;
        [eMecVar]=eleMecanicosRebarCols(rebar_disposition,nv,ov,av,b,h,...
                                          cUno,fdpc,E,beta1);
        frt=eMecVar(1,1)+eMecVar(2,1);
        raizUno=fr-frt;

        itdos=itdos+1;
    end

    cu=c;

    c=cDos-(raizDos*(cUno-cDos)/(raizUno-raizDos));
    if c==0
        c=0.001;
    end
    [eMecVar]=eleMecanicosRebarCols(rebar_disposition,nv,ov,av,b,h,...
                                          c,fdpc,E,beta1);
    frt=eMecVar(1,1)+eMecVar(2,1);
    raizc=fr-frt;

    if (c~=0)
        es=abs((c-cu)/c);
    end

    if itdos>1000 || ituno>1000
        break;
    end
end
mrt=eMecVar(1,2)+eMecVar(2,2);
root=[c,frt,mrt];   
