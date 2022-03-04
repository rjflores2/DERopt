%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;

co2_lim_loop = [0 .10 .25 .50 .60 .65 .675 .7 .725 .75 .775 .8 .85 .9 .95 .99];
% co2_lim_loop = [0 .10 .25 .50];
% co2_lim_loop = [0 .60 .65 .675 .7 .725 .75 .775 .8 .85 .9 .95 .99];
% co2_lim_loop = [0];
% co2_lim_loop = [0 .85 .9 .95 .99];
co2_production = [];
for co2_val = co2_lim_loop
    
    clearvars -except co2_val co2_lim_loop co2_production startsim
    co2_val
    co2_lim_loop
    co2_production


%% Parameters

%%% opt.m parameters
%%%Choose optimizaiton solver 
opt_now = 1; %CPLEX
opt_now_yalmip = 0; %YALMIP

%%%Optimize chiller plant operation
chiller_plant_opt = 0;

%% Dummy Variables
elec_dump = []; %%%Variable to "dump" electricity
%% Adoptable technologies toggles (opt_var_cf.m and tech_select.m)
utility_exists=[1]; %% Utility access
pv_on = 1;        %Turn on PV
ees_on = 1;       %Turn on EES/REES
rees_on = 1;  %Turn on REES

%%%Community/Utility Scale systems
util_solar_on = 1;
util_wind_on = 1;
util_ees_on = 1;
util_el_on = 1;
util_h2_inject_on = 1;

%%%Hydrogen technologies
el_on = 1; %Turn on generic electrolyer
rel_on = 1; %Turn on renewable tied electrolyzer
h2es_on = 1; %Hydrogen energy storage
hrs_on = 0; %Turn on hydrogen fueling station
h2_inject_on = 0; %Turn on H2 injection into pipeline
%% Legacy System Toggles
lpv_on = 1; %Turn on legacy PV 
lees_on = 1; %Legacy EES
ltes_on = 1; %Legacy TES

ldg_on = 1; %Turn on legacy GT
lbot_on = 1; %Turn on legacy bottoming cycle / Steam turbine
lhr_on = 1; %Legacy HR
ldb_on = 1; %Legacy Duct Burner
lboil_on = 1; %Legacy boilers

%% Utility PV Solar
util_pv_wheel = 0; %General Wheeling Capabilities
util_pv_wheel_lts = 0; %Wheeling for long term storage
util_pp_import = 0; %Can import power at power plant node
util_pp_export = 0; %Can import power at power plant node

%% Utility H2 production
util_h2_sale = 0;
util_h2_pipe_store = 1;
%% Strict storage design
strict_h2es = 0;

%% Legacy Generator Options
ldg_op_state = 1; %%%Generator can turn on/off
lbot_op_state = 0; %%%Steam turbine can turn on/off
%%%Gas turbine cycling costs
dg_legacy_cyc = 1;

%%%H2 fuel limit in legacy generator
%%%Used in opt_gen_inequalities
h2_fuel_limit = [1];%0.1; %%%Fuel limit on an energy basis - should be 0.1


%% Island operation (opt_nem.m) 

%%%Electric rates for UCI
%%% 1: current rate, which does not value export
%%% 2: current import rate + LMP export rate
%%% 3: LMP Rate + 0.2 and LMP Export
uci_rate = 1;

island = 0;

%%%Toggles NEM/Wholesale export (1 = on, 0 = off)
export_on = 0; %%%Tied to PV and REES export under current utility rates (opt_PV, opt_ees)

%%%General export
gen_export_on = 0; %%%Placed a "general export" capability in the general electrical energy equality system (opt_gen_equalities)

%% Carbon Related Toggles

%%%Available biogas/renewable gas per year (biogas limit is prorated in the model to the
%%%simulation period)
%%%Used in opt_gen_inequalities
biogas_limit = [144E6];%144E6; %kWh biofuel available per year
biogas_limit = [144E7];%144E6; %kWh biofuel available per year
biogas_limit = [491265*293.1]; %%%kWh - biofuel availabe per year - based on Matt Gudorff emails/pptx
biogas_limit = [0];
% biogas_limit = [491265*2931]; %%%kWh - biofuel availabe per year - based on Matt Gudorff emails/pptx
% biogas_limit = [10];%144E6; %kWh biofuel available per year

%%%Required fuel input
%%%Used in opt_gen_inequalities
h2_fuel_forced_fraction = []; %%%Energy fuel requirements

%%%CO2 Limit
% co2_lim = [0.30];
% co2_lim_red = 0.775
co2_lim_red = co2_val;
if co2_lim_red > 0
%     co2_lim = [6.7070e+07.*(1-co2_lim_red)];
    co2_lim = [4.8304e+07.*(1-co2_lim_red)];
