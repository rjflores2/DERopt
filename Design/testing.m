clc
tic
parfor bldg_idx = 1:50
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
                loads(kk,:) = elec(day_stpts(Locb(kk)):day_endpts(Locb(kk)),bld_idx);
                
                time_of_load(kk,:) = time(day_stpts(Locb(kk)):day_endpts(Locb(kk)));
            end
            
             %%%Matricies used in k-mediods funciton
            X = [sum(loads,2) max(loads,[],2)];
            %%%Execute k-mediods algorithm
            [idx,C] = kmedoids(X,1,'Algorithm','pam');
            
            %%%Which day was selected
            select_idx = find(X(:,1) == C(1) & X(:,2) == C(2));
            
             %%%Pulling day load and scaling it to have the same average load
            day_load =  (loads(select_idx,:)').* ...
                (mean(X(:,1))/sum(loads(select_idx,:)));
            
            %%%Assembling load/time/day multiplicaiton matricies
            week_load = [week_load
                day_load];
            time_dwslct = [time_dwslct
                time_of_load(select_idx,:)'];
            day_multi = [day_multi
                size(X,1).*ones(length(day_load),1)];
            
        end
    end
    
    elec_filtered(:,bldg_idx) = week_load;
    day_multi_filtered(:,bldg_idx) = day_multi;
    time_filtered(:,bldg_idx) = time_dwslct;
end
toc
%%

tic
for bldg_idx = 1:50
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
            for kk = 1:length(Locb)
                loads(kk,:) = elec(day_stpts(Locb(kk)):day_endpts(Locb(kk)),bld_idx);
                
                time_of_load(kk,:) = time(day_stpts(Locb(kk)):day_endpts(Locb(kk)));
            end
            
            %%%Matricies used in k-mediods funciton
            X = [sum(loads,2) max(loads,[],2)];
            %%%Execute k-mediods algorithm
            [idx,C] = kmedoids(X,1,'Algorithm','pam');
            
            %%%Which day was selected
            select_idx = find(X(:,1) == C(1) & X(:,2) == C(2));
            
            %%%Pulling day load and scaling it to have the same average load
            day_load =  (loads(select_idx,:)').* ...
                (mean(X(:,1))/sum(loads(select_idx,:)));
            
            %%%Assembling load/time/day multiplicaiton matricies
            week_load = [week_load
                day_load];
            time_dwslct = [time_dwslct
                time_of_load(select_idx,:)'];
            day_multi = [day_multi
                size(X,1).*ones(length(day_load),1)];
        end
    end
    
    elec_filtered(:,bldg_idx) = week_load;
    day_multi_filtered(:,bldg_idx) = day_multi;
    time_filtered(:,bldg_idx) = time_dwslct;
    
end
toc

