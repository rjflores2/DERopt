%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;

%% Parameters

%%% opt.m parameters
%%%Choose optimizaiton solver 
opt_now = 1; %CPLEX
opt_now_yalmip = 0; %YALMIP

%%%Optimize chiller plant operation
chiller_plant_opt = 0;
%% Island operation (opt_nem.m) 
island = 0;

%%%Toggles NEM/Wholesale export on/off
export_on = 1;

%% Carbon Related Constraints
h2_fuel_fraction = 0.1; %%%Energy fuel requirements
%% Turning technologies on/off (opt_var_cf.m and tech_select.m)
pv_on = 1;        %Turn on PV
ees_on = 1;       %Turn on EES/REES
rees_on = 1;  %Turn on REES


lpv_on = 1; %Turn on legacy PV
%% Turning incentives and other financial tools on/off
sgip_on = 0;

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

%%%DERopt paths
addpath(genpath('H:\_Tools_\DERopt\Design'))
addpath(genpath('H:\_Tools_\DERopt\Input_Data'))
addpath(genpath('H:\_Tools_\DERopt\Load_Processing'))
addpath(genpath('H:\_Tools_\DERopt\Post_Processing'))
addpath(genpath('H:\_Tools_\DERopt\Problem_Formulation_Single_Node'))
addpath(genpath('H:\_Tools_\DERopt\Techno_Economic'))
addpath(genpath('H:\_Tools_\DERopt\Utilities'))

%%%Specific project path
% addpath('H:\_Research_\CEC_OVMG\DERopt')

%%%SGIP CO2 Signal
addpath('H:\Data\CPUC_SGIP_Signal')

%% Loading building demand

%%%Loading Data
dt = load('H:\Data\UCI\Campus_Loads_2014_2019.mat');

heat = dt.loads.heating;
time = dt.loads.time;
if chiller_plant_opt
    elec = dt.loads.elec;
    cool = dt.loads.cooling;
else
    elec = dt.loads.elec_total;
    cool = [];
end

%% Placeholders
dc_exist = 1;
rate = {'TOU8'};
low_income = 0;
maxpv = 100000./.2;
sgip_pbi = 1;
res_units = 0;

%% Formatting Building Data
bldg_loader_UCI

%% Utility Data
%%%Loading Utility Data and Generating Energy Charge Vectors
utility_UCI

%%%Placeholder natural gas cost
ng_cost = 0.5/29.3; %$/kWh --> Converted from $/therm to $/kWh, 29.3 kWh / 1 Therm
rng_cost = ng_cost*10;
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