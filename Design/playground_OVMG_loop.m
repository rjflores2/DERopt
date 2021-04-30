%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;

%% Parameters

%%% opt.m parameters
%%%Choose optimizaiton solver 
opt_now = 1; %CPLEX
opt_now_yalmip = 0; %YALMIP

%% Island operation (opt_nem.m) 
island = 0;

%% Turning technologies on/off (opt_var_cf.m and tech_select.m)
pv_on = 1;        %Turn on PV
ees_on = 1;       %Turn on EES/REES
rees_on = 1;  %Turn on REES

%% Turning incentives and other financial tools on/off
sgip_on = 1;

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


%% Adding paths
%%%YALMIP Master Path
addpath(genpath('H:\Matlab_Paths\YALMIP-master'))

%%%CPLEX Path
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64'))

%%%Source of URBANopt Results
addpath('H:\_Research_\CEC_OVMG\URBANopt\UO_Results')
addpath('H:\_Research_\CEC_OVMG\URBANopt')

%%%DERopt paths
addpath(genpath('H:\_Tools_\DERopt'))

%%%Specific project path
addpath('H:\_Research_\CEC_OVMG\DERopt')

%%%SGIP CO2 Signal
addpath('H:\Data\CPUC_SGIP_Signal')

%% Loading building demand
file_name = 'UES_Sc2\Sc2_19_UES_ERSH_ACboost';

