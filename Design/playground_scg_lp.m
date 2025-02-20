%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;


results = [];
wave_range = [0:50:6000];
wave_range = [0:50:15000];
wave_range = [20000];
fc_limit = [0:0.1:20];
for fc_num = 1:length(fc_limit)
    clearvars -except results wave_range wave_num startsim
    %% Parameters

    %%% opt.m parameters
    %%%Choose optimizaiton solver
    opt_now = 1; %CPLEX
    opt_now_yalmip = 0; %YALMIP
    %% Dummy Variables
    elec_dump = []; %%%Variable to "dump" electricity
    %% Technonology On Toggles
    utility_exists= 1; %% Utility access
    pv_on = 1;        %Turn on PV
    ees_on = 1;       %Turn on EES/REES
    rees_on = 1;  %Turn on REES

    %% Turning everything else off
    ror_on = 0; % Turn On Run of river generator
    ror_integer_on = 0;
    pemfc_on = 0;

    %%%Hydrogen technologies
    el_on = 0; %Turn on generic electrolyer
    el_binary_on = 0;
    rel_on = 0; %Turn on renewable tied electrolyzer
    h2es_on = 0; %Hydrogen energy storage
    strict_h2es = 0; %Is H2 Energy Storage strict discharge or charge?
    %%% Legacy System Toggles
    lpv_on = 0; %Turn on legacy PV
    lees_on = 0; %Legacy EES
    ltes_on = 0; %Legacy TES

    lror_on = 0; %Turn on legacy run of river

    ldiesel_on = 0; %Turn on legacy diesel generators
    ldiesel_binary_on = 0; %Binary legacy diesel generators

    %% PV (opt_pv.m)
    %%%maxpv is maximum capacity that can be installed. If includes different
    %%%orientations, set maxpv to row vector: for example maxpv =
    %%%[max_north_capacity  max_east/west_capacity  max_flat_capacity  max_south_capacity]
    maxpv = [30000];% ; %%%Maxpv
    toolittle_pv = 0; %%% Forces solar PV adoption - value is defined by toolittle_pv value - kW
    curtail = 1; %%%Allows curtailment is = 1
    %% EES (opt_ees.m & opt_rees.m)
    toolittle_storage = 0; %%%Forces EES adoption - 13.5 kWh
    socc = 0; % SOC constraint: for each individual ees and rees, final SOC >= Initial SOC

    %% Adding paths
    %%%YALMIP Master Path
    addpath(genpath('H:\Matlab_Funcitons\YALMIP-master')) %rjf path

    %%%CPLEX Path
    % addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64')) %rjf path
    % addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio1263\cplex\matlab\x64_win64')) %cyc path

    %%%DERopt paths
    addpath(genpath('H:\_Tools_\DERopt\Design'))
    addpath(genpath('H:\_Tools_\DERopt\Input_Data'))
    addpath(genpath('H:\_Tools_\DERopt\Load_Processing'))
    addpath(genpath('H:\_Tools_\DERopt\Post_Processing'))
    addpath(genpath('H:\_Tools_\DERopt\Problem_Formulation_Single_Node'))
    addpath(genpath('H:\_Tools_\DERopt\Techno_Economic'))
    addpath(genpath('H:\_Tools_\DERopt\Utilities'))
    addpath(genpath('H:\_Tools_\DERopt\Data'))

    %% Loading building demand
    %%%Building file details
    cz = 'CZ16';
    file_name = strcat('Data\SCG_Nanogrid\Loads\',cz,'_Loader.xlsx');
    %%% Loading Data
    dt = readtable(file_name,'Sheet','Premium_Heat_Pump');
    time = (dt.HoursSince00_00Jan1 - 0.5)./24;
    %%%Basic Loads
    elec = dt.TotalElec_kWh_;
    heat = dt.TotalGas_kBtu_./3.41214;
    dhw = dt.DHW_kWh_;
    cool = zeros(size(elec));

    %%% Formatting Building Data
    %%%Values to filter data by
    month_idx = [];



    % month_idx = [2];
    % month_idx = [9];
    % month_idx = [1];
    % month_idx = [];
    bldg_loader_scg
assss

    %% Conventional Generator Data
    %%%Diesel Cost
    diesel_cost = 4.722; % $/gallon
    diesel_cost = diesel_cost./128488.*3412.14; % Conversion to $/kWh (1gallon:128,488 Btu, 1 kWh:3412.14 Btu)
    %% Financing CRAP
    interest=0.08; %%%Interest rates on any loans
    interest=nthroot(interest+1,12)-1; %Converting from annual to monthly rate for compounding interest
    period=10;%%%Length of any loans (years)
    equity=0.2; %%%Percent of investment made by investors
    required_return=.12; %%%Required return on equity investment
    required_return=nthroot(required_return+1,12)-1; % Converting from annual to monthly rate for compounding required return
    equity_return=10;% Length at which equity + required return will be paid off (Years)
    discount_rate = 0.08;
    %% Tech Parameters/Costs
    clc
    %%%Technology Parameters
    tech_select_Oahu

    %%%Including Required Return with Capital Payment (1 = Yes)
    if pv_on
        [pv_mthly_debt] = capital_cost_to_monthly_cost(pv_v(1,:),equity,interest,period,required_return);
    end
    if ror_integer_on
        [ror_mthly_debt] = capital_cost_to_monthly_cost(ror_integer_v(1,:),equity,interest,period,required_return);
    end
    if ees_on
        [ees_mthly_debt] = capital_cost_to_monthly_cost(ees_v(1,:),equity,interest,period,required_return);
        [rees_mthly_debt] = capital_cost_to_monthly_cost(ees_v(1,:),equity,interest,period,required_return);
    end
    if el_on
        [el_mthly_debt] = capital_cost_to_monthly_cost(el_v(1,:),equity,interest,period,required_return);
    end
    if el_binary_on
        [el_binary_mthly_debt] = capital_cost_to_monthly_cost(el_binary_v(1,:),equity,interest,period,required_return);
    end
    if h2es_on
        [h2es_mthly_debt] = capital_cost_to_monthly_cost(h2es_v(1,:),equity,interest,period,required_return);
    end
    if pemfc_on
        [pem_mthly_debt] = capital_cost_to_monthly_cost(pem_v(1,:),equity,interest,period,required_return);
    end
    if exist('wave_on') && wave_on
        [wave_mthly_debt] = capital_cost_to_monthly_cost(wave_v(1,:),equity,interest,period,required_return);
    end
    %%% Capital modifiers
    pv_cap_mod = ones(1,size(pv_v,2));
    % ees_mthly_debt = ones(size(pv_v,2));

    %% Legacy Technologies
    tech_legacy_Oahu

    %% DERopt
    if opt_now
        %% Setting up variables and cost function
        fprintf('%s: Objective Function.', datestr(now,'HH:MM:SS'))
        tic
        opt_var_cf %%%Added NEM and wholesale export to the PV Section
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)

        %% General Equality Constraints
        fprintf('%s: General Equalities.', datestr(now,'HH:MM:SS'))
        tic
        opt_gen_equalities %%%Does not include NEM and wholesale in elec equality constraint
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)

        %% General Inequality Constraints
        %     fprintf('%s: General Inequalities. ', datestr(now,'HH:MM:SS'))
        %     tic
        %     opt_gen_inequalities
        %     elapsed = toc;
        %     fprintf('Took %.2f seconds \n', elapsed)

        %% Legacy Diesel Constraints
        fprintf('%s: Legacy Diesel Constraints. ', datestr(now,'HH:MM:SS'))
        tic
        opt_diesel_legacy
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)

        %% Legacy Diesel Binary Constraints
        fprintf('%s: Legacy Diesel Binary Constraints. ', datestr(now,'HH:MM:SS'))
        tic
        opt_diesel_binary_legacy
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
        %% Solar PV Constraints
        fprintf('%s: PV Constraints.', datestr(now,'HH:MM:SS'))
        tic
        opt_pv
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)

        %% EES Constraints
        fprintf('%s: EES Constraints.', datestr(now,'HH:MM:SS'))
        tic
        opt_ees
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
        %% Legacy EES Constraints
        fprintf('%s: Legacy EES Constraints.', datestr(now,'HH:MM:SS'))
        tic
        opt_ees_legacy
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)

        %% H2 production Constraints
        fprintf('%s: Electrolyzer and H2 Storage Constraints.', datestr(now,'HH:MM:SS'))
        tic
        opt_h2_production
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)

        %% PEMFC Constraints
        fprintf('%s: PEMFC Constraints.', datestr(now,'HH:MM:SS'))
        tic
        opt_pemfc
        elapsed = toc
        fprintf('Took %.2f seconds \n', elapsed)

        %% Optimize
        fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))

        if fc_num>1
             results.fc_value(fc_num-1) 
        end
        opt

        %% Timer
        finish = datetime('now') ; totalelapsed = toc(startsim)

        %% Variable Conversion
        variable_values_oahu


        %% Metrics
        % lcoe = solution.objval/sum(elec);
        % co2_emisisons = sum(var_legacy_diesel_binary.electricity).*(1./ldiesel_binary_v(2,:)) ...
        %     .*(3.6) ... %%% Convert from kWh to MJ
        %     .*(1/135.6) ... %%% Convert from MJ to Gallons diesel fuel
        %     .*(10.19); %%%Convert from gallons to kg CO2
        % 
        % co2_emisisons/sum(elec);

        % .*(0.85) ... %%% Convert from liters to kg

        %% Finding Lambda Values

    end

    results.lcoe(wave_num) = solution.objval/sum(elec);
    results.adopted_tech(:,wave_num) = [var_wave.power
        var_pv.pv_adopt
        var_ees.ees_adopt
        var_el.el_adopt
        var_pem.cap
        var_h2es.h2es_adopt];

results.elec_total(:,wave_num) = [sum(var_wave.electricity)
    sum(var_pv.pv_elec)
    sum(var_legacy_diesel.electricity)];
results.elec_share(:,wave_num) = results.elec_total(:,wave_num) ./sum(results.elec_total(:,wave_num) );


     results.wave_value(wave_num) = solution.pi(end);

end