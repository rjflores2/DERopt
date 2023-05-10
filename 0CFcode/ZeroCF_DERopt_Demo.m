
%%                 ZERO CARBON FUTURE
%
%%              DER Optimizer Demonstration
%
%   New complete demo script file (prior to coding App)
%
%   Created: May 3rd 2023
%
%   Last Modified: May 10th 2023
%

clear;
close all;
clc;

%% Select which computer your are running this script
demo_files_location = 1;    % 1 - Robert's PC
                            % 2 - Roman's Laptop
                            % 3 - Roman's Desktop


%% Define all default configuration values (idem manual UI app)

% Baseline CO2 emissions [kg]
configurationData.co2_baseline_emissions_kg = [];

% Desired reduction
%configurationData.co2_desired_amount_reduction = [0:0.05:.5];
%configurationData.co2_desired_amount_reduction = [0 0.05];
configurationData.co2_desired_amount_reduction = 0;

% Building DataValues to filter data by
configurationData.month_idx = [1 4 7 10];
configurationData.year_idx = 2018;


% Demo files location
if demo_files_location == 1       % 1 - Robert's PC

    configurationData.files_path = 'H:\_Tools_';
    configurationData.data_path = 'H:\Data\UCI';
    configurationData.results_path = 'H:\_Tools_\UCI_Results\Sc19';

    configurationData.yalmip_master_path = 'H:\Matlab_Paths\YALMIP-master';
    configurationData.matlab_path = 'C:\Program Files\MATLAB\R2014b\YALMIP-master';


elseif demo_files_location == 2   % 2 - Roman's Laptop

    configurationData.files_path = 'C:\MotusVentures\DERopt';
    configurationData.data_path = 'C:\MotusVentures\DERopt\Data';
    configurationData.results_path = 'C:\MotusVentures\DERopt\SolveResults';

    configurationData.yalmip_master_path = 'C:\MotusVentures\YALMIP-master';
    configurationData.matlab_path = 'C:\Program Files\MATLAB\R2023a\YALMIP-master';


else                                % 3 - Roman's Desktop

    configurationData.files_path = 'E:\MotusVentures\DERopt';
    configurationData.data_path = 'E:\MotusVentures\DERopt\Data';
    configurationData.results_path = 'E:\MotusVentures\DERopt\SolveResults';

    configurationData.yalmip_master_path = 'C:\MotusVentures\YALMIP-master';
    configurationData.matlab_path = 'C:\Program Files\MATLAB\R2023a\YALMIP-master';

end


%%-------------------------------------------------------------------------
%--------------------------------------------------------------------------
%%          OTHER PARAMETERS CONFIGURATION       
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

    % Baseline CO2 emissions
    co2_base = configurationData.co2_baseline_emissions_kg;

    % Desired reduction
    co2_red = configurationData.co2_desired_amount_reduction;

    % Files paths
    demo_files_path = configurationData.files_path;
    demo_data_path = configurationData.data_path;
    yalmip_master_path = configurationData.yalmip_master_path;
    matlab_path = configurationData.matlab_path;
    results_path = configurationData.results_path;


    % Building Data Values to filter data by
    year_idx = configurationData.year_idx;
    month_idx = configurationData.month_idx;



%%-------------------------------------------------------------------------
%--------------------------------------------------------------------------
%%          OTHER PARAMETERS CONFIGURATION       
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------


% Optimize chiller plant operation
chiller_plant_opt = 0;

%% Dummy Variables
elec_dump = [];         %Variable to "dump" electricity

%% Adoptable technologies toggles (opt_var_cf.m and tech_select.m)
utility_exists = 1; % Utility access
pv_on = 1;          %Turn on PV
ees_on = 1;         %Turn on EES/REES
rees_on = 1;        %Turn on REES

%% Community/Utility Scale systems
util_solar_on = 0;
util_wind_on = 0;
util_ees_on = 0;
util_el_on = 0;
util_h2_inject_on = 0;

%% Hydrogen technologies
el_on = 1; %Turn on generic electrolyer
rel_on = 1; %Turn on renewable tied electrolyzer
h2es_on = 1; %Hydrogen energy storage
hrs_on = 0; %Turn on hydrogen fueling station
h2_inject_on = 0; %Turn on H2 injection into pipeline

%% Legacy System Toggles
lpv_on = 1; %Turn on legacy PV
lees_on = 1; %Legacy EES
ltes_on = 1; %Legacy TES
ldg_on = 1; %Turn on legacy GT
lbot_on = 0; %Turn on legacy bottoming cycle / Steam turbine
lhr_on = 0; %Legacy HR
ldb_on = 0; %Legacy Duct Burner
lboil_on = 0; %Legacy boilers

%% Utility PV Solar
util_pv_wheel = 0; %General Wheeling Capabilities
util_pv_wheel_lts = 0; %Wheeling for long term storage
util_pp_import = 0; %Can import power at power plant node
util_pp_export = 0; %Can import power at power plant node

