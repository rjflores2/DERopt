%%% OVMG Data Formatting
%% Setting Simulaiton Time

%%% Time Step
t_step = 60;

%%%Initial time step
time = datenum([2019 1 1 0 0 0]);

%%%Generating all time steps
for ii = 2:length(elec)
    time(ii,1) = time(ii-1,1) + 1/24;
end
 
%%%Date vectors for all time stamps
datetimev=datevec(time);
%%% Finding month start/endpoints
end_cnt = 1;
stpts=1;
for ii = 2:length(time)
    if datetimev(ii,2) ~= datetimev(ii-1,2)
        endpts(end_cnt,1) = ii-1;
        stpts(end_cnt+1,1) = ii;
        end_cnt = end_cnt +1;
    end
    if ii == length(time);
        endpts(end_cnt,1) = ii;
    end
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
%% Loading solar data
load 'solar_sna.mat'

%% Day multiplier
day_multi = ones(length(time),1);