%% Legacy Technologies

%% Legacy PV
if lpv_on
    %%%[O&M ($/kWh)  -  1
    %%%  PV Capacity (kW)] - 2
    pv_legacy = [0.001; 4000];
else
    pv_legacy= zeros(size(pv_v,2));
end

%% Generic generator - e.g. gas turbine
if ldg_on
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
%% Bottoming Generator - steam turbine
if lbot_on
    %%%Bottoming generator is any electricity producing device that operates
    %%%based on heat recovered from another generator
    
    %%%[O&M ($/kWh) - 1
    %%%Maximum output (kW) - 2
    %%%Minimum Setting - 3
    %%%Efficiency - 4
    %%%Heat utilization - 5
    bot_legacy = [0.01; 4500; .1; 0.9; 0.3];
    % bot_legacy = [];
else
    bot_legacy = [];
end
%% Heat Recovery
if lhr_on
    %%%[O&M ($/kWh) - 1
    %%%Effectivness - 2
    hr_legacy = [0.001; 0.8];
    % hr_legacy = [];
    if ldb_on
        
        %%%Duct burner operation
        %%%[O&M ($/kWh) - 1
        %%%Efficiency] - 2
        db_legacy = [0.0001; 0.63];
    else
        db_legacy = [];
    end
else
    hr_legacy = [];
    db_legacy = [];
end
%% Combustion heater systems
if lboil_on
    
    %%%Boiler Information
    %%%[O&M ($/kWh)
    %%% Utilizaiton
    boil_legacy = [0.001; 0.8];
    
else
    boil_legacy = [];
end
% db_legacy = [];
% boil_legacy = [];
%% Cooling
%%% Existing vapor compression
%%%Vapor Compression Informaiton
%%%[O&M ($/kWh)
%%% COP
%%% Max output (kW)
%%% Min Setting (%)

vc_v1=[0.014; 5.4; 3938; .8; ];
vc_v2=[0.01; 4.8; 4500; .8;];
vc_v3=[0.02; 4.8; 4500.; .8; ];
vc_v4=[0.005; 6.8; 8800; .8; ];
vc_v5=[0.007; 6.8; 8800; .8; ];
vc_v6=[0.012; 5.2; 10550; .8;];
vc_v7=[0.017; 5.2; 10550; .8;];
vc_legacy = [vc_v1 vc_v2 vc_v3 vc_v4 vc_v5 vc_v6 vc_v7];


%  vc_legacy = [];

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
    ees_legacy = [1000; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .90; .90; .995];
else
    ees_legacy = [];
end
%% Thermal Energy Storage Vector - Initial charge is inserted later
if ltes_on
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
    tes_legacy = [99010; %1
        0.0005; %2
        0.0005; %3
        .05; %4
        .95; %5
        .5; %6
        .5; %7
        .95; %8
        .95; %9
        .999]; %10
else
    tes_legacy = [];
end
%% Campus Properties
%%%[Available area for solar
%%% Cooling loop input (C)
%%% Cooling loop output (C)
%%% Building cooling side (C)]
camp_prop=[200000; 10; 18; 15];
%% Rewriting campus properties as facility properties
%%% 1: local max power
fac_prop = [50000];
