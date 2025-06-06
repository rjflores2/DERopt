%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;

%% Parameters

%%% opt.m parameters
%%%Choose optimizaiton solver 
opt_now = 1; %CPLEX
opt_now_yalmip = 0; %YALMIP
%% Dummy Variables
elec_dump = []; %%%Variable to "dump" electricity
%% Diesel Only Toggles
utility_exists=[]; %% Utility access
pv_on = 1;        %Turn on PV
ees_on = 1;       %Turn on EES/REES
rees_on = 0;  %Turn on REES
ror_on = 0; % Turn On Run of river generator
ror_integer_on = 0;
ror_integer_cost = 2000;
pemfc_on = 1;
%%%Hydrogen technologies
el_on = 1; %Turn on generic electrolyer
el_binary_on = 0;
rel_on = 0; %Turn on renewable tied electrolyzer
h2es_on = 1; %Hydrogen energy storage
strict_h2es = 0; %Is H2 Energy Storage strict discharge or charge?
%%% Legacy System Toggles
lpv_on = 0; %Turn on legacy PV 
lees_on = 1; %Legacy EES
ltes_on = 0; %Legacy TES

lror_on = 0; %Turn on legacy run of river
% ror_area = 200;
ldiesel_on = 0; %Turn on legacy diesel generators
ldiesel_binary_on = 0; %Binary legacy diesel generators

%% PV (opt_pv.m)
%%%maxpv is maximum capacity that can be installed. If includes different
%%%orientations, set maxpv to row vector: for example maxpv =
%%%[max_north_capacity  max_east/west_capacity  max_flat_capacity  max_south_capacity]
maxpv = [];% ; %%%Maxpv 
toolittle_pv = 0; %%% Forces solar PV adoption - value is defined by toolittle_pv value - kW
curtail = 0; %%%Allows curtailment is = 1
%% EES (opt_ees.m & opt_rees.m)
toolittle_storage = 0; %%%Forces EES adoption - 13.5 kWh
socc = 0; % SOC constraint: for each individual ees and rees, final SOC >= Initial SOC

%% Adding paths
%%%YALMIP Master Path
addpath(genpath('H:\Matlab_Funcitons\YALMIP-master')) %rjf path

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
dt = readtable('H:\_Tools_\DERopt\Data\Steel\EAF renewables.xlsx');

elec = dt.Load(4:end).*1000;
time = datenum([2020 1 1 0 0 0]);
for ii = 2:8760
    time(ii,1) = time(ii-1)+1/24;
end
heat = [];
cool = [];

%%% Formatting Building Data
%%%Values to filter data by
month_idx = [];
% month_idx = [2 3 8 9];
% month_idx = [2];
% month_idx = [9];
% month_idx = [1];
% month_idx = [];
bldg_loader_Steel

%%% Simulating an ice break up

ice_break_up_duration = 0; %days
if ice_break_up_duration > 0
    april_index = find(datetimev(:,2) == 4);
    april_index = april_index(1:ice_break_up_duration*24);
    river_power_potential(april_index,:) = 0;
end

%% Conventional Generator Data
%%%Diesel Cost
diesel_cost = 10; % $/gallon
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
tech_select_Igiugig

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
%%% Capital modifiers
pv_cap_mod = ones(1,size(pv_v,2));
% ees_mthly_debt = ones(size(pv_v,2));

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
    %% Legacy Run of River Constraints
    fprintf('%s: Legacy Run of River Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_run_of_river
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% BRAND NEW RUN OF RIVER CONSTRAINTS
   fprintf('%s: Integer Run of River Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_integer_run_of_river
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)

    %% Optimize
    fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))
    opt
    
    %% Timer
    finish = datetime('now') ; totalelapsed = toc(startsim)
    
    %% Variable Conversion
    variable_values_igiugig


    %% Metrics
    lcoe = solution.objval/sum(elec);
    % co2_emisisons = sum(var_legacy_diesel_binary.electricity).*(1./ldiesel_binary_v(2,:)) ...
    %     .*(3.6) ... %%% Convert from kWh to MJ
    %     .*(1/135.6) ... %%% Convert from MJ to Gallons diesel fuel
    %     .*(10.19); %%%Convert from gallons to kg CO2

% co2_emisisons/sum(elec);

        % .*(0.85) ... %%% Convert from liters to kg

    %% Finding Lambda Values

end

