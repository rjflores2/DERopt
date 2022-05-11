%%% OVMG Data Formatting
%% Loading solar data
load 'solar_sna.mat'

%% Setting Simulaiton Time

%%% Time Step (minutes)
t_step = (time(2) - time(1))*(24*60);

%%%Demand Charge Adjustment
e_adjust = 60/t_step;

time = [];
time = ([yr 1 1 0 0 0]);
%%%Generating all time steps
for ii = 2:length(elec)
    % for ii = 2:length(elec)
    time(ii,:) = time(ii-1,:);
    time(ii,5) =  time(ii,5) + t_step;
end
time = datenum(time);

%%%Date vectors for all time stamps
datetimev=datevec(time);
%%% Finding month start/endpoints
end_cnt = 1;
stpts=1;

day_cnt = 1;
day_stpts = 1;
if isempty(mth)
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
end
%% Filtering months 
if ~isempty(mth)
   idx = find( datetimev(:,2) == mth);
   
   time = time(idx);
   elec = elec(idx);
   cool = cool(idx);
   heat = heat(idx);
   hotwater = hotwater(idx);
   misc_gas = misc_gas(idx);
   solar = solar(idx);
   
   

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
   
end
%% Loading SGIP CO2 Signal
if sgip_on
    sgip_signal = xlsread('hourly_resolved.csv');
    
    %%%Lining up SGIP signal with current time step
    ind = find(datevec(sgip_signal(:,1)) == datetimev(1));
    sgip_signal = sgip_signal(ind(1):ind(1)+8760-1,:);
end
%% Loading TDV Data
%%%Loading Data
tdv_elec_raw = readtable(strcat('TDV_',cz_name,'.xlsx'),'Sheet','Elec'); %%%Elec (Btu/kWh)
tdv_gas_raw = readtable(strcat('TDV_',cz_name,'.xlsx'),'Sheet','Gas'); %%%Gas (kbtu/therm)

%%%Which year are we looking at?
yr_idx = find(strcmp(tdv_elec_raw.Properties.VariableNames,cellstr(strcat('x',mat2str(yr)))));
tdv_elec = [];
tdv_gas = [];

%%%Extracting Relevant TDV and adjusting based on losses
for ii = yr_idx:width(tdv_elec_raw)      
    
    tdv_elec = [tdv_elec
        table2array(tdv_elec_raw(:,ii)).*table2array(tdv_elec_raw(:,2))]; %%%Adjusting TDV based on losses
    
    tdv_gas = [tdv_gas
        table2array(tdv_gas_raw(:,2)).*table2array(tdv_gas_raw(:,3))]; %%%Adjsuting TDV based on losses
    
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

%% Loading Avoided Cost Data (ACC)
if nem_rate == 3
    %%%Loading in raw data
    acc_elec_raw = readtable(strcat('ACC_',cz_name,'.xlsx'),'Sheet','Hourly_Values'); %%%Avoided Cost ($/MWh)
    
    %%%Which year are we looking at?
    yr_idx = find(strcmp(acc_elec_raw.Properties.VariableNames,cellstr(strcat('x',mat2str(yr)))));
    
    acc_elec = [];
    %%%Extracting Relevant TDV and adjusting based on losses
    for ii = yr_idx:width(tdv_elec_raw)
        acc_elec = [acc_elec
            table2array(acc_elec_raw(:,ii))];
    end
    
    acc_time = [];
    acc_time = datenum(([yr 1 1 0 0 0]));
    for ii = 2:size(acc_elec,1)
        acc_time(ii,1) = acc_time(ii-1,1) + 1/24;
    end
    %%%Extracting TDV of interest
    acc_elec = interp1(acc_time,acc_elec,time)./1000; % $/kWh
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