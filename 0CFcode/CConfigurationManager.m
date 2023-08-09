classdef CConfigurationManager < handle
    
    properties (SetAccess = public)

        demo_files_path
        demo_data_path
        yalmip_master_path
        matlab_path
        results_path

        co2_base                    % Baseline CO2 emissions [Kg]
        co2_red                     % CO2 Desired reduction [%]
        co2_lim

        year_idx
        month_idx
        saveResultsToFile
        
        chiller_plant_opt           % Optimize chiller plant operation

        % Adoptable technologies toggles    1:on 0:off ??

        utility_exists              % Utility access    
        pv_on                       % Turn on PV
        ees_on                      % Turn on EES/REES
        rees_on                     % Turn on REES

        fuel_cell_binary_on         %Turn on DG with binary purchase option

        % Community/Utility Scale systems
        util_solar_on
        util_wind_on
        util_ees_on
        util_el_on
        util_h2_inject_on
        
        % Hydrogen technologies
        el_on               % Turn on generic electrolyer
        rel_on              % Turn on renewable tied electrolyzer
        h2es_on             % Hydrogen energy storage
        hrs_on              % Turn on hydrogen fueling station
        h2_inject_on        % Turn on H2 injection into pipeline
        
        % Legacy System Toggles
        lpv_on              % Turn on legacy PV
        lees_on             % Legacy EES
        ltes_on             % Legacy TES
        ldg_on              % Turn on legacy GT
        lbot_on             % Turn on legacy bottoming cycle / Steam turbine
        lhr_on              % Legacy HR
        ldb_on              % Legacy Duct Burner
        lboil_on            % Legacy boilers
        
        % Utility PV Solar
        util_pv_wheel       % General Wheeling Capabilities
        util_pv_wheel_lts   % Wheeling for long term storage
        util_pp_import      % Can import power at power plant node
        util_pp_export      % Can import power at power plant node
        
        % Utility H2 production
        util_h2_sale
        util_h2_pipe_store
        
        % Strict storage design
        strict_h2es
        
        % Legacy Generator Options
        ldg_op_state        % Generator can turn on/off
        lbot_op_state        % Steam turbine can turn on/off
        
        % Gas turbine cycling costs
        dg_legacy_cyc
        
        % H2 fuel limit in legacy generator (Used in opt_gen_inequalities)
        % Fuel limit on an energy basis - should be 0.1
        h2_fuel_limit

        %% Island operation
        
        % Electric rates for UCI
        % 1: current rate, which does not value export
        % 2: current import rate + LMP export rate
        % 3: LMP Rate + 0.2 and LMP Export
        uci_rate
        
        island
        
        % Toggles NEM/Wholesale export (1 = on, 0 = off)
        export_on % Tied to PV and REES export under current utility rates (opt_PV, opt_ees)
        
        % General export
        gen_export_on % Placed a "general export" capability in the general electrical energy equality system (opt_gen_equalities)

        % Fuel Related Toggles

        % Available biogas/renewable gas per year (biogas limit is prorated in the model to the simulation period)
        % Used in opt_gen_inequalities
        biogas_limit                    % kWh - biofuel availabe per year - based on Matt Gudorff emails/pptx

        % Required fuel input (Used in opt_gen_inequalities)
        h2_fuel_forced_fraction         % Energy fuel requirements

        % Turning incentives and other financial tools on/off
        sgip_on

        % Throughput requirement - DOE H2 Integration
        h2_charging_rec                 %Required throughput per day

        % PV (opt_pv.m)
        % maxpv is maximum capacity that can be installed. If includes different
        % orientations, set maxpv to row vector: for example maxpv =
        % [max_north_capacity  max_east/west_capacity  max_flat_capacity  max_south_capacity]
        maxpv
        toolittle_pv        % Forces solar PV adoption - value is defined by toolittle_pv value - kW
        curtail             % Allows curtailment is = 1

        % EES (opt_ees.m & opt_rees.m)
        toolittle_storage  % Forces EES adoption - 13.5 kWh
        socc               % SOC constraint: for each individual ees and rees, final SOC >= Initial SOC

        % Grid limits
        % On/Off Grid Import Limit
        grid_import_on

        % Limit on grid import power
        import_limit

        % Placeholders
        dc_exist
        low_income
        sgip_pbi
        res_units

        % Fixed Cost Defines

        % T&D charge ($/kWh)
        t_and_d

        % Placeholder natural gas cost
        ng_cost
        rng_cost
        rng_storage_cost
        ng_inject
        
        %Placeholder for H2 cost that is purchased form another source
        h2_cost

        % Including Required Return with Capital Payment (1 = Yes)
        req_return_on

        onoff_model


        % Capital Cost Calculations
        interestRateOnLoans
        lengthOfLoansYears
       
    end

    properties (SetAccess = private)

    end


    methods

        %--------------------------------------------------------------------------
        function obj = CConfigurationManager()

            obj.ResetToDefault();

        end
        
        %--------------------------------------------------------------------------
        function ResetToDefault(obj)

            obj.SetRunningEnvironment(1);       % 1 - Robert's PC

            obj.co2_base = [];
            obj.co2_red = 0;
            obj.co2_lim = 0;
            obj.year_idx = 2018;
            obj.month_idx = [1 4 7 10];
