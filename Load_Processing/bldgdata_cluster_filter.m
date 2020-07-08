%%%Data Organizer for putting together the clustered data
function [cluster_data,output_winter_wkdy,output_winter_wknd,output_summer_wkdy,output_summer_wknd]=bldgdata_cluster_filter(filenameholder,summer_days,summer_weekend_start,winter_days,winter_weekend_start)
%% Crap to be eliminated (Somewhere in the code)
%%%Adding cplex path to matlab folder

%%%Time demarking beginning of summer and end of winter
time_start=datenum([2010,6,1,0,0,0]);
%%%Loading Building Data

xls_filename=strcat('U:\Matlab_Reader\Building Data\',filenameholder,'.xlsx')
[bldgdata]= xlsread(xls_filename);

%%%Ajdusting building load if only electricity, or elec and cooling are
%%%included
if size(bldgdata,2)~=4
    bldgdata=[bldgdata zeros(size(bldgdata,1),4-size(bldgdata,2))];
end

%%%Converting all building demand to kWh
%%%Heating demand - kWh
bldgdata(:,3)=bldgdata(:,3)*293.1;
%%%Cooling
bldgdata(:,4)=bldgdata(:,4)*293.1;

datetimev=datevec(bldgdata(:,1));

%%%Cutting off last partial day
for i=1:length(datetimev)
    j=length(datetimev)+1-i;
    if datetimev(j,3)~=datetimev(j-1,3)
        bldgdata=bldgdata(1:j-1,:);
        datetimev=datevec(bldgdata(:,1));
        break
    end
end

%%%Eliminating tail if the last date is messed up
 if datetimev(length(datetimev),5)>50
%      datetimev=datetimev(1:length(datetimev)-1,:);
     bldgdata=bldgdata(1:length(datetimev)-1,:);
        datetimev=datevec(bldgdata(:,1));
 end

  %%%Checking the length of each individual day in the data set
 count=1;
 for i=2:length(datetimev)-1
     if i==2
         start=1;
     end
     if datetimev(i,3)~=datetimev(i-1,3)
         finish=i;
         day_delta(count)=finish-start;
         start=finish;
         count=count+1;
     end
     if i==length(datetimev)-1
         finish=length(datetimev)+1;
         day_delta(count)=finish-start;
     end
 end
 day_mean=mean(day_delta);

 %%% Finding endpts of the months
 %%%Determining endpoints for all months - end pt is the data entry for a
 %%%month
 counter=1;
 for i=2:length(datetimev)
     if datetimev(i,2)~=datetimev(i-1,2)
         endpts(counter,1)=i-1;
         %%%Summer month = 1
         if datetimev(i-1,2)>=6 && datetimev(i-1,2)<10
             endpts(counter,2)=1;
             %%%Winter month = 0
         else
             endpts(counter,2)=0;
         end
         counter=counter+1;
     end
 end
 %%%Seperating between summer and winter months

 winter=[];
 summer=[];
 for i=1:length(endpts)
     if i==1
         start=1;
         finish=endpts(i);
     else
         start=endpts(i-1)+1;
         finish=endpts(i);
     end
%      endpts(i,2)
     if endpts(i,2)==1
         summer=[summer
             bldgdata(start:finish,:)];
     else
         winter=[winter
             bldgdata(start:finish,:)];
     end
 end
     
 
 summer_datetimev=datevec(summer(:,1));
 winter_datetimev=datevec(winter(:,1));

 %% Summer Month 
 %%% Finding day endpts and seperating between weekday and weekends
 summer_weekday=[];
 summer_weekend=[];
 count=1;
 %%%Initializing starting point in loop
 start=1;

 for i=2:size(summer_datetimev,1)   
     %%%Checking for change in day
     if (summer_datetimev(i,3)~=summer_datetimev(i-1,3)) || i==size(summer_datetimev,1) 
         %%%Setting finish of the day
         if i==size(summer_datetimev,1)
             finish=size(summer_datetimev,1) ;
         else
             finish=i-1;
         end
         
         %%%Checking to see if during the weekend
         if weekday(summer(start,1))==1 || weekday(summer(start,1))==7             
             summer_weekend=[summer_weekend;
                 summer(start:finish,:)];
             
         else
             summer_weekday=[summer_weekday;
                 summer(start:finish,:)];
         end
         %%%Updating the start for the next iteration
         start=i;
         
     end
 end
%  mean(summer_weekend(:,2))
%  mean(summer_weekday(:,2))
 
 %%% Selecting summer weekend days
 [summer_weekend_new,output_summer_wkdy,day_endpts_summer_weekend,y_val_summer_weekend,z_mat_summer_weekend]=FDM_Day_Selection_v2(summer_weekend,summer_days(2));
 %%%Selecting summer weekday days
 [summer_weekday_new,output_summer_wknd,day_endpts_summer_weekday,y_val_summer_weekday,z_mat_summer_weekday]=FDM_Day_Selection_v2(summer_weekday,summer_days(1));
 
 %%% Assembling new summer data so that weekend days occur on the prescribed weekends
 %%% and weekdays occur during the prescribed weekdays
 count1=1;
 count2=1;
 summer_clustered=[];
 for i=1:sum(summer_days)
     %%%If a weekend is occuring
     i-summer_weekend_start;
     if rem(i-summer_weekend_start,7)==0 || rem(i-summer_weekend_start+1,7)==0
         
         day_index=y_val_summer_weekend(count1,1);
         count1=count1+1;
         if day_index==1;
             start=1;
             finish=day_endpts_summer_weekend(day_index);
         else
             start=day_endpts_summer_weekend(day_index-1)+1;
             finish=day_endpts_summer_weekend(day_index);
         end
         summer_clustered=[summer_clustered;
             summer_weekend(start:finish,:)];
     %%%If a weekday is occuring
     else
         day_index=y_val_summer_weekday(count2,1);
         count2=count2+1;
         if day_index==1;
             start=1;
             finish=day_endpts_summer_weekday(day_index);
         else
             start=day_endpts_summer_weekday(day_index-1)+1;
             finish=day_endpts_summer_weekday(day_index);
         end
         summer_clustered=[summer_clustered;
             summer_weekday(start:finish,:)];
     end
 end
 
 summer_time=time_start;
 %%%Setting date for the new fector
 for i=2:size(summer_clustered,1)
     summer_time(i,1)=summer_time(i-1,1)+datenum([0,0,0,0,15,0]);
 end
 summer_clustered(:,1)=summer_time;
 %% Summer Month 
 %%% Finding day endpts and seperating between weekday and weekends
 winter_weekday=[];
 winter_weekend=[];
 count=1;
 %%%Initializing starting point in loop
 start=1;

 for i=2:size(winter_datetimev,1)   
     %%%Checking for change in day
     if (winter_datetimev(i,3)~=winter_datetimev(i-1,3)) || i==size(winter_datetimev,1) 
         %%%Setting finish of the day
         if i==size(winter_datetimev,1)
             finish=size(winter_datetimev,1) ;
         else
             finish=i-1;
         end
         
         %%%Checking to see if during the weekend
         if weekday(winter(start,1))==1 || weekday(winter(start,1))==7             
             winter_weekend=[winter_weekend;
                 winter(start:finish,:)];
             
         else
             winter_weekday=[winter_weekday;
                 winter(start:finish,:)];
         end
         %%%Updating the start for the next iteration
         start=i;
         
     end
 end
 mean(winter_weekend(:,2));
 mean(winter_weekday(:,2));
 
 %%% Selecting winter weekend days
 [winter_weekend_new,output_winter_wkdy,day_endpts_winter_weekend,y_val_winter_weekend,z_mat_winter_weekend]=FDM_Day_Selection_v2(winter_weekend,winter_days(2));
 %%%Selecting winter weekday days
 [winter_weekday_new,output_winter_wknd,day_endpts_winter_weekday,y_val_winter_weekday,z_mat_winter_weekday]=FDM_Day_Selection_v2(winter_weekday,winter_days(1));
 
 
% day_endpts_winter_weekday
weekend_length=length(y_val_winter_weekend);
weekday_length=length(y_val_winter_weekday);

 weekend_length=length(day_endpts_winter_weekend);
 weekday_length=length(day_endpts_winter_weekday);
 %%% Assembling new winter data so that weekend days occur on the prescribed weekends
 %%% and weekdays occur during the prescribed weekdays
 count1=1;
 count2=1;
 winter_clustered=[];
 winter_days;
%  y_val_winter_weekday
 length(y_val_winter_weekday);
 length(day_endpts_winter_weekend);
 for i=1:sum(winter_days)
     %%%If a weekend is occuring
     i-winter_weekend_start;
     if rem(i-winter_weekend_start,7)==0 || rem(i-winter_weekend_start+1,7)==0
         
         day_index=y_val_winter_weekend(count1,1);
         count1=count1+1;
         if day_index==1;
             start=1;
             finish=day_endpts_winter_weekend(day_index);
         else
             start=day_endpts_winter_weekend(day_index-1)+1;
             finish=day_endpts_winter_weekend(day_index);
         end
         winter_clustered=[winter_clustered;
             winter_weekend(start:finish,:)];
%          delta1=finish-start
     %%%If a weekday is occuring
     else
         count1;
         count2;
%          length(winter_clustered)
         day_index=y_val_winter_weekday(count2,1);
         count2=count2+1;
         if day_index==1;
             start=1;
             finish=day_endpts_winter_weekday(day_index);
         else
             start=day_endpts_winter_weekday(day_index-1)+1;
             finish=day_endpts_winter_weekday(day_index);
         end
%          delta2=finish-start
         winter_clustered=[winter_clustered;
             winter_weekday(start:finish,:)];
     end
 end
 
 winter_time=summer_time(1)-datenum([0,0,0,0,15,0]);
 %%%Setting date for the new fector
 for i=2:size(winter_clustered,1)
     winter_time(i,1)=winter_time(i-1,1)-datenum([0,0,0,0,15,0]);
 end
  winter_time = flipud(winter_time);
  
  winter_clustered(:,1)=winter_time;
  
  cluster_data=[winter_clustered;
      summer_clustered];
  
  cluster_data=[cluster_data
      zeros(1,size(cluster_data,2))];
  
  cluster_data=cluster_data(2:length(cluster_data),:);
  
  datetimev_cluster=datevec(cluster_data(:,1));
  