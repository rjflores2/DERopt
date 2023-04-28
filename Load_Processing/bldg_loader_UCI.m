%%% OVMG Data Formatting
%Placeholders for
% Solar
% SGIP

%%% Time Step
t_step = round((time(2) - time(1))*(24*60)); %Minutes

%%%Demand Charge Adjustment
e_adjust = 60/t_step;

%%%Adjusting Data from power to energy
elec = elec.*(t_step/60);
heat = heat.*(t_step/60);
if ~isempty(cool)
    cool = cool.*(t_step/60);
end
%% Setting Simulaiton Time

%%%Date vectors for all time stamps
datetimev=datevec(time);

%%%Cutting down data

%%% change IDX to a specific month to allow for faster testing %%%

% idx = (datetimev(:,1) == year_idx & datetimev(:,2) == month_idx);
if ~isempty(year_idx) && ~isempty(month_idx)
    idx = (datetimev(:,1) == year_idx & ismember(datetimev(:,2),month_idx));
elseif ~isempty(year_idx) 
    idx = (datetimev(:,1) == year_idx);
end

% idx = (datetimev(:,1) == 2018);
elec = elec(idx);
heat = heat(idx);
if ~isempty(cool)
    cool = cool(idx);
end
time = time(idx);
datetimev=datevec(time);


%%% Finding month start/endpoints
end_cnt = 1;
stpts=1;

day_cnt = 1;
day_stpts = 1;
for ii = 2:length(time)
    if datetimev(ii,2) ~= datetimev(ii-1,2)
        endpts(end_cnt,1) = ii-1;
        stpts(end_cnt+1,1) = ii;
        end_cnt = end_cnt +1;
    end
    
    if datetimev(ii,3) ~= datetimev(ii-1,3)
        day_endpts(day_cnt,1) = ii-1;
        day_stpts(day_cnt+1,1) = ii;
        day_cnt = day_cnt +1;
    end
    
    if ii == length(time);
        endpts(end_cnt,1) = ii;
        day_endpts(day_cnt,1) = ii;
    end
end

%% Adjusting load data from avg power to energy
t_delta = (time(3) - time(2))

%% Loading/processing solar data
load('UCI_Solar_Normalized');

%%%Extracting solar data from the loaded normalized factor
solar = interp1(norm_slr(:,1),norm_slr(:,2),time);

%% Loadings Emission Factors

%%%Grid emission factors
grid_co2 = xlsread('grid_co2_factors.xlsx'); 
yr_shift = 12 + (year_idx(1) - 2018);
grid_co2(:,1) = grid_co2(:,1) - yr_shift;
co2_time = datenum(grid_co2(:,1:6));

% %%%Grid emissions [kg/kWh)
co2_import = interp1(co2_time,grid_co2(:,7),time); %[kg/kWh] - Unit conversion - tonne/MWh  = 1000 kg/ 1000 kWh = kg/kWh
co2_import(isnan(co2_import)) = nanmean(co2_import); %%%Eliminating any NaNs

%%% Dummy value for DEMO only - erasing emissions for CA grid in favor of a
%%% less efficient grid
co2_import = co2_import*0 + 0.45;

%%%CO2 rates for NG combustion 
co2_ng = (1/50)*(1/16)*44*3.6 ;%%%[kg/kWh]: (kg CH4 / 50MJ)*(1kmolCH4 / 16kg)*(1kmolCO2 / 1kmolCH4)*(44kgCO2 / 1kmolCO2)*(3.6MJ / 1kWh)   
co2_rng=co2_ng*0.2;
%% Day multiplier

%%%Currently set to one as long as entire years are considered during
%%%optimization
day_multi = ones(size(elec));

%% Loading SGIP CO2 Signal
sgip_signal_hour = xlsread(append(demo_files_path, '\DERopt\Data\CPUC_SGIP_Signal\hourly_resolved.csv'));
% sgip_signal_hour = xlsread('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Data\hourly_resolved.xlsx');

%%%Mannually adjusting SGIP time signal to fit with current UCI Data
delta = time(1) - sgip_signal_hour(1);
sgip_signal_hour(:,1) = sgip_signal_hour(:,1) + 365;

%%% Interpolating data from hourly to 15 minutes
sgip_signal = interp1(sgip_signal_hour(:,1),sgip_signal_hour(:,2),time);

%%%Assembling sgip_signal_vector
sgip_signal = [time sgip_signal];

%% Locating Summer Months
summer_month = [];
counter = 1;
counter1 = 1;
if length(endpts)>1
    for i=2:endpts(end)
        if datetimev(i,2)~=datetimev(i-1,2)
            counter=counter+1;
            if datetimev(i,2)>=6&&datetimev(i,2)<10
                summer_month(counter1,1)=counter;
                counter1=counter1+1;
            end
        end
    end
else
    if datetimev(1,2)>=6&&datetimev(1,2)<10
        summer_month=counter;
    end
end

%% Loading LMP Data
load Santiago_LMP_Summary
%%%Shifting LMP start date around
vector(:,1) = vector(:,1) -365;
%%%Extracting LMP Export
lmp_uci = interp1(vector(:,1),vector(:,2),time)./1000;
lmp_uci = lmp_uci + (lmp_uci - mean(lmp_uci))*0;

%% Loading Utility LMP Data and solar/wind profiles
if util_solar_on || util_wind_on
    load Schindlr_LMP_Summary
    
    %%%Shifting LMP start date around
    vector(:,1) = vector(:,1) -365;
    %%%Extracting LMP Export
    lmp_util = interp1(vector(:,1),vector(:,2),time)./1000;
    lmp_util = lmp_util + (lmp_util - mean(lmp_util))*0;
    
    %%%Solar Data
    if util_solar_on
        solar_util = xlsread('Five_Points_Tracking.xlsx')./1000;
        solar_util_tm = datenum([year(time(1)) 1 1 0 0 0]);
        for ii = 2:8760
            solar_util_tm(ii,1) = solar_util_tm(ii-1,1) + 1/24;
        end
        solar_util = interp1(solar_util_tm,solar_util,time);
        solar_util(isnan(solar_util)) = 0;
    end
    
    %%%Wind DAta
    if util_wind_on
        wind_util = xlsread('tehachapi_2011.xlsx');
        
        wind_util_tm = datenum([year(time(1)) 1 1 0 0 0]);
        for ii = 2:8760
            wind_util_tm(ii,1) = wind_util_tm(ii-1,1) + 1/24;
        end
        wind_util = interp1(wind_util_tm,wind_util,time);
        wind_util(isnan(wind_util)) = 0;
        
    end
end

%

%% Loading HRS data
if hrs_on
    load hrs_vector
    
    hrs_tm = datevec(hrs_vector(:,1));
    hrs_vector(:,1) = hrs_vector(:,1) + time(1);
    %%%Updating HRS to the current year
%     hrs_tm(:,1) = datetimev(1,1);
%     hrs_vector(:,1) = datenum(hrs_tm);
    
    
    hrs_demand = interp1(hrs_vector(:,1),hrs_vector(:,2),time);
    
end
