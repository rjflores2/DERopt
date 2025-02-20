%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;
addpath('H:\_Research_\CEC_OVMG\URBANopt\UO_Processing')
starttime = clock;

for crit_load_lvl = [0]%[0 1 2 3 4 5 6 7];%%[4 5 6 7] %%% Corresponding END around line 500 - after files have been saved
    clearvars -except crit_load_lvl crit_load_lvl started_at startsim starttime
% crit_load_lvl = 5;
% crit_load_lvl = [];
% %%

%% Parameters

%%% opt.m parameters
%%%Choose optimizaiton solver
opt_now = 1; %CPLEX
opt_now_yalmip = 0; %YALMIP

%% Resiliency Simulation level
%%% 1) = at each building
%%% 2) = at the transformer
%%% 3) = at the circuit
sim_lvl = 1;

%% Infrastructure Cosntraints
%%%AC Power Flow Simulation
%%% 1) LinDistFlow
if sim_lvl == 1 || sim_lvl == 3
    acpf_sim = 0;
else
    acpf_sim = 1; %%Turn on for
end
% acpf_sim = [];
%%%Are the transformer limits on or off?
acpf_xfmr_on = 0;

%%%Utility Binary Variables on or off??
util_bin_all_sim_on = 1;

%%% Battery Binary Variables on or off?
ees_bin_on = 1;
%% Downselection of building energy data?
testing = 0;
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
        dgb_on = 1;
        dgl_on = 0;
        h2_storage_on = 0;
    dgc_on = 1;
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


hrs_on = 0;
%% ESA On/Off (opt_var_cf)
esa_on = 1; %Building RAtes are Adjusted for CARE Rates

%% Include Critical Loads
crit_tier = []; %%%Residential Critical Load Requirements (Load Tier)
crit_tier_com = 0.15; %%%Commercial Critical Load Requirements (% of load)crit_load_lvl

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
% addpath(genpath('H:\Matlab_Paths\YALMIP-master'))
addpath(genpath('H:\Matlab_Funcitons\YALMIP-master')) %rjf path

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

scenario = 'baseline_retest_2B_v2' %Baseline Loads!!
% scenario = 'UES_1b'
% scenario = 'ues_1a_v2'
% scenario = 'UES_2b'

