classdef CTechnologySelectionOffSite < handle
    
    properties (SetAccess = public)

        utilpv_v = [];
        utilpv_fin

        util_wind_v = [];
        util_wind_fin

        util_ees_v = [];
        util_ees_fin

        util_el_v = [];
        util_el_fin

        util_h2_inject_v = [];

    end
    
    methods

        function obj = CTechnologySelectionOffSite()

        end


        function CalculateAllParams(obj, util_solar_on, util_wind_on, util_ees_on, util_el_on, util_h2_inject_on)

            if util_solar_on
                obj.CalcUtilityBasedSolar()
            end

            if util_wind_on
                obj.CalcUtilityWind()
            end

            if util_ees_on
                obj.CalcUtilityScaleBattery()
            end

            if util_el_on
                obj.CalcGenericElectrolyzer()
            end

            if util_h2_inject_on
                obj.CalcPipelineInjection()
            end

        end


        function CalcUtilityBasedSolar(obj)

            %%% Cap cost ($/kW)
            %%% Efficiency / Conversion Percent at 1 kW/m^2
            %%% O&M ($/kWh generated)
            obj.utilpv_v = [900; 0.2; 0.001];
            
            %%%Financial Aspects - Solar PV
            obj.utilpv_fin = [0; ... %%%Scaling linear factor - Based on Lazards cost of electricity
                5; ... %%%MACRS Schedule
                1]; ... %%%ITC Benefit

        end

        function CalcUtilityWind(obj)

            %%% Cap cost ($/kW)
            %%% O&M ($/kWh generated)
            obj.util_wind_v = [1190; 0.005];
            
            %%%Financial Aspects - Solar PV
            obj.util_wind_fin = [0; ... %%%Scaling linear factor - Based on Lazards cost of electricity
                5; ... %%%MACRS Schedule
                1]; ... %%%ITC Benefit

        end


        function CalcUtilityScaleBattery(obj)

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
            obj.util_ees_v=[240; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .90; .90; .995];
            
            %%%Financial Aspects - EES
            obj.util_ees_fin = [0;... %%%Scaling linear factor - Based on Lazards cost of electricity
                5; ... %%%MACRS Schedule
                1]; ... %%%ITC Benefit

        end


        function CalcGenericElectrolyzer(obj)

            %%% Generic electrolyzer
            %%% (1) Captail Cost ($/kW H2 produced)
            %%% (2) Variable O&M ($/kWh H2 produced)
            %%% (3) Electrolyzer efficiency (kWh H2/kWh elec)
            obj.util_el_v = [2100; 0.01; 0.6];
            % el_v = [1; 0.01; .99];
            % el_v = [1; 0.01; .6];
            
            %%%Financial Aspects - Electrolyzer
            obj.util_el_fin = [-0.02; ... %%%Scaling linear factor - Based on CA Roadmap - 2k H2 per day vs. 20k H2 per day
                5; ... %%%MACRS Schedule
                1]; ... %%%ITC Benefit

        end

        function CalcPipelineInjection(obj)

            % H2 injection - linear fit for capital costs
            % (1) Capital Cost Intercept
            % (2) Capital Cost Slope
            obj.util_h2_inject_v = 0.5*[3213860
                                37.6];

        end

    end

end