%% Utility H2 production
util_h2_sale = 0;
util_h2_pipe_store = 0;

%% Strict storage design
strict_h2es = 0;

%% Legacy Generator Options
ldg_op_state = 0; %%%Generator can turn on/off
lbot_op_state = 0; %%%Steam turbine can turn on/off

%% Gas turbine cycling costs
dg_legacy_cyc = 1;

%% H2 fuel limit in legacy generator
% Used in opt_gen_inequalities
h2_fuel_limit = 1;          %0.1; %%%Fuel limit on an energy basis - should be 0.1

%% Island operation (opt_nem.m)

%%%Electric rates for UCI
%%% 1: current rate, which does not value export
%%% 2: current import rate + LMP export rate
%%% 3: LMP Rate + 0.2 and LMP Export
uci_rate = 3;

island = 0;

%%%Toggles NEM/Wholesale export (1 = on, 0 = off)
export_on = 0; %%%Tied to PV and REES export under current utility rates (opt_PV, opt_ees)

%%%General export
gen_export_on = 0; %%%Placed a "general export" capability in the general electrical energy equality system (opt_gen_equalities)

%% Fuel Related Toggles

%%%Available biogas/renewable gas per year (biogas limit is prorated in the model to the simulation period)
%%%Used in opt_gen_inequalities
% biogas_limit = 491265*293.1; %%%kWh - biofuel availabe per year - based on Matt Gudorff emails/pptx
biogas_limit = 0;

%%%Required fuel input
%%%Used in opt_gen_inequalities
h2_fuel_forced_fraction = []; %%%Energy fuel requirements

%% Turning incentives and other financial tools on/off
sgip_on = 0;

%% Throughput requirement - DOE H2 Integration
h2_charging_rec = []; %Required throughput per day

%% PV (opt_pv.m)
%%%maxpv is maximum capacity that can be installed. If includes different
%%%orientations, set maxpv to row vector: for example maxpv =
%%%[max_north_capacity  max_east/west_capacity  max_flat_capacity  max_south_capacity]
maxpv = 300000;% ; %%%Maxpv
toolittle_pv = 0; %%% Forces solar PV adoption - value is defined by toolittle_pv value - kW
curtail = 0; %%%Allows curtailment is = 1

%% EES (opt_ees.m & opt_rees.m)
toolittle_storage = 1; %%%Forces EES adoption - 13.5 kWh
socc = 0; % SOC constraint: for each individual ees and rees, final SOC >= Initial SOC

%% Grid limits
%%% On/Off Grid Import Limit
grid_import_on = 1;
%%%Limit on grid import power
import_limit = .6;

rate = {'TOU8'};
rate_labels = {'TOU8'};

%%% Placeholders
dc_exist = 1;
low_income = 0;
sgip_pbi = 1;
res_units = 0;


%%  Fixed Cost Defines

% T&D charge ($/kWh)
t_and_d = 0.01;

% Placeholder natural gas cost
ng_cost = 0.5/29.3; %$/kWh --> Converted from $/therm to $/kWh, 29.3 kWh / 1 Therm
% rng_cost = 3/29.3;
rng_cost = 2.*ng_cost;
% rng_cost = 3;
rng_storage_cost = 0.2/29.3;
ng_inject = 0.05/29.3; %$/kWh --> Converted from $/therm to $/kWh, 29.3 kWh / 1 Therm

%%%Including Required Return with Capital Payment (1 = Yes)
req_return_on = 1;

onoff_model = 1;



%% Adding paths
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%%%YALMIP Master Path
addpath(genpath(yalmip_master_path)) %rjf path
addpath(genpath(matlab_path)) %cyc path

%%%CPLEX Path
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64')) %rjf path
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio1263\cplex\matlab\x64_win64')) %cyc path

%%%DERopt paths
addpath(genpath(append(demo_files_path, '\0CFcode')))
addpath(genpath(append(demo_files_path, '\Classes')))
addpath(genpath(append(demo_files_path, '\Data')))
addpath(genpath(append(demo_files_path, '\Problem_Formulation_Single_Node')))


%%-------------------------------------------------------------------------
%--------------------------------------------------------------------------
%%                  START SIMULATION
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

startsim = tic;
fprintf('%s: START SIMULATION \n', datetime("now","InputFormat",'HH:MM:SS'))

bldgData = CBuildingDataManager("UCI Labs");

if bldgData.LoadData(append(demo_data_path, '\Campus_Loads_2014_2019.mat'), chiller_plant_opt)

    bldgData.FormatData(month_idx, year_idx, demo_data_path, util_solar_on, util_wind_on, hrs_on);
    
else

    % TODO: stop... couldn't load data!

end

% CO2 Toggles ??
if isempty(co2_base)
    co2_base = bldgData.EstimateBaseCO2Emissions();
end

% Setting up the first CO2 limit
co2_lim = co2_base*(1-co2_red(1));


