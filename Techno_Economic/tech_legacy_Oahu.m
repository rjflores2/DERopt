%% Legacy Technologies
%% Legacy PV
if lpv_on
    %%%[O&M ($/kWh)  -  1
    %%%  PV Capacity (kW)] - 2
    pv_legacy = [0.001; 4000];
else
    pv_legacy= zeros(size(pv_v));
end

%% Generic generator - e.g. gas turbine
if exist('ldg_on') && ldg_on
    %%%[O&M ($/kWh)  -  1
    %%% Maximum output (kW)  -  2
    %%% Minimum output (kW)  -  3
    %%% Max ramp up (%/min)  -  4
    %%% Max ramp down (%/min)  -  5
    %%% Max utilization  -  6
    %%% Fuel input per electrical output - 7
    %%% Zero for fuel input per electrical output - 8
    %%% Heat output for elec output - 9
    %%% Zero for heat output per elec output - 10
    %%% Minimum on/off time in minutes - 11
    
    %%%Taurus Coefficients
    f1 = 2.318;
    f2 = 1.1370e+03;
    
    q1 = 1.4027;
    q2 = -35.8337;
    dg_legacy = [0.026; 9000; 5000; 0.01; 0.01; 0.52;f1; f2; q1; q2; 60*24*3];
    
    %%% Titan Cofficients
    f1 = 2.2337;
    f2 = 2.056635913250589e+03;
    
    q1 = 1.165836640310779;
    q2 = 65.443426383939470;
    
    %%%Titan coefficients - constant efficiency
%     f1 = 1/.36;
%     f2 = 0;
%     q1 = 1.166;
%     q2 = 0;
    
    dg_legacy = [0.026; 14500; 13000; 0.01; 0.01; 0.52;f1; f2; q1; q2; 60*24*3];
    dg_legacy = [0.026; 14500; 6000; 0.01; 0.01; 0.52;f1; f2; q1; q2; 60*24*3];
    dg_legacy = [0.006; 14500; 6000; 0.01; 0.01; 0.52;f1; f2; q1; q2; 60*24*3];
%     dg_legacy = [0.006; 14500; 0; 0.01; 0.01; 0.52;f1; f2; q1; q2; 60*24*3];
    
    %%%Costs assocaited with cycling the gas turbine
    %%% Cost to turn on the engine - 1 ($/start) - taken from 75% percentile of cold starts
    %%% Cost to change engine power - 2 ($/kWh difference) - Also taken from 75% percentile
    
    if dg_legacy_cyc
        dg_legacy_cyc = [101*19; 0.74*15*(15-6)/((2*15000+6000)/4)];
    else
        dg_legacy_cyc = [];
    end
else
    dg_legacy = [];
end
% dg_legacy_cyc = [];
%  top_f = [f1 f2];
%     top_q = [q1 q2];
% dg_legacy = [];
%% Legacy Diesel
if exist('ldiesel_on') && ldiesel_on
    
    %%% Engine Capacity (kW) - 1
    %%%Diesel engine efficiency (fraction)  - 2
    %%% Engine O&M ($/kWh) - 3
    ldiesel_v = [max(elec).*1.5
        0.33
        0.02];
%    ldiesel_v = [ldiesel_v ldiesel_v];
else
    ldiesel_v = [];
end

   %% Legacy Binary Diesel
if exist('ldiesel_binary_on') && ldiesel_binary_on
    
    %%% Engine Capacity (kW) - 1
    %%%Diesel engine efficiency (fraction)  - 2
    %%% Engine O&M ($/kWh) - 3
    %%% Minimnum part load (%capacity) - 4
    ldiesel_binary_v = [50
        0.33
        0.02
        0.5];
%    ldiesel_v = [ldiesel_v ldiesel_v];
else
    ldiesel_binary_v = [];
end 
%% Legacy Run of River
if exist('river_power_potential')
   l_run_of_river_v = [0.000]; %O&M
end

%% Electrical Energy Storage
if lees_on
    %%%[Capacity (kWh) [1]
    %%% Charge O&M ($/kWh) [2]
    %%% Discharge O&M ($/kWh) [3]
    %%% Minimum state of charge [4]
    %%% Maximum state of charge [5]
    %%% Maximum charge rate (kWh per 15 minute/m^3 storage) [6]
    %%% Maximum discharge rate(kWh per 15 minute/m^3 storage) [7]
    %%% Charging efficiency [8]
    %%% Discharging efficieny [9]
    %%% State of charge holdover [10]
    ees_legacy = [240; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .90; .90; .995];
else
    ees_legacy = [];
end
