%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;
%% Parameters %%
%%
%%% opt.m parameters
%%%Choose optimizaiton solver
opt_now = 1; %CPLEX
opt_now_yalmip = 0; %YALMIP


%% PM Running Values

%%%Turn TDV On/Off
tdv_on = 1;

%%%Building file details
cz = 'CZ06';
sheet_name = 'Baseline'

%%%Year of Interest
yr = 2030%2030, 2040, 2050

%%%Equipment efficiencies - Electric Water Heater
% erwh_eff = 1.65;    %CZ15:WHP COP:2.62 CZ16:ERWH:0.95 PremiumERWH:1 
                    %%% CZ16 WHP:1.65  %%% 0.9 for ERWH 0.99 for premium on-demand,
                    %%% CZ06 2.46 for COP_HPWH 2: ERWH energy factor- COPHPWH = 3 from AHRI Directory  From RFJ model for premium heat pump COP is 2.46

%%%Gas water heater
% gwh_eff = 0.6;  %%% 2: GWH energy factor (EF) Baseline:0.6, Premium_Gas:0.96

%%%Gas Space HEater
% gsph_eff = 0.96; %%% BEopt: Baseline: 0.8 - Premium Gas: 0.96  

%% Logical values for PM model and some pre-processing

file_name = strcat('Data\SCG_Nanogrid\Loads\',cz,'_Loader.xlsx');

%%%Electric space heater
ersph_eff = 1;

if strcmp(sheet_name,'Baseline')
    sc_num = 1;
    bldg_electrified = 0;    %%%Is building electric or no?
    gwh_eff = 0.6;  %%% 2: GWH energy factor (EF) Baseline:0.6, Premium_Gas:0.96
    gsph_eff = 0.8;
    erwh_eff = 0;
elseif strcmp(sheet_name,'Premium_gas')
    sc_num = 2;
    bldg_electrified = 0;    %%%Is building electric or no?
    gwh_eff = 0.96;  %%% 2: GWH energy factor (EF) Baseline:0.6, Premium_Gas:0.96
    gsph_eff = 0.96;
    erwh_eff = 0;
elseif strcmp(sheet_name,'Elec_resistive')
    sc_num = 3;
    bldg_electrified = 1;    %%%Is building electric or no?
    gwh_eff = 0;  %%% 2: GWH energy factor (EF) Baseline:0.6, Premium_Gas:0.96
    gsph_eff = 0;
    erwh_eff = 0.9;
elseif strcmp(sheet_name,'Premium_elec_resistive')
    sc_num = 4;
    bldg_electrified = 1;    %%%Is building electric or no?
    gwh_eff = 0;  %%% 2: GWH energy factor (EF) Baseline:0.6, Premium_Gas:0.96
    gsph_eff = 0;
    erwh_eff = 0.99;
elseif strcmp(sheet_name,'Heat_pump')
    sc_num = 5;
    bldg_electrified = 1;    %%%Is building electric or no?
    gwh_eff = 0;  %%% 2: GWH energy factor (EF) Baseline:0.6, Premium_Gas:0.96
    gsph_eff = 0;
    if strcmp(cz,'CZ06')
        erwh_eff = 2.46;
    elseif strcmp(cz,'CZ15')
        erwh_eff = 2.62;
    elseif strcmp(cz,'CZ16')
        erwh_eff = 1.65;
    end
elseif strcmp(sheet_name,'Premium_Heat_Pump')
    sc_num = 6;
    bldg_electrified = 1;    %%%Is building electric or no?
    gwh_eff = 0;  %%% 2: GWH energy factor (EF) Baseline:0.6, Premium_Gas:0.96
    gsph_eff = 0;
    if strcmp(cz,'CZ06')
        erwh_eff = 2.46;
    elseif strcmp(cz,'CZ15')
        erwh_eff = 2.62;
    elseif strcmp(cz,'CZ16')
        erwh_eff = 1.65;
    end
end
gwh_eff
gsph_eff
erwh_eff
if yr == 2030
    nem_rate = 2.0
    urg_adder = [0.015] %%%RPS 2030:$0.015/kWh (30% RPS)__2040:$0.031/kWh(60% RPS)__2050:$0.054/kWh (100% RPS)
    h2_cost_kg = 6 %renewable H2 cost ($/kg)  2030:6 $/kg__2040:4.5 $/kg__2050:4 $/kg
    h2_mix = 0.51; %Gas mixture assumption (%/vol)  2030:0.51__2040:0.86__2050:1(100% H2)
    co2_cost = 27.96 %$/tonne 2030: $27.96/tonne __2040: $50/tonne__2050: $71.5/tonne
    sofc_cap_cost = 5706 %2025:5706 $/kW__2035:5529.5 $/kW__2045:5420.5 $/kW
    sofc_tax_credit = 0.3;
    ees_cap_cost = 911.5 %2025:911.5 $/kWh__2035:755 $/kWh__2045:654 $/kWh
    pv_cap_cost = 2484 %2025:2484 $/kW__2035:1944 $/kW__2045:1317.5 $/kW
    
    pv_macrs = 5;
    pv_itc = 1;
    
    ees_macrs = 7;
    ees_itc = 0;
    rees_macrs = 5;
    rees_itc = 1;
elseif yr == 2040
    nem_rate = 3.0
    urg_adder = [0.031] %%%RPS 2030:$0.015/kWh (30% RPS)__2040:$0.031/kWh(60% RPS)__2050:$0.054/kWh (100% RPS)
    h2_cost_kg = 4.5 %renewable H2 cost ($/kg)  2030:6 $/kg__2040:4.5 $/kg__2050:4 $/kg
    h2_mix = 0.86 %Gas mixture assumption (%/vol)  2030:0.51__2040:0.86__2050:1(100% H2)
    co2_cost = 50 %$/tonne 2030: $27.96/tonne __2040: $50/tonne__2050: $71.5/tonne
    sofc_cap_cost = 5529.5 %2025:5706 $/kW__2035:5529.5 $/kW__2045:5420.5 $/kW
    sofc_tax_credit = 0.3;
    ees_cap_cost = 755 %2025:911.5 $/kWh__2035:755 $/kWh__2045:654 $/kWh
    pv_cap_cost = 2484 %2025:2484 $/kW__2035:1944 $/kW__2045:1317.5 $/kW
    pv_macrs = 0;
    pv_itc = 0;
    ees_macrs = 0;
    ees_itc = 0;
    rees_macrs = 0;
    rees_itc = 0;
elseif yr == 2050
    nem_rate = 3.0
    urg_adder = [0.054] %%%RPS 2030:$0.015/kWh (30% RPS)__2040:$0.031/kWh(60% RPS)__2050:$0.054/kWh (100% RPS)
    h2_cost_kg = 4 %renewable H2 cost ($/kg)  2030:6 $/kg__2040:4.5 $/kg__2050:4 $/kg
    h2_mix = 1 %Gas mixture assumption (%/vol)  2030:0.51__2040:0.86__2050:1(100% H2)
    co2_cost = 71.5 %$/tonne 2030: $27.96/tonne __2040: $50/tonne__2050: $71.5/tonne
    sofc_cap_cost = 5420.5 %2025:5706 $/kW__2035:5529.5 $/kW__2045:5420.5 $/kW
    sofc_tax_credit = 0.3;
    ees_cap_cost = 654 %2025:911.5 $/kWh__2035:755 $/kWh__2045:654 $/kWh
    pv_cap_cost = 1317.5 %2025:2484 $/kW__2035:1944 $/kW__2045:1317.5 $/kW
    pv_macrs = 0;
    pv_itc = 0; 
    ees_macrs = 0;
    ees_itc = 0;
    rees_macrs = 0;
    rees_itc = 0;
end

%% Turning technologies on/off (opt_var_cf.m and tech_select.m)
pv_on = 1;        %Turn on PV
ees_on = 1;       %Turn on EES/REES
rees_on = 1;      %Turn on REES
%%% Change these 3 items for SOFC ON/OFF
sofc_on =1;       %Turn on SOFC
tes_on = 1;       %Turn on thermal energy storage
sofcwh_on = 1;     %Turn on SOFC water heater (CHP)
%%%
gwh_on = (1 - bldg_electrified);        %Turn on GWH (Gas Water Heater)
gsph_on = (1 - bldg_electrified);      %Turn on GSPH (Gas Space Heater)
ersph_on = bldg_electrified;     %Turn on ERSPH (Electric Resistance Space Heater)
erwh_on = bldg_electrified;       %Turn on ERWH (Electric Resistance Water Heater)
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
%%%Which NEM scenario applies? 2025:2.0  2035:3.0  2045:3.0
% nem_rate = nem_rate;



%%% Island operation (opt_nem.m)
island = 0;

%%%Utility Cost Increase ($/kWh)   $0.031/kWh for 60% RPS,  $0.054/kWh for 100%
%%%RPS 2030:$0.015/kWh (30% RPS)__2040:$0.031/kWh(60% RPS)__2050:$0.054/kWh (100% RPS)
% urg_adder = [0.015]; %Utility retained generation



h2_lim = []; %Gas mixture Limit assumption (%/vol)
%% to check the git
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
% dt = readtable('CZ06_2020_Ref.csv');

% %%%All energy is in kWh
% time = (dt.HoursSince00_00Jan1 - 0.5)./24;
% %%%Basic loads
% cool = dt.MyDesign_SiteEnergy_Cooling_E__kWh_ + dt.MyDesign_SiteEnergy_CoolingFan_Pump_E__kWh_;
% cool = zeros(size(time)); %dt.MyDesign_SiteEnergy_Cooling_E__kWh_ + dt.MyDesign_SiteEnergy_CoolingFan_Pump_E__kWh_;
% dhw = dt.MyDesign_SiteEnergy_HotWater_E__kWh_;
% misc_gas = dt.MyDesign_SiteEnergy_Lg_Appl__G__Btu_./3412.14;
% heat = dt.MyDesign_SiteEnergy_Heating_G__Btu_./3412.14;
% 
% %%%Composite loads
% %%%%% Space cooling model is not complete - cooling is accounted for in the
% %%%%% elec variable. A seperate cooling variable will be developed later
% elec = dt.MyDesign_SiteEnergy_Total_E__kWh_  - dhw;

%% rjf mods
% dt = readtable('C:\Users\19498\Documents\GitHub\DERopt\Data\SCG_Nanogrid\Loads\CZ15_Loader.xlsx','Sheet','Premium_gas');
dt = readtable(file_name,'Sheet',sheet_name);
% sc_num = 5;

time = (dt.HoursSince00_00Jan1 - 0.5)./24;
%%%Basic Loads
elec = dt.TotalElec_kWh_;
heat = dt.TotalGas_kBtu_./3.41214; 
dhw = dt.DHW_kWh_;
cool = zeros(size(elec));
% heat = zeros(size(elec));

 
%%%Which rate?
rate = {'R1'};
%%%Do demand charges apply?
dc_exist = 0;
%%%Is the building low income?
low_income = 0;
%%%Number of residential units
res_units = 1;
%%%Max PV Capacity
maxpv = 200;
%%%Apartment Types
%%% Col1: non-profit units
%%% Col2: low-income for profit units
%%% Col3: >200% poverty limit units
apartment_types = [0 0 1];

%% Formatting Building Data

%%%Climate Zone
cz_name = cz;%'CZ06';
%%%Year to simulate utility
% yr = 2030; %2030, 2040, 2050
%%%Month filter - use during development/debugging
mth = [];

bldg_loader_scg

%% tdv_limit
% zne_red = 0; % Percent total energy use reduction (%)
% tdv_lim = (1-zne_red).*(tdv_elec'*(sum(elec,2) + sum(cool,2)) ...
%     + tdv_gas'*(sum(heat,2)./gsph_v(2) + sum(hotwater,2)./gwh_v(2) + sum(misc_gas,2)));

%% Utility Data
%%%Loading Utility Data and Generating Energy Charge Vectors
utility_elec

%%%Setting up utility gas info
utility_gas

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
%%
strcat(num2str(yr-5),'_Int_Scenario_',num2str(sc_num))
% save(strcat(num2str(yr-5),'_Int_Scenario_',num2str(sc_num)))