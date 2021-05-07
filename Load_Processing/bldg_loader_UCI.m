%%% OVMG Data Formatting
%Placeholders for
% Solar
% SGIP

%% Setting Simulaiton Time

%%% Time Step
t_step = 15;
time = table2array(dt(1:end,1));

%%%Date vectors for all time stamps
datetimev=datevec(time);

%%%Cutting down data
idx = datetimev(:,1) == 2018;
elec = elec(idx);
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

%% Loading/processing solar data
load('UCI_Solar_Normalized');

%%%Extracting solar data from the loaded normalized factor
solar = interp1(norm_slr(:,1),norm_slr(:,2),time);

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

