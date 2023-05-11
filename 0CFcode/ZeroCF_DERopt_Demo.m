
%%                 ZERO CARBON FUTURE
%
%%              DER Optimizer Demonstration Script
%
%   New complete demo script file (prior to coding App)
%
%   Created: May 3rd 2023               Version 0.6
%
%   Last Modified: May 11th 2023
%

clear;
close all;
clc;
SetCodePaths(1)                 % 1 - Robert's PC
                                % 2 - Roman's Laptop
                                % 3 - Roman's Desktop



%% Create all default configuration values
cfg = CConfigurationManager();


%% Select which computer your are running this script
cfg.SetRunningEnvironment(1);   % 1 - Robert's PC
                                % 2 - Roman's Laptop
                                % 3 - Roman's Desktop

cfg.AddMatlabPaths()


%% OVERWRITE DEFAULT CONFIGURATION       

cfg.co2_red = [0 0.1 0.2 0.3 0.4 0.5];
%cfg.year_idx = 2018;
%cfg.month_idx = [1 4 7 10];
    




%%  START SIMULATION

startsim = tic;

fprintf('%s: START SIMULATION \n', datetime("now","InputFormat",'HH:MM:SS'))

bldgData = CBuildingDataManager("UCI Labs");

fprintf('%s: Loading Building Data ', datetime("now","InputFormat",'HH:MM:SS'))
tic

if bldgData.LoadData(append(cfg.demo_data_path, '\Campus_Loads_2014_2019.mat'), cfg.chiller_plant_opt)

    fprintf('Took %.3f seconds \n', toc)

    fprintf('%s: Streamlining Building Data ', datetime("now","InputFormat",'HH:MM:SS'))
    tic

    bldgData.FormatData(cfg.month_idx, cfg.year_idx, cfg.demo_data_path, cfg.util_solar_on, cfg.util_wind_on, cfg.hrs_on);

    fprintf('Took %.3f seconds \n', toc)

else

    f = msgbox(append("Could not load Building Data File: ", append(cfg.demo_data_path, '\Campus_Loads_2014_2019.mat')),"0CF DERoptimizer","warn");
    return

end

if isempty(cfg.co2_base)
    cfg.co2_base = bldgData.EstimateBaseCO2Emissions();
end

cfg.SetUpFirstCO2Limit();


%--------------------------------------------------------------------------
% Loading Utility Data and Generating Energy Charge Vectors
%--------------------------------------------------------------------------

fprintf('%s: Loading Utility Data ', datetime("now","InputFormat",'HH:MM:SS'))
tic
utilInfo = CUtilityInfo(cfg.uci_rate, cfg.export_on, cfg.gen_export_on, bldgData.lmp_uci, bldgData.GetElecLen());
fprintf('Took %.3f seconds \n', toc)


%--------------------------------------------------------------------------
% Technology Parameters/Costs
%--------------------------------------------------------------------------

fprintf('%s: Calculating OnSite Technology Parameters & Costs ', datetime("now","InputFormat",'HH:MM:SS'))
tic
techSelOnSite = CTechnologySelection();
techSelOnSite.CalculateAllParams(cfg.pv_on, cfg.ees_on, cfg.el_on, cfg.h2es_on, cfg.rel_on, cfg.hrs_on, cfg.h2_inject_on);
fprintf('Took %.3f seconds \n', toc)


%--------------------------------------------------------------------------
% Technology Parameters/Costs for offsite resources
%--------------------------------------------------------------------------

fprintf('%s: Calculating OffSite Technology Parameters & Costs', datetime("now","InputFormat",'HH:MM:SS'))
tic
techSelOffSite = CTechnologySelectionOffSite();
techSelOffSite.CalculateAllParams(cfg.util_solar_on, cfg.util_wind_on, cfg.util_ees_on, cfg.util_el_on, cfg.util_h2_inject_on);
fprintf('Took %.3f seconds \n', toc)


%--------------------------------------------------------------------------
% Legacy Technologies
%--------------------------------------------------------------------------

