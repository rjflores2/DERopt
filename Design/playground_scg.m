%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;
%% Parameters %%
%%
%%% opt.m parameters
%%%Choose optimizaiton solver
opt_now = 1; %CPLEX
opt_now_yalmip = 0; %YALMIP

%% Turning technologies on/off (opt_var_cf.m and tech_select.m)
pv_on = 1;        %Turn on PV
ees_on = 1;       %Turn on EES/REES
rees_on = 1;      %Turn on REES
sofc_on =1;       %Turn on SOFC
erwh_on =1;       %Turn on ERWH (Electric Resistance Water Heater)
gwh_on =1;        %Turn on GWH (Gas Water Heater)
sofcwh_on =1;     %Turn on SOFC water heater (CHP)
gsph_on = 1;      %Turn on GSPH (Gas Space Heater)
ersph_on = 1;      %Turn on ERSPH (Electric Resistance Space Heater)

%%%NO LEGACY SYSTEMS YET!
lpv_on = 0;
lees_on = 0;
lrees_on = 0;

%% Toggles not in use

%%%Infrastructur Constraints
%%%Consider the AC power flow?
acpf_sim = 0;
%%%Transformer constraints on/off
xfmr_on = 0;
%%%Transformer limit adjustment
t_alpha = 1;

%%%Critical loads
crit_load_lvl = [];

%% ESA On/Off (opt_var_cf) Energy Savings Assistance
esa_on = 1; %Building RAtes are Adjusted for CARE Rates 

%% Include Critical Loads
crit_tier = []; %%%Residential Critical Load Requirements (Load Tier)
crit_tier_com = 0.15; %%%Commercial Critical Load Requirements (% of load)crit_load_lvl

%% Critical Load Level6
% crit_load_lvl = 5;

%% Turning incentives and other financial tools on/off
sgip_on = 0; %Self-Generation Incentive Program (SGIP)

%% PV (opt_pv.m)
pv_maxarea = 1; %%% Limits maximum PV size, based on initially solar PV panel
toolittle_pv = 0; %%% Forces solar PV adoption - value is defined by toolittle_pv value - kW
curtail = 1; %%%Allows curtailment is = 1
%% EES (opt_ees.m & opt_rees.m)
ees_onoff = 0;  %%% Avoid simultaneous Charge and Discharge (xd & xc binaries)
toolittle_storage = 1; %%%Forces EES adoption - 13.5 kWh
socc = 0; % SOC constraint: for each individual ees and rees, final SOC >= Initial SOC

%% Grid limits
%%% On/Off Grid Import Limit
grid_import_on = 0;
%%%Limit on grid import power
import_limit = .8;
%%%Can export back to the grid
export_on = 1;
%%%Which NEM scenario applies? (2.0 or 3.0)
nem_rate = 3.0;

%%% Island operation (opt_nem.m)
island = 0;
%% Adding paths
%%%YALMIP Master Path
addpath(genpath('H:\Matlab_Paths\YALMIP-master'))

%%%CPLEX Path
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64'))

%%%Source of URBANopt Results
addpath('H:\_Research_\CEC_OVMG\URBANopt\UO_Results_0.5.x')

%%%DERopt paths
addpath(genpath('H:\_Tools_\DERopt\Data'))
%%% pm paths
%%%DERopt paths - Pegah
addpath(genpath('C:\Users\19498\Documents\GitHub\DERopt\Design'))
addpath(genpath('C:\Users\19498\Documents\GitHub\DERopt\Input_Data'))
addpath(genpath('C:\Users\19498\Documents\GitHub\DERopt\Data'))
addpath(genpath('C:\Users\19498\Documents\GitHub\DERopt\Load_Processing'))
addpath(genpath('C:\Users\19498\Documents\GitHub\DERopt\Post_Processing'))
addpath(genpath('C:\Users\19498\Documents\GitHub\DERopt\Problem_Formulation_Multi_Node'))
addpath(genpath('C:\Users\19498\Documents\GitHub\DERopt\Techno_Economic'))
addpath(genpath('C:\Users\19498\Documents\GitHub\DERopt\Utilities'))

%%% rjf paths
addpath(genpath('H:\_Tools_\DERopt\Data'))
addpath(genpath('H:\_Tools_\SCG_DERopt\DERopt\Design'))
addpath(genpath('H:\_Tools_\SCG_DERopt\DERopt\Input_Data'))
addpath(genpath('H:\_Tools_\SCG_DERopt\DERopt\Load_Processing'))
addpath(genpath('H:\_Tools_\SCG_DERopt\DERopt\Post_Processing'))
addpath(genpath('H:\_Tools_\SCG_DERopt\DERopt\Problem_Formulation_Multi_Node'))
addpath(genpath('H:\_Tools_\SCG_DERopt\DERopt\Techno_Economic'))
addpath(genpath('H:\_Tools_\SCG_DERopt\DERopt\Utilities'))

