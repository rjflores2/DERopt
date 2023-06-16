classdef CEnergyGenerationTechnology  < handle

    % We are not using sub classing becuase we cannot create collections of
    % classes of different types. See:
    % https://www.mathworks.com/help/matlab/matlab_oop/hierarchies-of-classes-concepts.html
    
    properties

        Name string
        TechType CTypeTechnology

        Capital double

        CapitalCost double
        CapitalCostUnits CTypeUnits
        CapitalCostModifiers double
        CapitalCostModifiersTypes CTypeBuilding

        EnergyOutput double
        EnergyOutputUnits CTypeUnits
        Efficiency double
        EfficiencyUnits CTypeUnits

        EnergyOutputDischarging double
        EnergyOutputDischargingUnits CTypeUnits
        EfficiencyDischarging double
        EfficiencyDischargingUnits CTypeUnits

        CompetingHydrogenCost double
        CompetingHydrogenCostUnits CTypeUnits

        StateOfChargeMinimum double             % Percentage
        StateOfChargeMaximum double             % Percentage
        StateOfChargeHoldover double            % unit??
        ChargeRateMaximum double                % Capacity/hr
        DischargeRateMaximum double             % Capacity/hr

        FinancialScalingFactor double
        FinancialMacrsSchedule double           % MACRS Schedule
        FinancialItcBenefit double              % ITC Benefit

        % Self generation incentive program (SGIP)

        SgipC02ReductionRequired double
        SgipLargeStorageIncentive double
        SgipLargeStorageIncentiveThreshold double
        SgipResidentialStorageIncentive double
        SgipEquityRate double
        SgipKiloWattHourIncrement double

        SOMAH double                            % Solar on multifamily affordable homes

    end
    
    methods (Access = public)

        function obj = CEnergyGenerationTechnology(technologyType, assetName )

            obj.TechType = technologyType;
            obj.Name = assetName;

            obj.SetDefaultValues();            
        end

    end

    methods (Access = private)

        function SetDefaultValues(obj)

            switch obj.TechType

                % -----------------------------------------------------
                % -----------------------------------------------------
                case GenericElectrolizer

                    % (1) Captail Cost ($/kW H2 produced)
                    obj.CapitalCost = 2100;
                    obj.CapitalCostUnits = CTypeUnits.DollarsPerkiloWatt;

                    % (2) Variable O&M ($/kWh H2 produced)
                    obj.EnergyOutput = 0.01;
                    obj.EnergyOutputUnits = CTypeUnits.DollarsPerkiloWattHour;
            
                    % (3) Electrolyzer efficiency (kWh H2/kWh elec)
                    obj.Efficiency = 0.6;
                    obj.EfficiencyUnits = CTypeUnits.DollarsPerkiloWattHour;

                    obj.FinancialScalingFactor = -0.02;   % Based on CA Roadmap - 2k H2 per day vs. 20k H2 per day
                    obj.FinancialMacrsSchedule = 5;
                    obj.FinancialItcBenefit = 1;

                    % obj.el_cap = obj.el_v;            ????


                % -----------------------------------------------------
                % -----------------------------------------------------
                case GenericEnergyStorage

                    % (1) Capital Cost ($/kWh installed)
                    obj.CapitalCost = 830;
                    obj.CapitalCostUnits = CTypeUnits.DollarsPerkiloWatt;

                    % -----------------------------------------------------

                    % (2) Charge O&M ($/kWh charged)
                    obj.EnergyOutput = 0.001;
                    obj.EnergyOutputUnits = CTypeUnits.DollarsPerkiloWattHour;

                    % (8) Charging efficiency
                    obj.Efficiency = 0.90;
                    obj.EfficiencyUnits = CTypeUnits.NotDefined; % ???

                    % (3) Discharge O&M ($/kWh discharged)
                    obj.EnergyOutputDischarging = 0.001;
                    obj.EnergyOutputDischargingUnits = CTypeUnits.DollarsPerkiloWattHour;

                    % (9) Discharging efficiency
                    obj.EfficiencyDischarging = 0.90;
                    obj.EfficiencyDischargingUnits = CTypeUnits.NotDefined; % ???

                    % (4) Minimum state of charge
                    obj.StateOfChargeMinimum = 0.1;

                    % (5) Maximum state of charge
                    obj.StateOfChargeMaximum = 0.95;

                    % (10) State of charge holdover
                    obj.StateOfChargeHoldover = .995;

                    % (6) Maximum charge rate (% Capacity/hr)
                    obj.ChargeRateMaximum = 0.25;

                    % (7) Maximum discharge rate (% Capacity/hr)
                    obj.DischargeRateMaximum = 0.25;

                    % -----------------------------------------------------

                    %How pv capital cost is modified for different types of buildings
                    obj.CapitalCostModifiers = [575/830 830/830];
                    obj.CapitalCostModifiersTypes = [CTypeBuilding.CommercialOrIndustrial CTypeBuilding.Residential ];

                    obj.FinancialScalingFactor = -0.1306;   % Based on Lazards cost of electricity
                    obj.FinancialMacrsSchedule = 7;
                    obj.FinancialItcBenefit = 0;

                    % 1:CO2 reduction required per kWh for large scale systems
                    obj.SgipC02ReductionRequired = 5;
                    % 2: Large storage incentive($/kWh)                    
                    obj.SgipLargeStorageIncentive = 350;
                    %Non_residential rates that receive sgip(2) incentive
                    obj.SgipLargeStorageIncentiveThreshold = [1 2];
                    % 3: Residential storage incentive ($/kWh)
                    obj.SgipResidentialStorageIncentive = 200;
                    % 4: Equity rate ($/kWh)
                    obj.SgipEquityRate = 850;
                    % 5: kWh incriment at which SGIP decreases
                    obj.SgipKiloWattHourIncrement = 2000;

                    % obj.h2es_cap = obj.h2es_v(1);           ????


                % -----------------------------------------------------
                % -----------------------------------------------------
                case HydrogenEnergyStorage

                    % (1) Capital Cost ($/kWh installed)
                    obj.CapitalCost = 60;
                    obj.CapitalCostUnits = CTypeUnits.DollarsPerkiloWatt;

                    % -----------------------------------------------------

                    % (2) Charge O&M ($/kWh charged)
                    obj.EnergyOutput = 0.001;
                    obj.EnergyOutputUnits = CTypeUnits.DollarsPerkiloWattHour;

                    % Efficiency / Conversion Percent at 1 kW/m^2
                    % (8) Charging efficiency
                    obj.Efficiency = 0.90;
                    obj.EfficiencyUnits = CTypeUnits.NotDefined; % ???

                    % (3) Discharge O&M ($/kWh discharged)
                    obj.EnergyOutputDischarging = 0.001;
                    obj.EnergyOutputDischargingUnits = CTypeUnits.DollarsPerkiloWattHour;

                    % (9) Discharging efficiency
                    obj.EfficiencyDischarging = 0.95;
                    obj.EfficiencyDischargingUnits = CTypeUnits.NotDefined; % ???

                    % (4) Minimum state of charge
                    obj.StateOfChargeMinimum = 0.01;

                    % (5) Maximum state of charge
                    obj.StateOfChargeMaximum = 1;

                    % (10) State of charge holdover
                    obj.StateOfChargeHoldover = 1;

                    % (6) Maximum charge rate (% Capacity/hr)
                    obj.ChargeRateMaximum = 1;

                    % (7) Maximum discharge rate (% Capacity/hr)
                    obj.DischargeRateMaximum = 1;

                    % obj.h2es_cap = obj.h2es_v(1);         ????



                % -----------------------------------------------------
                % -----------------------------------------------------
                case HydrogenFuelingStationTransportation

                    % Cap cost ($/kW)
                    obj.CapitalCost = 300000000;
                    obj.CapitalCostUnits = CTypeUnits.NotDefined;

                    % (3) O&M
                    obj.EnergyOutput = 0.01;
                    obj.EnergyOutputUnits = CTypeUnits.NotDefined;

                    % (2) Compression efficiency
                    obj.Efficiency = 0.95;
                    obj.EfficiencyUnits = CTypeUnits.NotDefined;

                    % (4) Competing H2 cost ($/kWh
                    obj.CompetingHydrogenCost = 11/121*3.6;
                    obj.CompetingHydrogenCostUnits = CTypeUnits.DollarsPerkiloWattHour;



                % -----------------------------------------------------
                % -----------------------------------------------------
                case HydrogenPipelineInjection

                    %H2 injection - linear fit for capital costs
                    % (1) Capital Cost Intercept
                    % (2) Capital Cost Slope
                    %obj.h2_inject_v = 0.5*[3213860 37.6];

                % -----------------------------------------------------
                % -----------------------------------------------------
                case RenewableElectrolyzer

                    % (1) Captail Cost ($/kW H2 produced)
                    obj.CapitalCost = 2100;
                    obj.CapitalCostUnits = CTypeUnits.DollarsPerkiloWatt;

                    % (2) Variable O&M ($/kWh H2 produced)
                    obj.EnergyOutput = 0.01;
                    obj.EnergyOutputUnits = CTypeUnits.DollarsPerkiloWattHour;

                    % (3) Electrolyzer efficiency (kWh H2/kWh elec)
                    obj.Efficiency = 0.6;
                    obj.EfficiencyUnits = CTypeUnits.NotDefined;


                    obj.FinancialScalingFactor = -0.02;   % Based on CA Roadmap - 2k H2 per day vs. 20k H2 per day
                    obj.FinancialMacrsSchedule = 5;
                    obj.FinancialItcBenefit = 1;


                % -----------------------------------------------------
                % -----------------------------------------------------
                case SolarPhotoVoltaic

                    % Cap cost ($/kW)
                    obj.CapitalCost = 3000;
                    obj.CapitalCostUnits = CTypeUnits.DollarsPerkiloWatt;

                    % O&M ($/kWh generated)
                    obj.EnergyOutput = 0.001;
                    obj.EnergyOutputUnits = CTypeUnits.DollarsPerkiloWattHour;

                    % Efficiency / Conversion Percent at 1 kW/m^2
                    obj.Efficiency = 0.2;
                    obj.EfficiencyUnits = CTypeUnits.kiloWattPerSquareMeter;

                    %How pv capital cost is modified for different types of buildings
                    obj.CapitalCostModifiers = [2/2.65 2.65/2.65];
                    obj.CapitalCostModifiersTypes = [CTypeBuilding.CommercialOrIndustrial CTypeBuilding.Residential ];

                    obj.FinancialScalingFactor = -0.4648;   % Based on Lazards cost of electricity
                    obj.FinancialMacrsSchedule = 5;
                    obj.FinancialItcBenefit = 1;

                    % Specific to "SolarPhotoVoltaic"
                    obj.SOMAH = 2600;

                    % obj.pv_cap = obj.pv_v(1,:);       ???

                % -----------------------------------------------------
                % -----------------------------------------------------
                case UtilityBasedSolar

                    % Cap cost ($/kW)
                    obj.CapitalCost = 900;
                    obj.CapitalCostUnits = CTypeUnits.DollarsPerkiloWatt;

                    % O&M ($/kWh generated)
                    obj.EnergyOutput = 0.001;
                    obj.EnergyOutputUnits = CTypeUnits.DollarsPerkiloWattHour;

                    % Efficiency / Conversion Percent at 1 kW/m^2
                    obj.Efficiency = 0.2;
                    obj.EfficiencyUnits = CTypeUnits.kiloWattPerSquareMeter;

                    obj.FinancialScalingFactor = 0;   % Based on Lazards cost of electricity
                    obj.FinancialMacrsSchedule = 5;
                    obj.FinancialItcBenefit = 1;

                    
                % -----------------------------------------------------
                % -----------------------------------------------------
                case UtilityWind

                    % Cap cost ($/kW)
                    obj.CapitalCost = 1190;
                    obj.CapitalCostUnits = CTypeUnits.DollarsPerkiloWatt;

                    % O&M ($/kWh generated)
                    obj.EnergyOutput = 0.005;
                    obj.EnergyOutputUnits = CTypeUnits.DollarsPerkiloWattHour;

                    obj.FinancialScalingFactor = 0;   % Based on Lazards cost of electricity
                    obj.FinancialMacrsSchedule = 5;
                    obj.FinancialItcBenefit = 1;


                % -----------------------------------------------------
                % -----------------------------------------------------
                case UtilityScaleBattery

                    % (1) Capital Cost ($/kWh installed)
                    obj.CapitalCost = 240;
                    obj.CapitalCostUnits = CTypeUnits.DollarsPerkiloWatt;

                    % -----------------------------------------------------

                    % (2) Charge O&M ($/kWh charged)
                    obj.EnergyOutput = 0.001;
                    obj.EnergyOutputUnits = CTypeUnits.DollarsPerkiloWattHour;

                    % Efficiency / Conversion Percent at 1 kW/m^2
                    % (8) Charging efficiency
                    obj.Efficiency = 0.90;
                    obj.EfficiencyUnits = CTypeUnits.NotDefined; % ???

                    % (3) Discharge O&M ($/kWh discharged)
                    obj.EnergyOutputDischarging = 0.001;
                    obj.EnergyOutputDischargingUnits = CTypeUnits.DollarsPerkiloWattHour;

                    % (9) Discharging efficiency
                    obj.EfficiencyDischarging = 0.90;
                    obj.EfficiencyDischargingUnits = CTypeUnits.NotDefined; % ???

                    % (4) Minimum state of charge
                    obj.StateOfChargeMinimum = 0.1;

                    % (5) Maximum state of charge
                    obj.StateOfChargeMaximum = 0.95;

                    % (10) State of charge holdover
                    obj.StateOfChargeHoldover = .995;

                    % (6) Maximum charge rate (% Capacity/hr)
                    obj.ChargeRateMaximum = 0.25;

                    % (7) Maximum discharge rate (% Capacity/hr)
                    obj.DischargeRateMaximum = 0.25;

                    % -----------------------------------------------------

                    obj.FinancialScalingFactor = 0;   % Based on Lazards cost of electricity
                    obj.FinancialMacrsSchedule = 5;
                    obj.FinancialItcBenefit = 0;


                % -----------------------------------------------------
                % -----------------------------------------------------
                otherwise

                    throw(MException('Technology type not defined'))
            end

        end

    end

end

