%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;

%% Parameters
% ror_area_range = [0.1 1:120]

ror_area_range = [0.1 1:200];
pv_area_range = [1:25 30:5:100 110:10:9000 9100:100:26000];
% pv_area_range = [1 100:100:9000];
% pv_area_range = [16100:100:26000];
% ror_area_range = [0.1 1:100];
ror_area_range = [0 0.1  .5 1:0.5:18*3];
% ror_area_range = [0];

shadow_rec = [];
energy_mix = [];
tech_adopt = [];
for outer_loop = 1:29
for sim_loop = 1:length(ror_area_range)
    clearvars -except sim_loop ror_area_range shadow_rec startsim energy_mix tech_adopt pv_area_range outer_loop hydro_utilizaiton hydro_max_utilizaiton max_hkt_power
    ror_area = ror_area_range(sim_loop);
%     pv_area = pv_area_range(sim_loop);
    %%% opt.m parameters
    %%%Choose optimizaiton solver
    opt_now = 1; %CPLEX
    opt_now_yalmip = 0; %YALMIP
    %% Dummy Variables
    elec_dump = []; %%%Variable to "dump" electricity
    %% Adoptable technologies toggles (opt_var_cf.m and tech_select.m)
    utility_exists=[]; %% Utility access
    pv_on = 1;        %Turn on PV
    ees_on = 1;       %Turn on EES/REES
    rees_on = 0;  %Turn on REES
    
    ror_on = 0; % Turn On Run of river generator
    ror_integer_on = 0;
    
    pemfc_on = 1;
    
    %%%Hydrogen technologies
    el_on = 1; %Turn on generic electrolyer
    el_binary_on = 0;
    rel_on = 0; %Turn on renewable tied electrolyzer
    h2es_on = 1; %Hydrogen energy storage
    strict_h2es = 0; %Is H2 Energy Storage strict discharge or charge?
    %% Legacy System Toggles
    lpv_on = 0; %Turn on legacy PV
    lees_on = 1; %Legacy EES
    ltes_on = 0; %Legacy TES
    
    lror_on = 1; %Turn on legacy run of river
    
    ldiesel_on = 1; %Turn on legacy diesel generators
    
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
%     addpath(genpath('H:\Matlab_Paths\YALMIP-master')) %rjf path
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
    %%%Loading Data
    dt = readtable('H:\_Tools_\DERopt\Data\Igiugig\Igiugig_Load_Growth_added_time.csv');
    
    time = datenum(dt.Date);
    elec = dt.ElectricDemand_kW_;
    heat = [];
    cool = [];
    
    %%% Formatting Building Data
    %%%Values to filter data by
    month_idx = [];
    
    
    
    % month_idx = [2];
    % month_idx = [9];
    % month_idx = [1];
    % month_idx = [];
    bldg_loader_Igiugig_LP
    
    
    %% Conventional Generator Data
    %%%Diesel Cost
    diesel_cost = 10-0.5*(outer_loop-1)
    if outer_loop == 1
        diesel_cost = 10;
    else
        diesel_cost = 0.00001;
    end
    diesel_cost = 10;
     % $/gallon
%     diesel_cost = 5; % $/gallon
%     diesel_cost = 2.734; % $/gallon
%     diesel_cost = 1.62; % $/gallon
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
    tech_select_Igiugig_LP
    
    %%%Including Required Return with Capital Payment (1 = Yes)
    if pv_on
        [pv_mthly_debt] = capital_cost_to_monthly_cost(pv_v(1,:),equity,interest,period,required_return);
        pv_cap_mod = ones(1,size(pv_v,2));
    end
    if ees_on
        [ees_mthly_debt] = capital_cost_to_monthly_cost(ees_v(1,:),equity,interest,period,required_return);
        ees_cap_mod = ones(size(ees_v,2));
    end
    
    [rees_mthly_debt] = capital_cost_to_monthly_cost(ees_v(1,:),equity,interest,period,required_return);
    [el_mthly_debt] = capital_cost_to_monthly_cost(el_v(1,:),equity,interest,period,required_return);
    if rel_on
        [rel_mthly_debt] = capital_cost_to_monthly_cost(rel_v(1,:),equity,interest,period,required_return);
    end
    [h2es_mthly_debt] = capital_cost_to_monthly_cost(h2es_v(1,:),equity,interest,period,required_return);
    [pem_mthly_debt] = capital_cost_to_monthly_cost(pem_v(1,:),equity,interest,period,required_return);
    
    %%% Capital modifiers
   
    
    
    %% Legacy Technologies
    tech_legacy_Igiugig
    
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
        
        %% ???
        Constraints = [Constraints
            var_pem.elec <= var_pem.cap];
        %% Legacy Run of River Constraints
        fprintf('%s: Legacy Run of River Constraints.', datestr(now,'HH:MM:SS'))
        tic
        opt_run_of_river
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
        
        
        %% Solar Aarea Cosntraint
