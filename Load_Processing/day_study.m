%% Building Load Exploration
close all
for j=1:size(elec,2)
    figure
    for i=1:length(endpts)
        if i==1
            st=1;
            fn=endpts(i);
        else
            st=endpts(i-1)+1;
            fn=endpts(i);
        end
        subplot(6,2,i)
        plot(elec(st:fn,j))
    end
end

%% checking similarity between days
close all

yrly_energy=zeros(3,size(elec,2));
yrly_energy(2,:)=sum(elec);

for j = 1:size(elec,2)
    for i=1:length(endpts)
        if i==1
            st=1;
            fn=endpts(i);
        else
            st=endpts(i-1)+1;
            fn=endpts(i);
        end
        
        close all
        figure
        hold on
        plot(time(st:fn),elec(st:fn,j))
        set(gca,'XTick',[round(time(st))+.5:1:round(time(fn))+.5])
        datetick('x','ddd','KeepTicks')
        hold off

        week_time=[];
        weekend_time=[];
        
        week=[];
        weekend=[];
        days=[];
        days=[st weekday(time(st))];
        count=[1 1];
        clc
        %%%Going through each month
        for k=st+1:fn
            if datetimev(k,3) ~= datetimev(k-1,3)
                %%%Indicating end of each day
                days=[days
                    k weekday(time(k))];
                
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
%         weekend_std./weekend_avg
        
        week_avg(:,i)=mean(week,2);
        week_std(:,i)=std(week,1,2)./mean(week,2);
        week_total_std(1,i)=std(sum(week,1))/mean(sum(week,1));
        week_max(1,i)=max(abs((max(week)-max(week_avg(:,i)))./max(week_avg(:,i))));
        week_max(2,i)=max((max(week)-max(week_avg(:,i)))./max(week_avg(:,i)));
        
        week_num(i,j)=size(week,2);
        weekend_num(i,j)=size(weekend,2);
        
        %%%
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

    end
end

yrly_energy(3,:)=(yrly_energy(2,:)-yrly_energy(1,:))./yrly_energy(2,:);