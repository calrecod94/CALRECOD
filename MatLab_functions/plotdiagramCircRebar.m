function plotdiagramCircRebar(load_conditions,diagram,dispositionRebar,...
                diam,typeRebar)
            
%------------------------------------------------------------------------
% Syntax:
% plotdiagramCircRebar(load_conditions,diagram,dispositionRebar,diam,...
% typeRebar)
%
%-------------------------------------------------------------------------
% SYSTEM OF UNITS: Any.
%------------------------------------------------------------------------
% PURPOSE: To graph the interaction diagram of a circular reinforced
% column cross-section and the reinforced cross-section itself with rebars.
% 
% INPUT:  load_conditions:      load conditions in format: nload_conditions
%                               rows and four columns as [nload,Pu,Mux,Muy]
%
%         diagram:              interaction diagram data computed by using
%                               the function: widthEfficiencyCols
%                               (see Documentation)
%
%         dispositionRebar:     rebar local coordinates over the
%                               cross-section [x,y]
%
%         typeRebar:            list of types of rebar distributed over the
%                               cross-section
%
%------------------------------------------------------------------------
% LAST MODIFIED: L.F.Veduzco    2023-07-03
% Copyright (c)  Faculty of Engineering
%                Autonomous University of Queretaro, Mexico
%------------------------------------------------------------------------

%%% ------------------ Cross-section ------------------------------%%%
np=200;
teta=360/np;
for i=1:np
    x(i,1)=(diam*0.5)*cos(deg2rad(teta*i));
    y(i,1)=(diam*0.5)*sin(deg2rad(teta*i));
end

%---------------------- column plot -------------------------%

nbars=length(typeRebar);

t1=[];
t2=[];
t3=[];
t4=[];
t5=[];
t6=[];
t7=[];

dispVar1x=[];
dispVar1y=[];

dispVar2x=[];
dispVar2y=[];

dispVar3x=[];
dispVar3y=[];

dispVar4x=[];
dispVar4y=[];

dispVar5x=[];
dispVar5y=[];

dispVar6x=[];
dispVar6y=[];

dispVar7x=[];
dispVar7y=[];

for j=1:nbars
    if typeRebar(j)==1
        t1=[t1,1];
        dispVar1x=[dispVar1x,dispositionRebar(j,1)];
        dispVar1y=[dispVar1y,dispositionRebar(j,2)];
    elseif typeRebar(j)==2
        t2=[t2,2];
        dispVar2x=[dispVar2x,dispositionRebar(j,1)];
        dispVar2y=[dispVar2y,dispositionRebar(j,2)];
    elseif typeRebar(j)==3
        t3=[t3,3];
        dispVar3x=[dispVar3x,dispositionRebar(j,1)];
        dispVar3y=[dispVar3y,dispositionRebar(j,2)];
    elseif typeRebar(j)==4
        t4=[t4,4];
        dispVar4x=[dispVar4x,dispositionRebar(j,1)];
        dispVar4y=[dispVar4y,dispositionRebar(j,2)];
    elseif typeRebar(j)==5
        t5=[t5,5];
        dispVar5x=[dispVar5x,dispositionRebar(j,1)];
        dispVar5y=[dispVar5y,dispositionRebar(j,2)];
    elseif typeRebar(j)==6
        t6=[t6,6];
        dispVar6x=[dispVar6x,dispositionRebar(j,1)];
        dispVar6y=[dispVar6y,dispositionRebar(j,2)];
    elseif typeRebar(j)==7
        t7=[t7,7];
        dispVar7x=[dispVar7x,dispositionRebar(j,1)];
        dispVar7y=[dispVar7y,dispositionRebar(j,2)];
    end
end

figure(4)
plot(x,y,'k -','linewidth',1)
hold on
xlabel('x�')
ylabel('y�')
title('Circular Column')
legend('Column boundary')
axis([-(diam+5) diam+5 -(diam+5) diam+5])

if isempty(t1)~=1
    figure(4)
    plot(dispVar1x,dispVar1y,'r o','linewidth',1,'MarkerFaceColor',...
        'red','DisplayName','Bar Type 4');
end
if isempty(t2)~=1
    figure(4)
    plot(dispVar2x,dispVar2y,'b o','linewidth',1,'MarkerFaceColor',...
        'blue','DisplayName','Bar Type 5');
end
if isempty(t3)~=1
    figure(4)
    plot(dispVar3x,dispVar3y,'o','linewidth',1,'MarkerFaceColor',...
        '[0.05 0.205 0.05]','DisplayName','Bar Type 6');
end
if isempty(t4)~=1
    figure(4)
    plot(dispVar4x,dispVar4y,'o','linewidth',1,'MarkerFaceColor',...
        '[0.072 0.061 0.139]','DisplayName','Bar Type 8');
end
if isempty(t5)~=1
    figure(4)
    plot(dispVar5x,dispVar5y,'k o','linewidth',1,'MarkerFaceColor',...
        'black','DisplayName','Bar Type 9');
end
if isempty(t6)~=1
    figure(4)
    plot(dispVar6x,dispVar6y,'m o','linewidth',1,'MarkerFaceColor',...
        'magenta','DisplayName','Bar Type 10');
end
if isempty(t7)~=1
    figure(4)
    plot(dispVar7x,dispVar7y,'o','linewidth',1,'MarkerFaceColor',...
        '[0.255 0.069 0]','DisplayName','Bar Type 12');
end
        
%------------------------ end column plot ----------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Interaction diagram %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%% Not reduced %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x=diagram(:,2);
y=diagram(:,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reduced %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xfr=diagram(:,4);
yfr=diagram(:,3);
npuntos=length(y);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xcondicion=abs(load_conditions(:,3));
ycondicion=load_conditions(:,2);
figure(7)
plot(x,y,'k')
legend('Nominal')
hold on
plot(xfr,yfr,'r','DisplayName','Reduced')
hold on
plot(xcondicion,ycondicion,'r o','linewidth',0.05,'MarkerFaceColor','red',...
    'DisplayName','Load Condition')
axis([0 diagram(fix(npuntos/2)+1,2)*2 diagram(1,1) diagram(npuntos,1)]);
xlabel('Flexure moment')
ylabel('Axial Force')
title('Interaction diagram Rebar - Circular column')
grid on