%         Constraints = [Constraints
%             var_pv.pv_adopt <= pv_area.*pv_v(2)];
        %% Optimize
        fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))
        
        if sim_loop > 1
            prior_shadow = shadow_rec(outer_loop,sim_loop-1)
            sim_loop
            if prior_shadow == 0
                break 
            end
        end
%         pv_area
ror_area
size(shadow_rec)
        opt
        
        %% Timer
        finish = datetime('now') ; totalelapsed = toc(startsim)
        
        %% Variable Conversion
        variable_values_igiugig
        
        %% Finding Lambda Values
        tech_adopt(:,sim_loop) = [var_pv.pv_adopt'
            var_ees.ees_adopt + var_rees.rees_adopt
            var_el.el_adopt
            var_h2es.h2es_adopt
            var_pem.cap];
        %         fval_rec(sim_loop) = fval

        shadow_rec(outer_loop,sim_loop) = [solution.pi(end)];
%         shadow_rec(:,sim_loop) = [lambda.ineqlin(end) lambda.ineqlin(end-8761:end-1)'];
        %         shadow_rec(:,sim_loop) = [lambda.ineqlin(end)];
        
        hydro_utilizaiton(outer_loop,sim_loop) = sum(var_run_of_river.electricity)./(sum(river_power_potential).*var_run_of_river.swept_area);

        river_power_potential(river_power_potential==0) = 80/18;
        
        hydro_max_utilizaiton(outer_loop,sim_loop) = sum(var_run_of_river.electricity)./(sum(river_power_potential).*var_run_of_river.swept_area);
        
        energy_mix(:,sim_loop) = [sum(sum(var_legacy_diesel.electricity,2))
            sum(sum(var_pv.pv_elec,2))
            sum(sum(var_run_of_river.electricity,2))
            sum(sum(var_pem.elec,2))];

        max_hkt_power(outer_loop,sim_loop) = max(var_run_of_river.electricity);
        
if -solution.pi(end) < 1
    break
end

        %         shadow_ror_potential = lambda.ineqlin(end-8761:end-1);
        % shadow_ror_swept_area = lambda.ineqlin(end);


        %     lambda_range = [min([min(find(model.bineq == river_power_potential(1,1))) min(find(model.bineq == river_power_potential(1,2)))])
        % max([max(find(model.bineq == river_power_potential(end,1))) max(find(model.bineq == river_power_potential(end,2)))])]
        % shadow_value_ror./fval
        % sum(lambda.ineqlin(min(find(model.bineq == river_power_potential(1,1))):max(find(model.bineq == river_power_potential(end,1)))))

        %
        %
        % lambda_range = [min(find(model.bineq == river_power_potential(1,1))) min(find(model.bineq == river_power_potential(1,1)))+8759
        %     max(find(model.bineq == river_power_potential(end,2)))-8759 max(find(model.bineq == river_power_potential(end,2)))];
        % %
        % %
        % sum(lambda.ineqlin(lambda_range(1,1):lambda_range(1,2)))
        % sum(lambda.ineqlin(lambda_range(2,1):lambda_range(2,2)))
        % sum(model.bineq(lambda_range(1,1):lambda_range(2,2)))
        % sum(model.bineq(175204:192723))




        %     max(find(model.bineq == river_power_potential(end,2))) - 8759
        % sum(lambda.ineqlin(lambda_range(2):lambda_range(2)+8759))
        % sum(lambda.ineqlin(lambda_range(1)-8759:lambda_range(1)))
    end
end
end