%% Utility Data
%--------------------------------------------------------------------------
% Loading Utility Data and Generating Energy Charge Vectors
%--------------------------------------------------------------------------

utilInfo = CUtilityInfo(uci_rate, export_on, gen_export_on, bldgData.lmp_uci, bldgData.GetElecLen());


%% Technology Parameters/Costs
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
techSelOnSite = CTechnologySelection();

techSelOnSite.CalculateAllParams(pv_on, ees_on, el_on, h2es_on, rel_on, hrs_on, h2_inject_on);

% Erase Later...
pv_v = techSelOnSite.pv_v;
ees_v = techSelOnSite.ees_v;
el_v = techSelOnSite.el_v;
h2es_v = techSelOnSite.h2es_v;
rel_v = techSelOnSite.rel_v;



%% Technology Parameters/Costs for offsite resources
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
techSelOffSite = CTechnologySelectionOffSite();

techSelOffSite.CalculateAllParams(util_solar_on, util_wind_on, util_ees_on, util_el_on, util_h2_inject_on);



%% Capital Cost Modifications
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
capCostMods = CCapitalCostCalculator(0.08, 10, req_return_on);

capCostMods.DebtPaymentsFullCostSystem(techSelOnSite.pv_v, techSelOnSite.ees_v, techSelOnSite.el_v, ...
                                        techSelOnSite.rel_v, techSelOnSite.h2es_v, techSelOnSite.hrs_v, techSelOnSite.h2_inject_v,...
                                        techSelOffSite.utilpv_v, techSelOffSite.util_wind_v, techSelOffSite.util_ees_v, ...
                                        util_el_on, techSelOffSite.util_h2_inject_v, rees_on)

capCostMods.ConvertIncentivesToReductions(techSelOnSite.sgip, techSelOnSite.ees_v)

capCostMods.CalcCostScalars_SolarPV(techSelOnSite.pv_v, techSelOnSite.pv_fin, techSelOnSite.somah, bldgData.elec, maxpv, low_income)
capCostMods.CalcCostScalars_EES(techSelOnSite.ees_v, techSelOnSite.ees_fin, techSelOnSite.rees_fin, techSelOnSite.pv_v, bldgData.elec, maxpv, rees_on)
capCostMods.CalcCostScalars_Electrolizer(techSelOnSite.el_v, techSelOnSite.el_fin, bldgData.elec, h2_fuel_forced_fraction, low_income, bldgData.e_adjust)
capCostMods.CalcCostScalars_RenewableElectrolizer(techSelOnSite.rel_v, techSelOnSite.rel_fin, bldgData.elec, h2_fuel_forced_fraction, low_income, bldgData.e_adjust)

capCostMods.CalcCostScalars_UtilityScaleSolarPV(techSelOffSite.utilpv_v, techSelOffSite.utilpv_fin, bldgData.elec, techSelOnSite.somah, low_income)
capCostMods.CalcCostScalars_UtilityScaleWind(techSelOffSite.util_wind_v, techSelOffSite.util_wind_fin, bldgData.elec, techSelOnSite.somah)
capCostMods.CalcCostScalars_UtilityScaleBatteryStorage(techSelOffSite.util_ees_v, techSelOffSite.util_ees_fin, bldgData.elec, techSelOnSite.somah)
capCostMods.CalcCostScalars_UtilityScaleElectrolyzer(techSelOffSite.util_el_v, techSelOffSite.util_el_fin, bldgData.elec)



%% Legacy Technologies
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
legacyTech = CLegacyTechnologies(lpv_on, ldg_on, lbot_on, lhr_on, ldb_on, lboil_on, lees_on, ltes_on, dg_legacy_cyc);
dg_legacy_cyc = legacyTech.updatedDgLegacyCyc;

% Erase Later...

ees_legacy = legacyTech.ees_legacy;




%% Plotting loads & Costs for demo purpose
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% %%% 'Electric Demand (MW)'
% figure
% hold on
% plot(time,elec.*4./1000,'LineWidth',2)
% set(gca,'XTick',round(time(1),0)+.5:round(time(end),0)+.5,'FontSize',14)
% box on
% grid on
% datetick('x','ddd','keepticks')
% xlim([time(stpts(3)) time(stpts(3)+96*7)])
% ylabel('Electric Demand (MW)','FontSize',18)
% set(gcf,'Position',[100 450 500 275])
% hold off
% 
% %%% 'Electric Price ($/kWh)'
% figure
% hold on
% plot(time,utilInfo.importPrice,'LineWidth',2)
% %plot(time,import_price,'LineWidth',2)
% set(gca,'XTick',round(time(1),0)+.5:round(time(end),0)+.5,'FontSize',14)
% box on
% grid on
% datetick('x','ddd','keepticks')
% xlim([time(stpts(3)) time(stpts(3)+96*7)])
% ylabel('Electric Price ($/kWh)','FontSize',18)
% set(gcf,'Position',[100 100 500 275])
% hold off
% 
% %%% 'Solar Potential (kW/m^2)'
% figure
% hold on
% plot(time,bdf.solar,'LineWidth',2)
% %plot(time,solar,'LineWidth',2)
% set(gca,'XTick',round(time(1),0)+.5:round(time(end),0)+.5,'FontSize',14)
% box on
% grid on
% datetick('x','ddd','keepticks')
% xlim([time(stpts(3)) time(stpts(3)+96*7)])
% ylabel('Solar Potential (kW/m^2)','FontSize',18)
% set(gcf,'Position',[650 100 500 275])
% hold off
% 
% close all