else
    co2_lim = [];
end
%% Turning incentives and other financial tools on/off
sgip_on = 0;

%% Throughput requirement - DOE H2 Integration
h2_charging_rec = []; %Required throughput per day

%% PV (opt_pv.m)
%%%maxpv is maximum capacity that can be installed. If includes different
%%%orientations, set maxpv to row vector: for example maxpv =
%%%[max_north_capacity  max_east/west_capacity  max_flat_capacity  max_south_capacity]
maxpv = [30000];% ; %%%Maxpv 
toolittle_pv = 0; %%% Forces solar PV adoption - value is defined by toolittle_pv value - kW
curtail = 0; %%%Allows curtailment is = 1
%% EES (opt_ees.m & opt_rees.m)
toolittle_storage = 1; %%%Forces EES adoption - 13.5 kWh
socc = 0; % SOC constraint: for each individual ees and rees, final SOC >= Initial SOC

%% Grid limits 
%%% On/Off Grid Import Limit 
grid_import_on = 0;
%%%Limit on grid import power  
import_limit = .6;


%% Adding paths
%%%YALMIP Master Path
addpath(genpath('H:\Matlab_Paths\YALMIP-master')) %rjf path
addpath(genpath('C:\Program Files\MATLAB\R2014b\YALMIP-master')) %cyc path

%%%CPLEX Path
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64')) %rjf path
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio1263\cplex\matlab\x64_win64')) %cyc path

