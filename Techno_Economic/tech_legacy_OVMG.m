%% Legacy Technologies
%% Legacy PV
if lpv_on
    %%%[O&M - 1
    %%% PV Capacity (kW) - 2 through end
    pv_legacy = [0.001];
    %%%PV Capacity
    pv_legacy_cap = zeros(1,length(bldg));
    for ii = 1:length(bldg)
        pv_legacy_cap(ii) = bldg(ii).der_systems.pv_adopt;
    end
    
    sum(pv_legacy_cap)
    
else
    pv_legacy = [];
    pv_legacy_cap = zeros(1,size(elec,2));
end
   
%% Legacy EES
if lees_on
    %%% [Charge O&M ($/kWh) [1]
    %%% Discharge O&M ($/kWh) [2]
    %%% Minimum state of charge [3]
    %%% Maximum state of charge [4]
    %%% Maximum charge rate (kWh per 15 minute/m^3 storage) [5]
    %%% Maximum discharge rate(kWh per 15 minute/m^3 storage) [6]
    %%% Charging efficiency [7]
    %%% Discharging efficieny [8]
    %%% State of charge holdover [9]
    ees_legacy = [0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .90; .90; .9999];
    
    %%%EES Capacity
    ees_legacy_cap = zeros(1,length(bldg));
    for ii = 1:length(bldg)
        ees_legacy_cap(ii) = bldg(ii).der_systems.ees_adopt;
    end
    
    sum(ees_legacy_cap)
    
else
    ees_legacy = [];
    ees_legacy_cap = zeros(1,size(elec,2));
end


%% Legacy EES
if lrees_on
    %%% [Charge O&M ($/kWh) [1]
    %%% Discharge O&M ($/kWh) [2]
    %%% Minimum state of charge [3]
    %%% Maximum state of charge [4]
    %%% Maximum charge rate (kWh per 15 minute/m^3 storage) [5]
    %%% Maximum discharge rate(kWh per 15 minute/m^3 storage) [6]
    %%% Charging efficiency [7]
    %%% Discharging efficieny [8]
    %%% State of charge holdover [9]
    rees_legacy = [0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .90; .90; .9999];
    
    %%%EES Capacity
    rees_legacy_cap = zeros(1,length(bldg));
    for ii = 1:length(bldg)
        rees_legacy_cap(ii) = bldg(ii).der_systems.rees_adopt;
    end
    
    sum(rees_legacy_cap)
  
else
    rees_legacy = [];
    rees_legacy_cap = zeros(1,size(elec,2));
end

