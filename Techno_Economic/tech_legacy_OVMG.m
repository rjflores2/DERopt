%% Legacy Technologies
%% Legacy PV
if lpv_on
    %%%[O&M - 1
    %%% PV Capacity (kW) - 2 through end
    pv_legacy = [0.001];
    pv_legacy_cap = [ 2.24481550176073,10.1436646963582,16.3888356947536,0.149708223119071,59.7794313956994,135.090544731017,16.7272083014665,116.926811677638,15.7428279591136,893.485114032051,0.857419590481992,1.36863934888463,123.178094409100,7.08069707497888];
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
    ees_legacy = [0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .90; .90; .995];
    
    %%%Capacity at each building  [kWh]
    ees_legacy_cap = [10.*ones(1,14)];
else
    ees_legacy = [];
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
    rees_legacy = [0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .90; .90; .995];
    
    %%%Capacity at each building  [kWh]
    rees_legacy_cap = [10.*ones(1,14)];
else
    rees_legacy = [];
end