%% Setting up variables and cost function
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
fprintf('%s: Objective Function.', datetime("now","InputFormat",'HH:MM:SS'))
tic

modelVars = CModelVariables(bldgData.GetTimeLen(), bldgData.GetEndPointsLen());

% On Site

modelVars.SetupUtilityElectricity(utility_exists, dc_exist, bldgData.day_multi, utilInfo)
modelVars.SetupGeneralExport(gen_export_on, utilInfo)

% Added NEM and wholesale export to the PV Section
modelVars.SetupSolarPV(utility_exists, export_on, rees_on, island, bldgData.day_multi, techSelOnSite, utilInfo, capCostMods)
modelVars.SetupElectricalEnergyStorage(sgip_on, bldgData.day_multi, techSelOnSite, capCostMods)
modelVars.SetupRenewableElectrolyzer(util_pv_wheel_lts, strict_h2es, techSelOnSite.rel_v, techSelOnSite.el_v, techSelOnSite.h2es_v, capCostMods)
modelVars.SetupH2ProductionAndStorage(util_pv_wheel_lts, strict_h2es, techSelOnSite.el_v, techSelOnSite.h2es_v, capCostMods)
modelVars.SetupHRSEquipment(hrs_on, techSelOnSite.hrs_v, capCostMods)
modelVars.SetupH2PipelineInjection(h2_inject_on, ng_inject, rng_storage_cost, capCostMods)
modelVars.SetupLegacyPv(island, export_on, bldgData.day_multi, legacyTech.pv_legacy, techSelOnSite.pv_v, utilInfo)
modelVars.SetupLegacyGenerator(h2_inject_on, util_h2_inject_on, ldg_op_state, legacyTech.dg_legacy, dg_legacy_cyc, techSelOnSite.el_v, techSelOnSite.rel_v, ng_cost, rng_cost)
modelVars.SetupLegacyBottomingSystems(legacyTech.bot_legacy)
modelVars.SetupLegacyHeatRecovery(legacyTech.dg_legacy, legacyTech.hr_legacy, ng_cost, rng_cost)
modelVars.SetupLegacyBoiler(legacyTech.boil_legacy, ng_cost, rng_cost)
modelVars.SetupLegacyGenericChiller(bldgData.cool, legacyTech.vc_legacy)
modelVars.SetupLegacyEES(bldgData.day_multi, legacyTech.ees_legacy)
modelVars.SetupLegacyColdTES(bldgData.cool, legacyTech.tes_legacy)
modelVars.SetupLegacyChillers(onoff_model, bldgData.cool, legacyTech.vc_legacy)
modelVars.SetupDumpVariables(elec_dump)

fprintf('Took %.2f seconds \n', toc)


% Off Site

%% Setting up variables and cost function for offsite resources
fprintf('%s: Off-site variables.', datetime("now","InputFormat",'HH:MM:SS'))
tic

modelVars.SetupPowerPlantExports(util_solar_on, util_ees_on, util_pp_export, util_pp_import, util_pv_wheel, util_pv_wheel_lts)
modelVars.SetupCommunityScaleSolar(techSelOffSite.utilpv_v)
modelVars.SetupCommunityScaleWind(techSelOffSite.util_wind_v)
modelVars.SetupCommunityScaleStorage(techSelOffSite.util_ees_v)
modelVars.SetupRemoteElectrolyzer(techSelOffSite.util_el_v, bldgData.elec)
modelVars.SetupUtilH2PipelineInjection(util_h2_inject_on)

elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)


%%                  MODEL CONSTRAINTS
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

modelConstraints = CModelConstraints();


%% General Equality Constraints
fprintf('%s: General Equalities.', datetime("now","InputFormat",'HH:MM:SS'))

elapsed = modelConstraints.Calculate_GeneralEquality(onoff_model, modelVars, bldgData.heat, bldgData.cool, bldgData.elec, techSelOnSite.el_v, techSelOnSite.rel_v, hrs_on, util_solar_on, util_ees_on, util_pv_wheel_lts);

fprintf('Took %.2f seconds \n', elapsed)


%% General Inequality Constraints
        
fprintf('%s: General Inequalities. ', datetime("now","InputFormat",'HH:MM:SS'))

