
%% Utility Based Solar
if util_solar_on
    %%% Cap cost ($/kW)
    %%% Efficiency / Conversion Percent at 1 kW/m^2
    %%% O&M ($/kWh generated)
    utilpv_v = [900; 0.2; 0.001];
    
    %%%Financial Aspects - Solar PV
    utilpv_fin = [0; ... %%%Scaling linear factor - Based on Lazards cost of electricity
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
else

utilpv_v = [];
end

%% Utility Wind
if util_wind_on
    %%% Cap cost ($/kW)
    %%% O&M ($/kWh generated)
    util_wind_v = [1190; 0.005];
    
    %%%Financial Aspects - Solar PV
    util_wind_fin = [0; ... %%%Scaling linear factor - Based on Lazards cost of electricity
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
else
util_wind_v = [];
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

%% Generic Electrolyzer
if util_el_on
    %%% Generic electrolyzer
    %%% (1) Captail Cost ($/kW H2 produced)
    %%% (2) Variable O&M ($/kWh H2 produced)
    %%% (3) Electrolyzer efficiency (kWh H2/kWh elec)
    util_el_v = [2100; 0.01; 0.6];
    % el_v = [1; 0.01; .99];
    % el_v = [1; 0.01; .6];
    
    %%%Financial Aspects - Electrolyzer
   util_el_fin = [-0.02; ... %%%Scaling linear factor - Based on CA Roadmap - 2k H2 per day vs. 20k H2 per day
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
        
else
    util_el_v = []
    % h2es_v = [];
end

%% Pipeline injection
if util_h2_inject_on
    %%%H2 injection - linear fit for capital costs
    %%% (1) Capital Cost Intercept
    %%% (2) Capital Cost Slope
    util_h2_inject_v = 0.5*[3213860
        37.6];
else
    util_h2_inject_v = [];
end