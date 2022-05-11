%% Technology Selection

%% Utility
utility_exists=1;

%% Onsite Solar PV
if pv_on
    %%% Cap cost ($/kW)
    %%% Efficiency / Conversion Percent at 1 kW/m^2
    %%% O&M ($/kWh generated)
    
    %pv_v=[3500; 0.2 ; 0.001];
    
%     pv_v=[3000; 0.2 ; 0.001];
%     pv_v=[2650; 0.2 ; 0.001];
    
    pv_v = [900; 0.2; 0.001];
    
    %%%How pv capital cost is modified for different types of buildings
    pv_cap_mod = [2/2.65 %%%Commercial/industrial
        2.65/2.65]; %%%Residential
    
    %%%Financial Aspects - Solar PV
    pv_fin = [-0.4648; ... %%%Scaling linear factor - Based on Lazards cost of electricity
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
        
    pv_fin = [0; ... %%%Scaling linear factor - Based on Lazards cost of electricity
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
    
    % pv_fin = [-0.4648; ... %%%Scaling linear factor - Based on Lazards cost of electricity
    %     0; ... %%%MACRS Schedule
    %     0]; ... %%%ITC Benefit
    
    % pv_v = [pv_v pv_v];
    % pv_fin = [pv_fin pv_fin];
    % pv_cap_mod = [pv_cap_mod pv_cap_mod];
    
    
    if ~isempty(pv_v)
        pv_cap=pv_v(1,:);
    else
        pv_cap = 0;
    end
    %%%Solar on multifamily affordable homes (SOMAH)
    somah = [2600];
else
    pv_v = [];
end

%% Utility Based Solar
if util_solar_on
    %%% Cap cost ($/kW)
    %%% Efficiency / Conversion Percent at 1 kW/m^2
    %%% O&M ($/kWh generated)
    utilpv_v = [900; 0.2; 0.001];
    
    %%%Financial Aspects - Solar PV
    utilpv_fin =[0; ... %%%Scaling linear factor - Based on Lazards cost of electricity
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
else

utilpv_v = [];
end

%% Utility Scale Battery
if util_ees_on
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
    util_ees_v=[240; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .90; .90; .995];
    
    %%%Financial Aspects - EES
    util_ees_fin = [0;... %%%Scaling linear factor - Based on Lazards cost of electricity
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
else
util_ees_v = [];
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
    % ees_v=[100; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .90; .90; .995];
    % ees_v = [];
    
    %%%How pv capital cost is modified for different types of buildings
    ees_cap_mod = [575/830 %%%Commercial/industrial
        830/830]; %%%Residential
    
    %%%Financial Aspects - EES
    ees_fin = [-0.1306;... %%%Scaling linear factor - Based on Lazards cost of electricity
        7; ... %%%MACRS Schedule
        0]; ... %%%ITC Benefit
        
    %%%Financial Aspects - EES
    rees_fin = [-0.1306;... %%%Scaling linear factor - Based on Lazards cost of electricity
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
        
    %%%Self generation incentive program (SGIP) values
    sgip = [5 %%% 1:CO2 reduction required per kWh for large scale systems
        350 %%% 2: Large storage incentive($/kWh)
        200 %%% 3: Residential storage incentive ($/kWh)
        850 %%% 4: Equity rate ($/kWh)
        2000]; %%% 5: kWh incriment at which SGIP decreases
    sgip_o = sgip;
    %%%Non_residential rates that receive sgip(2) incentive
    non_res_rates = [1 2];
    
    
    
    % ees_v = [ees_v ees_v];
    % ees_cap_mod = [ees_cap_mod ees_cap_mod];
    % ees_fin = [ees_fin ees_fin];
    % rees_fin = [rees_fin rees_fin];
    if ~isempty(ees_v)
        ees_cap=ees_v(1);
    else
        ees_cap = [];
    end
else
    ees_v = [];
    rees_v = [];
end

%% Generic Electrolyzer
if el_on
    %%% Generic electrolyzer
    %%% (1) Captail Cost ($/kW H2 produced)
    %%% (2) Variable O&M ($/kWh H2 produced)
    %%% (3) Electrolyzer efficiency (kWh H2/kWh elec)
    el_v = [2100; 0.01; 0.6];
    % el_v = [1; 0.01; .99];
    % el_v = [1; 0.01; .6];
    
    %%%Financial Aspects - Electrolyzer
    el_fin = [-0.02; ... %%%Scaling linear factor - Based on CA Roadmap - 2k H2 per day vs. 20k H2 per day
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
        
else
    el_v = []
    % h2es_v = [];
end
%% Hydrogen energy storage
if h2es_on
    %%%Hydrogen energy storage
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
    h2es_v = [60;0.001;0.001;0.01;1;1;1;0.95;1;1];
else
    h2es_v = [];
end

%% Reversible Solid Oxide Cell [SOFC+SOEC]
if rsoc_on
    % Source:
    % https://www.hydrogen.energy.gov/pdfs/review20/fc332_wei_2020_o.pdf -
    % Slide 26
    %%% (1) Capital Cost ($/kW H2 produced)
    %%% (2) Variable O&M ($/kWh H2 produced)
    %%% (3) Electrolyzer efficiency (kWh H2/kWh elec)
    %%% (4) Fuel Cell Efficiency (kWh elec/kWh H2)
    %%% (5) Ratio of electrolyzer electricity in to fuel cell capacity (kW electrolyzer input / kW fuel cell output
    %%% (6) Minimum load fraction 
    %%% (7) Ramp Limit

    rsoc_v = [1120*.12/12; 0.02; 0.83; 0.53; 1.816; 0.1; 0.1];
    % rsoc_v = [10*.12/12;0.01;1;1;1.5];

    %%%Dummy variable for reversible SOC capital cost
    rsoc_mthly_debt = rsoc_v(1);
else
    rsoc_v = [];
end

%% Renewable Electrolyzer (rel)
if rel_on
    %%% Generic electrolyzer
    %%% (1) Captail Cost ($/kW H2 produced)
    %%% (2) Variable O&M ($/kWh H2 produced)
    %%% (3) Electrolyzer efficiency (kWh H2/kWh elec)
    rel_v = [2100; 0.01; 0.6];
    
    %%%Financial Aspects - Electrolyzer
    rel_fin = [-0.02; ... %%%Scaling linear factor - Based on CA Roadmap - 2k H2 per day vs. 20k H2 per day
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
else
rel_v = [];
end
%% H2 Fueling Station - Transportation
if hrs_on
    %%%H2 fueling supply equipment
    %%% (1) Capital Cost ($ installed)
    %%% (2) Compression efficiency
    %%% (3) O&M
    %%% (4) Competing H2 cost ($/kWh
    hrs_v  = [300000000; .95; 0.01; 11/121*3.6];
    
else
    hrs_v = [];
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


% pv_v = [];
% ees_v = [];
% el_v = [];
% h2es_v = [];
% rel_v = [];