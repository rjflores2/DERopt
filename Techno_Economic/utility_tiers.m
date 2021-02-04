%% Energy charges - C/I
count_w=1;
count_s=2;
count=1;
tou_index=1;
time_index=0;
tou_block=[];

%% Execute for when t_step is 15 minutes
if t_step == 15
    for i=1:size(datetimev,1)
        if datetimev(i,2)>=6 && datetimev(i,2)<10
            %%%TOU blocks only change during the weekdays (not weekend)
            %%%If the current time equals to the time of change
            if datetimev(i,4) == tou_summer(tou_index) ...
                    && time_index > 5 %%%and the time index is not back inside the same hour
                tou_block(count,1)=time_index;
                count=count+1;
                time_index=0;
                if tou_index<length(tou_summer)
                    tou_index=tou_index+1;
                else
                    tou_index=1;
                end
            end
        else
            %%%If the current time equals to the time of change
            if datetimev(i,4) == tou_winter(tou_index) ...
                    && time_index > 5 %%%and the time index is not back inside the same hour
                
                tou_block(count,1)=time_index;
                count=count+1;
                time_index=0;
                if tou_index<length(tou_winter)
                    tou_index=tou_index+1;
                else
                    tou_index=1;
                end
            end
        end
        
        if i>1 && (datetimev(i,2)>=6 && datetimev(i-1,2)<6) || (datetimev(i,2)>=10 && datetimev(i-1,2)<10)
            tou_block(count,1)=time_index;
            count=count+1;
            time_index=0;
            
            tou_index=1;
        end
        
        if i==length(datetimev)
            tou_block(count,1)=time_index;
        end
        
        time_index=time_index+1;
    end
    
elseif t_step == 60
    for i=1:size(datetimev,1)
        %%%TOU blocks only change during the weekdays (not weekend)
            %%%If the current time equals to the time of change
            %%%Summer months
%          if datetimev(i,2)>=6 && datetimev(i,2)<10
             
    end   
    
end