elapsed = modelConstraints.Calculate_GeneralInequality(modelVars, bldgData.e_adjust, utility_exists, dc_exist,...
                                                bldgData.endpts, utilInfo.onpeak_index, utilInfo.midpeak_index, export_on, utilInfo.export_price,...
                                                utilInfo.import_price, legacyTech.fac_prop, util_pv_wheel, util_ees_on, util_pp_import,...
                                                h2_fuel_forced_fraction, techSelOnSite.el_v, h2_fuel_limit, ldg_on, co2_lim,...
                                                biogas_limit, h2_charging_rec, gen_export_on, bldgData.co2_import, bldgData.co2_ng, bldgData.co2_rng);

fprintf('Took %.2f seconds \n', elapsed)


%% Heat Recovery Inequality Constraints
fprintf('%s: Heat Recovery Inequalities. ', datetime("now","InputFormat",'HH:MM:SS'))

elapsed = modelConstraints.Calculate_HeatRecoveryInequality(modelVars, legacyTech.dg_legacy, legacyTech.hr_legacy, legacyTech.bot_legacy);
fprintf('Took %.2f seconds \n', elapsed)


%% Legacy DG Constraints
fprintf('%s: Legacy DG Constraints. ', datetime("now","InputFormat",'HH:MM:SS'))

elapsed = modelConstraints.Calculate_LegacyDG(modelVars, legacyTech.dg_legacy, bldgData.e_adjust, dg_legacy_cyc);
fprintf('Took %.2f seconds \n', elapsed)


%% Legacy ST Constraints
fprintf('%s: Legacy ST Constraints. ', datetime("now","InputFormat",'HH:MM:SS'))

elapsed = modelConstraints.Calculate_LegacyST(modelVars, legacyTech.bot_legacy);
fprintf('Took %.2f seconds \n', elapsed)

    
%% Solar PV Constraints
fprintf('%s: PV Constraints.', datetime("now","InputFormat",'HH:MM:SS'))

elapsed = modelConstraints.Calculate_SolarPV(modelVars, techSelOnSite.pv_v, bldgData.solar, legacyTech.pv_legacy, toolittle_pv, maxpv, curtail, bldgData.e_adjust);
fprintf('Took %.2f seconds \n', elapsed)


%% EES Constraints
fprintf('%s: EES Constraints.', datetime("now","InputFormat",'HH:MM:SS'))


Constraints = modelConstraints.Constraints;
T = bldgData.GetTimeLen();
opt_ees_0cf                                         %% URGENT!
modelConstraints.Constraints = Constraints;


%elapsed = modelConstraints.Calculate_EES(modelVars, techSelOnSite.ees_v, techSelOnSite>pv_v, rees_on);
fprintf('Took %.2f seconds \n', elapsed)


%% Legacy EES Constraints
fprintf('%s: Legacy EES Constraints.', datetime("now","InputFormat",'HH:MM:SS'))


Constraints = modelConstraints.Constraints;
opt_ees_legacy_0cf                                  %% URGENT!
modelConstraints.Constraints = Constraints;


%elapsed = modelConstraints.Calculate_LegacyEES(modelVars, legacyTech.ees_legacy);
fprintf('Took %.2f seconds \n', elapsed)


%% Legacy VC Constraints
fprintf('%s: Legacy VC Constraints.', datetime("now","InputFormat",'HH:MM:SS'))

elapsed = modelConstraints.Calculate_LegacyVC(modelVars, onoff_model, bldgData.cool, legacyTech.vc_legacy);
fprintf('Took %.2f seconds \n', elapsed)


%% Legacy TES Constraints
fprintf('%s: Legacy TES Constraints.', datetime("now","InputFormat",'HH:MM:SS'))

elapsed = modelConstraints.Calculate_LegacyTES(modelVars, bldgData.cool, legacyTech.tes_legacy);
fprintf('Took %.2f seconds \n', elapsed)


%% DER Incentives
fprintf('%s: DER Incentives Constraints.', datetime("now","InputFormat",'HH:MM:SS'))

elapsed = modelConstraints.Calculate_DERIncentives(modelVars, techSelOnSite.ees_v, sgip_on);
fprintf('Took %.2f seconds \n', elapsed)


%% H2 production Constraints
fprintf('%s: Electrolyzer and H2 Storage Constraints.', datetime("now","InputFormat",'HH:MM:SS'))


Constraints = modelConstraints.Constraints;
e_adjust = bldgData.e_adjust;
opt_h2_production_0cf                               %% URGENT!
modelConstraints.Constraints = Constraints;


%elapsed = modelConstraints.Calculate_H2production(modelVars, techSelOnSite.el_v, techSelOnSite.rel_v, techSelOnSite.h2es_v, bldgData.e_adjust);
fprintf('Took %.2f seconds \n', elapsed)


%% Utility Solar
fprintf('%s: Utility Scale Solar Constraints.', datetime("now","InputFormat",'HH:MM:SS'))

