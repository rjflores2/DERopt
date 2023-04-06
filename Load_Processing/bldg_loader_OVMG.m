%%% OVMG Data Formatting
%% Loading solar data
load 'solar_sna.mat'
legacy.solar = solar;
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


%% Downselection
clustering.weekdays = weekday(time);
clustering.months = month(time);

%%%If downselecting to representative weeks
if downselection == 1
    elec_filtered = [];
    day_multi_filtered = [];
    time_filtered = [];
    lighting_filtered = [];
    tic
    %     for bldg_idx = 2:size(elec,2)
    %         bldg_idx
    parfor bldg_idx = 1:size(elec,2)
%     for bldg_idx = 1:size(elec,2)
        week_load = [];
        time_dwslct = [];
            day_multi = [];
            for ii = unique(clustering.months)'
                for jj = 1:7
                    %%%Hours that belong to the current month and day being analyzed
                    ind_hour = [];
                    ind_hour = find(clustering.months == ii & clustering.weekdays == jj);
                    %%%Days that belong in the current month
                    ind_days = [];
                    ind_days = find(day_stpts == min(ind_hour) & day_endpts<= max(ind_hour));
                    
                    %%%Where the day starting points are
                [Lia,Locb] = ismember(ind_hour,day_stpts);
                Locb = Locb(Locb>0);
                
                %%%Assembling loads/time matricies
                loads = [];
                time_of_load = [];
                %%%Assembling loads/time matricies
                loads = [];
                for kk = 1:length(Locb)
                    loads(kk,:) = elec(day_stpts(Locb(kk)):day_endpts(Locb(kk)),bldg_idx);
                    
                    time_of_load(kk,:) = time(day_stpts(Locb(kk)):day_endpts(Locb(kk)));
                end
                
                %%%Matricies used in k-mediods funciton
                X = [sum(loads,2) max(loads,[],2)];
                %%%Execute k-mediods algorithm
                [idx,C] = kmedoids(X,1,'Algorithm','pam');
                
                %%%Which day was selected
                select_idx = find(X(:,1) == C(1) & X(:,2) == C(2));
                
                %%%Pulling day load and scaling it to have the same average load
                day_load =  (loads(select_idx(1),:)').* ...
                    (mean(X(:,1))/sum(loads(select_idx(1),:)));
                
                %%%Assembling load/time/day multiplicaiton matricies
                week_load = [week_load
                    day_load];
                time_dwslct = [time_dwslct
                    time_of_load(select_idx(1),:)'];
                day_multi = [day_multi
                    size(X,1).*ones(length(day_load),1)];
                
            end
        end
        
        elec_filtered(:,bldg_idx) = week_load;
        day_multi_filtered(:,bldg_idx) = day_multi;
        time_filtered(:,bldg_idx) = time_dwslct;
    end
    
    
    
    toc
    
    %% Filtering Solar & SGIP Data
    solar_filtered = [];
    sgip_filtered = [];
    for ii = unique(clustering.months)'
        for jj = 1:7
            %%%Hours that belong to the current month and day being analyzed
            ind_hour = [];
            ind_hour = find(clustering.months == ii & clustering.weekdays == jj);
            %%%Days that belong in the current month
            ind_days = [];
            ind_days = find(day_stpts == min(ind_hour) & day_endpts<= max(ind_hour));
            
            %%%Where the day starting points are
            [Lia,Locb] = ismember(ind_hour,day_stpts);
            Locb = Locb(Locb>0);
            
            %%%Assembling loads/time matricies
            loads = [];
            time_of_load = [];
            %%%Assembling loads/time matricies
            loads = [];
            for kk = 1:length(Locb)
                loads(kk,:) = solar(day_stpts(Locb(kk)):day_endpts(Locb(kk)));
                loads2(kk,:) = sgip_signal(day_stpts(Locb(kk)):day_endpts(Locb(kk)),2);
            end
            
            %%% Solar %%%
            
            %%%Matricies used in k-mediods funciton
            X = [sum(loads,2)];
            %%%Execute k-mediods algorithm
            [idx,C] = kmedoids(X,1,'Algorithm','pam');
            %%%Which day was selected
            select_idx = find(X(:,1) == C(1));
            
            %%%Pulling day load and scaling it to have the same average load
            %             solar_day =  (loads(select_idx,:)').* ...
            %                 (mean(X(:,1))/sum(loads(select_idx,:)));
            
            solar_day =  (loads(select_idx,:)');
            
            solar_filtered = [solar_filtered
                solar_day];
            
            %%% SGIP Signal %%%
            
            %%%Matricies used in k-mediods funciton
            X = [sum(loads2,2)];
            %%%Execute k-mediods algorithm
            [idx,C] = kmedoids(X,1,'Algorithm','pam');
            %%%Which day was selected
            select_idx = find(X(:,1) == C(1));
            
            %%%Pulling day load and scaling it to have the same average load
            %             solar_day =  (loads(select_idx,:)').* ...
            %                 (mean(X(:,1))/sum(loads(select_idx,:)));
            
            sgip_day =  (loads2(select_idx,:)');
            sgip_filtered = [sgip_filtered
                sgip_day];
            
        end
    end
    %% Resetting values according to filtered data
    
    %%%Resetting electrical data
    legacy.elec = elec;
    legacy.time = time;
    
    %%%Electrical/time/and day_multi values
    elec = elec_filtered;
    time = time_filtered(:,1);
    day_multi = day_multi_filtered(:,1);
    
    %%%Solar/sgip values
    legacy.solar = solar;
    legacy.sgip_signal = sgip_signal;
    
    solar = solar_filtered.*mean(solar)./mean(solar_filtered);
    sgip_signal = [time sgip_filtered.*mean(solar)./mean(sgip_signal(:,2))];
    
elseif downselection == 2 && ~isempty(mth)
    elec = elec(stpts(min(mth)):endpts(max(mth)),:);
    time = time(stpts(min(mth)):endpts(max(mth)),:);
    day_multi = ones(size(elec,1),1);
    
    
    solar = solar(stpts(min(mth)):endpts(max(mth)),:);
    sgip_signal = sgip_signal(stpts(min(mth)):endpts(max(mth)),:);
else
    
    day_multi = ones(size(elec,1),1);
end

%% Cutting Data Down More
% elec = elec(1:336,:);
% time = time(1:336);
% day_multi = day_multi(1:336);
% solar = solar(1:336);
% sgip_signal = sgip_signal(1:336);


%% Recreating endpts
%%%Date vectors for all time stamps
datetimev = [];
datetimev=datevec(time);
%%% Finding month start/endpoints
end_cnt = 1;
stpts=1;
endpts = [];
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

%% Shutdown parallel pool
poolobj = gcp('nocreate')
delete(poolobj)
