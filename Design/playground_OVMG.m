%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;

%% Parameters

%%% opt.m parameters
%%%Choose optimizaiton solver 
opt_now = 1; %CPLEX
opt_now_yalmip = 0; %YALMIP

%% PV (opt_pv.m)
pv_maxarea = 1;

%% PV (opt_pv.m)
pv_maxarea = 1;
%% Too little PV/EES
toolittle_pv = 1;
toolittle_storage = 1;

%% Island operation (opt_nem.m) 
island = 0;
%% EES (opt_ees.m)
%%% Avoid simultaneous Charge and Discharge (xd & xc binaries)
ees_onoff = 0; 
%socc = 0; % SOC constraint: for each individual ees and rees, final SOC >= Initial SOC

%% REES (opt_var_cf.m)
%%%Allow renewable storage decision using EES type
rees_exist = 1;

%% Grid limits 
%%% On/Off Grid Import Limit 
grid_import_on = 0;
%%%Limit on grid import power  
import_limit = .8;
%% Quick Constraints
nopv = 0;        %Turn off all PV
noees = 0;       %Turn off all EES/REES
tc = 0;          %On/Off tranformer constraints 
nem_c = 1;       %On/Off NEM constraints 
dlpfc = 1;       %On/Off Decoupled Linearized Power Flow (DLPF) constraints 
lindist = 0;     %On/Off LinDistFlow constraints 
socc = 0;        %On/Off SOC constraints 
voltage = 1;     %Use upped and lower limit for voltage 
branch = 1;      %On/Off Banch kVA constraints 
VH = 1.05;       %Low Voltage Limit (p.u.)
VL = 0.95;        %High Voltage Limit(p.u.)
Rmulti = 1;      %Multiplier for resistance in impedance matrix

%% Adding paths
%%%YALMIP Master Path
addpath(genpath('H:\Matlab_Paths\YALMIP-master'))

%%%CPLEX Path
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64'))

%%%Source of URBANopt Results
addpath('H:\_Research_\CEC_OVMG\URBANopt\UO_Results')

%%%DERopt paths
addpath(genpath('H:\_Tools_\DERopt'))
%% Loading building demand

%%%Loading Data
dt = load('Sc1_0_Baseline.mat');

%%%Pulling out load data
elec_o = dt.loads_fac;
gas = dt.gas_fac;

dc_exist = [0 0];
rate={'R1'	'R1'};%Mar.15.19
elec = elec_o(:,[1 2]);
day_multi=ones(length(elec),1);

%% Filling a time gap 

time = datenum([2019 1 1 0 0 0]);

for ii = 2:length(elec)
    time(ii,1) = time(ii-1,1) + 1/24;
end
 
%%%Date vectors for all time stamps
datetimev=datevec(time);
%%% Finding month start/endpoints
end_cnt = 1;
stpts=1;
for ii = 2:length(time)
    if datetimev(ii,2) ~= datetimev(ii-1,2)
        endpts(end_cnt,1) = ii-1;
        stpts(end_cnt+1,1) = ii;
        end_cnt = end_cnt +1;
    end
    if ii == length(time);
        endpts(end_cnt,1) = ii;
    end
end  

load 'solar_sna.mat'

%% Tech Parameters/Costs
%%%Technology Parameters
tech_select
%%%Including Required Return with Capital Payment (1 = Yes)
req_return_on = 1;
%%%Technology Capital Costs
tech_payment

%% Utility Data
%%%Loading and formatting utility data
utility
%%%Energy charges for TOU Rates
elec_vecs


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
opt_gen_equalities %%%Include NEM and wholesale in elec equality constraint
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

%% Optimize
fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))
opt
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