elapsed = modelConstraints.Calculate_UtilitySolar(modelVars, techSelOffSite.utilpv_v, bldgData.e_adjust);
fprintf('Took %.2f seconds \n', elapsed)


%% Utility Wind
fprintf('%s: Utility Scale Wind Constraints.', datetime("now","InputFormat",'HH:MM:SS'))

elapsed = modelConstraints.Calculate_UtilityWind(modelVars, techSelOffSite.util_wind_v, bldgData.e_adjust);
fprintf('Took %.2f seconds \n', elapsed)


%% Utility EES Storage
fprintf('%s: Utility Scale Battery Storage Constraints.', datetime("now","InputFormat",'HH:MM:SS'))

elapsed = modelConstraints.Calculate_UtilityEESStorage(modelVars, techSelOffSite.util_ees_v);
fprintf('Took %.2f seconds \n', elapsed)


%% Utility Electrolyzer
fprintf('%s: Utility Scale Electrolyzer Constraints.', datetime("now","InputFormat",'HH:MM:SS'))

elapsed = modelConstraints.Calculate_UtilityElectrolyzer(modelVars, techSelOffSite.util_el_v);
fprintf('Took %.2f seconds \n', elapsed)


%% H2 Pipeline Injection
fprintf('%s: H2 Pipeline Injection Constraints.', datetime("now","InputFormat",'HH:MM:SS'))