fprintf('%s: Calculating Legacy Technology Parameters & Costs ', datetime("now","InputFormat",'HH:MM:SS'))
tic
legacyTech = CLegacyTechnologies(cfg.lpv_on, cfg.ldg_on, cfg.lbot_on, cfg.lhr_on, cfg.ldb_on, cfg.lboil_on, cfg.lees_on, cfg.ltes_on, cfg.dg_legacy_cyc);

cfg.dg_legacy_cyc = legacyTech.updatedDgLegacyCyc;      % TODO: review
fprintf('Took %.3f seconds \n', toc)


%--------------------------------------------------------------------------
% Capital Cost Modifications
%--------------------------------------------------------------------------

fprintf('%s: Calculating Capital Costs Modifications ', datetime("now","InputFormat",'HH:MM:SS'))
tic
capCostMods = CCapitalCostCalculator(cfg.interestRateOnLoans, cfg.lengthOfLoansYears, cfg.req_return_on);

capCostMods.DebtPaymentsFullCostSystem(techSelOnSite.pv_v, techSelOnSite.ees_v, techSelOnSite.el_v, ...
                                        techSelOnSite.rel_v, techSelOnSite.h2es_v, techSelOnSite.hrs_v, techSelOnSite.h2_inject_v,...
                                        techSelOffSite.utilpv_v, techSelOffSite.util_wind_v, techSelOffSite.util_ees_v, ...
                                        cfg.util_el_on, techSelOffSite.util_h2_inject_v, cfg.rees_on)

capCostMods.ConvertIncentivesToReductions(techSelOnSite.sgip, techSelOnSite.ees_v)

capCostMods.CalcCostScalars_SolarPV(techSelOnSite.pv_v, techSelOnSite.pv_fin, techSelOnSite.somah, bldgData.elec, cfg.maxpv, cfg.low_income)
capCostMods.CalcCostScalars_EES(techSelOnSite.ees_v, techSelOnSite.ees_fin, techSelOnSite.rees_fin, techSelOnSite.pv_v, bldgData.elec, cfg.maxpv, cfg.rees_on)
capCostMods.CalcCostScalars_Electrolizer(techSelOnSite.el_v, techSelOnSite.el_fin, bldgData.elec, cfg.h2_fuel_forced_fraction, cfg.low_income, bldgData.e_adjust)
capCostMods.CalcCostScalars_RenewableElectrolizer(techSelOnSite.rel_v, techSelOnSite.rel_fin, bldgData.elec, cfg.h2_fuel_forced_fraction, cfg.low_income, bldgData.e_adjust)

capCostMods.CalcCostScalars_UtilityScaleSolarPV(techSelOffSite.utilpv_v, techSelOffSite.utilpv_fin, bldgData.elec, techSelOnSite.somah, cfg.low_income)
capCostMods.CalcCostScalars_UtilityScaleWind(techSelOffSite.util_wind_v, techSelOffSite.util_wind_fin, bldgData.elec, techSelOnSite.somah)
capCostMods.CalcCostScalars_UtilityScaleBatteryStorage(techSelOffSite.util_ees_v, techSelOffSite.util_ees_fin, bldgData.elec, techSelOnSite.somah)
capCostMods.CalcCostScalars_UtilityScaleElectrolyzer(techSelOffSite.util_el_v, techSelOffSite.util_el_fin, bldgData.elec)

fprintf('Took %.3f seconds \n', toc)


%--------------------------------------------------------------------------
% Plotting loads & Costs for demo purpose
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



%--------------------------------------------------------------------------
% Setting up variables and cost function
%--------------------------------------------------------------------------
fprintf('%s: Generating Model Variables. ', datetime("now","InputFormat",'HH:MM:SS'))
tic

modelVars = CModelVariables(bldgData.GetTimeLen(), bldgData.GetEndPointsLen());

% On Site

modelVars.SetupUtilityElectricity(cfg.utility_exists, cfg.dc_exist, bldgData.day_multi, utilInfo)
modelVars.SetupGeneralExport(cfg.gen_export_on, utilInfo)

