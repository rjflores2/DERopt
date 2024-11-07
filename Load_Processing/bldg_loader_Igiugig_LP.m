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

%% Loading/processing solar data
solar_fixed = readtable('pvwatts_solar_fixed.csv');
solar_tracking = readtable('pvwatts_solar_tracking.csv');

%%%Extracting solar data from the loaded normalized factor
solar = [solar_fixed.ACSystemOutput_kW_ solar_tracking.ACSystemOutput_kW_];
% solar = [solar_fixed.ACSystemOutput_kW_ ];

%% Loading River Data
% river_power_potential = readtable('Iguigig_River_Power.xlsx','Sheet','Real_Hour');
% river_power_potential = readtable('Iguigig_River_Power.xlsx','Sheet','Eff_plus_1_hour');
% river_power_potential = readtable('Iguigig_River_Power.xlsx','Sheet','Eff_plus_25_hour');
river_power_potential = readtable('Iguigig_River_Power.xlsx','Sheet','Site1_Speed_Delta');

% %  repmat(river_power_potential.Site2_Power_kW,1,0)
% river_power_potential = [repmat(river_power_potential.Site1_Power_kW,1,5)];
% river_power_potential = river_power_potential(:,1);
%% Finding the value of the RivGen system!!!
% river_power_potential = [river_power_potential.Normalized_Site2_Power];
river_power_potential = table2array(river_power_potential(:,30+outer_loop));
% river_power_potential(:,2) = [river_power_potential.Properties.VariableNames{24}];
% river_power_potential = [river_power_potential.Site1_Power_kW river_power_potential.Site2_Power_kW];
% river_power_potential = zeros(8760,1);

%% eff_delta
% eff_delta = [-10:1:10]./100;
% river_power_potential = river_power_potential.*((0.4+eff_delta(outer_loop))/0.4);
%% Setting Simulaiton Time

%%%Date vectors for all time stamps
datetimev=datevec(time);

%%%Cutting down data

%%% change IDX to a specific month to allow for faster testing %%%

% idx = (datetimev(:,1) == year_idx & datetimev(:,2) == month_idx);
if ~isempty(month_idx)
    idx = (datetimev(:,2) == month_idx );
    elec = elec(idx);
    solar = solar(idx,:);
    river_power_potential = river_power_potential(idx,:);
    time = time(idx);
    datetimev=datevec(time);
end



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
%% Dummy Day Multiplier
day_multi = ones(size(elec));
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
%% Adjusting load data from avg power to energy
t_delta = (time(3) - time(2))

