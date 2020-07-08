%% Elec import/export price
%% C/I Rates

onpeak_index=zeros(length(elec),1);
midpeak_index=zeros(size(onpeak_index));

import_price_ci=[];

%%%Indicies of TOU DCs
dc_on_index = zeros(size(elec,1),1);
dc_mid_index = zeros(size(elec,1),1);

if isempty(erate_ci) == 0
    
    %%%For each instance in time
    for i=1:size(elec,1)
        %%%Summer Months
        if datetimev(i,2)>=6 && datetimev(i,2)<10
            %%%On
            if datetimev(i,4)>=12 && datetimev(i,4)<18....
                    && weekday(time(i)) ~= 1 && weekday(time(i)) ~= 7
                import_price_ci(i,:) = erate_ci(1,:);
                
                dc_on_index(i) = 1;
                %%% Mid Morning
            elseif datetimev(i,4)>=8&&datetimev(i,4)<12....
                    && weekday(time(i)) ~= 1 && weekday(time(i)) ~= 7
                import_price_ci(i,:) = erate_ci(2,:);
                
                dc_mid_index(i) = 1;
                %%% Early Evening
            elseif datetimev(i,4)>=18&&datetimev(i,4)<23....
                    && weekday(time(i)) ~= 1 && weekday(time(i)) ~= 7
                import_price_ci(i,:) = erate_ci(2,:);
                
                dc_mid_index(i) = 1;
                %%%Night/Early Morning
            else
                import_price_ci(i,:) = erate_ci(3,:);
            end
            
            %%%Winter
        else
            %%%Mid
            if datetimev(i,4)>=8&&datetimev(i,4)<21....
                    && weekday(time(i)) ~= 1 && weekday(time(i)) ~= 7
                import_price_ci(i,:) = erate_ci(4,:);
                %%%All other time
            else
                import_price_ci(i,:) = erate_ci(5,:);
            end
        end
    end
end

%%%Export price is import - NBCs
for i=1:size(import_price_ci,2)
    export_price_ci(:,i) = import_price_ci(:,i) - nbc_ci(i);
end


%% Domestic Normal Rates

import_price_d=[];
if isempty(erates_d_tou) == 0
    %%%For each instance in time
    for i=1:size(elec,1)
        %%%Summer Months
        if datetimev(i,2)>=6 && datetimev(i,2)<10
            %%%On
            if datetimev(i,4)>=14 && datetimev(i,4)<20....
                    && weekday(time(i)) ~= 1 && weekday(time(i)) ~= 7
                import_price_d(i,:) = erates_d_tou(1,:);
                %%%Mid Early Morning
            elseif datetimev(i,4)>=8 && datetimev(i,4)<14....
                    && weekday(time(i)) ~= 1 && weekday(time(i)) ~= 7
                import_price_d(i,:) = erates_d_tou(2,:);
                %%% Early Evening
            elseif datetimev(i,4)>=20 && datetimev(i,4)<22....
                    && weekday(time(i)) ~= 1 && weekday(time(i)) ~= 7
                import_price_d(i,:) = erates_d_tou(2,:);
                %%%Late Evening
            elseif datetimev(i,4)>=22 ....
                    && weekday(time(i)) ~= 1 && weekday(time(i)) ~= 7
                import_price_d(i,:) = erates_d_tou(3,:);
                %%%Early Morning
            elseif datetimev(i,4)<8 ....
                    && weekday(time(i)) ~= 1 && weekday(time(i)) ~= 7
                import_price_d(i,:) = erates_d_tou(3,:);
                %%%Weekend Midday
            elseif datetimev(i,4)>=8 && datetimev(i,4)<22....
                    && (weekday(time(i)) == 1 || weekday(time(i)) == 7)
                import_price_d(i,:) = erates_d_tou(2,:);
                %%%Weekend Mornings/Evenings
            else
                import_price_d(i,:) = erates_d_tou(3,:);
            end
            %%%Winter
        else
            %%%On
            if datetimev(i,4)>=14 && datetimev(i,4)<20....
                    && weekday(time(i)) ~= 1 && weekday(time(i)) ~= 7
                import_price_d(i,:) = erates_d_tou(4,:);
                %%%Mid Early Morning
            elseif datetimev(i,4)>=8 && datetimev(i,4)<14....
                    && weekday(time(i)) ~= 1 && weekday(time(i)) ~= 7
                import_price_d(i,:) = erates_d_tou(5,:);
                %%% Early Evening
            elseif datetimev(i,4)>=20 && datetimev(i,4)<22....
                    && weekday(time(i)) ~= 1 && weekday(time(i)) ~= 7
                import_price_d(i,:) = erates_d_tou(5,:);
                %%%Late Evening
            elseif datetimev(i,4)>=22 ....
                    && weekday(time(i)) ~= 1 && weekday(time(i)) ~= 7
                import_price_d(i,:) = erates_d_tou(6,:);
                %%%Early Morning
            elseif datetimev(i,4)<8 ....
                    && weekday(time(i)) ~= 1 && weekday(time(i)) ~= 7
                import_price_d(i,:) = erates_d_tou(6,:);
                %%%Weekend Midday
            elseif datetimev(i,4)>=8 && datetimev(i,4)<22....
                    && (weekday(time(i)) == 1 || weekday(time(i)) == 7)
                import_price_d(i,:) = erates_d_tou(5,:);
                %%%Weekend Mornings/Evenings
            else
                import_price_d(i,:) = erates_d_tou(6,:);
            end
        end
    end
end

%%%Export price
for i = 1:size(import_price_d,2)
    export_price_d(:,i) = import_price_d(:,i) - nbc_d_tou(i);
end
            

%% Domestic Evening Rates
import_price_d_pm=[];

if isempty(erates_d_tou_pm) == 0

    %%%For each instance in time
    for i=1:size(elec,1)
        %%%Summer Months
        if datetimev(i,2)>=6 && datetimev(i,2)<10
            %%%On
            if datetimev(i,4)>=16 && datetimev(i,4)<21....
                    && weekday(time(i)) ~= 1 && weekday(time(i)) ~= 7
                import_price_d_pm(i,:) = erates_d_tou_pm(1,:);
                %%%Weekend On
            elseif datetimev(i,4)>=16 && datetimev(i,4)<21....
                    && (weekday(time(i)) == 1 || weekday(time(i)) == 7)
                import_price_d_pm(i,:) = erates_d_tou_pm(2,:);
                %%Weekday Off
            else
                import_price_d_pm(i,:) = erates_d_tou_pm(3,:);
            end
            %%%Winter Months
        else
            %%%Weekend and Weekday On
            if datetimev(i,4)>=16 && datetimev(i,4)<21 
                import_price_d_pm(i,:) = erates_d_tou_pm(4,:);
                %%%Weekend On
            elseif datetimev(i,4)>=8 && datetimev(i,4)<16
                import_price_d_pm(i,:) = erates_d_tou_pm(6,:);
                %%Weekday Off
            else
                import_price_d_pm(i,:) = erates_d_tou_pm(5,:);
            end
        end
    end
end

%%%Export price
for i = 1:size(import_price_d_pm,2)
    export_price_d_pm(:,i) = import_price_d_pm(:,i) - nbc_d_tou_pm(i);
end

%% Combining Prices
import_price = [import_price_ci import_price_d import_price_d_pm];

export_price = [export_price_ci export_price_d export_price_d_pm];