%%% Building UO Object Path
addpath('H:\_Research_\CEC_OVMG\URBANopt\UO_Processing')

%%%UO Utility Files
addpath(genpath('H:\_Research_\CEC_OVMG\Rates'))

%% Loading building demand - BEopt Data Ref Format

% dt = xlsread('UO_Example.xlsx');
dt = readtable('CZ06_2020_Ref.csv');

%%%All energy is in kWh
time = (dt.HoursSince00_00Jan1 - 0.5)./24;
%%%Basic loads
cool = dt.MyDesign_SiteEnergy_Cooling_E__kWh_ + dt.MyDesign_SiteEnergy_CoolingFan_Pump_E__kWh_;
cool = zeros(size(time)); %dt.MyDesign_SiteEnergy_Cooling_E__kWh_ + dt.MyDesign_SiteEnergy_CoolingFan_Pump_E__kWh_;
dhw = dt.MyDesign_SiteEnergy_HotWater_E__kWh_;
misc_gas = dt.MyDesign_SiteEnergy_Lg_Appl__G__Btu_./3412.14;
heat = dt.MyDesign_SiteEnergy_Heating_G__Btu_./3412.14;

%%%Composite loads
%%%%% Space cooling model is not complete - cooling is accounted for in the
%%%%% elec variable. A seperate cooling variable will be developed later
elec = dt.MyDesign_SiteEnergy_Total_E__kWh_  - dhw;

%%%Which rate?
rate = {'R1'};
%%%Do demand charges apply?
dc_exist = 0;
%%%Is the building low income?
low_income = 0;
%%%Number of residential units
res_units = 1;
%%%Max PV Capacity
maxpv = 2000000;
%%%Apartment Types
%%% Col1: non-profit units
%%% Col2: low-income for profit units
%%% Col3: >200% poverty limit units
apartment_types = [0 0 1];

%% Formatting Building Data

%%%Climate Zone
cz_name = 'CZ06';
%%%Year to be simulated
yr = 2035;
%%%Month filter - use during development/debugging
mth = [7];

bldg_loader_scg

%% tdv_limit
% zne_red = 0; % Percent total energy use reduction (%)
% tdv_lim = (1-zne_red).*(tdv_elec'*(sum(elec,2) + sum(cool,2)) ...
%     + tdv_gas'*(sum(heat,2)./gsph_v(2) + sum(hotwater,2)./gwh_v(2) + sum(misc_gas,2)));

%% Utility Data
%%%Loading Utility Data and Generating Energy Charge Vectors
utility_elec

%% Tech Parameters/Costs
%%%Technology Parameters
tech_select
%%%Including Required Return with Capital Payment (1 = Yes)
req_return_on = 1;

%%%Technology Capital Costs
% tech_payment

%%%Exsiting Technologies
tech_legacy_OVMG
% low_income = 1;
%%%Capital cost mofificaitons
cap_cost_mod
%% Building and run model

if opt_now
    %% DERopt
    % elec(1000:1012,:) = 100;
    %% Setting up variables and cost function
    fprintf('%s: Objective Function.', datestr(now,'HH:MM:SS'))
    tic
    opt_var_cf %%%Added NEM and wholesale export to the PV Section
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    %% Adding resiliency and reliability varialbes
    fprintf('%s: Resileincy Varaibles and Objective Funciton.', datestr(now,'HH:MM:SS'))
    tic
    opt_var_cf_resiliency %%%Added NEM and wholesale export to the PV Section
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    % return
    %% General Equality Constraints
    fprintf('%s: General Equalities.', datestr(now,'HH:MM:SS'))
    tic
    opt_gen_equalities %%%Does not include NEM and wholesale in elec equality constraint
    
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% General Inequality Constraints
    fprintf('%s: General Inequalities. ', datestr(now,'HH:MM:SS'))
    tic
    opt_gen_inequalities
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
    
    %% SOFC constraints
    fprintf('%s: SOFC Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_sofc
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    %% ERWH constraints
    fprintf('%s: ERWH Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_erwh
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% GWH constraints
    fprintf('%s: GWH Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_gwh
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    %% GSPH constraints
    fprintf('%s: GSPH Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_gsph
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    %% ERSPH constraints
    fprintf('%s: ERSPH Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_ersph
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    %% DER Incentives
    fprintf('%s: DER Incentives Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_incentives
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% Legacy Storage Technologies
    fprintf('%s: Legacy EES/REES Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_legacy_ees
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% Resiliency Constraints
    fprintf('%s: Resiliency Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_resiliency
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% LDN Transformer Constraints
    fprintf('%s: LDN Transformer Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_xfmrs
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% Lower Bounds
    fprintf('%s: Lower Bound Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_lower_bound
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    %% Optimize
    fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))
    WHATS_THE_CRITICAL_LOAD = crit_load_lvl
    
    opt
 
    %% Timer
    finish = datetime('now') ; totalelapsed = toc(startsim)
    
%     %% Extract Variables
    variable_values_multi_node
end

