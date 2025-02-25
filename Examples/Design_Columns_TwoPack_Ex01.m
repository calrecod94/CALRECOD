% Design_Columns_TwoPack_Ex01
%----------------------------------------------------------------
% PURPOSE 
%    To design optimally (with respect to saving in reinforcing area)
%    a rectangular column' cross-section, considering biaxial bending
%    loads in which only asymmetrical designs in packages of two rebars are
%    allowed. As many as four rebar diameters are allowed in a symmetrical
%    distribution.
%
%    Note: function "Asym2packSym4Diam" is used.
%
%----------------------------------------------------------------
%
% LAST MODIFIED: L.F.Veduzco    2023-07-03
% Copyright (c)  Faculty of Engineering
%                Autonomous University of Queretaro, Mexico
%----------------------------------------------------------------

clear all
clc

%% GEOMETRY
height=300; % column's length
b=45; % cross-section width
h=45; % cross-section height

%% MATERIALS
fy=4200; % yield stress of rebars 
Es=fy/0.0021; % Modulus of elasticity of reinforcing steel

fc=250; % concrete's compressive strength Kg/cm2
fdpc=0.85*fc; % reduced f'c

if fc<280
    beta1=0.85;
elseif fc>=280
    beta1=1.05-fc/1400;
    if (beta1<0.65)
        beta1=0.65;
    elseif (beta1>0.85)
        beta1=0.85;
    end
end

ws=0.0078; % volumetric weight of reinforcing steel (Kg/cm3)

%% Loads
load_conditions=[1 -53.52e3 -15.602e5 19e5]; % [nload, Pu, Mx, My]
      
%% Rebar data
% Commerically available rebars
RebarAvailable=[4 4/8*2.54;
                5 5/8*2.54;
                6 6/8*2.54;
                8 8/8*2.54;
                9 9/8*2.54;
                10 10/8*2.54;
                12 12/8*2.54];
            
%% ADITIONAL PARAMETERS
rec=[4 4]; % [coverx covery] - concrete cover
npdiag=30; % number of points to compute for the interaction diagram

puColBuild=[1.2,0.9,128,214.75,0.04,0.105,7];
pu_cols_isr=[28.93];
    
condition_cracking="Cracked"; % "Cracked" or "Non-cracked"

% Ductility demand
ductility=3;
dataCFA=[0,1,1,2]; % Data required for the computation of the 
                   % constructability factor for the rebar designs of columns
                   % Lower and upper values for the range of the CFA and 
                   % weight factors for the uniformity of rebars and rebar 
                   % diameters
%% ISR optimization
[b,h,cost_elem_col,Ac_sec_elem,Ef_sec_col,Mr_col,t_value_01,t_value_03,cxy]=...
isrColumns(pu_cols_isr,height,b,h,rec,fy,fc,load_conditions,ws,ductility,...
0,0);
    
%% Optimization rebar design - RP: (Asym-2pack-Sym4Diam)

[Mr_col,h,Inertia_xy_modif,bestArea8,bestCost,bestdiagram,bestdiagram2,bestnv,...
bestEf,bestArrangement,bestDisposition,nv4,bestcxy,bestCP,bestCFA]=...
Asym2packSym4Diam(b,h,rec,Ac_sec_elem,Es,npdiag,fdpc,...
beta1,load_conditions,ws,height,RebarAvailable,...
condition_cracking,ductility,puColBuild,dataCFA);


%% Ploting design results
diagDoubleDirecAsymRebarCols(load_conditions,bestdiagram,...
    bestdiagram2,bestDisposition,h,b,bestArrangement);

% ----------------------------- End ----------------------------------
