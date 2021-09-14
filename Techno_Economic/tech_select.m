%% Technology Selection
%% Utility
utility_exists=1;

%% Solar PV
%%% Cap cost ($/kW)
%%% Efficiency / Conversion Percent at 1 kW/m^2
%%% O&M ($/kWh generated)
%%% Power output per unit area (kW/m^2);
if pv_on
    %pv_v=[3500; 0.2 ; 0.001];
    pv_v=[2650; 0.2 ; 0.001];
    
    pv_cap=pv_v(1,:);
    
    %%%How pv capital cost is modified for different types of buildings
    pv_cap_mod = [2/2.65 %%%Commercial/industrial
        2.65/2.65]; %%%Residential
    
    %%%Financial Aspects - Solar PV
    pv_fin = [-0.4648; ... %%%Scaling linear factor - Based on Lazards cost of electricity
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
        
    
    %%%Solar on multifamily affordable homes (SOMAH)
    somah = [2600];
else
    pv_v = [];
    
end
%% Electrical Energy Storage
if ees_on
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
    ees_v=[830; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .90; .90; .995];
    %ees_v=[600; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; 1; 1; .995]; %Testing with 100% RTE
    
    ees_cap=ees_v(1);
    
    %%%How pv capital cost is modified for different types of buildings
    ees_cap_mod = [575/830 %%%Commercial/industrial
        830/830]; %%%Residential
    
    %%%Financial Aspects - EES
    ees_fin = [-0.4648;... %%%Scaling linear factor - Based on Lazards cost of electricity
        7; ... %%%MACRS Schedule
        0]; ... %%%ITC Benefit
        
    %%%Financial Aspects - EES
    rees_fin = [-0.4648;... %%%Scaling linear factor - Based on Lazards cost of electricity
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
else
ees_v = [];
rees_v = [];
end
    %% SGIP incentives
if sgip_on
    %%%Self generation incentive program (SGIP) values
    sgip = [5 %%% 1:CO2 reduction required per kWh for large scale systems
        350 %%% 2: Large storage incentive($/kWh)
        200 %%% 3: Residential storage incentive ($/kWh)
        850 %%% 4: Equity rate ($/kWh)
        2000]; %%% 5: kWh incriment at which SGIP decreases
    sgip_o = sgip;
    %%%Non_residential rates that receive sgip(2) incentive
    non_res_rates = [1 2];
else
    sgip = [];
end
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

if ~pv_on
    pv_v=[];
end

if ~ees_on
    ees_v =[];
end

%% Placeholders

%%%Technologies avaialable at a single node
el_v = [];
rel_v = [];
h2es_v = [];
utilpv_v = [];
util_ees_v = [];
hrs_on = [];

%%%Legacy technologies available at a single node
pv_legacy = []; 
dg_legacy = [];
hr_legacy = [];