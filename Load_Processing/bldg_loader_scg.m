%%% OVMG Data Formatting
%% Loading solar data
% load 'solar_sna.mat'

solar_dt = readtable('C:\Users\rjf\OneDrive - UC Irvine\Papers\SCG_Nanogrid_Experiments\Fast Dynamics (May 15-30)\solar_data_czs.xlsx');
solar = solar_dt.CZ06_LAX;

%% Setting Simulaiton Time

%%% Time Step
t_step = 60;

%%%Demand Charge Adjustment
e_adjust = 60/t_step;

time = [];
time = ([yr 1 1 0 0 0]);
%%%Generating all time steps
for ii = 2:8760
    % for ii = 2:length(elec)
    time(ii,:) = time(ii-1,:);
    time(ii,5) =  time(ii,5) + 60;
end
time = datenum(time);

%%%Date vectors for all time stamps
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
%% Loading SGIP CO2 Signal
if sgip_on
sgip_signal = xlsread('hourly_resolved.csv');

%%%Lining up SGIP signal with current time step
ind = find(datevec(sgip_signal(:,1)) == datetimev(1));
sgip_signal = sgip_signal(ind(1):ind(1)+8760-1,:);
end
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

%% Day Multi Fill In
day_multi = ones(size(elec));

%% Loading TDV Data
%%%Loading Data
tdv_elec_raw = readtable(strcat('TDV_',cz_name,'.xlsx'),'Sheet','Elec'); %%%Elec (Btu/kWh)
tdv_gas_raw = readtable(strcat('TDV_',cz_name,'.xlsx'),'Sheet','Gas'); %%%Gas (kbtu/therm)

% tdv_elec_raw = readtable(strcat('TDV_2025.xlsx'),'Sheet','Elec'); %%%Elec (Btu/kWh)
% tdv_gas_raw = readtable(strcat('TDV_2025.xlsx'),'Sheet','Gas'); %%%Gas (kbtu/therm)

%%%Which year are we looking at?
% yr_idx = find(strcmp(tdv_elec_raw.Properties.VariableNames,cellstr(strcat('x',mat2str(yr)))));
yr_idx = find(table2array(tdv_elec_raw(1,:)) == yr);
% yr_idx = find(strcmp(tdv_elec_raw.Properties.VariableNames,cellstr(strcat('x',mat2str(yr)))));
tdv_elec = [];
tdv_gas = [];

%%%Extracting Relevant TDV and adjusting based on losses
for ii = yr_idx:width(tdv_elec_raw)      
    
    tdv_elec = [tdv_elec
        table2array(tdv_elec_raw(2:end,ii)).*table2array(tdv_elec_raw(2:end,2))]; %%%Adjusting TDV based on losses
    
    tdv_gas = [tdv_gas
        table2array(tdv_gas_raw(1:end,2)).*table2array(tdv_gas_raw(1:end,3))]; %%%Adjsuting TDV based on losses
    
end

%%%TDV Time
tdv_time = [];
tdv_time = datenum(([yr 1 1 0 0 0]));
for ii = 2:size(tdv_elec,1)
    tdv_time(ii,1) = tdv_time(ii-1,1) + 1/24;
end
%%%Extracting TDV of interest
tdv_elec = interp1(tdv_time,tdv_elec,time);
tdv_gas = interp1(tdv_time,tdv_gas,time);

%%%Unit conversion for elec - 3412.14 btu/kWh (units are kWh primary energy/kWh electricity)
tdv_elec = tdv_elec./3412.14; %./1000; %kWh/kWh

%%%Unit conversion for gas  - 1 therm = 100 kbtu. Conversion becomes
%%%unitless
tdv_gas = tdv_gas./100; %kWh/kWh

clear tdv_time