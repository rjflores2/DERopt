%%% Cuts 8760 data down to 864 size data
%%% Initial code determines average weekend/week day, then sets data as
%%% [weekday; weekday; weekend], or a month is now two weekdays, followed
%%% by weekend. Data is just the average days

%%%Recording yearly energy to compare cut down months to whole month
%%%simulation
yrly_energy=zeros(3,size(elec,2));
yrly_energy(2,:)=sum(elec);

solar_avg=[];
solar_filter=[];
time_filter=[];
day_multi=[];
%clc
%%%For each Building
for j = 1:size(elec,2)
    %%%For each month
    for i=1:length(endpts)
        %%%finding starting and ending of each month
        if i==1
            st=1;
            fn=endpts(i);
        else
            st=endpts(i-1)+1;
            fn=endpts(i);
        end
        
        %%%Initialize week and weekend data recorded
        week=[];
        week_time=[];
        weekend=[];
        weekend_time=[];
        %%% Recorder for solar
        solar_days=[];

        %%%Indexing start/finish of each day
        days=[];
        days=[st weekday(time(st))];
        %%%indicating if its the first time a week/weekend day has been
        %%%recorded
        count=[1 1];
        
         %%%Going through each month
        for k=st+1:fn
            if datetimev(k,3) ~= datetimev(k-1,3)
                %%%Indicating end of each day
                days=[days
                    k weekday(time(k))];
                
                %%%Recording Solar days ( only if j (bldg) = 1, it only does it
                %%%once in the loop) 
                if j == 1
                    if count(1) == 1 && count(2) == 1 && i == 1
                        solar_days=[solar_days solar(days(end-1,1):days(end,1))];
                    else
                        solar_days=[solar_days solar(days(end-1,1)+1:days(end,1))];
                    end
                end
                
                %%%Recording weekdays
                if weekday(time(days(end-1,1))) == 7 || weekday(time(days(end-1,1))) == 1
                    if count(1) == 1 && days(end-1,1) == 1
                        
                        weekend=[weekend elec(days(end-1,1):days(end,1),j)];
                        weekend_time=[weekend_time time(days(end-1,1):days(end,1))];
                        count(1)=2;
                        
                        
                    else
                        weekend=[weekend elec(days(end-1,1)+1:days(end,1),j)];
                        weekend_time=[weekend_time time(days(end-1,1)+1:days(end,1))];
                    end
                else
                    if count(2)==1 && days(end-1,1) == 1
                        week=[week elec(days(end-1,1):days(end,1),j)]; 
                        week_time=[week_time time(days(end-1,1):days(end,1))];
                        
                        count(2)=count(2)+1;
%                         count
%                         poop
                    else
                        week=[week elec(days(end-1,1)+1:days(end,1),j)];
                        week_time=[week_time time(days(end-1,1)+1:days(end,1))];
                        
                    end
                end
                
            end
        end
        %% Average Day
        %%%Average weekend
        weekend_avg(:,i)=mean(weekend,2);
        weekend_std(:,i)=std(weekend,1,2)./mean(weekend,2);
        weekend_total_std(1,i)=std(sum(weekend,1))/mean(sum(weekend,1));
        
        weekend_max(1,i)=max(abs((max(weekend)-max(weekend_avg(:,i)))./max(weekend_avg(:,i))));
        weekend_max(2,i)=max((max(weekend)-max(weekend_avg(:,i)))./max(weekend_avg(:,i)));
        
        week_avg(:,i)=mean(week,2);
        week_std(:,i)=std(week,1,2)./mean(week,2);
        week_total_std(1,i)=std(sum(week,1))/mean(sum(week,1));
        week_max(1,i)=max(abs((max(week)-max(week_avg(:,i)))./max(week_avg(:,i))));
        week_max(2,i)=max((max(week)-max(week_avg(:,i)))./max(week_avg(:,i)));
        
        week_num(i,j)=size(week,2);
        weekend_num(i,j)=size(weekend,2);
        
        %%%indexing for where to add building energy model data
        if i == 1
            wk_st=1;
            wk_fn=48;
            
            wd_st=49;
            wd_fn=72;
        else
            wk_st=wk_st+72;
            wk_fn=wk_fn+72;
            
            wd_st=wd_st+72;
            wd_fn=wd_fn+72;
        end
        
        %%%Adding Weekday
        elec_filtered(wk_st:wk_fn,j)=[week_avg(:,i)
            week_avg(:,i)];
        
        %%%Adding Weekend
        elec_filtered(wd_st:wd_fn,j)=weekend_avg(:,i);
        
        yrly_energy(1,j)=yrly_energy(1,j)+sum(week_avg(:,i))*size(week,2) ...
            +sum(weekend_avg(:,i))*size(weekend,2);
        
        %%%Solar Average
        if j == 1
            %%%Recording Average Solar
            solar_avg(:,i) = mean(solar_days,2);
            
            if i==1
                sl_st=1;
                sl_fn=72;
            else
                sl_st=sl_st+72;
                sl_fn=sl_fn+72;
            end
            %%%Filtered Solar Data
            solar_filter(sl_st:sl_fn,1)=[solar_avg(:,i)
                solar_avg(:,i)
                solar_avg(:,i)];
            
            %%%New Time
            time_filter(sl_st:sl_fn,1)=[week_time(:,1)
                week_time(:,1)
                weekend_time(:,1)];
            %%%Day Multiplier
            day_multi(sl_st:sl_fn,1)=[ones(24,1)
                (week_num(i,1)-1)*ones(24,1)
                weekend_num(i,1)*ones(24,1)];
        end
    end
end

%%turning back time at end of each day by one second
for i=1:(length(time_filter)/24)-1
    time_filter(i*24)=time_filter(i*24)-1/(24*3600);
end

datetimev_filter=datevec(time_filter);
datetimev_weekdays=weekday(time_filter);