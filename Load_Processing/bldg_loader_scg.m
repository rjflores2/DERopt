%%% OVMG Data Formatting
%% Loading solar data
load 'solar_sna.mat'

%% Setting Simulaiton Time

%%% Time Step
t_step = 60;

%%%Demand Charge Adjustment
e_adjust = 60/t_step;

time = [];
time = ([2019 1 1 0 0 0]);
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
sgip_signal = xlsread('hourly_resolved.csv');

%%%Lining up SGIP signal with current time step
ind = find(datevec(sgip_signal(:,1)) == datetimev(1));
sgip_signal = sgip_signal(ind(1):ind(1)+8760-1,:);

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