%% Technology Selection

dgb_v = [];
dgc_v = [];

%% Solar PV
if pv_on
    %%% Cap cost ($/kW)
    %%% Efficiency / Conversion Percent at 1 kW/m^2
    %%% O&M ($/kWh generated)
   
    pv_v1=[0.7*(3000+174); 0.2 ; 0.001];   
    
    pv_v2=[0.7*(2300+216); 0.2 ; 0.001];
    
    pv_v = [pv_v2];
%     pv_v = [pv_v1];
    
%     %%%How pv capital cost is modified for different types of buildings
%     pv_cap_mod = [2/2.65 %%%Commercial/industrial
%         2.65/2.65]; %%%Residential
%     
    %%%Financial Aspects - Solar PV
    pv_fin = [-0.4648; ... %%%Scaling linear factor - Based on Lazards cost of electricity
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
        
    pv_fin = repmat(pv_fin,1,size(pv_v,2));
 
    if ~isempty(pv_v)
        pv_cap=pv_v(1,:);
    else
        pv_cap = 0;
    end
else
    pv_v = [];
end

%% wave power
if exist('wave_on') && wave_on
    wave_v = [10000
        0];
end

%% Run of river generator
if ror_integer_on
    ror_integer_v = [ror_integer_cost.*[1 1] %%% Capital cost ($/kW)
        80 80 %%% Power Capacity (kW)
        18 18%%% Swept area (m^2)
        10 10];%%% Site limit (#)
end

%% PEM Fuel Cel
if exist('pemfc_on') && pemfc_on
    %%%Capital Cost
    %%%Efficiency
    pem_v = [2000+2.7
        0.45
        0.005
        0];
    
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
   
    ees_v=[0.7.*830; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .90; .90; .995];
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
      
    if ~isempty(ees_v)
        ees_cap=ees_v(1);
    else
        ees_cap = [];
    end
else
    ees_v = [];
    rees_v = [];
    sgip = [];
end

%% Generic Electrolyzer
if el_on
    %%% Generic electrolyzer
    %%% (1) Captail Cost ($/kW H2 produced)
    %%% (2) Variable O&M ($/kWh H2 produced)
    %%% (3) Electrolyzer efficiency (kWh H2/kWh elec)
    el_v = [2100+2.7; 0.01; 0.6];
    % el_v = [1; 0.01; .99];
    % el_v = [1; 0.01; .6];
    
    %%%Financial Aspects - Electrolyzer
    el_fin = [-0.02; ... %%%Scaling linear factor - Based on CA Roadmap - 2k H2 per day vs. 20k H2 per day
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
      
    el_cap = el_v;
else
    el_v = []
    % h2es_v = [];
end
%% Generic Electrolyzer with Binary on/off
if el_binary_on
    %%% Generic electrolyzer
    %%% (1) Captail Cost ($/kW H2 produced)
    %%% (2) Variable O&M ($/kWh H2 produced)
    %%% (3) Electrolyzer efficiency (kWh H2/kWh elec)
    %%% (4) Minimum electrolyzer load (%)
    el_binary_v = [2100+2.7; 0.01; 0.6; 0.3];
    % el_v = [1; 0.01; .99];
    % el_v = [1; 0.01; .6];
    
    %%%Financial Aspects - Electrolyzer
    el_fin = [-0.02; ... %%%Scaling linear factor - Based on CA Roadmap - 2k H2 per day vs. 20k H2 per day
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
      
    el_binary_cap = el_binary_v;
else
    el_binary_v = []
    % h2es_v = [];
end
%% Renewable Electrolyzer (rel)
if rel_on
    %%% Generic electrolyzer
    %%% (1) Captail Cost ($/kW H2 produced)
    %%% (2) Variable O&M ($/kWh H2 produced)
    %%% (3) Electrolyzer efficiency (kWh H2/kWh elec)
    rel_v = [2100+2.7; 0.01; 0.6];
    
    %%%Financial Aspects - Electrolyzer
    rel_fin = [-0.02; ... %%%Scaling linear factor - Based on CA Roadmap - 2k H2 per day vs. 20k H2 per day
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
else
rel_v = [];
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
    h2es_v = [22;0.001;0.001;0.01;1;1;1;1;1;1];
    h2es_cap = h2es_v(1);
else
    h2es_v = [];
end

%% Building space
%%%[space available for PV (m^2)
%%%Cooling loop input (C)
%%%Cooling loop output (C)
%%%Building cooling side (C)
bldg_v= [10000000000; 10; 18; 15];

%% Tech select

if ~pv_on
    pv_v=[];
end

if ~ees_on
    ees_v =[];
end
