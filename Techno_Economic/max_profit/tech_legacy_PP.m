%% Legacy Technologies

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
    
    %%%GE 7HA.03 Coefficients
    f1 = 1.8542;
    f2 = 48940;
    
    q1 = 0.6834;
    q2 = 39152;
    dg_legacy = [0.906499/1000; 430000; 430000*0.25; 0.17; 0.17; 0.52;f1; f2; q1; q2; 60*24*3];
    
    dg_legacy = [dg_legacy dg_legacy];
    
    %%%Costs assocaited with cycling the gas turbine
    %%% Cost to turn on the engine - 1 ($/start/kW) - taken from 75% percentile of cold starts
    %%% Cost to change engine power - 2 ($/kWh difference) - Also taken from 75% percentile
    
    if dg_legacy_cyc
        dg_legacy_cyc = [101/1000; 0.74*dg_legacy(2)/1000*(dg_legacy(2)/1000-dg_legacy(3)/1000)/((2*dg_legacy(2)+dg_legacy(3))/4)];
    else
        dg_legacy_cyc = [];
    end
    dg_legacy_cyc = [dg_legacy_cyc dg_legacy_cyc];
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
    bot_legacy = [.798671/1000; 422000; .25; 1; 0.456];
    % bot_legacy = [];
else
    bot_legacy = [];
end
%% Heat Recovery
if lhr_on
    %%%[O&M ($/kWh) - 1
    %%%Effectivness - 2
    hr_legacy = [0.0001; 1];
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
