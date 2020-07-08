%% Technology Selection
%% Utility 
utility_exists=1;

%% Solar PV  
%%% Cap cost ($/kW)
%%% Efficiency / Conversion Percent at 1 kW/m^2
%%% O&M ($/kWh generated)
%%% Power output per unit area (kW/m^2);

%pv_v=[3500; 0.2 ; 0.001];
pv_v=[2000; 0.2 ; 0.001];

pv_cap=pv_v(1,:);

%% Electrical Energy Storage
%%% (1) Capital Cost ($/kWh installed) 
%%% (2) Charge O&M ($/kWh charged) 
%%% (3) Discharge O&M ($/kWh discharged) 
%%% (4) Minimum state of charge 
%%% (5) Maximum state of charge 
%%% (6) Maximum charge rate (% Capacity/hr) 
%%% (7) Maximum discharge rate (% Capacity/hr) 
%%% (8) Charging efficiency 
%%% (9) Discharging efficiency 
%%% (10) State of charge holdover 

%ees_v=[200; 0.001; 0.001; 0.3; 0.95; 0.25; 0.25; .95; .95; .995];
%ees_v=[195; 0.001; 0.001; 0.25; 0.99; 0.3; 0.3; .9; .85; .999];
%ees_v=[200; 0.001; 0.001; 0.1; 0.95; 1; 1; 1; 1; 1];
%ees_v=[200; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .95; .95; .995];
%ees_v=[300; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .95; .95; .995];
%ees_v=[500; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .95; .95; .995];
ees_v=[600; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .90; .90; .995];
%ees_v=[600; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; 1; 1; .995]; %Testing with 100% RTE 

ees_cap=ees_v(1);

%% Building space
%%%[space available for PV (m^2)
%%%Cooling loop input (C)
%%%Cooling loop output (C)
%%%Building cooling side (C)
bldg_v= [10000000000; 10; 18; 15];

%% Inverter 
%%% Cap cost ($/kW)
inv_v = [49]; 

%% Transformer 
%%% Cap cost ($/kVA)
xfmr_v = [1090]; 

%% Tech select

if nopv
pv_v=[];
end

if noees
ees_v =[];
end 