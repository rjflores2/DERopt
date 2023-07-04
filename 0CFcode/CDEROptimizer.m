classdef CDEROptimizer < handle
    
    properties (SetAccess = public)
        
        cfgManager
        
    end
    
    properties (SetAccess = private)
        
        optimizationRecordings
        
        plotData_text
        plotData_dt1
        plotData_dt2
        plotData_time
        plotData_stpts
        
        environmentIndex
        
    end
    
    methods
        
        function obj = CDEROptimizer()
            
            opList = {'1 - Robert''s PC', '2 - Roman''s Laptop', '3 - Roman''s Desktop'};
            
            [obj.environmentIndex,~] = listdlg('ListString',opList,'SelectionMode','single', 'InitialValue',1,'PromptString','Select Environment','ListSize',[160 60]);
            
            if isempty(obj.environmentIndex)
                obj.environmentIndex = 1;
            end
            
            obj.cfgManager = CConfigurationManager;
            
            % Select which computer your are running this app
            obj.cfgManager.SetRunningEnvironment(obj.environmentIndex); % 1 - Robert's PC
            % 2 - Roman's Laptop
            % 3 - Roman's Desktop
            
            obj.cfgManager.AddMatlabPaths()
            
        end
        
        
        function Optimize(obj, UserInterfaceFig, PlotElectricSources, PlotElectricLoads)
            
            obj.optimizationRecordings = [];
            obj.plotData_text = [];
            obj.plotData_dt1 = [];
            obj.plotData_dt2 = [];
            obj.plotData_time = [];
            obj.plotData_stpts = [];
            
            prepSteps = 30;
            
            progBar = uiprogressdlg(UserInterfaceFig,'Title','Please Wait','Message','Starting Optimization');
            
            bldgData = CBuildingDataManager("UCI Labs");
            
            progBar.Value = 0;
            progBar.Message = "Loading Building Data ";
            
            if bldgData.LoadData(append(obj.cfgManager.demo_data_path, '\Campus_Loads_2014_2019.mat'), obj.cfgManager.chiller_plant_opt)
                
                progBar.Value = (1/prepSteps);
                progBar.Message = "Streamlining Building Data";
                
                bldgData.FormatData(obj.cfgManager.month_idx, obj.cfgManager.year_idx, obj.cfgManager.demo_data_path, obj.cfgManager.util_solar_on, obj.cfgManager.util_wind_on, obj.cfgManager.hrs_on);
                
                progBar.Value = (2/prepSteps);
                progBar.Message = "Recalibrating Emissions Parameters";
                
                if isempty(obj.cfgManager.co2_base)
                    obj.cfgManager.co2_base = bldgData.EstimateBaseCO2Emissions();
                end
                
                obj.cfgManager.SetUpFirstCO2Limit();
                
                progBar.Value = (3/prepSteps);
                progBar.Message = "Loading Utility Data and Generating Energy Charge Vectors";
                
                utilInfo = CUtilityInfo(obj.cfgManager.uci_rate, obj.cfgManager.export_on, obj.cfgManager.gen_export_on, bldgData.lmp_uci, bldgData.GetElecLen());
                
                
                %--------------------------------------------------------------------------
                % Technology Parameters/Costs
                %--------------------------------------------------------------------------
                
                progBar.Value = (4/prepSteps);
                progBar.Message = "Calculating OnSite Technology Parameters & Costs";
                
                techSelOnSite = CTechnologySelection();
                techSelOnSite.CalculateAllParams(obj.cfgManager.pv_on, obj.cfgManager.ees_on, obj.cfgManager.el_on, obj.cfgManager.h2es_on, obj.cfgManager.rel_on, obj.cfgManager.hrs_on, obj.cfgManager.h2_inject_on, obj.cfgManager.fuel_cell_binary_on);
                
                
                %--------------------------------------------------------------------------
                % Technology Parameters/Costs for offsite resources
                %--------------------------------------------------------------------------
                
                progBar.Value = (5/prepSteps);
                progBar.Message = "Calculating OffSite Technology Parameters & Costs";
                
                techSelOffSite = CTechnologySelectionOffSite();
                techSelOffSite.CalculateAllParams(obj.cfgManager.util_solar_on, obj.cfgManager.util_wind_on, obj.cfgManager.util_ees_on, obj.cfgManager.util_el_on, obj.cfgManager.util_h2_inject_on);
                
                
                %--------------------------------------------------------------------------
                % Legacy Technologies
                %--------------------------------------------------------------------------
                
                progBar.Value = (6/prepSteps);
                progBar.Message = "Calculating Legacy Technology Parameters & Costs";
                
                legacyTech = CLegacyTechnologies(obj.cfgManager.lpv_on, obj.cfgManager.ldg_on, obj.cfgManager.lbot_on, obj.cfgManager.lhr_on, obj.cfgManager.ldb_on, obj.cfgManager.lboil_on, obj.cfgManager.lees_on, obj.cfgManager.ltes_on, obj.cfgManager.dg_legacy_cyc);
                
                obj.cfgManager.dg_legacy_cyc = legacyTech.updatedDgLegacyCyc;      % TODO: review
                
                
                %--------------------------------------------------------------------------
                % Capital Cost Modifications
                %--------------------------------------------------------------------------
                
                progBar.Value = (7/prepSteps);
                progBar.Message = "Calculating Capital Costs Modifications (1/3)";
                
                capCostMods = CCapitalCostCalculator(obj.cfgManager.interestRateOnLoans, obj.cfgManager.lengthOfLoansYears, obj.cfgManager.req_return_on);
                
                capCostMods.DebtPaymentsFullCostSystem(techSelOnSite.pv_v, techSelOnSite.ees_v, techSelOnSite.el_v, ...
                    techSelOnSite.rel_v, techSelOnSite.h2es_v, techSelOnSite.hrs_v, techSelOnSite.h2_inject_v,...
                    techSelOffSite.utilpv_v, techSelOffSite.util_wind_v, techSelOffSite.util_ees_v, ...
                    obj.cfgManager.util_el_on, techSelOffSite.util_h2_inject_v, obj.cfgManager.rees_on, techSelOnSite.FuelCellBinary_v)
                
                capCostMods.ConvertIncentivesToReductions(techSelOnSite.sgip, techSelOnSite.ees_v)
                
                
                progBar.Value = (8/prepSteps);
                progBar.Message = "Calculating Capital Costs Modifications (2/3)";
                
                capCostMods.CalcCostScalars_SolarPV(techSelOnSite.pv_v, techSelOnSite.pv_fin, techSelOnSite.somah, bldgData.elec, obj.cfgManager.maxpv, obj.cfgManager.low_income)
                capCostMods.CalcCostScalars_EES(techSelOnSite.ees_v, techSelOnSite.ees_fin, techSelOnSite.rees_fin, techSelOnSite.pv_v, bldgData.elec, obj.cfgManager.maxpv, obj.cfgManager.rees_on)
                capCostMods.CalcCostScalars_Electrolizer(techSelOnSite.el_v, techSelOnSite.el_fin, bldgData.elec, obj.cfgManager.h2_fuel_forced_fraction, obj.cfgManager.low_income, bldgData.e_adjust)
                capCostMods.CalcCostScalars_RenewableElectrolizer(techSelOnSite.rel_v, techSelOnSite.rel_fin, bldgData.elec, obj.cfgManager.h2_fuel_forced_fraction, obj.cfgManager.low_income, bldgData.e_adjust)
                
                progBar.Value = (9/prepSteps);
                progBar.Message = "Calculating Capital Costs Modifications (3/3)";
                
                capCostMods.CalcCostScalars_UtilityScaleSolarPV(techSelOffSite.utilpv_v, techSelOffSite.utilpv_fin, bldgData.elec, techSelOnSite.somah, obj.cfgManager.low_income)
                capCostMods.CalcCostScalars_UtilityScaleWind(techSelOffSite.util_wind_v, techSelOffSite.util_wind_fin, bldgData.elec, techSelOnSite.somah)
                capCostMods.CalcCostScalars_UtilityScaleBatteryStorage(techSelOffSite.util_ees_v, techSelOffSite.util_ees_fin, bldgData.elec, techSelOnSite.somah)
                capCostMods.CalcCostScalars_UtilityScaleElectrolyzer(techSelOffSite.util_el_v, techSelOffSite.util_el_fin, bldgData.elec)
                
                
                %--------------------------------------------------------------------------
                % Setting up variables and cost function
                %--------------------------------------------------------------------------
                modelVars = CModelVariables(bldgData.GetTimeLen(), bldgData.GetEndPointsLen());
                
                progBar.Value = (10/prepSteps);
                progBar.Message = "Generating OnSite Model Variables";
                
                modelVars.SetupUtilityElectricity(obj.cfgManager.utility_exists, obj.cfgManager.dc_exist, bldgData.day_multi, utilInfo)
                modelVars.SetupGeneralExport(obj.cfgManager.gen_export_on, utilInfo)
                modelVars.SetupUtilityHydrogen(obj.cfgManager.h2_cost)
                % Added NEM and wholesale export to the PV Section
                
                
                modelVars.SetupFuelCellBinary(techSelOnSite, capCostMods, bldgData.day_multi, obj.cfgManager.ng_cost)
                modelVars.SetupSolarPV(obj.cfgManager.utility_exists, obj.cfgManager.export_on, obj.cfgManager.rees_on, obj.cfgManager.island, bldgData.day_multi, techSelOnSite, utilInfo, capCostMods)
                modelVars.SetupElectricalEnergyStorage(obj.cfgManager.sgip_on, bldgData.day_multi, techSelOnSite, capCostMods)
                modelVars.SetupRenewableElectrolyzer(obj.cfgManager.util_pv_wheel_lts, obj.cfgManager.strict_h2es, techSelOnSite.rel_v, techSelOnSite.el_v, techSelOnSite.h2es_v, capCostMods)
                modelVars.SetupH2ProductionAndStorage(obj.cfgManager.util_pv_wheel_lts, obj.cfgManager.strict_h2es, techSelOnSite.el_v, techSelOnSite.h2es_v, capCostMods)
                modelVars.SetupHRSEquipment(obj.cfgManager.hrs_on, techSelOnSite.hrs_v, capCostMods)
                modelVars.SetupH2PipelineInjection(obj.cfgManager.h2_inject_on, obj.cfgManager.ng_inject, obj.cfgManager.rng_storage_cost, capCostMods)
                modelVars.SetupLegacyPv(obj.cfgManager.island, obj.cfgManager.export_on, bldgData.day_multi, legacyTech.pv_legacy, techSelOnSite.pv_v, utilInfo)
                modelVars.SetupLegacyGenerator(obj.cfgManager.h2_inject_on, obj.cfgManager.util_h2_inject_on, obj.cfgManager.ldg_op_state, legacyTech.dg_legacy, obj.cfgManager.dg_legacy_cyc, techSelOnSite.el_v, techSelOnSite.rel_v, obj.cfgManager.ng_cost, obj.cfgManager.rng_cost)
                modelVars.SetupLegacyBottomingSystems(legacyTech.bot_legacy)
                modelVars.SetupLegacyHeatRecovery(legacyTech.dg_legacy, legacyTech.hr_legacy, obj.cfgManager.ng_cost, obj.cfgManager.rng_cost)
                modelVars.SetupLegacyBoiler(legacyTech.boil_legacy, obj.cfgManager.ng_cost, obj.cfgManager.rng_cost)
                modelVars.SetupLegacyGenericChiller(bldgData.cool, legacyTech.vc_legacy)
                modelVars.SetupLegacyEES(bldgData.day_multi, legacyTech.ees_legacy)
                modelVars.SetupLegacyColdTES(bldgData.cool, legacyTech.tes_legacy)
                modelVars.SetupLegacyChillers(obj.cfgManager.onoff_model, bldgData.cool, legacyTech.vc_legacy)
                modelVars.SetupDumpVariables(bldgData.elec_dump)
                
                progBar.Value = (11/prepSteps);
                progBar.Message = "Generating OffSite Model Variables";
                
                % Setting up variables and cost function for offsite resources
                modelVars.SetupPowerPlantExports(obj.cfgManager.util_solar_on, obj.cfgManager.util_ees_on, obj.cfgManager.util_pp_export, obj.cfgManager.util_pp_import, obj.cfgManager.util_pv_wheel, obj.cfgManager.util_pv_wheel_lts)
                modelVars.SetupCommunityScaleSolar(techSelOffSite.utilpv_v)
                modelVars.SetupCommunityScaleWind(techSelOffSite.util_wind_v)
                modelVars.SetupCommunityScaleStorage(techSelOffSite.util_ees_v)
                modelVars.SetupRemoteElectrolyzer(techSelOffSite.util_el_v, bldgData.elec)
                modelVars.SetupUtilH2PipelineInjection(obj.cfgManager.util_h2_inject_on)
                
                %--------------------------------------------------------------------------
                %                  MODEL CONSTRAINTS
                %--------------------------------------------------------------------------
                
                modelConstraints = CModelConstraints(bldgData.GetTimeLen(), bldgData.GetEndPointsLen());
                
                progBar.Value = (12/prepSteps);
                progBar.Message = "Model Constraints -> General Equality";
                
                modelConstraints.Calculate_GeneralEquality(obj.cfgManager.onoff_model, modelVars, bldgData.heat, bldgData.cool, bldgData.elec, techSelOnSite.el_v, techSelOnSite.rel_v, obj.cfgManager.hrs_on, obj.cfgManager.util_solar_on, obj.cfgManager.util_ees_on, obj.cfgManager.util_pv_wheel_lts);
                
                progBar.Value = (13/prepSteps);
                progBar.Message = "Model Constraints -> General Inequality";
                
                modelConstraints.Calculate_GeneralInequality(modelVars, bldgData.e_adjust, obj.cfgManager.utility_exists, obj.cfgManager.dc_exist,...
                    bldgData.endpts, utilInfo.onpeak_index, utilInfo.midpeak_index, obj.cfgManager.export_on, utilInfo.export_price,...
                    utilInfo.import_price, legacyTech.fac_prop, obj.cfgManager.util_pv_wheel, obj.cfgManager.util_ees_on, obj.cfgManager.util_pp_import,...
                    obj.cfgManager.h2_fuel_forced_fraction, techSelOnSite.el_v, obj.cfgManager.h2_fuel_limit, obj.cfgManager.ldg_on, obj.cfgManager.co2_lim,...
                    obj.cfgManager.biogas_limit, obj.cfgManager.h2_charging_rec, obj.cfgManager.gen_export_on, bldgData.co2_import, bldgData.co2_ng, bldgData.co2_rng);
                
                
                progBar.Value = (14/prepSteps);
                progBar.Message = "Model Constraints -> Heat Recovery Inequalities";
                
                modelConstraints.Calculate_HeatRecoveryInequality(modelVars, legacyTech.dg_legacy, legacyTech.hr_legacy, legacyTech.bot_legacy);
                
                progBar.Value = (15/prepSteps);
                progBar.Message = "Model Constraints -> Legacy DG Constraints";
                
                modelConstraints.Calculate_LegacyDG(modelVars, legacyTech.dg_legacy, bldgData.e_adjust, obj.cfgManager.dg_legacy_cyc);
                
                progBar.Value = (16/prepSteps);
                progBar.Message = "Model Constraints -> Legacy ST Constraints";
                
                modelConstraints.Calculate_LegacyST(modelVars, legacyTech.bot_legacy);
                
                progBar.Value = (16/prepSteps);
                progBar.Message = "Model Constraints -> Fuel Cell Binary Constraints";
                
                modelConstraints.Calculate_FuelCellBinary(modelVars, bldgData.e_adjust, techSelOnSite.FuelCellBinary_v, bldgData.elec);
                
                progBar.Value = (17/prepSteps);
                progBar.Message = "Model Constraints -> PV Constraints";
                
                modelConstraints.Calculate_SolarPV(modelVars, techSelOnSite.pv_v, bldgData.solar, legacyTech.pv_legacy, obj.cfgManager.toolittle_pv, obj.cfgManager.maxpv, obj.cfgManager.curtail, bldgData.e_adjust);
                
                progBar.Value = (18/prepSteps);
                progBar.Message = "Model Constraints -> EES Constraints";
                
                modelConstraints.Calculate_EES(modelVars, techSelOnSite.ees_v, techSelOnSite.pv_v, obj.cfgManager.rees_on,obj.cfgManager.export_on);
                
                progBar.Value = (19/prepSteps);
                progBar.Message = "Model Constraints -> Legacy EES Constraints";
                
                modelConstraints.Calculate_LegacyEES(modelVars, legacyTech.ees_legacy);
                
                progBar.Value = (20/prepSteps);
                progBar.Message = "Model Constraints -> Legacy VC Constraints";
                
                modelConstraints.Calculate_LegacyVC(modelVars, obj.cfgManager.onoff_model, bldgData.cool, legacyTech.vc_legacy);
                
                progBar.Value = (21/prepSteps);
                progBar.Message = "Model Constraints -> Legacy TES Constraints";
                
                modelConstraints.Calculate_LegacyTES(modelVars, bldgData.cool, legacyTech.tes_legacy);
                
                progBar.Value = (22/prepSteps);
                progBar.Message = "Model Constraints -> DER Incentives Constraints";
                
                modelConstraints.Calculate_DERIncentives(modelVars, techSelOnSite.ees_v, obj.cfgManager.sgip_on);%% DER Incentives
                
                progBar.Value = (23/prepSteps);
                progBar.Message = "Model Constraints -> Electrolyzer and H2 Storage Constraints";
                
                modelConstraints.Calculate_H2production(modelVars, techSelOnSite.el_v, techSelOnSite.rel_v, techSelOnSite.h2es_v, bldgData.e_adjust);
                
                
                progBar.Value = (28/prepSteps);
                progBar.Message = "Model Constraints -> H2 Pipeline Injection Constraints";
                
                modelConstraints.Calculate_H2PipelineInjection(modelVars, obj.cfgManager.h2_inject_on);
                
                progBar.Value = (29/prepSteps);
                progBar.Message = "Model Constraints -> Creating Optimization Model";
                
                mSolver = CModelSolver;
                
                % Export Model
                mSolver.CreateModel(modelConstraints.Constraints, modelVars.Objective, obj.cfgManager.co2_lim);
                
                if mSolver.SetupFirstSolve(obj.cfgManager.co2_lim, obj.cfgManager.co2_base, sum(bldgData.elec), bldgData.co2_import, bldgData.co2_ng, bldgData.co2_rng)
                    
                end
                
                close(progBar);
                
                %--------------------------------------------------------------------------
                %                  OPTIMIZATION LOOP
                %--------------------------------------------------------------------------
                
                rec = [];
                
                obj.plotData_time = bldgData.time;
                obj.plotData_stpts = bldgData.stpts;
                
                optLoops = length(obj.cfgManager.co2_red);
                
                for ii = 1:optLoops
                    
                    loopUIText = ['Step ' num2str(ii) ' of ' num2str(optLoops) ' - Optiziming for '...
                        num2str((obj.cfgManager.co2_red(ii)*100),'%d') '% CO2 Reduction'];
                    
                    progBar = uiprogressdlg(UserInterfaceFig,'Title','Please Wait','Message',loopUIText);
                    
                    progBar.Value = ((ii-1)/optLoops);
                    
                    mSolver.SolveModel(ii, obj.cfgManager.co2_red(ii), modelVars);
                    
                    close(progBar);
                    
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
                    
                    %% New variables
                    rec.fuel_cell_binary.fuel_cell_adopt(:,ii) = mSolver.fuelCellAdopt;
                    rec.fuel_cell_binary.fuel_cell_capacity(:,ii) = mSolver.fuelCellCapacity;
                    rec.fuel_cell_binary.fuel_cell_electricity(:,ii) = mSolver.fuelCellElectricity;
                    rec.fuel_cell_binary.fuel_cell_fuel(:,ii) = mSolver.fuelCellFuelIn;
                    rec.fuel_cell_binary.fuel_cell_hydrogen(:,ii) = mSolver.fuelCellH2In;
                    
                    rec.utility_h2.utility_h2(:,ii) = mSolver.utilityH2;
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
                    %                     if ~isempty(legacyTech.ees_legacy)
                    rec.lees.ees_chrg(:,ii) = mSolver.lees_chrg;
                    rec.lees.ees_dchrg(:,ii) = mSolver.lees_dchrg;
                    rec.lees.ees_soc(:,ii) = mSolver.lees_soc;
                    %                     end
                    
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
                    
                    % Dispatch Plots
                    idx = ii;
                    
                    co2_red_text = ['CO2 Reduction:' num2str((obj.cfgManager.co2_red(idx)*100),'%2d') '%'];
                    
                    dt1 = [sum(rec.fuel_cell_binary.fuel_cell_electricity(:,idx),2)...
                        sum(rec.ldg.ldg_elec(:,idx),2)...
                        sum(rec.utility.import(:,idx),2)...
                        sum(rec.solar.pv_elec(:,idx),2) + sum(rec.rees.rees_chrg(:,idx),2)...
                        sum(rec.ees.ees_dchrg(:,idx),2) + sum(rec.rees.rees_dchrg(:,idx),2) + sum(rec.lees.ees_dchrg(:,idx),2)];
                    
                    dt2 = [bldgData.elec ...
                        sum(rec.ees.ees_chrg(:,idx),2) + sum(rec.lees.ees_chrg(:,idx),2) + sum(rec.rees.rees_chrg(:,idx),2)...
                        sum(modelVars.el_eff.*rec.el.el_prod(:,idx),2) + sum(modelVars.h2_chrg_eff.*rec.h2es.h2es_chrg(:,idx),2) + sum(modelVars.rel_eff.*rec.rel.rel_prod(:,idx),2) ...
                        rec.solar.pv_nem(:,idx)];
                    
                    
                    obj.plotData_text = [obj.plotData_text convertCharsToStrings(co2_red_text)];
                    obj.plotData_dt1(:,:,ii) = dt1;
                    obj.plotData_dt2(:,:,ii) = dt2;
                    
                    notify(obj, 'NewDataAvailable');
                    
                    obj.UpdatePlots(ii, PlotElectricSources, PlotElectricLoads)
                    
                    pause(1)
                    
                end
                
                % Update optimization results
                obj.optimizationRecordings = rec;
                
            else
                
                close(progBar);
                msgbox(append("Could not load Building Data File: ", append(obj.cfgManager.demo_data_path, '\Campus_Loads_2014_2019.mat')),"0CF DERoptimizer","warn");
                
            end
        end
        
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        
        function SetMonthsSelection(obj, monthSel)
            
            obj.cfgManager.month_idx = monthSel;
            
        end
        
        function SetRunningEnv(obj, envId)
            
            obj.cfgManager.SetRunningEnvironment(envId);
            
        end
        
        function result = IsMonthSelectionEmpty(obj)
            
            result = isempty(obj.cfgManager.month_idx);
            
        end
        
        function result = OptimizationResultsAvailable(obj)
            
            result = ~isempty(obj.optimizationRecordings);
            
        end
        
        function indx = GetEnvironmentIndex(obj)
            
            indx = obj.environmentIndex;
            
        end
        
        function plotIndex = FindPlotIndex(obj, value)
            
            plotIndex = find(obj.cfgManager.co2_red == value/100);
            
        end
        
        
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        
        function [numberSteps] = CalculateInitialPathCO2Reduction(obj, reductionBegin, reductionFinish, reductionStep)
            
            numberSteps = obj.cfgManager.CalculateInitialPathCO2Reduction(reductionBegin, reductionFinish, reductionStep);
            
        end
        
        function [co2Reduction] = GetCO2ReductionPercentaje(obj)
            
            co2Reduction = obj.cfgManager.co2_red * 100;
            
        end
        
        function [co2Reduction] = GetMaxCO2ReductionPercentaje(obj)
            
            co2Reduction = obj.cfgManager.co2_red(length(obj.cfgManager.co2_red)) * 100;
            
        end
        
        
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        
        function UpdatePlots(obj, ii, PlotElectricSources, PlotElectricLoads)
            
            graphIndex = find(obj.cfgManager.month_idx == 7);
            
            if isempty(graphIndex)
                graphIndex = 1;
            end
            
            if ii > 0 && ii <= length(obj.plotData_text)
                
                %--------------------------------------------------
                % Plot 'Electric Sources (MW)'
                %--------------------------------------------------
                
                if ~isempty(PlotElectricSources)
                    
                    PlotElectricSources.Title.String = obj.plotData_text(ii);
                    area(PlotElectricSources, obj.plotData_time, obj.plotData_dt1(:,:,ii).*4./1000)
                    set(PlotElectricSources,'XTick', round(obj.plotData_time(1),0)+.5:round(obj.plotData_time(end),0)+.5,'FontSize',14)
                    PlotElectricSources.Box = "on";
                    PlotElectricSources.XGrid = "on";
                    datetick(PlotElectricSources,'x','ddd','keepticks');
                    PlotElectricSources.XLim = [obj.plotData_time(obj.plotData_stpts(graphIndex)) obj.plotData_time(obj.plotData_stpts(graphIndex)+96*7)];
                    ylabel(PlotElectricSources,'Electric Sources (MW)','FontSize',14)
                    legend(PlotElectricSources,'Fuel Cell','Gas Turbine','Utility Import','Solar','Battery Discharge','Location','Best')
                    PlotElectricSources.Visible = true;
                    
                else
                    
                    figure('Name', obj.plotData_text(ii));
                    hold on
                    area(obj.plotData_time, obj.plotData_dt1(:,:,ii).*4./1000)
                    set(gca,'XTick', round(obj.plotData_time(1),0)+.5:round(obj.plotData_time(end),0)+.5,'FontSize',14)
                    box on
                    grid on
                    datetick('x','ddd','keepticks')
                    xlim([obj.plotData_time(obj.plotData_stpts(graphIndex)) obj.plotData_time(obj.plotData_stpts(graphIndex)+96*7)])
                    ylabel('Electric Sources (MW)','FontSize',14)
                    legend('Fuel Cell','Gas Turbine','Utility Import','Solar','Battery Discharge','Location','Best')
                    set(gcf,'Position',[(100 + ii*40) (450 + ii*20) 500 275])
                    hold off
                    
                end
                
                
                %--------------------------------------------------
                % Plot 'Electric Loads (MW)'
                %--------------------------------------------------
                if ~isempty(PlotElectricLoads)
                    
                    PlotElectricLoads.Title.String = obj.plotData_text(ii);
                    area(PlotElectricLoads, obj.plotData_time, obj.plotData_dt2(:,:,ii).*4./1000)
                    set(PlotElectricLoads,'XTick', round(obj.plotData_time(1),0)+.5:round(obj.plotData_time(end),0)+.5,'FontSize',14)
                    PlotElectricLoads.Box = "on";
                    PlotElectricLoads.XGrid = "on";
                    datetick(PlotElectricLoads,'x','ddd','keepticks');
                    PlotElectricLoads.XLim = [obj.plotData_time(obj.plotData_stpts(graphIndex)) obj.plotData_time(obj.plotData_stpts(graphIndex)+96*7)];
                    ylabel(PlotElectricLoads,'Electric Loads (MW)','FontSize',14)
                    legend(PlotElectricLoads,'Campus','Battery Charging','H_2 Production','Export','Location','Best')
                    PlotElectricLoads.Visible = true;
                    
                else
                    
                    figure('Name',obj.plotData_text(ii));
                    hold on
                    area(obj.plotData_time, obj.plotData_dt2(:,:,ii).*4./1000)
                    set(gca,'XTick', round(obj.plotData_time(1),0)+.5:round(obj.plotData_time(end),0)+.5,'FontSize',14)
                    box on
                    grid on
                    datetick('x','ddd','keepticks')
                    xlim([obj.plotData_time(obj.plotData_stpts(graphIndex)) obj.plotData_time(obj.plotData_stpts(graphIndex)+96*7)])
                    ylabel('Electric Loads (MW)','FontSize',14)
                    legend('Campus','Battery Charging','H_2 Production','Export','Location','Best')
                    set(gcf,'Position',[(100 + ii*40) (50 + ii*20) 500 275])
                    hold off
                    
                end
                
            end
            
        end
        
        
        function PlotOtherResults(obj, PlotLCOE, PlotCostOfCO2, PlotCapitalCost)
            
            %--------------------------------------------------------------------------
            %        SHOW OTHER RESULTS
            %--------------------------------------------------------------------------
            plotLimits = [obj.cfgManager.co2_red(1) obj.cfgManager.co2_red(length(obj.cfgManager.co2_red))] * 100;
            
            if ~isempty(PlotLCOE)
                
                % Plot 'LCOE ($/kWh)'
                PlotLCOE.Title.String = "Levelized Cost of Electricity";
                hold(PlotLCOE,'on');
                plot(PlotLCOE, obj.optimizationRecordings.co2_emissions_red, obj.optimizationRecordings.financials.lcoe,'LineWidth',2);
                PlotLCOE.Box = "on";
                PlotLCOE.XGrid = "on";
                PlotLCOE.YGrid = "on";
                ylabel(PlotLCOE,'LCOE ($/kWh)','FontSize',18);
                xlabel(PlotLCOE,'CO_2 Reduction (%)','FontSize',18);
                PlotLCOE.XLim = plotLimits;
                PlotLCOE.Visible = true;
                
            else
                
                figure("Name","Levelized Cost of Electricity");
                hold on
                plot(obj.optimizationRecordings.co2_emissions_red, obj.optimizationRecordings.financials.lcoe,'LineWidth',2);
                box on
                grid on
                ylabel('LCOE ($/kWh)','FontSize',18)
                xlabel('CO_2 Reduction (%)','FontSize',18)
                set(gcf,'Position',[800 50 500 275])
                xlim(plotLimits)
                hold off
                
            end
            
            if ~isempty(PlotCostOfCO2)
                
                % Plot 'Cost of Carbon'
                
                PlotCostOfCO2.Title.String = "Cost of Carbon";
                hold(PlotCostOfCO2,'on');
                plot(PlotCostOfCO2, obj.optimizationRecordings.co2_emissions_red,obj.optimizationRecordings.financials.cost_of_co2,'LineWidth',2)
                plot(PlotCostOfCO2, obj.optimizationRecordings.co2_emissions_red,obj.optimizationRecordings.financials.cost_of_co2_marginal,'LineWidth',2)
                PlotCostOfCO2.Box = "on";
                PlotCostOfCO2.XGrid = "on";
                PlotCostOfCO2.YGrid = "on";
                ylabel(PlotCostOfCO2,'Cost of CO_2 ($/tonne)','FontSize',18)
                xlabel(PlotCostOfCO2,'CO_2 Reduction (%)','FontSize',18)
                PlotCostOfCO2.XLim = plotLimits;
                legend(PlotCostOfCO2,'Average Cost','Marginal Cost','Location','NorthWest')
                PlotCostOfCO2.Visible = true;
                
            else
                
                figure("Name","Cost of Carbon");
                hold on
                plot(obj.optimizationRecordings.co2_emissions_red,obj.optimizationRecordings.financials.cost_of_co2,'LineWidth',2)
                plot(obj.optimizationRecordings.co2_emissions_red,obj.optimizationRecordings.financials.cost_of_co2_marginal,'LineWidth',2)
                box on
                grid on
                ylabel('Cost of CO_2 ($/tonne)','FontSize',18)
                xlabel('CO_2 Reduction (%)','FontSize',18)
                set(gcf,'Position',[800 300 500 275])
                xlim(plotLimits)
                legend('Average Cost','Marginal Cost','Location','NorthWest')
                hold off
                
            end
            
            if ~isempty(PlotCapitalCost)
                
                %%% Plot 'Capital Requirements'
                
                PlotCapitalCost.Title.String = "Capital Requirements";
                hold(PlotCapitalCost,'on');
                plot(PlotCapitalCost, obj.optimizationRecordings.co2_emissions_red,sum(obj.optimizationRecordings.financials.cap_cost,2)./1000000,'LineWidth',2)
                PlotCapitalCost.Box = "on";
                PlotCapitalCost.XGrid = "on";
                PlotCapitalCost.YGrid = "on";
                ylabel(PlotCapitalCost,'Capital Cost ($MM)','FontSize',18)
                xlabel(PlotCapitalCost,'CO_2 Reduction (%)','FontSize',18)
                PlotCapitalCost.XLim = plotLimits;
                PlotCapitalCost.Visible = true;
                
            else
                
                figure("Name","Capital Requirements");
                hold on
                plot(obj.optimizationRecordings.co2_emissions_red,sum(obj.optimizationRecordings.financials.cap_cost,2)./1000000,'LineWidth',2)
                box on
                grid on
                ylabel('Capital Cost ($MM)','FontSize',18)
                xlabel('CO_2 Reduction (%)','FontSize',18)
                set(gcf,'Position',[800 600 500 275])
                xlim(plotLimits)
                hold off
                
            end
            
        end
        
    end
    
    
    %--------------------------------------------------------------------------
    %--------------------------------------------------------------------------
    %--------------------------------------------------------------------------
    
    
    events
        NewDataAvailable
    end
end

