%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;

for crit_load_lvl = [3]%%[4 5 6 7] %%% Corresponding END around line 500 - after files have been saved
    clearvars -except crit_load_lvl crit_load_lvl started_at startsim
% crit_load_lvl = 5;
% crit_load_lvl = [];
% %%
%% Parameters

%%% opt.m parameters
%%%Choose optimizaiton solver
opt_now = 1; %CPLEX
opt_now_yalmip = 0; %YALMIP

%% Optimization resileincy models
%%%1) at the building
%%%2) at the xfmr
%%%3) at the circuit
%%%4) at the circuit with linearized ACPF
opt_resiliency_model = 3;

%% Resiliency Simulation level
%%% 1) = at each building
%%% 2) = at the transformer
%%% 3) = at the circuit
sim_lvl = 1;

%%%Include pumping station? yes or no
include_pump_station = 1;
%% Infrastructure Cosntraints
%%%AC Power Flow Simulation
%%% 1) LinDistFlow
acpf_sim = 0;

%%%Are the transformer limits on or off?
acpf_xfmr_on = 0;

%%%Utility Binary Variables on or off??
util_bin_on = 0;

%%% Battery Binary Variables on or off?
ees_bin_on = 0;

%%% Are H2 systems for resiliency only?
h2_systems_for_resiliency_only = 0;
%% Downselection of building energy data?
testing = 0;
h2_tech_on = 0;
if ~testing
    downselection = 0;
    if downselection == 1
        sz_on = 1;
    else
        sz_on = 1;
%         temp = load('temp')
    end
    pv_on = sz_on;
    ees_on = sz_on;
    rees_on = sz_on;
    dgb_on = 0;
    dgc_on = 0;
    dgl_on = h2_tech_on;
    h2_storage_on = h2_tech_on;
    sofc_on = 0;
    lpv_on = 1-sz_on;
    lees_on = 1-sz_on;
    lrees_on = 1-sz_on;
    
    sgip_on = sz_on;
else
    downselection = 0;
    sz_on = 1;
    pv_on = sz_on;
    ees_on = sz_on;
    rees_on = sz_on;
    lpv_on = 1-sz_on;
    lees_on = 1-sz_on;
    lrees_on = 1-sz_on;
    sgip_on = sz_on;
    
    pv_on = 0;
    ees_on = 0;
    rees_on = 0;
    lpv_on = 1;
    lees_on = 1;
    lrees_on = 1;
    sgip_on = 0;
    temp = load('temp')
    %
    %     pv_on = 1;
    %     ees_on = 1;
    %     rees_on = 1;
    %     lpv_on = 0;
    %     lees_on = 0;
    %     lrees_on = 0;
    %     sgip_on = 1;
    %     temp = load('temp')
    
end
testing
downselection = 0

%% ESA On/Off (opt_var_cf)
esa_on = 1; %Building RAtes are Adjusted for CARE Rates

%% Include Critical Loads
crit_tier = []; %%%Residential Critical Load Requirements (Load Tier)
crit_tier_com = 0.15; %%%Commercial Critical Load Requirements (% of load)crit_load_lvl

%% Critical Load Level6
% crit_load_lvl = 5;

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
xfmr_on = 1;
%%%Transformer limit adjustment
t_alpha = 1.25;


%% SHITT
xfmr_on = 0;


%%% Island operation (opt_nem.m)
island = 0;
%% Adding paths
%%%YALMIP Master Path
addpath(genpath('H:\Matlab_Paths\YALMIP-master'))

%%%Guobi Path
addpath('C:\gurobi1103\win64\matlab')

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