elapsed = modelConstraints.Calculate_H2PipelineInjection(modelVars, h2_inject_on);
fprintf('Took %.2f seconds \n', elapsed)


    %% Optimize
    fprintf('%s: Optimizing \n....', datetime("now","InputFormat",'HH:MM:SS'))
    
    lanin = CModelSolver;

    %% Export Model
    elapsed = lanin.CreateModel(modelConstraints.Constraints, modelVars.Objective, co2_lim);

    fprintf('Model Export took %.2f seconds \n', elapsed)

    if lanin.SetupFirstSolve(co2_lim, co2_base, sum(bldgData.elec), bldgData.co2_import, bldgData.co2_ng, bldgData.co2_rng)

    end

    %% Loop to rerun optimization

    for ii = 1:length(co2_red)

        fprintf('%s Starting CPLEX Solver \n', datetime("now",'InputFormat','HH:MM:SS'))

        elapsed = lanin.SolveModel(ii, co2_red(ii), modelVars);

        fprintf('CPLEX took %.2f seconds \n', elapsed)


        %% Starting Recorder Structure - Model Outputs
        rec.solver.x(ii,:) = lanin.lastSolveX;
        rec.solver.fval(ii,1) = lanin.lastSolveFval;
        rec.solver.exitflag(ii,1) = lanin.lastSolveExitFlag;
        rec.solver.output(ii,1) = lanin.lastSolveExitFlag;

        %% Optimized Variables -  Utilities

        %%% Utility Variables
        rec.utility.import(:,ii) = lanin.utilityImport;
        rec.utility.nontou_dc(:,ii) = lanin.utilityNontouDc;
        rec.utility.onpeak_dc(:,ii) = lanin.utilityOnpeakDc;
        rec.utility.midpeak_dc(:,ii) = lanin.utilityMidpeakDc;
        rec.utility.gen_export(:,ii) = lanin.utilityGenExport;

        %% Optimized Variables - New Technologies
        %%% Solar Variables
        rec.solar.pv_adopt(:,ii) = lanin.solarPhotoVoltaicAdopt;
        rec.solar.pv_elec(:,ii) = lanin.solarPhotoVoltaicElec;
        rec.solar.pv_nem(:,ii) = lanin.solarPhotoVoltaicNem;

        %%% Electrical Energy Storage
        rec.ees.ees_adopt(:,ii) = lanin.electricalEnergyStorage_adopt;
        rec.ees.ees_chrg(:,ii) = lanin.electricalEnergyStorage_chrg;
        rec.ees.ees_dchrg(:,ii) = lanin.electricalEnergyStorage_dchrg;
        rec.ees.ees_soc(:,ii) = lanin.electricalEnergyStorage_soc;

        %%% Renewable Electrical Energy Storage
        rec.rees.rees_adopt(:,ii) = lanin.renewableElectricalEnergyStorage_adopt;
        rec.rees.rees_chrg(:,ii) = lanin.renewableElectricalEnergyStorage_chrg;
        rec.rees.rees_dchrg(:,ii) = lanin.renewableElectricalEnergyStorage_dchrg;
        rec.rees.rees_soc(:,ii) = lanin.renewableElectricalEnergyStorage_soc;
        rec.rees.rees_dchrg_nem(:,ii) = lanin.renewableElectricalEnergyStorage_dchrg_nem;

        %%% H2 Production - Electrolyzer
        rec.el.el_adopt(:,ii) = lanin.h2ProductionElectrolyzer_adopt;
        rec.el.el_prod(:,ii) = lanin.h2ProductionElectrolyzer_prod;

        %%% H2 Production - Renewable Electrolyzer
        rec.rel.rel_adopt(:,ii) = lanin.h2ProductionRenewableElectrolyzer_adopt;
        rec.rel.rel_prod(:,ii) = lanin.h2ProductionRenewableElectrolyzer_prod;
        rec.rel.rel_prod_wheel(:,ii) = lanin.h2ProductionRenewableElectrolyzer_prod;

        %%% H2 Production - Storage
        rec.h2es.h2es_adopt(:,ii) = lanin.h2ProductionEnergyStorage_adopt;
        rec.h2es.h2es_chrg(:,ii) = lanin.h2ProductionEnergyStorage_chrg;
        rec.h2es.h2es_dchrg(:,ii) = lanin.h2ProductionEnergyStorage_dchrg;
        rec.h2es.h2es_soc(:,ii) = lanin.h2ProductionEnergyStorage_soc;
        rec.h2es.h2es_bin(:,ii) = lanin.h2ProductionEnergyStorage_bin;

        %% Optimized Variables -  Legacy technologies %%
        %% DG - Topping Cycle
        rec.ldg.ldg_elec(:,ii) = lanin.ldg_elec;
        rec.ldg.ldg_fuel(:,ii) = lanin.ldg_fuel;
        rec.ldg.ldg_rfuel(:,ii) = lanin.ldg_rfuel;
        rec.ldg.ldg_hfuel(:,ii) = lanin.ldg_hfuel;
        rec.ldg.ldg_sfuel(:,ii) = lanin.ldg_sfuel;
        rec.ldg.ldg_dfuel(:,ii) = lanin.ldg_dfuel;
        rec.ldg.ldg_elec_ramp(:,ii) = lanin.ldg_elec_ramp;
        % var_ldg.ldg_off(:,ii) = lanin.ldg_off;
        rec.ldg.ldg_opstate(:,ii) = lanin.ldg_opstate;
        %% Bottoming Cycle
        rec.lbot.lbot_elec(:,ii) = lanin.lbot_elec;
        rec.lbot.lbot_on(:,ii) = lanin.lbot_on;

        %% Heat Recovery Systems
        rec.ldg.hr_heat(:,ii) = lanin.ldg_hr_heat;
        rec.ldg.db_fire(:,ii) = lanin.ldg_db_fire;
        rec.ldg.db_rfire(:,ii) = lanin.ldg_db_rfire;
        rec.ldg.db_hfire(:,ii) = lanin.ldg_db_hfire;

        %% Boiler
        rec.boil.boil_fuel(:,ii) = lanin.boiler_fuel;
        rec.boil.boil_rfuel(:,ii) = lanin.boiler_rfuel;
        rec.boil.boil_hfuel(:,ii) = lanin.boiler_hfuel;

        %% EES
        if ~isempty(ees_legacy)
            rec.lees.ees_chrg(:,ii) = lanin.lees_chrg;
            rec.lees.ees_dchrg(:,ii) = lanin.lees_dchrg;
            rec.lees.ees_soc(:,ii) = lanin.lees_soc;
        end

        %% Carbon Emissions
        % Carbon emissions from 1) utility electiricity, 2) natural gas, 3) renewable natural gas
        rec.co2_emissions(1,ii) = lanin.co2EmissionsUtilityElect;
        rec.co2_emissions(2,ii) = lanin.co2EmissionsNaturalGas;
        rec.co2_emissions(3,ii) = lanin.co2EmissionsRenewableNaturalGas;

        % Total carbon emissions
        rec.co2_emissions(4,ii) =   lanin.co2TotalEmissions;

        % Percent reduction
        rec.co2_emissions_red(1,ii) = lanin.co2EmissionsReductionPercentaje;

        %% Financials
        %%%($/kWh)
        rec.financials.lcoe(ii,1) = lanin.levelizedCostOfElectricityInKWh;

        %%%Bulk cost of carbon ($/tonne)
        rec.financials.cost_of_co2(ii,1) = lanin.BulkCostOfCarbonByTonne;

        %%%Marginal cost of carbon ($/tonne)
        if ii > 1
            rec.financials.cost_of_co2_marginal(ii,1) = abs((rec.solver.fval(ii,1) - rec.solver.fval(ii-1,1))/((rec.co2_emissions(4,ii) - rec.co2_emissions(4,ii-1))./1000));
        else 
            rec.financials.cost_of_co2_marginal(ii,1) = NaN;
        end

        %%%Capital Cost Requirements
        rec.financials.cap_cost(ii,:) = [lanin.solarPhotoVoltaicAdopt.*techSelOnSite.pv_cap*capCostMods.pv_cap_mod
                                        lanin.electricalEnergyStorage_adopt.*techSelOnSite.ees_cap.*capCostMods.ees_cap_mod
                                        lanin.renewableElectricalEnergyStorage_adopt.*techSelOnSite.ees_cap.*capCostMods.rees_cap_mod
                                        lanin.h2ProductionElectrolyzer_adopt.*techSelOnSite.el_cap.*capCostMods.el_cap_mod
                                        lanin.h2ProductionRenewableElectrolyzer_adopt.*techSelOnSite.el_cap.*capCostMods.rel_cap_mod
                                        lanin.h2ProductionEnergyStorage_adopt.*techSelOnSite.h2es_cap];

    end



