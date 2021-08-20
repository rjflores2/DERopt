%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;

%% Parameters

%%% opt.m parameters
%%%Choose optimizaiton solver 
opt_now = 1; %CPLEX
opt_now_yalmip = 0; %YALMIP

%%%Optimize chiller plant operation
chiller_plant_opt = 0;

%% Dummy Variables
elec_dump = []; %%%Variable to "dump" electricity

%% Island operation (opt_nem.m) 
island = 0;

%%%Toggles NEM/Wholesale export (1 = on, 0 = off)
export_on = 0;

%% Carbon Related Constraints

%%%Available biogas/renewable gas per year (biogas limit is prorated in the model to the
%%%simulation period)
biogas_limit = 144E6; %kWh biofuel available per year

%%%Required fuel input
h2_fuel_forced_fraction = []; %%%Energy fuel requirements

%%%H2 fuel limit in legacy generator
h2_fuel_limit = 0.1;%[];%0.15; %%%Fuel limit on an energy basis - should be 0.1

%%%CO2 Limit
% For a complete year in 2018, CO2 emission is 1.3365E8 lbs.
co2_lim = 35785283.5020413*(1-80/100);%10735500;%[];%3.5785e+07;%1.2220e+07*0.5;
%% Turning technologies on/off (opt_var_cf.m and tech_select.m)
pv_on = 1;        %Turn on PV
ees_on = 1;       %Turn on EES
rees_on = 1;  %Turn on REES

lpv_on = 1; %Turn on legacy PV
%% Turning incentives and other financial tools on/off
sgip_on = 0;

%% Throughput requirement - DOE H2 Integration
h2_charging_rec = []; %Required throughput per day

%% PV (opt_pv.m)
%%%maxpv is maximum capacity that can be installed. If includes different
%%%orientations, set maxpv to row vector: for example maxpv =
%%%[max_north_capacity  max_east/west_capacity  max_flat_capacity  max_south_capacity]
maxpv = [];% 250000; %%%Maxpv 
toolittle_pv = 0; %%% Forces solar PV adoption - value is defined by toolittle_pv value - kW
curtail = 0; %%%Allows curtailment is = 1
%% EES (opt_ees.m & opt_rees.m)
ees_onoff = 0;  %%% Avoid simultaneous Charge and Discharge (xd & xc binaries)
toolittle_storage = 1; %%%Forces EES adoption - 13.5 kWh
socc = 0; % SOC constraint: for each individual ees and rees, final SOC >= Initial SOC

%% Grid limits 
%%% On/Off Grid Import Limit 
grid_import_on = 0;
%%%Limit on grid import power  
import_limit = .8;


%% Adding paths
%%%YALMIP Master Path
addpath(genpath('H:\Matlab_Paths\YALMIP-master')) %rjf path
addpath(genpath('C:\Program Files\MATLAB\YALMIP-master')) %cyc path

%%%CPLEX Path
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64')) %rjf path
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio1263\cplex\matlab\x64_win64')) %cyc path


%%%DERopt paths (rjf computer)
addpath(genpath('H:\_Tools_\DERopt\Design'))
addpath(genpath('H:\_Tools_\DERopt\Input_Data'))
addpath(genpath('H:\_Tools_\DERopt\Load_Processing'))
addpath(genpath('H:\_Tools_\DERopt\Post_Processing'))
addpath(genpath('H:\_Tools_\DERopt\Problem_Formulation_Single_Node'))
addpath(genpath('H:\_Tools_\DERopt\Techno_Economic'))
addpath(genpath('H:\_Tools_\DERopt\Utilities'))

%%% DERopt paths (cyc computer)
addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Design'))
addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Input_Data'))
addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Load_Processing'))
addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Post_Processing'))
addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Problem_Formulation_Single_Node'))
addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Techno_Economic'))
addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Utilities'))

%%%Specific project path
addpath('H:\_Research_\CEC_OVMG\DERopt')

%%%SGIP CO2 Signal
addpath('H:\Data\CPUC_SGIP_Signal')
addpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Data')

%%% CO2 Signal Path
addpath('H:\Data\Emission_Factors')
addpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Data\Emission_Factors')

%% Loading building demand

%%%Loading Data
%dt = load('H:\Data\UCI\Campus_Loads_2014_2019.mat');
dt = load('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Data\Campus_Loads_2014_2019.mat');

heat = dt.loads.heating;
time = dt.loads.time;

if chiller_plant_opt
    elec = dt.loads.elec;
    cool = dt.loads.cooling;
else
    elec = dt.loads.elec_total;
    cool = [];
end

%% troubleshooting
tblshoot = 0;

%% Placeholders
dc_exist = 1;
rate = {'TOU8'};
low_income = 0;
sgip_pbi = 1;
res_units = 0;

%% Formatting Building Data
%%%Values to filter data by
year_idx = 2018;
month_idx = [7 8 9];

bldg_loader_UCI

%% Utility Data
%%%Loading Utility Data and Generating Energy Charge Vectors
utility_UCI

%%%Placeholder natural gas cost
ng_cost = 0.5/29.3; %$/kWh --> Converted from $/therm to $/kWh, 29.3 kWh / 1 Therm
rng_cost = ng_cost*2;
%% Tech Parameters/Costs
%%%Technology Parameters
tech_select_UCI

%%%Including Required Return with Capital Payment (1 = Yes)
req_return_on = 1;

%%%Capital cost mofificaitons
cap_cost_mod

%% Legacy Technologies
tech_legacy_UCI

%% DERopt
%% Setting up variables and cost function
fprintf('%s: Objective Function.', datestr(now,'HH:MM:SS'))
tic
opt_var_cf %%%Added NEM and wholesale export to the PV Section
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

%% rSOC Constraints
fprintf('%s: rSOC Constraints.', datestr(now,'HH:MM:SS'))
tic
opt_rsoc
elapsed = toc;
fprintf('Took %.2f seconds \n',elapsed)


%% Optimize
fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))
opt

%% Timer
finish = datetime('now') ; totalelapsed = toc(startsim)

%% Variable Conversion
variable_values
%% System Evaluaiton
uci_evaluation 

%% Check Simultaneous Charging/Discharging and Fuel/Electricity Production
% Electrical Energy Storage (EES)
if (var_ees.ees_adopt > 0)
    ees_ops = [var_ees.ees_chrg var_ees.ees_dchrg];
    ees_double_duty = find(ees_ops(:,1) > 0 & ees_ops(:,2) > 0)
end

% Renewable Electricial Energy Storage (REES)
if (var_rees.rees_adopt > 0)
    rees_ops = [var_rees.rees_chrg var_rees.rees_dchrg];
    rees_double_duty = find(rees_ops(:,1) > 0 & rees_ops(:,2) > 0)
end

% Hydrogen energy Storage (H2ES)
if (var_h2es.h2es_adopt > 0)
    h2es_ops = [var_h2es.h2es_chrg var_h2es.h2es_dchrg];
    h2es_double_duty = find(h2es_ops(:,1) > 0 & h2es_ops(:,2) > 0)
end

% Reversible Solid Oxide Cell (RSOC)
if (var_rsoc.rsoc_adopt > 0)
    rSOC_ops = [var_rsoc.rsoc_prod var_rsoc.rsoc_elec]; 
    rsoc_double_duty = find(rSOC_ops(:,1) > 0 & rSOC_ops(:,2) > 0) 
end