%%%Loading Data
dt = load(strcat('H:\_Research_\CEC_OVMG\URBANopt\UO_Results\',file_name,'.mat'));

%%%Pulling out load data
elec = dt.loads_fac;
gas = dt.gas_fac;
elec_o = elec;
%%
%%%Reading dc_exist and rate info
[ri_num,ri_txt] = xlsread('bldg_rate_info.xlsx');

dc_exist = ri_num; %%%DC Exist - 1 = yes, 0 = no
rate = ri_txt(2:end,2); %%%Rate info for each building

%%%Low income properties
low_income = xlsread('OV_Low_Income_Properties.xlsx');

%%%Estimating residential units
res_units = floor(cell2mat(dt.bldg_info(:,6))./1100);

for ii = 1:size(dt.bldg_info,1)
    if not(cellfun('isempty',strfind({'Multifamily (2 to 4 units)'},char(dt.bldg_info(ii,3))))) || ...
            not(cellfun('isempty',strfind({'Single-Family'},char(dt.bldg_info(ii,3)))))
        res_units(ii) = res_units(ii);
    else
        res_units(ii) = 0;
    end
end

%%% maximum PV
maxpv = cell2mat(dt.bldg_info(:,4))./10.76*0.2*.7;

% bldg_ind = [180:200];
% elec = [elec_o(:,bldg_ind)];
% rate = rate(bldg_ind);
% dc_exist = dc_exist(bldg_ind);
% low_income = low_income(bldg_ind);
% res_units = res_units(bldg_ind);


%%
% bldg_ind = find(res_units~=0);
bldg_ind = 1:10;
bldg_name = dt.bldg_info(bldg_ind,:);
elec = elec(:,bldg_ind);
elec_o = elec_o(:,bldg_ind);
dc_exist = dc_exist(bldg_ind);
rate = rate(bldg_ind);
low_income = low_income(bldg_ind);
res_units = res_units(bldg_ind);
maxpv = maxpv(bldg_ind);
sgip_pbi = strcmp(rate,'TOU8') + strcmp(rate,'GS1');

%% Formatting Building Data
bldg_loader_OVMG

%% Utility Data
%%%Loading Utility Data and Generating Energy Charge Vectors
utility_SCE_2020

%% Tech Parameters/Costs
%%%Technology Parameters
tech_select
%%%Including Required Return with Capital Payment (1 = Yes)
req_return_on = 1;
%%%Technology Capital Costs
tech_payment

%%%Capital cost mofificaitons
cap_cost_mod

%% original building info 
elec_o = elec;
rate_o = rate;
res_units_o = res_units;
maxpv_o = maxpv;
sgip_pbi_o = sgip_pbi;
low_income_o = low_income;
cap_mod_o = cap_mod;
cap_scalar_o = cap_scalar;
dc_exist_o = dc_exist;
%% DERopt
time_start = clock

for bldg_ind = 1%:size(elec_o,2)
    %% Current variable set
    elec = elec_o(:,bldg_ind);
    rate = rate_o(bldg_ind);
    res_units = res_units_o(bldg_ind);
    maxpv = maxpv_o(bldg_ind);
    sgip_pbi = sgip_pbi_o(bldg_ind);
    low_income = low_income_o(bldg_ind);
    dc_exist = dc_exist_o(bldg_ind);
    cap_mod.pv = cap_mod_o.pv(bldg_ind);
    cap_mod.rees = cap_mod_o.rees(bldg_ind);
    cap_mod.ees = cap_mod_o.ees(bldg_ind);
    cap_scalar.pv = cap_scalar_o.pv(bldg_ind);
    cap_scalar.rees = cap_scalar_o.rees(bldg_ind);
    cap_scalar.ees = cap_scalar_o.ees(bldg_ind);
    %% Setting up variables and cost function
    fprintf('%s: Objective Function.', datestr(now,'HH:MM:SS'))
    tic
    opt_var_cf %%%Added NEM and wholesale export to the PV Section
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
    
    %% DER Incentives
    fprintf('%s: DER Incentives Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_incentives
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% Optimize
    fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))
    opt
    
    %% Response Recording
    rec_import(:,bldg_ind) = import;
    rec_pv_elec(:,bldg_ind) = pv_elec;
    rec_pv_nem(:,bldg_ind) = pv_nem;
    rec_pv_adopt(1,bldg_ind) = pv_adopt;
    pv_adopt
    rec_ees_adopt(1,bldg_ind) = value(ees_adopt);
    rec_ees_soc(:,bldg_ind) = value(ees_soc);
    rec_ees_chrg(:,bldg_ind) = value(ees_chrg);
    rec_ees_dchrg(:,bldg_ind) = value(ees_dchrg);
    
    rec_rees_adopt(1,bldg_ind) = value(rees_adopt);
    rec_rees_soc(:,bldg_ind) = value(rees_soc);
    rec_rees_chrg(:,bldg_ind) = value(rees_chrg);
    rec_rees_dchrg(:,bldg_ind) = value(rees_dchrg);
    rec_rees_dchrg_nem(:,bldg_ind) = value(rees_dchrg_nem);
    
    rec_sgip_ees_pbi(:,bldg_ind) = sgip_ees_pbi;
    rec_sgip_ees_npbi(:,bldg_ind) = sgip_ees_npbi;
    rec_sgip_ees_npbi_equity(:,bldg_ind) = sgip_ees_npbi_equity;
    
    rec_fval(1,bldg_ind) = fval;
    
    bldg_ind
end

time_end = clock

%% Save Results
save(strcat('H:\_Research_\CEC_OVMG\URBANopt\UO_Results\',file_name,'_DER.mat'),...
    'rec_import',...
    'rec_pv_elec',...
    'rec_pv_nem',...
    'rec_pv_adopt',...
    'rec_ees_adopt',...
    'rec_ees_soc',...
    'rec_ees_chrg',...
    'rec_ees_dchrg',...
    'rec_rees_adopt',...
    'rec_rees_soc',...
    'rec_rees_chrg',...
    'rec_rees_dchrg',...
    'rec_rees_dchrg_nem',...
    'rec_sgip_ees_pbi',...
    'rec_sgip_ees_npbi',...
    'rec_sgip_ees_npbi_equity',...
    'rec_fval',...
    'cap_mod_o',...
    'cap_scalar_o',...
    'pv_v',...
    'pv_cap',...
    'ees_v',...
    'ees_cap',...
    'sgip_o')
    