%%%DERopt paths
addpath(genpath('H:\_Tools_\DERopt\Design'))
addpath(genpath('H:\_Tools_\DERopt\Input_Data'))
addpath(genpath('H:\_Tools_\DERopt\Load_Processing'))
addpath(genpath('H:\_Tools_\DERopt\Post_Processing'))
addpath(genpath('H:\_Tools_\DERopt\Problem_Formulation_Single_Node'))
addpath(genpath('H:\_Tools_\DERopt\Techno_Economic'))
addpath(genpath('H:\_Tools_\DERopt\Utilities'))
addpath(genpath('H:\_Tools_\DERopt\Data'))
%%%cyc PC Paths
% addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Design'))
% addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Input_Data'))
% addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Load_Processing'))
% addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Post_Processing'))
% addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Problem_Formulation_Single_Node'))
% addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Techno_Economic'))
% addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Utilities'))
% 
% %%%cyc Office Paths
% addpath(genpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Design'))
% addpath(genpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Input_Data'))
% addpath(genpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Load_Processing'))
% addpath(genpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Post_Processing'))
% addpath(genpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Problem_Formulation_Single_Node'))
% addpath(genpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Techno_Economic'))
% addpath(genpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Utilities'))

%%%Specific project path
% addpath('H:\_Research_\CEC_OVMG\DERopt')

%%%SGIP CO2 Signal
% addpath('H:\Data\CPUC_SGIP_Signal')
% addpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Data')
addpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Data')

%%%CO2 Signal Path
% addpath('H:\Data\Emission_Factors')
% addpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Data\Emission_Factors')
addpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Data\Emission_Factors')

%% Loading building demand
%%%Loading Data
dt = load('H:\Data\UCI\Campus_Loads_2014_2019.mat');
% dt = load('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Data\Campus_Loads_2014_2019.mat');
% dt = load('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Data\Campus_Loads_2014_2019.mat');

heat = dt.loads.heating;
time = dt.loads.time;
if chiller_plant_opt
    elec = dt.loads.elec;
    cool = dt.loads.cooling;
else
    elec = dt.loads.elec_total;
    cool = [];
end

%%% Placeholders
dc_exist = 1;
rate = {'TOU8'};
low_income = 0;
sgip_pbi = 1;
res_units = 0;

%%% Formatting Building Data
%%%Values to filter data by
year_idx = 2018;
% month_idx = [10];
month_idx = [1 4 7 10];
month_idx = [2 9];
month_idx = [1 3 6 7 9 11];
month_idx = [1 4 7 10];



% month_idx = [2];
% month_idx = [9];
% month_idx = [1];
% month_idx = [];
bldg_loader_UCI

% elec = elec ;
% heat = [];


% if length(month_idx) == 6 && ~isempty(co2_lim)
%     co2_lim = 6.4533e+07.*(1-co2_lim);
% elseif length(month_idx) == 2 && ~isempty(co2_lim)
%     co2_lim = 2.1550e+07.*(1-co2_lim);
% end
%  [mean(solar) ...
%  mean(elec)*4/1000 ....
% mean(heat)*4/1000]
% assss
% elec = elec + heat./3;
% heat = 0;

% for ii = 1:12
% avgs_uci(ii,1) = mean(solar(stpts(ii):endpts(ii)));
% avgs_uci(ii,2) = mean(elec(stpts(ii):endpts(ii)))*4/1000;
% avgs_uci(ii,3) = mean(heat(stpts(ii):endpts(ii)))*4/1000;
% end
% avgs_uci

%% Utility Data
%%%Loading Utility Data and Generating Energy Charge Vectors
utility_UCI

%%T&D charge ($/kWh)
t_and_d = 0.01;


% export_price = export_price*0;
%%%Placeholder natural gas cost
ng_cost = 0.5/29.3; %$/kWh --> Converted from $/therm to $/kWh, 29.3 kWh / 1 Therm
% rng_cost = 3/29.3;
rng_cost = 2.*ng_cost;
% rng_cost = 3;
rng_storage_cost = 0.2/29.3;
ng_inject = 0.05/29.3; %$/kWh --> Converted from $/therm to $/kWh, 29.3 kWh / 1 Therm
%% Tech Parameters/Costs
%%%Technology Parameters
tech_select_UCI

%%%Technology parameters for offsite resources
tech_select_offsite_UCI

%%%Including Required Return with Capital Payment (1 = Yes)
req_return_on = 1;

%%%Capital cost mofificaitons
cap_cost_mod


%% Legacy Technologies
tech_legacy_UCI

%% DERopt
if opt_now
    %% Setting up variables and cost function
    fprintf('%s: Objective Function.', datestr(now,'HH:MM:SS'))
    tic
    opt_var_cf %%%Added NEM and wholesale export to the PV Section
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    %% Setting up variables and cost function for offsite resources
    fprintf('%s: Off-site variables.', datestr(now,'HH:MM:SS'))
    tic
    opt_var_cf_offsite %%%Added NEM and wholesale export to the PV Section
    elapsed = toc;
    
    fprintf('Took %.2f seconds \n', elapsed)
    %% General Equality Constraints
    fprintf('%s: General Equalities.', datestr(now,'HH:MM:SS'))
    tic
    if onoff_model
        opt_gen_equalities %%%Does not include NEM and wholesale in elec equality constraint
    else
        opt_gen_equalities_vc_mod
    end
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% General Inequality Constraints
    fprintf('%s: General Inequalities. ', datestr(now,'HH:MM:SS'))
    tic
    opt_gen_inequalities
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% Heat Recovery Inequality Constraints
    fprintf('%s: Heat Recovery Inequalities. ', datestr(now,'HH:MM:SS'))
    tic
    opt_heat_recovery
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    %% Legacy DG Constraints
    fprintf('%s: Legacy DG Constraints. ', datestr(now,'HH:MM:SS'))
    tic
    opt_dg_legacy
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    %% Legacy ST Constraints
    fprintf('%s: Legacy ST Constraints. ', datestr(now,'HH:MM:SS'))
    tic
    opt_bot_legacy
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
    %% Legacy VC Constraints
    fprintf('%s: Legacy VC Constraints.', datestr(now,'HH:MM:SS'))
    tic
    if onoff_model
        opt_vc_legacy
    end
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    %% Legacy TES Constraints
    fprintf('%s: Legacy TES Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_tes_legacy
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    %% DER Incentives
    fprintf('%s: DER Incentives Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_incentives
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% H2 production Constraints
    fprintf('%s: Electrolyzer and H2 Storage Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_h2_production
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    %% Utility Solar
    fprintf('%s: Utility Scale Solar Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_utility_pv
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
     %% Utility Wind
    fprintf('%s: Utility Scale Wind Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_utility_wind
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% Utility EES Storage
    fprintf('%s: Utility Scale Battery Storage Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_utility_ees
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% Utility Electrolyzer
    fprintf('%s: Utility Scale Electrolyzer Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_utility_el
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    %% H2 Pipeline Injection
    fprintf('%s: H2 Pipeline Injection Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_h2_pipeline_injection
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% Optimize
    fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))
    co2_val
    co2_production
    opt
    
    %% Timer
    finish = datetime('now') ; totalelapsed = toc(startsim)
    
    %% Variable Conversion
    variable_values
    
    %% System Evaluaiton
    uci_evaluation_2
    
    %     co2_lim/6.4533e+07
    %     1 - co2_lim/6.4533e+07
    
    if isempty(co2_production)
        co2_production =     co2_emissions;
    end
    
    %%
    if isempty(co2_lim)
        save('H:\_Tools_\UCI_Results\Sc16\Baseline.mat')
    else
        save(strcat('H:\_Tools_\UCI_Results\Sc16\',num2str(100.*co2_lim_red),'_reduction.mat'))
    end
end
end
% fval/sum(elec)
% (fval - sum((var_utilpv.util_pv_adopt/e_adjust.*solar_util - sum(var_pp.pp_elec_wheel,2) - sum(var_pp.pp_elec_export,2)).*lmp_util))/sum(elec)