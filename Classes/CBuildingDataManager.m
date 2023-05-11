classdef CBuildingDataManager < handle

    properties (SetAccess = public)

        buildingName
        
        heat
        time
        elec
        cool
        solar

        e_adjust        % demandChargeAdjustment
        co2_import
        co2_ng          % co2RatesNaturalgas
        co2_rng         % co2RatesRenewableNaturalGas
        lmp_uci
        lmp_util
        stpts
        endpts
        day_multi       % dayMultiplier

    end
    
    properties (SetAccess = private)
        lDateTimeVector
    end    

    methods

        function obj = CBuildingDataManager(buildingName)

            obj.buildingName = buildingName;
            obj.heat = [];
            obj.time = [];
            obj.elec = [];
            obj.cool = [];
            obj.solar = [];

        end
        
        %% Load building demand
        function [success] = LoadData(obj, dataFilePath, loadCoolingData)

            try

                dt = load(dataFilePath);
            
                obj.heat = dt.loads.heating;
                obj.heat = zeros(size(obj.heat));
                obj.time = dt.loads.time;
                
                if loadCoolingData
                    obj.elec = dt.loads.elec;
                    obj.cool = dt.loads.cooling;
                else
                    obj.elec = dt.loads.elec_total;
                    obj.cool = [];
                end

                success = true;
            catch
                success = false;
            end
        end


        %% Format Data
        function FormatData(obj, month_idx, year_idx, demo_data_path, util_solar_on, util_wind_on, hrs_on)

            % Placeholders for Solar & SGIP
            
            % Time Step
            t_step = round((obj.time(2) - obj.time(1))*(24*60)); % Minutes
            
            % Demand Charge Adjustment
            obj.e_adjust = 60/t_step;
            
            % Adjusting Data from power to energy
            obj.elec = obj.elec.*(t_step/60);
            obj.heat = obj.heat.*(t_step/60);
            if ~isempty(obj.cool)
                obj.cool = obj.cool.*(t_step/60);
            end
        
            %% Setting Simulaiton Time
            
            % Date vectors for all time stamps
            obj.lDateTimeVector = datevec(obj.time);
            
            % Cutting down data
            
            %%% change IDX to a specific month to allow for faster testing %%%
            if ~isempty(year_idx) && ~isempty(month_idx)
                idx = (obj.lDateTimeVector(:,1) == year_idx & ismember(obj.lDateTimeVector(:,2),month_idx));
            elseif ~isempty(year_idx) 
                idx = (obj.lDateTimeVector(:,1) == year_idx);
            end

            obj.elec = obj.elec(idx);
            obj.heat = obj.heat(idx);
            if ~isempty(obj.cool)
                obj.cool = obj.cool(idx);
            end

            obj.time = obj.time(idx);            
            obj.lDateTimeVector = datevec(obj.time);

            % Finding month start/endpoints
            end_cnt = 1;
            obj.stpts = 1;    
            day_cnt = 1;
            day_stpts = 1;
        
            for ii = 2:length(obj.time)
        
                if obj.lDateTimeVector(ii,2) ~= obj.lDateTimeVector(ii-1,2)
                    obj.endpts(end_cnt,1) = ii-1;
                    obj.stpts(end_cnt+1,1) = ii;
                    end_cnt = end_cnt +1;
                end
                
                if obj.lDateTimeVector(ii,3) ~= obj.lDateTimeVector(ii-1,3)
                    day_endpts(day_cnt,1) = ii-1;
                    day_stpts(day_cnt+1,1) = ii;
                    day_cnt = day_cnt +1;
                end
                
                if ii == length(obj.time)
                    obj.endpts(end_cnt,1) = ii;
                    day_endpts(day_cnt,1) = ii;
                end
        
            end

            
            %% Adjusting load data from avg power to energy
            t_delta = (obj.time(3) - obj.time(2));
            
            %% Loading/processing solar data
            load('UCI_Solar_Normalized');
            
            %%%Extracting solar data from the loaded normalized factor
            obj.solar = interp1(norm_slr(:,1), norm_slr(:,2), obj.time);
            
            %% Loadings Emission Factors
            
            %%%Grid emission factors
            grid_co2 = xlsread('grid_co2_factors.xlsx'); 
            yr_shift = 12 + (year_idx(1) - 2018);
            grid_co2(:,1) = grid_co2(:,1) - yr_shift;
            co2_time = datenum(grid_co2(:,1:6));
            
            % %%%Grid emissions [kg/kWh)
            obj.co2_import = interp1(co2_time, grid_co2(:,7), obj.time); %[kg/kWh] - Unit conversion - tonne/MWh  = 1000 kg/ 1000 kWh = kg/kWh
            obj.co2_import(isnan(obj.co2_import)) = nanmean(obj.co2_import); %%%Eliminating any NaNs
            
            %%% Dummy value for DEMO only - erasing emissions for CA grid in favor of a
            %%% less efficient grid
            obj.co2_import = obj.co2_import * 0 + 0.45;
            
            %%%CO2 rates for NG combustion
            obj.co2_ng = (1/50)*(1/16)*44*3.6 ;%%%[kg/kWh]: (kg CH4 / 50MJ)*(1kmolCH4 / 16kg)*(1kmolCO2 / 1kmolCH4)*(44kgCO2 / 1kmolCO2)*(3.6MJ / 1kWh)   
            obj.co2_rng = obj.co2_ng*0.2;
        
            %% Day multiplier
            
            %%%Currently set to one as long as entire years are considered during
            %%%optimization
            obj.day_multi = ones(size(obj.elec));
            
            %% Loading SGIP CO2 Signal
            sgip_signal_hour = xlsread(append(demo_data_path, '\CPUC_SGIP_Signal\hourly_resolved.csv'));
            
            %%%Mannually adjusting SGIP time signal to fit with current UCI Data
            delta = obj.time(1) - sgip_signal_hour(1);
            sgip_signal_hour(:,1) = sgip_signal_hour(:,1) + 365;
            
            %%% Interpolating data from hourly to 15 minutes
            sgip_signal = interp1(sgip_signal_hour(:,1), sgip_signal_hour(:,2), obj.time);
            
            %%%Assembling sgip_signal_vector
            sgip_signal = [obj.time sgip_signal];
            
            %% Locating Summer Months
            summer_month = [];
            counter = 1;
            counter1 = 1;

            if length(obj.endpts) > 1                
                for i=2:obj.endpts(end)
                    if obj.lDateTimeVector(i,2)~=obj.lDateTimeVector(i-1,2)
                        counter = counter+1;

                        if obj.lDateTimeVector(i,2) >= 6 && obj.lDateTimeVector(i,2) < 10
                            summer_month(counter1,1) = counter;
                            counter1 = counter1+1;
                        end
                    end
                end
            else
                if obj.lDateTimeVector(1,2) >= 6 && obj.lDateTimeVector(1,2) < 10
                    summer_month = counter;
                end
            end
            
            %% Loading LMP Data
        
            load Santiago_LMP_Summary
            %%%Shifting LMP start date around
            vector(:,1) = vector(:,1) - 365;

            %%%Extracting LMP Export
            obj.lmp_uci = interp1(vector(:,1),vector(:,2), obj.time)./1000;
            obj.lmp_uci = obj.lmp_uci + (obj.lmp_uci - mean(obj.lmp_uci))*0;
            
            %% Loading Utility LMP Data and solar/wind profiles
            if util_solar_on || util_wind_on
        
                load Schindlr_LMP_Summary
                
                %%%Shifting LMP start date around
                vector(:,1) = vector(:,1) -365;
        
                %%%Extracting LMP Export
                obj.lmp_util = interp1(vector(:,1),vector(:,2), obj.time)./1000;
                obj.lmp_util = obj.lmp_util + (obj.lmp_util - mean(obj.lmp_util))*0;
                
                %%%Solar Data
                if util_solar_on

                    solar_util = xlsread('Five_Points_Tracking.xlsx')./1000;
                    solar_util_tm = datenum([year(obj.time(1)) 1 1 0 0 0]);
                    for ii = 2:8760
                        solar_util_tm(ii,1) = solar_util_tm(ii-1,1) + 1/24;
                    end
                    solar_util = interp1(solar_util_tm,solar_util, obj.time);
                    solar_util(isnan(solar_util)) = 0;
                end
                
                %%%Wind DAta
                if util_wind_on

                    wind_util = xlsread('tehachapi_2011.xlsx');
                    
                    wind_util_tm = datenum([year(obj.time(1)) 1 1 0 0 0]);
                    for ii = 2:8760
                        wind_util_tm(ii,1) = wind_util_tm(ii-1,1) + 1/24;
                    end
                    wind_util = interp1(wind_util_tm,wind_util, obj.time);
                    wind_util(isnan(wind_util)) = 0;
                    
                end
            end
            
            %% Loading HRS data
            if hrs_on
        
                load hrs_vector
                
                hrs_tm = datevec(hrs_vector(:,1));
                hrs_vector(:,1) = hrs_vector(:,1) + obj.time(1);
        
                %%%Updating HRS to the current year
            %     hrs_tm(:,1) = obj.lDateTimeVector(1,1);
            %     hrs_vector(:,1) = datenum(hrs_tm);
        
                hrs_demand = interp1(hrs_vector(:,1), hrs_vector(:,2), obj.time);
                
            end

        end

            
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function [co2_base] = EstimateBaseCO2Emissions(obj)

            co2_base = obj.elec'*obj.co2_import ...         % Assume all electricity is met using grid electricity
                        + sum((obj.heat./0.8)*obj.co2_ng);  % Assume all heating is met using an 80% AFUE heater

        end

        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function [co2_base] = SetUpFirstCO2Limit(obj)

            co2_lim = cfg.co2_base*(1-cfg.co2_red(1));

            
            co2_base = obj.elec'*obj.co2_import ...         % Assume all electricity is met using grid electricity
                        + sum((obj.heat./0.8)*obj.co2_ng);  % Assume all heating is met using an 80% AFUE heater

        end



        function [electricityVectorLength] = GetElecLen(obj)
            electricityVectorLength = length(obj.elec);
        end

        function [timeVectorLength] = GetTimeLen(obj)
            timeVectorLength = length(obj.time);
        end

        function [endPointsVectorLength] = GetEndPointsLen(obj)
            endPointsVectorLength = length(obj.endpts);
        end


    end
end