% % % scenario = 'ues_baseline_update'
scenario = 'baseline_retest_2B_v2';
% scenario = 'UES_1b'
% scenario = 'ues_1a_v2'
% % % scenario = 'UES_2b'
% scenario = 'ues_baseline_ASHP_HPWH_film_coating_int_ex_lite_AppElec_Plus_envelope'
% scenario = 'ues_baseline_passive_Int_Ex_Lite_AppElec_plus_envelope_rev'
fprintf('%s: Loading UO Data.', datestr(now,'HH:MM:SS'))
tic
%%%Loading Data
sc_txt = strcat('H:\_Research_\CEC_OVMG\URBANopt\UO_Results_0.5.x\',scenario);
load(strcat(sc_txt,'.mat'));
% bldg = bldg(1:50);
% compare = load(strcat('H:\_Research_\CEC_OVMG\URBANopt\UO_Results_0.5.x\',scenario,'.mat'));
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)
bldg_rec = [];


%% Loading Critical Loads
if crit_load_lvl > 0
    %     elec_resiliency_full = xlsread(strcat('H:\_Research_\CEC_OVMG\URBANopt\Resiliency\UES_2a_Crit_Loads.xlsx'),strcat('Crit_Load_',num2str(crit_load_lvl)));
    elec_resiliency_full = xlsread(strcat('H:\_Research_\CEC_OVMG\URBANopt\Resiliency\',scenario,'_Crit_Loads.xlsx'),strcat('Crit_Load_',num2str(crit_load_lvl)));
else
    elec_resiliency_full = [];
end

%% Loading water pumping station data
if include_pump_station
    load('H:\_Research_\CEC_OVMG\URBANopt\Resiliency\HB_Water_Pumping_Station\pump_station_2018.mat');
    pump_station_index = 5;
    xfmr_map{318} = 'T20';
    elec_resiliency_full(:,318) = pump_elec;

    bldg(318).elec_loads = array2table(pump_elec,"VariableNames","Total");
    bldg(318).gas_loads = array2table(zeros(size(pump_elec)),"VariableNames","Total");
    bldg(318).type = 'Pump';
    bldg(318).units = 0;
    bldg(318).xfmr = {'T20'};
    bldg(318).roof_area = 286.9333;
end
bldg_base = bldg;
%% electrical infrastructure links
% elec_infrastructure_OVMG
infrastructure_mapping_OVMG

%% Loops
st_idx = [1 51 101 151 201 251 301];
end_idx = [50 100 150 200 250 300 317];

% st_idx = [1 6 11];
% end_idx = [5 10 15];

st_idx = [1 11 21 31 41];
end_idx = [10 20 30 40 50];


st_idx = [1:20:311];
end_idx = st_idx + 19;
end_idx(end) = 318;


st_idx = 1:318;
end_idx = st_idx;

% st_idx = 220:240;
% end_idx = st_idx;


adopted.pv = [];
adopted.rees = [];
adopted.ees = [];
adopted.dgl = [];
adopted.h2es = [];
adopted.mean_elec = [];

%% Simulation indicies based on resiliency constraints
if opt_resiliency_model == 0
    sim_end = length(st_idx);
elseif opt_resiliency_model == 1 %&& (~acpf_sim || isempty(acpf_sim)) %%%If resiliency is examined per building and no linearized ACPF/infrastructure constraints are implemented 
    sim_end = length(st_idx);
elseif opt_resiliency_model == 2 %||  ((~acpf_sim || isempty(acpf_sim)) && xfmr_on) %%%If resiliency is examined at each transformer, OR only xfmr constraints are implemented
    sim_end = length(xfmrs_unique);
elseif opt_resiliency_model == 3 %|| acpf_sim %%%If resiliency is examined on each individual branch OR ACPF is implemented
    xfmr_2_circuit = readtable('H:\_Tools_\DERopt\Data\OVMG_Inputs\OV_Distribtuion_Circuit_Xfmrs.xlsx');
%     xfmr_2_circuit = readtable('H:\_Tools_\DERopt\Data\OVMG_Inputs\OV_Distribtuion_Circuit_Xfmrs_Island_Formation.xlsx');
    %%%Temp hard coding of transformers
    sheets = {'Sm1','Sm2','Sm3','Sm4','Sm5','Sm6','St1'};
    sim_end = width(xfmr_2_circuit) - 1;
end

%%
for sim_idx = 1:sim_end
   %% Building indicies in the current simulation
   if opt_resiliency_model == 0 %&& (acpf_sim == 0 || isempty(acpf_sim))
        bldg_ind = [st_idx(sim_idx):end_idx(sim_idx)]; 
   elseif opt_resiliency_model == 1 %&& (acpf_sim == 0 || isempty(acpf_sim))
        bldg_ind = [st_idx(sim_idx):end_idx(sim_idx)];
    elseif opt_resiliency_model == 2 % && (acpf_sim == 0 || isempty(acpf_sim))
        bldg_ind = find(strcmp(xfmrs_unique(sim_idx),xfmr_map));
        xfmrs = xfmrs_unique(sim_idx);
    elseif opt_resiliency_model == 3 %&& acpf_sim > 0
        %%%Transformers in the current circuit branch
        xfmrs = table2cell(xfmr_2_circuit(:,sim_idx + 1));
        xfmrs = xfmrs( ~strcmp(xfmrs,''));
        %%%Finding building indicies
        bldg_ind = [];
        for kk = 1:length(xfmrs)
            xfmrs(kk)
            find(strcmp(xfmrs(kk),xfmr_map))
            bldg_ind = [bldg_ind
                find(strcmp(xfmrs(kk),xfmr_map))];
        end
    end
    
    clear bldg
    bldg = bldg_base;
    
    %% Loadings relevant circuit data
    if  opt_resiliency_model >= 3
        %%Branch/Bus matrix
%         [branch_bus,bb_lbl] = xlsread('OV_Branch_Bus_Matricies_Island_Formation.xlsx',char(sheets(sim_idx)));
        [branch_bus,bb_lbl] = xlsread('OV_Branch_Bus_Matricies.xlsx',char(sheets(sim_idx)));
        %%% Eliminating NaN in branch bus matrix
        branch_bus(isnan(branch_bus)) = 0;
        %%%Transformer labels included in current power flow
        bb_lbl = bb_lbl(1,2:end)
        
        %%%Circuit properties
        reactance = [];
        reactance = xlsread('OV_Line_Properties.xlsx',strcat(char(sheets(sim_idx)),'_Reactance'));
%         reactance = xlsread('OV_Line_Properties_Island_Formation.xlsx',strcat(char(sheets(sim_idx)),'_Reactance'));
        reactance(isnan(reactance)) = 0;
        resistance = [];
        resistance = xlsread('OV_Line_Properties.xlsx',strcat(char(sheets(sim_idx)),'_Resistance'));
%         resistance = xlsread('OV_Line_Properties_Island_Formation.xlsx',strcat(char(sheets(sim_idx)),'_Resistance'));
        resistance(isnan(resistance)) = 0;
    end
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
        
    %% Adding pumping station
    if include_pump_station
%         elec(:,318) =  pump_elec;
        dc_exist(318) = 1;
        rate{318} = 'TOU8';
        low_income(318) = 0;
        res_units(318) = 0;
        maxpv(318) = 20;
        bldg_type{318} = 'Pump';
        apartment_types(318,:) = [0 0 0];
    end
    
    %% Reducing scope for testing
    if ~isempty(bldg_ind)
        elec = elec(:,bldg_ind);
        if crit_load_lvl > 0
            elec_res = elec_resiliency_full(:,bldg_ind);
        end
        dc_exist = dc_exist(bldg_ind);
        rate = rate(bldg_ind);
        low_income = low_income(bldg_ind);
        res_units = res_units(bldg_ind);
        maxpv = maxpv(bldg_ind);
        apartment_types = apartment_types(bldg_ind,:);
%         apartment_types = apartment_types(bldg_ind);
        xfmr_subset = xfmr_map(bldg_ind);
    end
    
    
    %% Reducing load around each transformer
    xfmrs_loads = unique(xfmr_subset)
    elec_red = [];
    elec_res_red = [];
    dc_exist_red = [];
    rate_red = [];
    
    for ii = 1:length(xfmrs_loads)
        idx = find(strcmp(xfmrs_loads(ii),xfmr_subset))
        
        
        elec_red(:,ii) = sum(elec(:,idx),2);
        if crit_load_lvl > 0
            elec_res_red(:,ii) = sum(elec_res(:,idx),2);
        end
        dc_exist_red(ii,1) = sum(dc_exist(idx));
        rate_red{ii,1} = rate{idx(1)};
        low_income_red(ii,1) = round(sum(low_income(idx))/length(idx));
        res_units_red(ii,1) = sum(res_units(idx));
        maxpv_red(ii,1) = sum(maxpv(idx));
        
    end
    
%     elec = elec_red;
%     elec_res = elec_res_red;
%     dc_exist = dc_exist_red;
%     rate = rate_red;
%     low_income = low_income_red;
%     res_units = res_units_red;
%     maxpv = maxpv_red;
%     xfmr_subset = xfmrs_loads;

    res_idx = res_units>0;
    %%
    
    %%%Buildings that fall under PBI SGIP program
    sgip_pbi = strcmp(rate,'TOU8') + strcmp(rate,'GS1');
    
    %% Formatting Building Data
    mth = [2];
    bldg_loader_OVMG
    
    %% Determining Resiliency Data for Examination
    crit_load_selection_OVMG    
    
    %% Utility Data
    
    %%%Loading in NEM 3.0 data
    export_energy_credits = xlsread('Export_Energy_Credit_2023.xlsx');
    
    %%%Credit for NEM 3.0 customers
    nem3_0_credit = 0.04;
    nem3_0_credit_low_income = 0.09;
    
    %%%Loading Utility Data and Generating Energy Charge Vectors
    utility_SCE_2023
    
%% Gas Costs - only when a fuel cell is available
ng_cost = (1.*(strcmp(rate,'TOU8') + strcmp(rate,'GS1')) + 1.5.*strcmp(rate,'R1'))./29.3;
% ng_cost = (2/120*105.5 + 0.6)/29.3;
ng_cost = (6/120*105.5 + 0.6)/29.3;
    %% Reducing size for testing
%     time = time(1:endpts(2));
%     elec = elec(1:endpts(2),:);
%     day_multi = day_multi(1:endpts(2),:);
%     endpts = endpts(1:2);
%     datetimev = datetimev(1:endpts(2),:);
%     import_price = import_price(1:endpts(2),:);
%     export_price = export_price(1:endpts(2),:);
%     solar = solar(1:endpts(2),:);
%     sgip_signal = sgip_signal(1:endpts(2),:);
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
%         opt_var_cf_resiliency %%%Added NEM and wholesale export to the PV Section
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
        % return
        %% Different Forms of Resiliency
        fprintf('%s: Resileincy Varaibles and Objective Funciton.', datestr(now,'HH:MM:SS'))
        tic
        opt_resiliency_model_1 %%%Added NEM and wholesale export to the PV Section
        opt_resiliency_model_2
        opt_resiliency_model_3
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
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
        %% Utility Constraints
        fprintf('%s: Electric Utility Constraints.', datestr(now,'HH:MM:SS'))
         tic
        opt_elec_utility
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
         %% DGL Constraints
        fprintf('%s: DGL Constraints.', datestr(now,'HH:MM:SS'))
        tic
        opt_dgl
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
        %% H2 Storage Constraints
        fprintf('%s: H2 Storage Constraints.', datestr(now,'HH:MM:SS'))
        tic
        opt_h2_storage
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
         %% DGB Constraints
        fprintf('%s: DGB Constraints.', datestr(now,'HH:MM:SS'))
        tic
        opt_dgb
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
         %% DGC Constraints
        fprintf('%s: DGC Constraints.', datestr(now,'HH:MM:SS'))
        tic
        opt_dgc
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
%         opt_resiliency
% opt_resiliency_model_1
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
        
        %% LDN Transformer Constraints
        fprintf('%s: LDN Transformer Constraints.', datestr(now,'HH:MM:SS'))
        tic
%         opt_xfmrs
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
        
        %% LinDistFlow Constraints
        fprintf('%s: LinDistFlow Constraints.', datestr(now,'HH:MM:SS'))
        tic
%         opt_ldf
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
        %% Lower Bounds
        fprintf('%s: Lower Bound Constraints.', datestr(now,'HH:MM:SS'))
        tic
        %         opt_lower_bound
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
        %% Optimize
        fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))
        WHATS_THE_CRITICAL_LOAD = crit_load_lvl
        WHATS_THE_CIRCUIT = sim_idx

        opt

        if strcmp(solution.status,'INF_OR_UNBD')
            bldg_base(bldg_ind(ii)).der_systems = 'INF_OR_UNBD';
            adopted.pv = [adopted.pv  0/0];
            adopted.rees = [adopted.rees 0/0];
            adopted.ees = [adopted.ees 0/0];
            if dgl_on
                adopted.dgl = [adopted.dgl 0/0];
            end
            if h2_storage_on
                adopted.h2es = [adopted.h2es 0/0];
            end
            adopted.mean_elec = [adopted.mean_elec 0/0];
            continue
        end

        %% Timer
        finish = datetime('now') ; totalelapsed = toc(startsim)

        %% Extract Variables
        variable_values_multi_node


    end
%     
%     save(strcat('Sim_',num2str(sim_idx)))
    
    %%
    adopted.pv = [adopted.pv  var_pv.pv_adopt];
    adopted.rees = [adopted.rees var_rees.rees_adopt];
    adopted.ees = [adopted.ees var_ees.ees_adopt];
    adopted.mean_elec = [adopted.mean_elec mean(elec)];

            if dgl_on
                adopted.dgl = [adopted.dgl var_dgl.dg_capacity];
            end
            if h2_storage_on
                adopted.h2es = [adopted.h2es var_h2_storage.capacity];
            end



    npbi_idx = 1;
    pbi_idx = 1;
    eq_idx = 1;
    somah_counter = 1;
    for ii = 1:length(bldg_ind)
        %%%New import/export for each building
        %         bldg(ii).elec_der = [var_util.import(:,ii) - (var_rees.rees_dchrg_nem(:,ii) + var_pv.pv_nem(:,ii))... %%%Net electricity flow
        %             var_util.import(:,ii)... %%%All imports
        %             (var_rees.rees_dchrg_nem(:,ii) + var_pv.pv_nem(:,ii))]; %%%All Exports


        %%%DER Systems
        bldg_base(bldg_ind(ii)).der_systems.pv_adopt = var_pv.pv_adopt(ii); %%%Adopted solar  (kW)
        if dgl_on
            bldg_base(bldg_ind(ii)).der_systems.dgl_adopt = var_dgl.dg_capacity(ii); %%%Adopted PEMFC  (kW)

            bldg_base(bldg_ind(ii)).der_systems.dgl_ops  = table;
            bldg_base(bldg_ind(ii)).der_systems.dgl_ops.electric_output = var_dgl.dg_elec(:,ii);
        end

        bldg_base(bldg_ind(ii)).der_systems.ees_adopt = var_ees.ees_adopt(ii); %%%Adopted EES  (kWh)
        bldg_base(bldg_ind(ii)).der_systems.rees_adopt = var_rees.rees_adopt(ii); %%%Adopted REES  (kWh)
        
        bldg_base(bldg_ind(ii)).der_systems.utility = table;
        bldg_base(bldg_ind(ii)).der_systems.utility.import = [var_util.import(:,ii) ];
        bldg_base(bldg_ind(ii)).der_systems.utility.export = [ var_util.export(:,ii)];
        bldg_base(bldg_ind(ii)).der_systems.utility_rates = table;
        bldg_base(bldg_ind(ii)).der_systems.utility_rates.import = import_cost(:,ii) ;
        bldg_base(bldg_ind(ii)).der_systems.utility_rates.export = export_value(:,ii) ;
        bldg_base(bldg_ind(ii)).der_systems.pv_ops = table;
        bldg_base(bldg_ind(ii)).der_systems.pv_ops.electric_output = [var_pv.pv_elec(:,ii)];
        bldg_base(bldg_ind(ii)).der_systems.ees_ops = table;
        bldg_base(bldg_ind(ii)).der_systems.ees_ops.soc = var_ees.ees_soc(:,ii);
        bldg_base(bldg_ind(ii)).der_systems.ees_ops.charge = var_ees.ees_chrg(:,ii);
        bldg_base(bldg_ind(ii)).der_systems.ees_ops.discharge = var_ees.ees_dchrg(:,ii);
     
        bldg_base(bldg_ind(ii)).der_systems.rees_ops = table;
        bldg_base(bldg_ind(ii)).der_systems.rees_ops.soc = var_rees.rees_soc(:,ii);
        bldg_base(bldg_ind(ii)).der_systems.rees_ops.charge = var_rees.rees_chrg(:,ii);
        bldg_base(bldg_ind(ii)).der_systems.rees_ops.discharge = var_rees.rees_dchrg(:,ii);
       
        if h2_storage_on
            bldg_base(bldg_ind(ii)).der_systems.h2_storage = var_h2_storage.capacity(ii); %%%Adopted H2 storage capacity  (kWh)
        end
        %%%SGIP Values
        if strcmp(bldg_type(bldg_ind(ii)),'MFm') || strcmp(bldg_type(bldg_ind(ii)),'Single-Family Detached') || strcmp(bldg_type(bldg_ind(ii)),'Residential')
            if low_income(ii) == 1
                bldg_base(bldg_ind(ii)).der_systems.sgip_pbi = [0;0;0];
                bldg_base(bldg_ind(ii)).der_systems.sgip_npbi = 0;
                bldg_base(bldg_ind(ii)).der_systems.sgip_equity = var_sgip.sgip_ees_npbi_equity(eq_idx);
                eq_idx = eq_idx + 1;
            else
                bldg_base(bldg_ind(ii)).der_systems.sgip_pbi = [0;0;0];
                bldg_base(bldg_ind(ii)).der_systems.sgip_npbi = var_sgip.sgip_ees_npbi(npbi_idx);
                bldg_base(bldg_ind(ii)).der_systems.sgip_equity = 0;
                npbi_idx = npbi_idx + 1;
            end
        else
            bldg_base(bldg_ind(ii)).der_systems.sgip_pbi = var_sgip.sgip_ees_pbi(:,pbi_idx);
            bldg_base(bldg_ind(ii)).der_systems.sgip_npbi = 0;
            bldg_base(bldg_ind(ii)).der_systems.sgip_equity = 0;
            pbi_idx = pbi_idx + 1;
        end

        if opt_resiliency_model >= 0
            if opt_resiliency_model >= 1
bldg_base(bldg_ind(ii)).der_systems.resiliency = table;
bldg_base(bldg_ind(ii)).der_systems.resiliency.load = elec_res(T_res(1):T_res(2),ii);
bldg_base(bldg_ind(ii)).der_systems.resiliency.pv_elec = var_resiliency.pv_elec(:,ii);
bldg_base(bldg_ind(ii)).der_systems.resiliency.ees_chrg = var_resiliency.ees_chrg(:,ii);
bldg_base(bldg_ind(ii)).der_systems.resiliency.ees_dchrg = var_resiliency.ees_dchrg(:,ii);
bldg_base(bldg_ind(ii)).der_systems.resiliency.ees_soc = var_resiliency.ees_soc(:,ii);
bldg_base(bldg_ind(ii)).der_systems.resiliency.dg_elec = var_resiliency.dg_elec(:,ii);

if opt_resiliency_model == 2 || opt_resiliency_model == 3
bldg_base(bldg_ind(ii)).der_systems.resiliency.import = var_resiliency.import(:,ii);
bldg_base(bldg_ind(ii)).der_systems.resiliency.exportc = var_resiliency.export(:,ii);
end

            end
        end


        if low_income(ii) == 1
            bldg_base(bldg_ind(ii)).der_systems.somah = var_somah.somah_capacity(somah_counter);
            somah_counter = somah_counter + 1;
        end

        bldg_base(bldg_ind(ii)).der_systems.cap_mods = [pv_cap_mod(ii) ees_cap_mod(ii) rees_cap_mod(ii)];
    end
    
    %% recording resiliency results
    if opt_resiliency_model >= 3 && acpf_sim == 1
%         save(strcat(scenario,'_',num2str(sim_idx),'_CriticalLoad_Island_formation_',num2str(crit_load_lvl)),'var_resiliency')
%         save(strcat(scenario,'_',num2str(sim_idx),'_wout_pump_CL_',num2str(crit_load_lvl)))
        
    end
end

%% Update Utility Costs
% OVMG_updated_utility_costs

% save(strcat(scenario,'_',num2str(WHATS_THE_CRITICAL_LOAD)))

%% Saving Data
bldg = bldg_base;

% if isempty(crit_load_lvl) || crit_load_lvl == 0
%     save_here = 1
if crit_load_lvl ==0
%     save(strcat(sc_txt,'_DER_no_export_limit'),'bldg')
    save(strcat(sc_txt,'_DER_baseline'),'bldg')
elseif opt_resiliency_model == 1
    save(strcat(sc_txt,'_DER_bldg_nanogrid'),'bldg')
elseif opt_resiliency_model == 2
    save(strcat(sc_txt,'_DER_bldg_xfmr_microgrid'),'bldg')
elseif opt_resiliency_model == 3
    save(strcat(sc_txt,'_DER_bldg_microgrid'),'bldg')
end
% else
%     save_here = 2
%     save(strcat(sc_txt,'_DER_Crit_Load_Circuit_Island_Formation_',num2str(crit_load_lvl)),'bldg')
% end
end
return