% Added NEM and wholesale export to the PV Section
modelVars.SetupSolarPV(cfg.utility_exists, cfg.export_on, cfg.rees_on, cfg.island, bldgData.day_multi, techSelOnSite, utilInfo, capCostMods)
modelVars.SetupElectricalEnergyStorage(cfg.sgip_on, bldgData.day_multi, techSelOnSite, capCostMods)
modelVars.SetupRenewableElectrolyzer(cfg.util_pv_wheel_lts, cfg.strict_h2es, techSelOnSite.rel_v, techSelOnSite.el_v, techSelOnSite.h2es_v, capCostMods)
modelVars.SetupH2ProductionAndStorage(cfg.util_pv_wheel_lts, cfg.strict_h2es, techSelOnSite.el_v, techSelOnSite.h2es_v, capCostMods)
modelVars.SetupHRSEquipment(cfg.hrs_on, techSelOnSite.hrs_v, capCostMods)
modelVars.SetupH2PipelineInjection(cfg.h2_inject_on, cfg.ng_inject, cfg.rng_storage_cost, capCostMods)
modelVars.SetupLegacyPv(cfg.island, cfg.export_on, bldgData.day_multi, legacyTech.pv_legacy, techSelOnSite.pv_v, utilInfo)
modelVars.SetupLegacyGenerator(cfg.h2_inject_on, cfg.util_h2_inject_on, cfg.ldg_op_state, legacyTech.dg_legacy, cfg.dg_legacy_cyc, techSelOnSite.el_v, techSelOnSite.rel_v, cfg.ng_cost, cfg.rng_cost)
modelVars.SetupLegacyBottomingSystems(legacyTech.bot_legacy)
modelVars.SetupLegacyHeatRecovery(legacyTech.dg_legacy, legacyTech.hr_legacy, cfg.ng_cost, cfg.rng_cost)
modelVars.SetupLegacyBoiler(legacyTech.boil_legacy, cfg.ng_cost, cfg.rng_cost)
modelVars.SetupLegacyGenericChiller(bldgData.cool, legacyTech.vc_legacy)
modelVars.SetupLegacyEES(bldgData.day_multi, legacyTech.ees_legacy)
modelVars.SetupLegacyColdTES(bldgData.cool, legacyTech.tes_legacy)
modelVars.SetupLegacyChillers(cfg.onoff_model, bldgData.cool, legacyTech.vc_legacy)
modelVars.SetupDumpVariables(bldgData.elec_dump)

% Off Site

%% Setting up variables and cost function for offsite resources
modelVars.SetupPowerPlantExports(cfg.util_solar_on, cfg.util_ees_on, cfg.util_pp_export, cfg.util_pp_import, cfg.util_pv_wheel, cfg.util_pv_wheel_lts)
modelVars.SetupCommunityScaleSolar(techSelOffSite.utilpv_v)
modelVars.SetupCommunityScaleWind(techSelOffSite.util_wind_v)
modelVars.SetupCommunityScaleStorage(techSelOffSite.util_ees_v)
modelVars.SetupRemoteElectrolyzer(techSelOffSite.util_el_v, bldgData.elec)
modelVars.SetupUtilH2PipelineInjection(cfg.util_h2_inject_on)

elapsed = toc;
fprintf('Took %.3f seconds \n', elapsed)


%--------------------------------------------------------------------------
%                  MODEL CONSTRAINTS
%--------------------------------------------------------------------------

modelConstraints = CModelConstraints(bldgData.GetTimeLen(), bldgData.GetEndPointsLen());

