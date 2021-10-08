%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;

% %%
%% Parameters

%%% opt.m parameters
%%%Choose optimizaiton solver
opt_now = 1; %CPLEX
opt_now_yalmip = 0; %YALMIP

%% Downselection of building energy data?
downselection = 0;
pv_on = 1;
ees_on = 1;
rees_on = 1;
lpv_on = 0;
lees_on = 0;
lrees_on = 0;
%% Turning technologies on/off (opt_var_cf.m and tech_select.m)
% if downselection == 0
%     pv_on = 0;        %Turn on PV
%     ees_on = 0;       %Turn on EES/REES
%     rees_on = 0;  %Turn on REES
% else
%     pv_on = 1;
%     ees_on = 1;
%     rees_on = 1;
% end Legacy technologies
% if downselection == 0
%     lpv_on = 1;
%     lees_on = 0;
%     lrees_on = 1;
% else
%     lpv_on = 0;
%     lees_on = 0;
%     lrees_on = 0;
% end

%% ESA On/Off (opt_var_cf)
esa_on = 0;

%% Include Critical Loads
crit_tier = []; %%%Residential Critical Load Requirements (Load Tier)
crit_tier_com = 0.15; %%%Commercial Critical Load Requirements (% of load)

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
%%%Can export back to the grid
export_on = 1;

%%%Transformer constraints on/off
xfmr_on = 0;
%%%Transformer limit adjustment
t_alpha = 1;

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
addpath(genpath('H:\_Tools_\DERopt'))

%%% Building UO Object Path
addpath('H:\_Research_\CEC_OVMG\URBANopt\UO_Processing')

%%%UO Utility Files
addpath(genpath('H:\_Research_\CEC_OVMG\Rates'))
%% Loading/seperating building demand

fprintf('%s: Loading UO Data.', datestr(now,'HH:MM:SS'))
tic
%%%Loading Data
load('H:\_Research_\CEC_OVMG\URBANopt\UO_Results_0.5.x\ues_baseline_update.mat');

elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)

%% Extracting UO Data
elec = [];
gas = [];
bldg_name = [];
for ii = 1:length(bldg)
    elec(:,ii) = bldg(ii).elec_loads.Total;
    gas(:,ii) = bldg(ii).gas_loads.Total;
    bldg_name{ii,1} = bldg(ii).name;
    bldg_id{ii,1} = bldg(ii).id;
    bldg_type{ii,1} = bldg(ii).type;
end
    
%%%Reading dc_exist and rate info
[ri_num,ri_txt] = xlsread('bldg_rate_info_update.xlsx');

dc_exist = ri_num; %%%DC Exist - 1 = yes, 0 = no
rate = ri_txt(2:end,2); %%%Rate info for each building

%%%Low income properties
[~,low_income_names] = xlsread('OV_Affordable_Housing.xlsx');

%%%Low income Building IDs
low_income_idx = zeros(size(low_income_names));
%%%Residential Units
res_units = zeros(length(bldg),1);
%%%maximum PV Area
maxpv = zeros(length(bldg),1);
%%%Low income buildings
low_income = zeros(length(bldg),1);


%%%Is the building residential?
is_residential = zeros(length(bldg),1);

for ii = 1:length(bldg)
    %%%Building Index for low income properties
    if sum(strcmp(bldg(ii).name,low_income_names))
        low_income_idx(find(strcmp(bldg(ii).name,low_income_names) == 1)) = str2num(bldg(ii).id);
        low_income(ii) = 1;
    end
    %%%Residential Units
    if strcmp(bldg(ii).type,'MFm') || strcmp(bldg(ii).type,'Single-Family Detached') || strcmp(bldg(ii).type,'Residential')
        if ~isempty(bldg(ii).units) && bldg(ii).units > 0
            res_units(ii) = bldg(ii).units;
        else
            res_units(ii) = round(bldg(ii).footprint/1200);
        end
        %%%Building is residential
        is_residential(ii) = 1;
    end
    %%%Maximum Area Available for Solar PV (m^2)
    maxpv(ii) = bldg(ii).roof_area./10.76; %10.76 ft^2 per m^2
    
    
    %%%
end


%% Reducing scope for testing
bldg_ind = [306];

% elec = [elec_o(:,bldg_ind)];
% rate = rate(bldg_ind);
% dc_exist = dc_exist(bldg_ind);
% low_income = low_income(bldg_ind);
% res_units = res_units(bldg_ind);

bldg_ind = find(res_units==0);
bldg_ind = [1];
bldg_ind = [1 27 92 95 96 97 100 174 204 231 246 282 302 305];
bldg_ind = [301:317];
bldg_ind = [];
if ~isempty(bldg_ind)
    % return
    % bldg_ind = [1:160];
    elec = elec(:,bldg_ind);
    
%     elec_o = elec_o(:,bldg_ind);
    dc_exist = dc_exist(bldg_ind);
    rate = rate(bldg_ind);
    low_income = low_income(bldg_ind);
    res_units = res_units(bldg_ind);
    maxpv = maxpv(bldg_ind);
end

%%%Buildings that fall under PBI SGIP program
sgip_pbi = strcmp(rate,'TOU8') + strcmp(rate,'GS1');

%% Formatting Building Data
bldg_loader_OVMG

%% Pulling crirical loads
critical_loads_OVMG

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

%%%Exsiting Technologies 
tech_legacy_OVMG
% low_income = 1;
%%%Capital cost mofificaitons
cap_cost_mod

%%%electrical infrastructure
elec_infrastructure_OVMG

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
opt

%% Timer
finish = datetime('now') ; totalelapsed = toc(startsim)

%% Extract Variables
variable_values_multi_node

%%
% clc
% for ii = 11%:size(elec,2)
%     adopted_tech = round([var_pv.pv_adopt(ii) var_ees.ees_adopt(ii) + var_rees.rees_adopt(ii)],1);
%     operatons = [];
%     operatons = [elec(:,ii) ...
%         var_util.import(:,ii) ...
%         var_pv.pv_elec(:,ii) ...
%         var_pv.pv_nem(:,ii)...
%         var_ees.ees_chrg(:,ii)+var_rees.rees_chrg(:,ii)...
%         var_ees.ees_dchrg(:,ii)+var_rees.rees_dchrg(:,ii)...
%         var_rees.rees_dchrg_nem(:,ii) ...
%         var_ees.ees_soc(:,ii) + var_rees.rees_soc(:,ii)];
%         
%     
% end
% return
%% Utility Costs
OVMG_updated_utility_costs
% 

%% UO Consolidaiton
UO_Consolidation
% %% UCI Post Processing
% OVMG_Evaluation
% 
% %% Close all
% close all
% figure
% hold on
% plot(elec(:,1),'LineWidth',2)
% box on
% set(gca,'FontSize',16,...
%     'XTick',[])
% 
% ylabel('Electric Demand (kW)','FontSize',16)
% ylim([0 700])
% % title('Winter','FontSize',16)
% % xlim([0 24*7])
% 
% 
% title('Summer','FontSize',16)
% xlim([24*240 24*240+24*7])
% 
% 
% 
% set(gcf, 'Position',  [-1500, -150, 900, 300])