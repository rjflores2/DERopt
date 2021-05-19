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

%%%Loading Data
dt = load('H:\_Research_\CEC_OVMG\URBANopt\UO_Results\UES_Sc1\Sc1_0_Baseline.mat');

%%%Pulling out load data
elec = dt.loads_fac;
gas = dt.gas_fac;
elec_o = elec;
% return
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

bldg_ind = [306];

% elec = [elec_o(:,bldg_ind)];
% rate = rate(bldg_ind);
% dc_exist = dc_exist(bldg_ind);
% low_income = low_income(bldg_ind);
% res_units = res_units(bldg_ind);

bldg_ind = find(res_units==0);

bldg_ind = 1;
% return
% bldg_ind = [1:160];
bldg_name = dt.bldg_info(bldg_ind,:);
elec = elec(:,bldg_ind);
elec_o = elec_o(:,bldg_ind);
dc_exist = dc_exist(bldg_ind);
rate = rate(bldg_ind);
low_income = low_income(bldg_ind);
res_units = res_units(bldg_ind);
maxpv = maxpv(bldg_ind);
sgip_pbi = strcmp(rate,'TOU8') + strcmp(rate,'GS1');

% return
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
% tech_payment

%%%Capital cost mofificaitons
cap_cost_mod

%% DERopt
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
return
%% Timer
finish = datetime('now') ; totalelapsed = toc(startsim)

%% YALMIP Conversions
import=value(import);
if sum(dc_exist) > 0
    onpeak_dc=value(onpeak_dc);
    midpeak_dc=value(midpeak_dc);
    nontou_dc=value(nontou_dc);
end

if isempty(pv_v) == 0
    pv_adopt=value(pv_adopt);
    pv_elec=value(pv_elec);
    pv_nem = value(pv_nem);
    pv_wholesale = value(pv_wholesale);
end

if isempty(ees_v) == 0
    ees_adopt = value(ees_adopt);
    ees_soc = value(ees_soc);
    ees_dchrg = value(ees_dchrg);
    ees_chrg = value(ees_chrg);
else
    ees_adopt=zeros(1,K);
end

if isempty(ees_v) == 0 & rees_exist == 1
    rees_adopt = value(rees_adopt);
    rees_soc = value(rees_soc);
    rees_dchrg = value(rees_dchrg);
    rees_dchrg_nem = value(rees_dchrg_nem);
    rees_chrg = value(rees_chrg);
else
    rees_adopt=zeros(1,K);
end

Objective = value(Objective);

if island == 0 % If not an island 
    if nopv == 0 % If there's solar 
        pv_nem_revenue=sum(value(pv_nem_revenue));
        pv_w_revenue=sum(value(pv_w_revenue));
        if noees == 0; % And EES/RESS
            rees_revenue=sum(value(rees_revenue));
        else %Or no EES 
            rees_revenue=0;
        end 
    else %If there's no solar 
        if noees == 1 % And no EES/REES
            rees_revenue=0;
        else  % or EES/REES 
            rees_revenue=sum(value(rees_revenue));
        end 
        pv_nem_revenue=0;
        pv_w_revenue=0;
    end 
end 

%% Close all
close all
figure
hold on
plot(elec(:,1),'LineWidth',2)
box on
set(gca,'FontSize',16,...
    'XTick',[])

ylabel('Electric Demand (kW)','FontSize',16)
ylim([0 700])
% title('Winter','FontSize',16)
% xlim([0 24*7])


title('Summer','FontSize',16)
xlim([24*240 24*240+24*7])



set(gcf, 'Position',  [-1500, -150, 900, 300])