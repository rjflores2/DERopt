classdef CModelSolver < handle

    % This class receives "Constraints" and "Objective" and handles
    % how the model is constructed and solved

    properties (SetAccess = public)

        lastSolveCplexFunction
        lastSolveX
        lastSolveFval
        lastSolveExitFlag
        lastSolveOutput
        lastSolveLambda

        % Utility Variables
        utilityImport
        utilityNontouDc
        utilityOnpeakDc
        utilityMidpeakDc
        utilityGenExport
            
        % Solar Variables
        solarPhotoVoltaicAdopt
        solarPhotoVoltaicElec
        solarPhotoVoltaicNem
    
        % Electrical Energy Storage
        electricalEnergyStorage_adopt
        electricalEnergyStorage_chrg
        electricalEnergyStorage_dchrg
        electricalEnergyStorage_soc
        
        % Renewable Electrical Energy Storage
        renewableElectricalEnergyStorage_adopt
        renewableElectricalEnergyStorage_chrg
        renewableElectricalEnergyStorage_dchrg
        renewableElectricalEnergyStorage_soc
        renewableElectricalEnergyStorage_dchrg_nem
        
        % H2 Production - Electrolyzer
        h2ProductionElectrolyzer_adopt
        h2ProductionElectrolyzer_prod
        
        % H2 Production - Renewable Electrolyzer
        h2ProductionRenewableElectrolyzer_adopt
        h2ProductionRenewableElectrolyzer_prod
        h2ProductionRenewableElectrolyzer_prod_wheel
        
        % H2 Production - Storage
        h2ProductionEnergyStorage_adopt
        h2ProductionEnergyStorage_chrg
        h2ProductionEnergyStorage_dchrg
        h2ProductionEnergyStorage_soc
        h2ProductionEnergyStorage_bin

        % DG - Topping Cycle
        ldg_elec
        ldg_fuel
        ldg_rfuel
        ldg_hfuel
        ldg_sfuel
        ldg_dfuel
        ldg_elec_ramp
        ldg_off
        ldg_opstate
        % Bottoming Cycle
        lbot_elec
        lbot_on
        
        % Heat Recovery Systems
        ldg_hr_heat
        ldg_db_fire
        ldg_db_rfire
        ldg_db_hfire

        % Boiler
        boiler_fuel
        boiler_rfuel
        boiler_hfuel
        
        % Legacy EES
        lees_chrg
        lees_dchrg
        lees_soc

        %% Carbon Emissions
        co2EmissionsUtilityElect
        co2EmissionsNaturalGas
        co2EmissionsRenewableNaturalGas
        co2TotalEmissions

        % Percent reduciton
        co2EmissionsReductionPercentaje

        co2BaselineEmissions

        %% Financials

        %($/kWh)
        levelizedCostOfElectricityInKWh
            
        %Bulk cost of carbon ($/tonne)
        BulkCostOfCarbonByTonne
            
        %Marginal cost of carbon ($/tonne)
        marginalCostOfCarbonByTonne

        %Capital Cost Requirements
        capitalCostRequirements

    end

    properties (SetAccess = private)
        lModelCreated = false;
        lSolverSettings
        lLowerBounds
        lUpperBounds
        lConstraintsData
        lObjectiveData
        lModel
        lRecoveryModel
        lExportDiagnostic
        lExportInternalModel
        lCO2LimitIndex
        lCo2TotalEmissionsFirstLoop
        lFvalFirstLoop
        lTotalElectricityLoad
        lCo2LimitIndex
        lCo2ImportData
        lCo2RatesNaturalGas
        lCo2RatesRenewableNaturalGas
    end
    
    methods

        %% Constructor
        function obj = CModelSolver()
            obj.lModelCreated = false;
        end
        

        %% Create model with YALMIP
        function elapsedTimeSeconds = CreateModel(obj, Constraints, Objective, firstCO2Limit)

            obj.lConstraintsData = Constraints;
            obj.lObjectiveData = Objective;

            % Export Model YALMIP -> CPLEX
            tic
            [obj.lModel, obj.lRecoveryModel, obj.lExportDiagnostic, obj.lExportInternalModel] = export(Constraints,Objective,sdpsettings('solver','cplex'));
            elapsedTimeSeconds = toc;

            % Other limits and settings
    
            % Setting lower/upper bounds for all variables
            obj.lLowerBounds = zeros(size(obj.lModel.f));
            obj.lUpperBounds = inf(size(obj.lLowerBounds));
    
            % Solver settings
            obj.lSolverSettings = sdpsettings('solver','cplex','verbose',1);
        
            % Finding location of carbon constraing in model.bineq           
            obj.lCo2LimitIndex = find(obj.lModel.bineq == firstCO2Limit);

            obj.lModelCreated = true;
            
        end

        %% Setup Solved Initial Values
        function processResult = SetupFirstSolve(obj, co2Limit, co2BaselineEmissionskg, totalElectricityLoad, co2ImportData, co2RatesNaturalgas, co2RatesRenewableNaturalGas)

            processResult = false;

            if obj.lModelCreated

                % Finding location of carbon constraing in model.bineq    
                obj.lCO2LimitIndex = find(obj.lModel.bineq == co2Limit);

                obj.co2BaselineEmissions = co2BaselineEmissionskg;

                obj.lTotalElectricityLoad = totalElectricityLoad;

                obj.lCo2ImportData = co2ImportData;

                obj.lCo2RatesNaturalGas = co2RatesNaturalgas;
                obj.lCo2RatesRenewableNaturalGas = co2RatesRenewableNaturalGas;

                processResult = true;
            end
        end


        %% Model Sover
        function elapsedTimeSeconds = SolveModel(obj, iterationIndex, co2Reduction, modelVars)
       
            %If this is not the 1st iteration, update the CO2 limit
            if iterationIndex > 1
                obj.lModel.bineq(obj.lCO2LimitIndex) = obj.co2BaselineEmissions*(1-co2Reduction);
            end
                        
            x = [];
                    
            tic
            
            if (sum(strfind(obj.lModel.ctype,'B') > 0) + sum(strfind(obj.lModel.ctype,'I')) > 0)
                
                obj.lastSolveCplexFunction = "cplexmilp";
                [x, fval, exitflag, output] = cplexmilp(obj.lModel.f, obj.lModel.Aineq, obj.lModel.bineq, ...
                                                        obj.lModel.Aeq, obj.lModel.beq, [],[],[], obj.lLowerBounds, ...
                                                        obj.lUpperBounds, obj.lModel.ctype,x, obj.lSolverSettings);
                lambda = 0;

            else
                
                obj.lastSolveCplexFunction = "cplexlp";
                [x, fval, exitflag, output, lambda] = cplexlp(obj.lModel.f, obj.lModel.Aineq, obj.lModel.bineq, ...
                                                            obj.lModel.Aeq, obj.lModel.beq, obj.lLowerBounds, ...
                                                            obj.lUpperBounds, [], obj.lSolverSettings);

            end
            
            elapsedTimeSeconds = toc;
            

            %% Recovering data and assigning to the YALMIP variables
            assign(recover(obj.lRecoveryModel.used_variables),x)

            %     cplex = Cplex(obj.lModel); %instantiate object cplex of class Cplex
            %     cplex.solve() %metod solve() to create Solution dynamic property
            %     cplex.Solution.status
            %     cplex.Solution.miprelgap

            %% Starting Recorder Structure - Model Outputs
            obj.lastSolveX = x;
            obj.lastSolveFval = fval;
            obj.lastSolveExitFlag = exitflag;
            obj.lastSolveOutput = output;
            obj.lastSolveLambda = lambda;
            
            %% Optimized Variables -  Utilities
            
            % Utility Variables
            obj.utilityImport = value(modelVars.utilImport);
            obj.utilityNontouDc = value(modelVars.utilNontouDc);
            obj.utilityOnpeakDc = value(modelVars.utilOnpeakDc);
            obj.utilityMidpeakDc = value(modelVars.utilMidpeakDc);
            obj.utilityGenExport = value(modelVars.utilGeneralExport);
            
            %% Optimized Variables - New Technologies
            % Solar Variables
            obj.solarPhotoVoltaicAdopt = value(modelVars.pvAdopt);
            obj.solarPhotoVoltaicElec = value(modelVars.pvElect);
            obj.solarPhotoVoltaicNem = value(modelVars.pvNem);

            % Electrical Energy Storage
            obj.electricalEnergyStorage_adopt = value(modelVars.eesAdopt);
            obj.electricalEnergyStorage_chrg = value(modelVars.eesChrg);
            obj.electricalEnergyStorage_dchrg = value(modelVars.eesDchrg);
            obj.electricalEnergyStorage_soc = value(modelVars.eesSoc);
            
            % Renewable Electrical Energy Storage
            obj.renewableElectricalEnergyStorage_adopt = value(modelVars.reesAdopt);
            obj.renewableElectricalEnergyStorage_chrg = value(modelVars.reesChrg);
            obj.renewableElectricalEnergyStorage_dchrg = value(modelVars.reesDchrg);
            obj.renewableElectricalEnergyStorage_soc = value(modelVars.reesSoc);
            obj.renewableElectricalEnergyStorage_dchrg_nem = value(modelVars.reesDchrgNem);

            % H2 Production - Electrolyzer
            obj.h2ProductionElectrolyzer_adopt = value(modelVars.el_adopt);
            obj.h2ProductionElectrolyzer_prod = value(modelVars.el_prod);
            
            % H2 Production - Renewable Electrolyzer
            obj.h2ProductionRenewableElectrolyzer_adopt = value(modelVars.rel_adopt);
            obj.h2ProductionRenewableElectrolyzer_prod = value(modelVars.rel_prod);
            obj.h2ProductionRenewableElectrolyzer_prod_wheel = value(modelVars.rel_prod_wheel);
            
            % H2 Production - Storage
            obj.h2ProductionEnergyStorage_adopt = value(modelVars.h2es_adopt);
            obj.h2ProductionEnergyStorage_chrg = value(modelVars.h2es_chrg);
            obj.h2ProductionEnergyStorage_dchrg = value(modelVars.h2es_dchrg);
            obj.h2ProductionEnergyStorage_soc = value(modelVars.h2es_soc);
            obj.h2ProductionEnergyStorage_bin = value(modelVars.h2es_bin);

            %% Optimized Variables -  Legacy technologies %%
            % DG - Topping Cycle
            obj.ldg_elec = value(modelVars.ldg_elec);
            obj.ldg_fuel = value(modelVars.ldg_fuel);
            obj.ldg_rfuel = value(modelVars.ldg_rfuel);
            obj.ldg_hfuel = value(modelVars.ldg_hfuel);
            obj.ldg_sfuel = value(modelVars.ldg_sfuel);
            obj.ldg_dfuel = value(modelVars.ldg_dfuel);
            obj.ldg_elec_ramp = value(modelVars.ldg_elec_ramp);
            %obj.ldg_off = value(modelVars.ldg_off);
            obj.ldg_opstate = value(modelVars.ldg_opstate);
            
            % Bottoming Cycle
            obj.lbot_elec = value(modelVars.lbot_elec);
            obj.lbot_on = value(modelVars.lbot_on);
            
            % Heat Recovery Systems
            obj.ldg_hr_heat = value(modelVars.hr_heat);
            obj.ldg_db_fire = value(modelVars.db_fire);
            obj.ldg_db_rfire = value(modelVars.db_rfire);
            obj.ldg_db_hfire = value(modelVars.db_hfire);

            % Boiler
            obj.boiler_fuel = value(modelVars.boil_fuel);
            obj.boiler_rfuel = value(modelVars.boil_rfuel);
            obj.boiler_hfuel = value(modelVars.boil_hfuel);
            
            % EES
            obj.lees_chrg = value(modelVars.lees_chrg);
            obj.lees_dchrg = value(modelVars.lees_dchrg);
            obj.lees_soc = value(modelVars.lees_soc);


            %% Carbon Emissions

            obj.co2EmissionsUtilityElect = sum(obj.utilityImport.*obj.lCo2ImportData);

            obj.co2EmissionsNaturalGas = obj.lCo2RatesNaturalGas*(sum(sum(obj.ldg_fuel)) + sum(sum(obj.ldg_db_fire)) + sum(sum(obj.boiler_fuel)));

            obj.co2EmissionsRenewableNaturalGas = obj.lCo2RatesRenewableNaturalGas*(sum(sum(obj.ldg_rfuel)) + sum(sum(obj.ldg_db_rfire)) + sum(sum(obj.boiler_rfuel)));

            obj.co2TotalEmissions = obj.co2EmissionsUtilityElect + obj.co2EmissionsNaturalGas + obj.co2EmissionsRenewableNaturalGas;

            % Save for succesive iterations
            if iterationIndex == 1
                obj.lCo2TotalEmissionsFirstLoop = obj.co2TotalEmissions;
                obj.lFvalFirstLoop = obj.lastSolveFval;
            end

            % Percent reduciton
            obj.co2EmissionsReductionPercentaje = 100.*(obj.lCo2TotalEmissionsFirstLoop - obj.co2TotalEmissions)./obj.lCo2TotalEmissionsFirstLoop;


            %% Financials
            %($/kWh)
            obj.levelizedCostOfElectricityInKWh = obj.lastSolveFval./obj.lTotalElectricityLoad;
            
            %Bulk cost of carbon ($/tonne)
            obj.BulkCostOfCarbonByTonne = abs((obj.lastSolveFval - obj.lFvalFirstLoop)/((obj.co2TotalEmissions - obj.lCo2TotalEmissionsFirstLoop)./1000));


            %Marginal cost of carbon ($/tonne)
            % if ii > 1
            %     obj.marginalCostOfCarbonByTonne = abs((rec.solver.fval(ii,1) - rec.solver.fval(ii-1,1))/((rec.co2_emissions(4,ii) - rec.co2_emissions(4,ii-1))./1000));
            % else 
            %     obj.marginalCostOfCarbonByTonne = NaN;
            % end
            
            %%%Capital Cost Requirements
            % obj.capitalCostRequirements = [obj.solarPhotoVoltaicAdopt.*pv_cap*pv_cap_mod
            %                             obj.electricalEnergyStorage_adopt.*ees_cap.*ees_cap_mod
            %                             obj.renewableElectricalEnergyStorage_adopt.*ees_cap.*rees_cap_mod
            %                             obj.h2ProductionElectrolyzer_adopt.*el_cap.*el_cap_mod
            %                             obj.h2ProductionRenewableElectrolyzer_adopt.*el_cap.*rel_cap_mod
            %                             obj.h2ProductionEnergyStorage_adopt.*h2es_cap];
                
            %% Resetting CO2 baseline limit
            %If economic operation yields lower emissions than the initial estimate
            if iterationIndex == 1 && obj.co2TotalEmissions < obj.co2BaselineEmissions

                % Then set "co2_base" variable to the economic dispatch level
                obj.co2BaselineEmissions = obj.co2TotalEmissions;
            end

        end       
    end
end