%             obj.month_idx = [1];
            obj.saveResultsToFile = false;
            obj.chiller_plant_opt = 0;          % what is 0 o 1??
            
            % Adoptable technologies toggles
            obj.utility_exists = 1;
            obj.pv_on = 1;
            obj.ees_on = 1;
            obj.rees_on = 0;
            
            obj.fuel_cell_binary_on = 1; %Fuel Cell with binary option
            
            % Community/Utility Scale systems
            obj.util_solar_on = 0;
            obj.util_wind_on = 0;
            obj.util_ees_on = 0;
            obj.util_el_on = 0;
            obj.util_h2_inject_on = 0;

            % Hydrogen technologies
            obj.el_on = 1;
            obj.rel_on = 1;
            obj.h2es_on = 1;
            obj.hrs_on = 0;
            obj.h2_inject_on = 0;
            
            % Legacy System Toggles
            obj.lpv_on = 0;
            obj.lees_on = 0;
            obj.ltes_on = 0;
            obj.ldg_on = 0;
            obj.lbot_on = 0;
            obj.lhr_on = 0;
            obj.ldb_on = 0;
            obj.lboil_on = 0;
            
            % Utility PV Solar
            obj.util_pv_wheel = 0;
            obj.util_pv_wheel_lts = 0;
            obj.util_pp_import = 0;
            obj.util_pp_export = 0;
            
            % Utility H2 production
            obj.util_h2_sale = 0;
            obj.util_h2_pipe_store = 0;
            
            % Strict storage design
            obj.strict_h2es = 0;
            
            % Legacy Generator Options
            obj.ldg_op_state = 0;
            obj.lbot_op_state = 0;
            
            % Gas turbine cycling costs
            obj.dg_legacy_cyc = 1;
            
            % H2 fuel limit in legacy generator
            obj.h2_fuel_limit = 1;
            
            %% Island operation
            % Electric rates for UCI
            obj.uci_rate = 3;

            obj.island = 0;

            % Toggles NEM/Wholesale export (1 = on, 0 = off)
            obj.export_on = 0;

            % General export
            obj.gen_export_on = 0;

            % Fuel Related Toggles
            obj.biogas_limit = 0; % 491265*293.1; % kWh - biofuel availabe per year - based on Matt Gudorff emails/pptx

            obj.h2_fuel_forced_fraction = []; % Energy fuel requirements

            obj.sgip_on = 0; % incentives and other financial tools OFF

            obj.h2_charging_rec = [];       % DOE H2 Integration required throughput per day

            obj.maxpv = 300000;
            obj.toolittle_pv = 0;
            obj.curtail = 1;

            obj.toolittle_storage = 1;
            obj.socc = 0;

            obj.grid_import_on = 1;
            obj.import_limit = .6;

            obj.dc_exist = 1;
            obj.low_income = 0;
            obj.sgip_pbi = 1;
            obj.res_units = 0;

            %  Fixed Cost Defines

            obj.t_and_d = 0.01; % ($/kWh)

            % natural gas cost
            obj.ng_cost = 0.5/29.3; %$/kWh --> Converted from $/therm to $/kWh, 29.3 kWh / 1 Therm
            obj.rng_cost = 2.*obj.ng_cost;
            obj.rng_storage_cost = 0.2/29.3;
            obj.ng_inject = 0.05/29.3; %$/kWh --> Converted from $/therm to $/kWh, 29.3 kWh / 1 Therm

