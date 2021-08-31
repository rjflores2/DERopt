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
idx = (datetimev(:,1) == year_idx & ismember(datetimev(:,2),month_idx));
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

% grid_co2(:,1) = grid_co2(:,1) - (grid_co2(1) - year(time(1)));
% co2_time = datenum(grid_co2(:,1:6));
co2_time = [];
co2_time(1) = time(1);
for ii = 2:size(grid_co2,1)
    co2_time(ii,1) = co2_time(ii-1) + 1/24;
end

%%%Grid emissions
co2_import = interp1(co2_time,grid_co2(:,7),time)*2.205; %tonne/MWh * 2.205 lb/kWh / tonne/MWh

%%%CO2 rates for NG combustion
co2_ng=12.74272*(1/29.3071);%%%(lb CO2/therm methane)*(therm/kWh)
co2_rng=co2_ng*0.2;
%% Day multiplier

%%%Currently set to one as long as entire years are considered during
%%%optimization
day_multi = ones(size(elec));

%% Loading SGIP CO2 Signal
sgip_signal_hour = xlsread('hourly_resolved.csv');

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
