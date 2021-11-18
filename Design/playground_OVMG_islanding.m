%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;

% %%
%% Parameters

%%% opt.m parameters
%%%Choose optimizaiton solver
opt_now = 1; %CPLEX
opt_now_yalmip = 0; %YALMIP

%% Downselection of building energy data?
testing = 0;
downselection = 0;
pv_on = 0;
ees_on = 0;
rees_on = 0;
lpv_on = 1;
lees_on = 1;
lrees_on = 1;
sgip_on = 0;

%% ESA On/Off (opt_var_cf)
esa_on = 1; %Building RAtes are Adjusted for CARE Rates

%% Include Critical Loads
crit_tier = []; %%%Residential Critical Load Requirements (Load Tier)
crit_tier_com = 0.15; %%%Commercial Critical Load Requirements (% of load)

%% Turning incentives and other financial tools on/off
% sgip_on = 1;

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
addpath(genpath('H:\_Tools_\DERopt\Data'))
addpath(genpath('H:\_Tools_\DERopt\Design'))
addpath(genpath('H:\_Tools_\DERopt\Input_Data'))
addpath(genpath('H:\_Tools_\DERopt\Load_Processing'))
addpath(genpath('H:\_Tools_\DERopt\Post_Processing'))
addpath(genpath('H:\_Tools_\DERopt\Problem_Formulation_Multi_Node'))
addpath(genpath('H:\_Tools_\DERopt\Techno_Economic'))
addpath(genpath('H:\_Tools_\DERopt\Utilities'))

%%% Building UO Object Path
addpath('H:\_Research_\CEC_OVMG\URBANopt\UO_Processing')

%%%UO Utility Files
addpath(genpath('H:\_Research_\CEC_OVMG\Rates'))

%% Loading/seperating building demand

fprintf('%s: Loading UO Data.', datestr(now,'HH:MM:SS'))
tic
%%%Loading Data
sc_txt = 'H:\_Research_\CEC_OVMG\URBANopt\UO_Results_0.5.x\UES_2a_DER';
load(strcat(sc_txt,'.mat'));
bldg_base = bldg;
compare = load('H:\_Research_\CEC_OVMG\URBANopt\UO_Results_0.5.x\UES_2a_DER.mat');
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)
bldg_rec = [];

%% Loops
st_idx = [1 51 101 151 201 251 301];
end_idx = [50 100 150 200 250 300 317];

st_idx = [1];
end_idx = [317];

% st_idx = 1
% end_idx = 5

for sim_idx = 1:length(st_idx)
    bldg_ind = [st_idx(sim_idx):end_idx(sim_idx)];
    clear bldg
    bldg = bldg_base;
    
    bldg_ind
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
    
    %%%Info on ESA eligiblity
    load esa_defs
    
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
            
            
            if apartment_types(ii,2)/sum(apartment_types(ii,[2 3])) > 0.8
                low_income(ii) = 1;
            end
        end
        %%%Maximum Area Available for Solar PV (m^2)
        maxpv(ii) = bldg(ii).roof_area./10.76*0.75; %10.76 ft^2 per m^2
        
        %%%
    end
    
    if sim_idx == 1
        res_units_total = res_units;
    end
        
    
    %% Reducing scope for testing
    % bldg_ind = [306];
    
    % elec = [elec_o(:,bldg_ind)];
    % rate = rate(bldg_ind);
    % dc_exist = dc_exist(bldg_ind);
    % low_income = low_income(bldg_ind);
    % res_units = res_units(bldg_ind);
    
    % bldg_ind = find(res_units==0);
    % bldg_ind = [1];
    % bldg_ind = [1 27 92 95 96 97 100 174 204 231 246 282 302 305];
    % bldg_ind = [301:317];
    % if testing
    %     bldg_ind = 3;
    % else
    %     bldg_ind = [];
    % end
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
    
    elec = xlsread('H:\_Research_\CEC_OVMG\URBANopt\Resiliency\UES_2a_Crit_Loads.xlsx','Crit_Load_2');
    
%     sheeeit
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
    
    
    if opt_now
        %% DERopt
        % elec(1000:1012,:) = 100;
        %% Setting up variables and cost function
        fprintf('%s: Objective Function.', datestr(now,'HH:MM:SS'))
        tic
        opt_var_cf_island %%%Added NEM and wholesale export to the PV Section
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
     
        %% General Equality Constraints
        fprintf('%s: General Equalities.', datestr(now,'HH:MM:SS'))
        tic
        opt_gen_equalities_islanding %%%Does not include NEM and wholesale in elec equality constraint
        
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
        
        %% General Inequality Constraints
        fprintf('%s: General Inequalities. ', datestr(now,'HH:MM:SS'))
        tic
        opt_gen_inequalities_islanding
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
        %% Solar PV Constraints
        fprintf('%s: PV Constraints.', datestr(now,'HH:MM:SS'))
        tic
        opt_pv_islanding
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
        
        %% Legacy Storage Technologies
        fprintf('%s: Legacy EES/REES Constraints.', datestr(now,'HH:MM:SS'))
        tic
        opt_legacy_ees
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
        opt_lower_bound_islanding
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
        
        %% Optimize
        fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))
        opt
        
        %% Timer
        finish = datetime('now') ; totalelapsed = toc(startsim)
        
        %% Extract Variables
        variable_values_multi_node_islanding
    end
    %%
    
    
    save('UES_2a_Crit_Load_2','var_lees','var_lrees','var_pv','var_util')
    
    
end

%% Update Utility Costs
OVMG_updated_utility_costs
%% Saving Data
bldg = bldg_base;
save(strcat(sc_txt,'_DER'),'bldg')