fprintf('%s: Loading UO Data.', datestr(now,'HH:MM:SS'))
tic
%%%Loading Data
sc_txt = strcat('H:\_Research_\CEC_OVMG\URBANopt\UO_Results_0.5.x\',scenario);
load(strcat(sc_txt,'.mat'));
% bldg = bldg(1:50);
bldg_base = bldg;
compare = load(strcat('H:\_Research_\CEC_OVMG\URBANopt\UO_Results_0.5.x\',scenario,'.mat'));
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

%% electrical infrastructure links
% elec_infrastructure_OVMG
infrastructure_mapping_OVMG
%% Loops
st_idx = [1 51 101 151 201 251 301];
end_idx = [50 100 150 200 250 300 317];

st_idx = [1:20:301];
end_idx = st_idx + 19;
end_idx(end) = 317;

% st_idx = [1 6 11];
% end_idx = [5 10 15];

st_idx = [1 11 21 31 41];
end_idx = [10 20 30 40 50];


st_idx = [1:2:317];
end_idx = st_idx + 1;

st_idx = [1:317];
end_idx = [1:317];

% st_idx = [3];
% end_idx = [3];
% st_idx = [1:20:311];
% end_idx = st_idx + 19;
% end_idx(end) = 317;

% temp_idx_testing %%%Temporary index tester


adopted.pv = [];
adopted.rees = [];
adopted.ees = [];
adopted.mean_elec = [];
adopted.fval = [];

%% Simulation indicies based on resiliency constraints
if sim_lvl == 1 && ( isempty(acpf_sim) || ~acpf_sim) %%%If resiliency is examined per building and no linearized ACPF/infrastructure constraints are implemented 
    sim_end = length(st_idx);
elseif sim_lvl == 2 |  ((~acpf_sim | isempty(acpf_sim)) & xfmr_on) %%%If resiliency is examined at each transformer, OR only xfmr constraints are implemented
    sim_end = length(xfmrs_unique);
elseif sim_lvl == 3 & acpf_sim %%%If resiliency is examined on each individual branch OR ACPF is implemented
    xfmr_2_circuit = readtable('H:\_Tools_\DERopt\Data\OVMG_Inputs\OV_Distribtuion_Circuit_Xfmrs.xlsx');
    %%%Temp hard coding of transformers
    sheets = {'Sm1','Sm2','Sm3','Sm4','Sm5','Sm6','St1'};
    sim_end = width(xfmr_2_circuit) - 1;
end

%%
bldg_bin_off = [97 98 99 100 103 104 174 231 243];

for sim_idx = 1:sim_end
    
    
   %% Building indicies in the current simulation
    if sim_lvl == 1 && ( isempty(acpf_sim) || ~acpf_sim)
        bldg_ind = [st_idx(sim_idx):end_idx(sim_idx)];
%         bldg_ind = [11:20];

    elseif sim_lvl == 2  && (acpf_sim == 0 || isempty(acpf_sim))
        bldg_ind = find(strcmp(xfmrs_unique(sim_idx),xfmr_map));
        xfmrs = xfmrs_unique(sim_idx);
    elseif sim_lvl == 3 && acpf_sim > 0
        %%%Transformers in the current circuit branch
        xfmrs = table2cell(xfmr_2_circuit(:,sim_idx + 1));
        xfmrs = xfmrs( ~strcmp(xfmrs,''));
        %%%Finding building indicies
        bldg_ind = [];
        for kk = 1:length(xfmrs)
            find(strcmp(xfmrs(kk),xfmr_map))
            bldg_ind = [bldg_ind
                find(strcmp(xfmrs(kk),xfmr_map))];
        end
    end
    
    if sum(ismember(bldg_ind , bldg_bin_off)) || util_bin_all_sim_on == 0
        util_bin_on = 0
    else
        util_bin_on = 1
    end
    %%
    clear bldg
    bldg = bldg_base;
    
    %% Loadings relevant circuit data
    if ~isempty(acpf_sim) && (acpf_sim == 1 || sim_lvl >= 3)
        %%Branch/Bus matrix
        [branch_bus,bb_lbl] = xlsread('OV_Branch_bus_Matricies.xlsx',char(sheets(sim_idx)));
        %%% Eliminating NaN in branch bus matrix
        branch_bus(isnan(branch_bus)) = 0;
        %%%Transformer labels included in current power flow
        bb_lbl = bb_lbl(1,2:end)
        
        %%%Circuit properties
        reactance = [];
        reactance = xlsread('OV_Line_Properties.xlsx',strcat(char(sheets(sim_idx)),'_Reactance'));
        reactance(isnan(reactance)) = 0;
        resistance = [];
        resistance = xlsread('OV_Line_Properties.xlsx',strcat(char(sheets(sim_idx)),'_Resistance'));
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
    
    %%%Loading in NEM 3.0 data
    export_energy_credits = xlsread('Export_Energy_Credit_2024.xlsx');
    
    %%%Credit for NEM 3.0 customers
    nem3_0_credit = 0.04;
    nem3_0_credit_low_income = 0.09;
    
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
        
    
    %% Reducing scope for simulation
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
        xfmr_subset = xfmr_map(bldg_ind);
    end
    
    %%%Buildings that fall under PBI SGIP program
    sgip_pbi = strcmp(rate,'TOU8') + strcmp(rate,'GS1');
    
    %% Formatting Building Data
    bldg_loader_OVMG
    
    %% Determining Resiliency Data for Examination
    crit_load_selection_OVMG    
    
    %% Utility Data
    %%%Loading Utility Data and Generating Energy Charge Vectors
    utility_SCE_2023
    %% Gas Costs - only when a fuel cell is available
    ng_cost = (1.*(strcmp(rate,'TOU8') + strcmp(rate,'GS1')) + 1.5.*strcmp(rate,'R1'))./29.3;
    % ng_cost = (2/120*105.5 + 0.6)/29.3;
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
        opt_lower_bound
        elapsed = toc;
        fprintf('Took %.2f seconds \n', elapsed)
        %% Optimize
        
        fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))
        WHATS_THE_CRITICAL_LOAD = crit_load_lvl
        WHATS_THE_CIRCUIT = sim_idx
        opt
        
        %% Timer
        finish = datetime('now') ; totalelapsed = toc(startsim)
        
        %% Extract Variables
        variable_values_multi_node
         
    end
    pv_size = var_pv.pv_adopt
    rees_size = var_rees.rees_adopt
% butthole
%     save(strcat('Sim_',num2str(sim_idx)))
ind = 1;
outlet = [var_util.import(:,ind) ...
    var_util.export(:,ind) ...
    var_pv.pv_elec(:,ind) ...
    var_rees.rees_dchrg(:,ind) + var_ees.ees_dchrg(:,ind) ...
    elec(:,ind) ...
    var_rees.rees_dchrg(:,ind)  + var_ees.ees_dchrg(:,ind)...
    var_rees.rees_chrg(:,ind) + var_ees.ees_chrg(:,ind) ...
    var_rees.rees_soc(:,ind) + var_ees.ees_soc(:,ind) ...
    var_pv.pv_adopt(ind).*solar];


    %%
    adopted.pv = [adopted.pv  var_pv.pv_adopt];
    adopted.rees = [adopted.rees var_rees.rees_adopt];
    adopted.ees = [adopted.ees var_ees.ees_adopt];
    adopted.mean_elec = [adopted.mean_elec mean(elec)];
    adopted.fval = [adopted.fval solution.objval];
    
    
    
    npbi_idx = 1;
    pbi_idx = 1;
    eq_idx = 1;
    for ii = 1:length(bldg_ind)
        %%%New import/export for each building
        bldg(ii).elec_der = [var_util.import(:,ii) - var_util.export(:,ii)... %%%Net electricity flow
            var_util.import(:,ii)... %%%All imports
            var_util.export(:,ii)]; %%%All Exports
        
        
        %%%DER Systems
        bldg_base(bldg_ind(ii)).der_systems.pv_adopt = var_pv.pv_adopt(ii); %%%Adopted solar  (kW)
        bldg_base(bldg_ind(ii)).der_systems.ees_adopt = var_ees.ees_adopt(ii); %%%Adopted EES  (kWh)
        bldg_base(bldg_ind(ii)).der_systems.rees_adopt = var_rees.rees_adopt(ii); %%%Adopted REES  (kWh)
        
        bldg_base(bldg_ind(ii)).der_systems.import = [var_util.import(:,ii) var_util.export(:,ii)];
        bldg_base(bldg_ind(ii)).der_systems.pv_ops = [var_pv.pv_elec(:,ii)];
        bldg_base(bldg_ind(ii)).der_systems.ees_ops = [var_ees.ees_soc(:,ii) var_ees.ees_chrg(:,ii) var_ees.ees_dchrg(:,ii)];
        bldg_base(bldg_ind(ii)).der_systems.rees_ops = [var_rees.rees_soc(:,ii) var_rees.rees_chrg(:,ii) var_rees.rees_dchrg(:,ii) ];
        
        
        %%%SGIP Values
        if strcmp(bldg_type(bldg_ind(ii)),'MFm') || strcmp(bldg_type(bldg_ind(ii)),'Single-Family Detached') || strcmp(bldg_type(bldg_ind(ii)),'Residential')
            if low_income(ii) == 1
                bldg_base(bldg_ind(ii)).der_systems.sgip_pbi = [0;0;0];
                bldg_base(bldg_ind(ii)).der_systems.sgip_npbi = 0;
                bldg_base(bldg_ind(ii)).der_systems.sgip_equity = var_sgip.sgip_ees_npbi_equity(eq_idx);
                bldg_base(bldg_ind(ii)).der_systems.somah = var_somah.somah_capacity(eq_idx);
                eq_idx = eq_idx + 1;
            else
                bldg_base(bldg_ind(ii)).der_systems.sgip_pbi = [0;0;0];
                bldg_base(bldg_ind(ii)).der_systems.sgip_npbi = var_sgip.sgip_ees_npbi(npbi_idx);
                bldg_base(bldg_ind(ii)).der_systems.sgip_equity = 0;
                bldg_base(bldg_ind(ii)).der_systems.somah = 0;
                npbi_idx = npbi_idx + 1;
            end
        else
            bldg_base(bldg_ind(ii)).der_systems.sgip_pbi = var_sgip.sgip_ees_pbi(:,pbi_idx);
            bldg_base(bldg_ind(ii)).der_systems.sgip_npbi = 0;
            bldg_base(bldg_ind(ii)).der_systems.sgip_equity = 0;
            bldg_base(bldg_ind(ii)).der_systems.somah = 0;
            pbi_idx = pbi_idx + 1;
        end
        
        bldg_base(bldg_ind(ii)).der_systems.cap_mods = [pv_cap_mod(ii) ees_cap_mod(ii) rees_cap_mod(ii)];
    end
    
    %% recording resiliency results
    if sim_lvl >= 3 && acpf_sim == 1
        save(strcat(scenario,'_',num2str(sim_idx),'_CriticalLoad_',num2str(crit_load_lvl)),'var_resiliency')
        
    end
end

%% Update Utility Costs
% OVMG_updated_utility_costs

% save(strcat(scenario,'_',num2str(WHATS_THE_CRITICAL_LOAD)))

%% Saving Data
bldg = bldg_base;

if isempty(crit_load_lvl) || crit_load_lvl == 0
    save_here = 1
    save(strcat(sc_txt,'_DER'),'bldg')
else
    save_here = 2
    save(strcat(sc_txt,'_DER_Crit_Load_Circuit3_',num2str(crit_load_lvl)),'bldg')
end
end
finishtime = clock-starttime;
return