elapsed = modelConstraints.Calculate_GeneralEquality(cfg.onoff_model, modelVars, bldgData.heat, bldgData.cool, bldgData.elec, techSelOnSite.el_v, techSelOnSite.rel_v, cfg.hrs_on, cfg.util_solar_on, cfg.util_ees_on, cfg.util_pv_wheel_lts);
fprintf('%s: General Equality -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

elapsed = modelConstraints.Calculate_GeneralInequality(modelVars, bldgData.e_adjust, cfg.utility_exists, cfg.dc_exist,...
                                                bldgData.endpts, utilInfo.onpeak_index, utilInfo.midpeak_index, cfg.export_on, utilInfo.export_price,...
                                                utilInfo.import_price, legacyTech.fac_prop, cfg.util_pv_wheel, cfg.util_ees_on, cfg.util_pp_import,...
                                                cfg.h2_fuel_forced_fraction, techSelOnSite.el_v, cfg.h2_fuel_limit, cfg.ldg_on, cfg.co2_lim,...
                                                cfg.biogas_limit, cfg.h2_charging_rec, cfg.gen_export_on, bldgData.co2_import, bldgData.co2_ng, bldgData.co2_rng);
fprintf('%s: General Inequality -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

elapsed = modelConstraints.Calculate_HeatRecoveryInequality(modelVars, legacyTech.dg_legacy, legacyTech.hr_legacy, legacyTech.bot_legacy);
fprintf('%s: Heat Recovery Inequalities -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

elapsed = modelConstraints.Calculate_LegacyDG(modelVars, legacyTech.dg_legacy, bldgData.e_adjust, cfg.dg_legacy_cyc);
fprintf('%s: Legacy DG Constraints -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

elapsed = modelConstraints.Calculate_LegacyST(modelVars, legacyTech.bot_legacy);
fprintf('%s: Legacy ST Constraints -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)
    
elapsed = modelConstraints.Calculate_SolarPV(modelVars, techSelOnSite.pv_v, bldgData.solar, legacyTech.pv_legacy, cfg.toolittle_pv, cfg.maxpv, cfg.curtail, bldgData.e_adjust);
fprintf('%s: PV Constraints -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

elapsed = modelConstraints.Calculate_EES(modelVars, techSelOnSite.ees_v, techSelOnSite.pv_v, cfg.rees_on);
fprintf('%s: EES Constraints -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

elapsed = modelConstraints.Calculate_LegacyEES(modelVars, legacyTech.ees_legacy);
fprintf('%s: Legacy EES Constraints -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

elapsed = modelConstraints.Calculate_LegacyVC(modelVars, cfg.onoff_model, bldgData.cool, legacyTech.vc_legacy);
fprintf('%s: Legacy VC Constraints -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

elapsed = modelConstraints.Calculate_LegacyTES(modelVars, bldgData.cool, legacyTech.tes_legacy);
fprintf('%s: Legacy TES Constraints -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

elapsed = modelConstraints.Calculate_DERIncentives(modelVars, techSelOnSite.ees_v, cfg.sgip_on);%% DER Incentives
fprintf('%s: DER Incentives Constraints -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

elapsed = modelConstraints.Calculate_H2production(modelVars, techSelOnSite.el_v, techSelOnSite.rel_v, techSelOnSite.h2es_v, bldgData.e_adjust);
fprintf('%s: Electrolyzer and H2 Storage Constraints -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

elapsed = modelConstraints.Calculate_UtilitySolar(modelVars, techSelOffSite.utilpv_v, bldgData.e_adjust);
fprintf('%s: Utility Scale Solar Constraints -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

elapsed = modelConstraints.Calculate_UtilityWind(modelVars, techSelOffSite.util_wind_v, bldgData.e_adjust);
fprintf('%s: Utility Scale Wind Constraints -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

elapsed = modelConstraints.Calculate_UtilityEESStorage(modelVars, techSelOffSite.util_ees_v);
fprintf('%s: Utility Scale Battery Storage Constraints -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

elapsed = modelConstraints.Calculate_UtilityElectrolyzer(modelVars, techSelOffSite.util_el_v);
fprintf('%s: Utility Scale Electrolyzer Constraints -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

elapsed = modelConstraints.Calculate_H2PipelineInjection(modelVars, cfg.h2_inject_on);
fprintf('%s: H2 Pipeline Injection Constraints -> %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

mSolver = CModelSolver;

%% Export Model
elapsed = mSolver.CreateModel(modelConstraints.Constraints, modelVars.Objective, cfg.co2_lim);

fprintf('%s: Model Export took %.3f seconds \n', datetime("now","InputFormat",'HH:MM:SS'), elapsed)

if mSolver.SetupFirstSolve(cfg.co2_lim, cfg.co2_base, sum(bldgData.elec), bldgData.co2_import, bldgData.co2_ng, bldgData.co2_rng)

end

%% Optimize
fprintf('\n%s: Optimizing...\n\n', datetime("now","InputFormat",'HH:MM:SS'))


%% Loop to rerun optimization

rec = [];

for ii = 1:length(cfg.co2_red)

    fprintf('%s Starting CPLEX Solver \n', datetime("now",'InputFormat','HH:MM:SS'))

    elapsed = mSolver.SolveModel(ii, cfg.co2_red(ii), modelVars);

    fprintf('CPLEX took %.3f seconds \n', elapsed)


    %% Starting Recorder Structure - Model Outputs
    rec.solver.x(ii,:) = mSolver.lastSolveX;
    rec.solver.fval(ii,1) = mSolver.lastSolveFval;
    rec.solver.exitflag(ii,1) = mSolver.lastSolveExitFlag;
    rec.solver.output(ii,1) = mSolver.lastSolveExitFlag;

    %% Optimized Variables -  Utilities

    %%% Utility Variables
    rec.utility.import(:,ii) = mSolver.utilityImport;
    rec.utility.nontou_dc(:,ii) = mSolver.utilityNontouDc;
    rec.utility.onpeak_dc(:,ii) = mSolver.utilityOnpeakDc;
    rec.utility.midpeak_dc(:,ii) = mSolver.utilityMidpeakDc;
    rec.utility.gen_export(:,ii) = mSolver.utilityGenExport;

    %% Optimized Variables - New Technologies
    %%% Solar Variables
    rec.solar.pv_adopt(:,ii) = mSolver.solarPhotoVoltaicAdopt;
    rec.solar.pv_elec(:,ii) = mSolver.solarPhotoVoltaicElec;
    rec.solar.pv_nem(:,ii) = mSolver.solarPhotoVoltaicNem;

    %%% Electrical Energy Storage
    rec.ees.ees_adopt(:,ii) = mSolver.electricalEnergyStorage_adopt;
    rec.ees.ees_chrg(:,ii) = mSolver.electricalEnergyStorage_chrg;
    rec.ees.ees_dchrg(:,ii) = mSolver.electricalEnergyStorage_dchrg;
    rec.ees.ees_soc(:,ii) = mSolver.electricalEnergyStorage_soc;

    %%% Renewable Electrical Energy Storage
    rec.rees.rees_adopt(:,ii) = mSolver.renewableElectricalEnergyStorage_adopt;
    rec.rees.rees_chrg(:,ii) = mSolver.renewableElectricalEnergyStorage_chrg;
    rec.rees.rees_dchrg(:,ii) = mSolver.renewableElectricalEnergyStorage_dchrg;
    rec.rees.rees_soc(:,ii) = mSolver.renewableElectricalEnergyStorage_soc;
    rec.rees.rees_dchrg_nem(:,ii) = mSolver.renewableElectricalEnergyStorage_dchrg_nem;

    %%% H2 Production - Electrolyzer
    rec.el.el_adopt(:,ii) = mSolver.h2ProductionElectrolyzer_adopt;
    rec.el.el_prod(:,ii) = mSolver.h2ProductionElectrolyzer_prod;

    %%% H2 Production - Renewable Electrolyzer
    rec.rel.rel_adopt(:,ii) = mSolver.h2ProductionRenewableElectrolyzer_adopt;
    rec.rel.rel_prod(:,ii) = mSolver.h2ProductionRenewableElectrolyzer_prod;
    rec.rel.rel_prod_wheel(:,ii) = mSolver.h2ProductionRenewableElectrolyzer_prod;

    %%% H2 Production - Storage
    rec.h2es.h2es_adopt(:,ii) = mSolver.h2ProductionEnergyStorage_adopt;
    rec.h2es.h2es_chrg(:,ii) = mSolver.h2ProductionEnergyStorage_chrg;
    rec.h2es.h2es_dchrg(:,ii) = mSolver.h2ProductionEnergyStorage_dchrg;
    rec.h2es.h2es_soc(:,ii) = mSolver.h2ProductionEnergyStorage_soc;
    rec.h2es.h2es_bin(:,ii) = mSolver.h2ProductionEnergyStorage_bin;

    %% Optimized Variables -  Legacy technologies %%
    %% DG - Topping Cycle
    rec.ldg.ldg_elec(:,ii) = mSolver.ldg_elec;
    rec.ldg.ldg_fuel(:,ii) = mSolver.ldg_fuel;
    rec.ldg.ldg_rfuel(:,ii) = mSolver.ldg_rfuel;
    rec.ldg.ldg_hfuel(:,ii) = mSolver.ldg_hfuel;
    rec.ldg.ldg_sfuel(:,ii) = mSolver.ldg_sfuel;
    rec.ldg.ldg_dfuel(:,ii) = mSolver.ldg_dfuel;
    rec.ldg.ldg_elec_ramp(:,ii) = mSolver.ldg_elec_ramp;
    % var_ldg.ldg_off(:,ii) = mSolver.ldg_off;
    rec.ldg.ldg_opstate(:,ii) = mSolver.ldg_opstate;
    %% Bottoming Cycle
    rec.lbot.lbot_elec(:,ii) = mSolver.lbot_elec;
    rec.lbot.lbot_on(:,ii) = mSolver.lbot_on;

    %% Heat Recovery Systems
    rec.ldg.hr_heat(:,ii) = mSolver.ldg_hr_heat;
    rec.ldg.db_fire(:,ii) = mSolver.ldg_db_fire;
    rec.ldg.db_rfire(:,ii) = mSolver.ldg_db_rfire;
    rec.ldg.db_hfire(:,ii) = mSolver.ldg_db_hfire;

    %% Boiler
    rec.boil.boil_fuel(:,ii) = mSolver.boiler_fuel;
    rec.boil.boil_rfuel(:,ii) = mSolver.boiler_rfuel;
    rec.boil.boil_hfuel(:,ii) = mSolver.boiler_hfuel;

    %% EES
    if ~isempty(legacyTech.ees_legacy)
        rec.lees.ees_chrg(:,ii) = mSolver.lees_chrg;
        rec.lees.ees_dchrg(:,ii) = mSolver.lees_dchrg;
        rec.lees.ees_soc(:,ii) = mSolver.lees_soc;
    end

    %% Carbon Emissions
    % Carbon emissions from 1) utility electiricity, 2) natural gas, 3) renewable natural gas
    rec.co2_emissions(1,ii) = mSolver.co2EmissionsUtilityElect;
    rec.co2_emissions(2,ii) = mSolver.co2EmissionsNaturalGas;
    rec.co2_emissions(3,ii) = mSolver.co2EmissionsRenewableNaturalGas;

    % Total carbon emissions
    rec.co2_emissions(4,ii) =   mSolver.co2TotalEmissions;

    % Percent reduction
    rec.co2_emissions_red(1,ii) = mSolver.co2EmissionsReductionPercentaje;

    %% Financials
    %%%($/kWh)
    rec.financials.lcoe(ii,1) = mSolver.levelizedCostOfElectricityInKWh;

    %%%Bulk cost of carbon ($/tonne)
    rec.financials.cost_of_co2(ii,1) = mSolver.BulkCostOfCarbonByTonne;

    %%%Marginal cost of carbon ($/tonne)
    if ii > 1
        rec.financials.cost_of_co2_marginal(ii,1) = abs((rec.solver.fval(ii,1) - rec.solver.fval(ii-1,1))/((rec.co2_emissions(4,ii) - rec.co2_emissions(4,ii-1))./1000));
    else 
        rec.financials.cost_of_co2_marginal(ii,1) = NaN;
    end

    %%%Capital Cost Requirements
    rec.financials.cap_cost(ii,:) = [mSolver.solarPhotoVoltaicAdopt.*techSelOnSite.pv_cap*capCostMods.pv_cap_mod
                                    mSolver.electricalEnergyStorage_adopt.*techSelOnSite.ees_cap.*capCostMods.ees_cap_mod
                                    mSolver.renewableElectricalEnergyStorage_adopt.*techSelOnSite.ees_cap.*capCostMods.rees_cap_mod
                                    mSolver.h2ProductionElectrolyzer_adopt.*techSelOnSite.el_cap.*capCostMods.el_cap_mod
                                    mSolver.h2ProductionRenewableElectrolyzer_adopt.*techSelOnSite.el_cap.*capCostMods.rel_cap_mod
                                    mSolver.h2ProductionEnergyStorage_adopt.*techSelOnSite.h2es_cap];

end


%% SAVE Resuts to file
if cfg.saveResultsToFile
    save(strcat(results_path,'\deropt_results.mat'), "rec")
end



%%        SHOW RESULTS (Plot data)
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------


%%% Plot 'LCOE ($/kWh)'
figure
hold on
plot(rec.co2_emissions_red,rec.financials.lcoe,'LineWidth',2)
box on
grid on
ylabel('LCOE ($/kWh)','FontSize',18)
xlabel('CO_2 Reduction (%)','FontSize',18)
set(gcf,'Position',[50 50 500 275])
xlim([0 50])
hold off
    
        
%%% Plot 'Cost of Carbon'
figure
hold on
plot(rec.co2_emissions_red,rec.financials.cost_of_co2,'LineWidth',2)
plot(rec.co2_emissions_red,rec.financials.cost_of_co2_marginal,'LineWidth',2)
box on
grid on
ylabel('Cost of CO_2 ($/tonne)','FontSize',18)
xlabel('CO_2 Reduction (%)','FontSize',18)
set(gcf,'Position',[50 300 500 275])
xlim([5 50])
legend('Average Cost','Marginal Cost','Location','NorthWest')
hold off


%%% Plot 'Capital Requirements'
figure
hold on
plot(rec.co2_emissions_red,sum(rec.financials.cap_cost,2)./1000000,'LineWidth',2)
% plot(rec.co2_emissions_red,rec.financials.cost_of_co2_marginal,'LineWidth',2)
box on
grid on
ylabel('Capital Cost ($MM)','FontSize',18)
xlabel('CO_2 Reduction (%)','FontSize',18)
set(gcf,'Position',[50 600 500 275])
xlim([5 50])
% legend('Average Cost','Marginal Cost','Location','NorthWest')
hold off


%%% Dispatch Plots


for idx = 1:length(cfg.co2_red)

    co2_red_text = ['CO2 Reduction:' num2str((cfg.co2_red(idx)*100),'%02d') '%'];


    dt1 = [sum(rec.ldg.ldg_elec(:,idx),2)...
            sum(rec.utility.import(:,idx),2)...
            sum(rec.solar.pv_elec(:,idx),2) + sum(rec.rees.rees_chrg(:,idx),2)...
            sum(rec.ees.ees_dchrg(:,idx),2) + sum(rec.rees.rees_dchrg(:,idx),2) + sum(rec.lees.ees_dchrg(:,idx),2)];
             
    dt2 = [bldgData.elec ...
            sum(rec.ees.ees_chrg(:,idx),2) + sum(rec.lees.ees_chrg(:,idx),2) + sum(rec.rees.rees_chrg(:,idx),2)...
            sum(modelVars.el_eff.*rec.el.el_prod(:,idx),2) + sum(modelVars.h2_chrg_eff.*rec.h2es.h2es_chrg(:,idx),2) + sum(modelVars.rel_eff.*rec.rel.rel_prod(:,idx),2) ...
            rec.solar.pv_nem(:,idx)];
    
    
    %%% Plot 'Electric Sources (MW)'
    figure('Name', co2_red_text);
    hold on
    area(bldgData.time,dt1.*4./1000)
    set(gca,'XTick', round(bldgData.time(1),0)+.5:round(bldgData.time(end),0)+.5,'FontSize',14)
    box on
    grid on
    datetick('x','ddd','keepticks')
    xlim([bldgData.time(bldgData.stpts(3)) bldgData.time(bldgData.stpts(3)+96*7)])
    ylabel('Electric Sources (MW)','FontSize',18)
    legend('Gas Turbine','Utility Import','Solar','Battery Discharge','Location','Best')
    set(gcf,'Position',[(600 + idx*20) (450 + idx*20) 500 275])
    hold off
    
    %%% Plot 'Electric Loads (MW)'
    figure('Name',co2_red_text);
    hold on
    area(bldgData.time,dt2.*4./1000)
    set(gca,'XTick', round(bldgData.time(1),0)+.5:round(bldgData.time(end),0)+.5, 'FontSize',14)
    box on
    grid on
    datetick('x','ddd','keepticks')
    xlim([bldgData.time(bldgData.stpts(3)) bldgData.time(bldgData.stpts(3)+96*7)])
    ylabel('Electric Loads (MW)','FontSize',18)
    legend('Campus','Battery Charging','H_2 Production','Export','Location','Best')
    set(gcf,'Position',[(600 + idx*20) (50 + idx*10) 500 275])
    hold off

end