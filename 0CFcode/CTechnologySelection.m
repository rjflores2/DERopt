classdef CTechnologySelection < handle
    
    properties (SetAccess = public)
        
        pv_v = [];
        pv_cap = [];
        pv_cap_mod = [];
        pv_fin = [];
        somah = [];

        ees_v = [];
        ees_cap = [];
        ees_cap_mod = [];
        ees_fin = [];
        rees_fin = [];
        sgip = [];
        non_res_rates = [];

        el_v = [];
        el_fin = [];
        el_cap = [];

        h2es_v = [];
        h2es_cap = [];

        rel_v = [];
        rel_fin = [];

        hrs_v = [];
        h2_inject_v = [];
        bldg_v = [];
        inv_v = [];
        xfmr_v = [];

    end
    
    methods
        function obj = CTechnologySelection()

        end

        function CalculateAllParams(obj, pv_on, ees_on, el_on, h2es_on, rel_on, hrs_on, h2_inject_on)

            if pv_on
                obj.CalcSolarPV()
            end

            if ees_on            
                obj.CalcElectricalEnergyStorage()
            end

            if el_on
                obj.CalcGenericElectrolyzer()
            end
            
            if h2es_on
                obj.CalcHydrogenEnergyStorage()
            end

            if rel_on
                obj.CalcRenewableElectrolyzer()
            end

            if hrs_on
                obj.CalcH2FuelingStationTransportation()
            end

            if h2_inject_on
                obj.CalcH2PipelineInjection()
            end
            
            obj.CalcOther()

        end


        function CalcSolarPV(obj)

            %%% Cap cost ($/kW)
            %%% Efficiency / Conversion Percent at 1 kW/m^2
            %%% O&M ($/kWh generated)
            
            obj.pv_v = [3000; 0.2 ; 0.001];
            
            %%%How pv capital cost is modified for different types of buildings
            obj.pv_cap_mod = [2/2.65 %%%Commercial/industrial
                            2.65/2.65]; %%%Residential
            
            %%%Financial Aspects - Solar PV
            obj.pv_fin = [-0.4648; ... %%%Scaling linear factor - Based on Lazards cost of electricity
                        5; ... %%%MACRS Schedule
                        1]; ... %%%ITC Benefit
                
            % pv_fin = [-0.4648; ... %%%Scaling linear factor - Based on Lazards cost of electricity
            %     0; ... %%%MACRS Schedule
            %     0]; ... %%%ITC Benefit
            
            % pv_v = [pv_v pv_v];
            % pv_fin = [pv_fin pv_fin];
            % pv_cap_mod = [pv_cap_mod pv_cap_mod];
                        
            if ~isempty(obj.pv_v)
                obj.pv_cap = obj.pv_v(1,:);
            else
                obj.pv_cap = 0;
            end

            %%%Solar on multifamily affordable homes (SOMAH)
            obj.somah = 2600;
        end


        function CalcElectricalEnergyStorage(obj)

            %%% (1) Capital Cost ($/kWh installed)
            %%% (2) Charge O&M ($/kWh charged)
            %%% (3) Discharge O&M ($/kWh discharged)
            %%% (4) Minimum state of charge
            %%% (5) Maximum state of charge
            %%% (6) Maximum charge rate (% Capacity/hr)
            %%% (7) Maximum discharge rate (% Capacity/hr)
            %%% (8) Charging efficiency
            %%% (9) Discharging efficiency
            %%% (10) State of charge holdover
            
            %ees_v=[200; 0.001; 0.001; 0.3; 0.95; 0.25; 0.25; .95; .95; .995];
            %ees_v=[195; 0.001; 0.001; 0.25; 0.99; 0.3; 0.3; .9; .85; .999];
            %ees_v=[200; 0.001; 0.001; 0.1; 0.95; 1; 1; 1; 1; 1];
            %ees_v=[200; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .95; .95; .995];
            %ees_v=[300; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .95; .95; .995];
            %ees_v=[500; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .95; .95; .995];
            obj.ees_v=[830; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .90; .90; .995];
            %ees_v=[600; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; 1; 1; .995]; %Testing with 100% RTE
            % ees_v=[100; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .90; .90; .995];
            % ees_v = [];
            
            %%%How pv capital cost is modified for different types of buildings
            obj.ees_cap_mod = [575/830 %%%Commercial/industrial
                830/830]; %%%Residential
            
            %%%Financial Aspects - EES
            obj.ees_fin = [-0.1306;... %%%Scaling linear factor - Based on Lazards cost of electricity
                7; ... %%%MACRS Schedule
                0]; ... %%%ITC Benefit
                
            %%%Financial Aspects - EES
            obj.rees_fin = [-0.1306;... %%%Scaling linear factor - Based on Lazards cost of electricity
                5; ... %%%MACRS Schedule
                1]; ... %%%ITC Benefit
                
            %%%Self generation incentive program (SGIP) values
            obj.sgip = [5 %%% 1:CO2 reduction required per kWh for large scale systems
                350 %%% 2: Large storage incentive($/kWh)
                200 %%% 3: Residential storage incentive ($/kWh)
                850 %%% 4: Equity rate ($/kWh)
                2000]; %%% 5: kWh incriment at which SGIP decreases

            %%%Non_residential rates that receive sgip(2) incentive
            obj.non_res_rates = [1 2];

            % ees_v = [ees_v ees_v];
            % ees_cap_mod = [ees_cap_mod ees_cap_mod];
            % ees_fin = [ees_fin ees_fin];
            % rees_fin = [rees_fin rees_fin];
            if ~isempty(obj.ees_v)
                obj.ees_cap = obj.ees_v(1);
            else
                obj.ees_cap = [];
            end

        end


        function CalcGenericElectrolyzer(obj)

            %%% Generic electrolyzer
            %%% (1) Captail Cost ($/kW H2 produced)
            %%% (2) Variable O&M ($/kWh H2 produced)
            %%% (3) Electrolyzer efficiency (kWh H2/kWh elec)
            obj.el_v = [2100; 0.01; 0.6];
            % el_v = [1; 0.01; .99];
            % el_v = [1; 0.01; .6];
            
            %%%Financial Aspects - Electrolyzer
            obj.el_fin = [-0.02; ... %%%Scaling linear factor - Based on CA Roadmap - 2k H2 per day vs. 20k H2 per day
                5; ... %%%MACRS Schedule
                1]; ... %%%ITC Benefit
              
            obj.el_cap = obj.el_v;

        end


        function CalcHydrogenEnergyStorage(obj)

            %%%Hydrogen energy storage
            %%% (1) Capital Cost ($/kWh installed)
            %%% (2) Charge O&M ($/kWh charged)
            %%% (3) Discharge O&M ($/kWh discharged)
            %%% (4) Minimum state of charge
            %%% (5) Maximum state of charge
            %%% (6) Maximum charge rate (% Capacity/hr)
            %%% (7) Maximum discharge rate (% Capacity/hr)
            %%% (8) Charging efficiency
            %%% (9) Discharging efficiency
            %%% (10) State of charge holdover
            obj.h2es_v = [60;0.001;0.001;0.01;1;1;1;0.95;1;1];
            obj.h2es_cap = obj.h2es_v(1);
    
        end

        function CalcRenewableElectrolyzer(obj)

            %%% Generic electrolyzer
            %%% (1) Captail Cost ($/kW H2 produced)
            %%% (2) Variable O&M ($/kWh H2 produced)
            %%% (3) Electrolyzer efficiency (kWh H2/kWh elec)
            obj.rel_v = [2100; 0.01; 0.6];
            
            %%%Financial Aspects - Electrolyzer
            obj.rel_fin = [-0.02; ... %%%Scaling linear factor - Based on CA Roadmap - 2k H2 per day vs. 20k H2 per day
                5; ... %%%MACRS Schedule
                1]; ... %%%ITC Benefit
        end


        function CalcH2FuelingStationTransportation(obj)

            %%%H2 fueling supply equipment
            %%% (1) Capital Cost ($ installed)
            %%% (2) Compression efficiency
            %%% (3) O&M
            %%% (4) Competing H2 cost ($/kWh
            obj.hrs_v  = [300000000; .95; 0.01; 11/121*3.6];

        end


        function CalcH2PipelineInjection(obj)

            %%%H2 injection - linear fit for capital costs
            %%% (1) Capital Cost Intercept
            %%% (2) Capital Cost Slope
            obj.h2_inject_v = 0.5*[3213860
                            37.6];
        end

        function CalcOther(obj)

            %% Building space
            %%%[space available for PV (m^2)
            %%%Cooling loop input (C)
            %%%Cooling loop output (C)
            %%%Building cooling side (C)
            obj.bldg_v= [10000000000; 10; 18; 15];
            
            %% Inverter
            %%% Cap cost ($/kW)
            obj.inv_v = 49;
            
            %% Transformer
            %%% Cap cost ($/kVA)
            obj.xfmr_v = 1090;
        end

    end

end