%%%Regular H2 cost
obj.h2_cost = 4/120*105.5 + 0*(8/120*105.5 + 0.6)/29.3;

            % Including Required Return with Capital Payment (1 = Yes)
            obj.req_return_on = 1;

            obj.onoff_model = 1;

            obj.interestRateOnLoans = 0.08;
            obj.lengthOfLoansYears = 10;


        end

        
        %--------------------------------------------------------------------------
        function SetRunningEnvironment(obj, mode)

            if mode == 1                    % 1 - Robert's PC
            
                obj.demo_files_path = 'H:\_Tools_\DERopt';
                obj.demo_data_path = 'H:\_Tools_\DERopt\Data';
                obj.results_path = 'H:\_Tools_\UCI_Results\Sc19';
            
                obj.yalmip_master_path = 'H:\Matlab_Paths\YALMIP-master';
                obj.matlab_path = 'C:\Program Files\MATLAB\R2014b\YALMIP-master';
            
            
            elseif mode == 2                    % 2 - Roman's Laptop
            
                obj.demo_files_path = 'C:\MotusVentures\DERopt';
                obj.demo_data_path = 'C:\MotusVentures\DERopt\Data';
                obj.results_path = 'C:\MotusVentures\DERopt\SolveResults';
            
                obj.yalmip_master_path = 'C:\MotusVentures\YALMIP-master';
                obj.matlab_path = 'C:\Program Files\MATLAB\R2023a\YALMIP-master';

            elseif mode == 3                    % 3 - Roman's Desktop
            
                obj.demo_files_path = 'E:\MotusVentures\DERopt';
                obj.demo_data_path = 'E:\MotusVentures\DERopt\Data';
                obj.results_path = 'E:\MotusVentures\DERopt\SolveResults';
            
                obj.yalmip_master_path = 'C:\MotusVentures\YALMIP-master';
                obj.matlab_path = 'C:\Program Files\MATLAB\R2023a\YALMIP-master';
            
           	else                                % 4 - Bruce's PC
            
                obj.demo_files_path = 'E:\MotusVentures\DERopt';
                obj.demo_data_path = 'E:\MotusVentures\DERopt\Data';
                obj.results_path = 'E:\MotusVentures\DERopt\SolveResults';
            
                obj.yalmip_master_path = 'C:\MotusVentures\YALMIP-master';
                obj.matlab_path = 'C:\Program Files\MATLAB\R2019b\YALMIP-master';
  
            end

        end


        %--------------------------------------------------------------------------
        function SetUpFirstCO2Limit(obj)

            obj.co2_lim = obj.co2_base * (1 - obj.co2_red(1));

        end

        %--------------------------------------------------------------------------
        function AddMatlabPaths(obj)
            
            %%%YALMIP Master Path
            addpath(genpath(obj.yalmip_master_path)) %rjf path
            addpath(genpath(obj.matlab_path)) %cyc path
            
            %%%CPLEX Path
            addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64')) %rjf path
            addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio1263\cplex\matlab\x64_win64')) %cyc path
            
            %%%DERopt paths
            addpath(genpath(append(obj.demo_files_path, '\0CFcode')))
            addpath(genpath(append(obj.demo_files_path, '\Classes')))
            addpath(genpath(append(obj.demo_files_path, '\Data')))

        end


        %--------------------------------------------------------------------------
        function [numberSteps] = CalculateInitialPathCO2Reduction(obj, reductionBegin, reductionFinish, reductionStep)

            obj.co2_red = reductionBegin/100:reductionStep/100:reductionFinish/100;

            numberSteps = length(obj.co2_red);
        end

    end
end