%% Add local variables Results
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

rec.el_eff = modelVars.el_eff;
rec.rel_eff = modelVars.rel_eff;
rec.h2_chrg_eff = modelVars.h2_chrg_eff;
rec.time = bldgData.time;
rec.elec = bldgData.elec;
rec.stpts = bldgData.stpts;


%% SAVE Resuts to file
% save(strcat(results_path,'\deropt_results.mat'), "rec")



% Timer
finish = datetime('now') ; totalelapsed = toc(startsim);

optRec = rec;



%%        SHOW RESULTS (Plot data)
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%%% Plot 'LCOE ($/kWh)'
figure
hold on
plot(optRec.co2_emissions_red,optRec.financials.lcoe,'LineWidth',2)
box on
grid on
ylabel('LCOE ($/kWh)','FontSize',18)
xlabel('CO_2 Reduction (%)','FontSize',18)
set(gcf,'Position',[100 100 500 275])
xlim([0 50])
hold off
    
        
%%% Plot 'Cost of Carbon'
close all
figure
hold on
plot(optRec.co2_emissions_red,optRec.financials.cost_of_co2,'LineWidth',2)
plot(optRec.co2_emissions_red,optRec.financials.cost_of_co2_marginal,'LineWidth',2)
box on
grid on
ylabel('Cost of CO_2 ($/tonne)','FontSize',18)
xlabel('CO_2 Reduction (%)','FontSize',18)
set(gcf,'Position',[100 100 500 275])
xlim([5 50])
legend('Average Cost','Marginal Cost','Location','NorthWest')
hold off


%%% Plot 'Capital Requirements'
close all
figure
hold on
plot(optRec.co2_emissions_red,sum(optRec.financials.cap_cost,2)./1000000,'LineWidth',2)
% plot(optRec.co2_emissions_red,optRec.financials.cost_of_co2_marginal,'LineWidth',2)
box on
grid on
ylabel('Capital Cost ($MM)','FontSize',18)
xlabel('CO_2 Reduction (%)','FontSize',18)
set(gcf,'Position',[100 100 500 275])
xlim([5 50])
% legend('Average Cost','Marginal Cost','Location','NorthWest')
hold off


%%% Dispatch Plots
close all
idx = 1;
    
dt1 = [sum(optRec.ldg.ldg_elec(:,idx),2)...
        sum(optRec.utility.import(:,idx),2)...
        sum(optRec.solar.pv_elec(:,idx),2) + sum(optRec.rees.rees_chrg(:,idx),2)...
        sum(optRec.ees.ees_dchrg(:,idx),2) + sum(optRec.rees.rees_dchrg(:,idx),2) + sum(optRec.lees.ees_dchrg(:,idx),2)];
         
dt2 = [optRec.elec ...
        sum(optRec.ees.ees_chrg(:,idx),2) + sum(optRec.lees.ees_chrg(:,idx),2) + sum(optRec.rees.rees_chrg(:,idx),2)...
        sum(optRec.el_eff.*optRec.el.el_prod(:,idx),2) + sum(optRec.h2_chrg_eff.*optRec.h2es.h2es_chrg(:,idx),2) + sum(optRec.rel_eff.*optRec.rel.rel_prod(:,idx),2) ...
        optRec.solar.pv_nem(:,idx)];


%%% Plot 'Electric Sources (MW)'
figure
hold on
area(optRec.time,dt1.*4./1000)
set(gca,'XTick', round(optRec.time(1),0)+.5:round(optRec.time(end),0)+.5,'FontSize',14)
box on
grid on
datetick('x','ddd','keepticks')
xlim([optRec.time(optRec.stpts(3)) optRec.time(optRec.stpts(3)+96*7)])
ylabel('Electric Sources (MW)','FontSize',18)
legend('Gas Turbine','Utility Import','Solar','Battery Discharge','Location','Best')
set(gcf,'Position',[100 450 500 275])
hold off

%%% Plot 'Electric Loads (MW)'
figure
hold on
area(optRec.time,dt2.*4./1000)
set(gca,'XTick', round(optRec.time(1),0)+.5:round(optRec.time(end),0)+.5, 'FontSize',14)
box on
grid on
datetick('x','ddd','keepticks')
xlim([optRec.time(optRec.stpts(3)) optRec.time(optRec.stpts(3)+96*7)])
ylabel('Electric Loads (MW)','FontSize',18)
legend('Campus','Battery Charging','H_2 Production','Export','Location','Best')
set(gcf,'Position',[100 100 500 275])
hold off
