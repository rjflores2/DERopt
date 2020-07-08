%clear all ; close all ; clc 

load bldgdata\mdl_loads 
elec = [comm.all_ecm.ind comm.all_ecm.res comm.all_ecm.com]; 
%elec = [comm.base.ind comm.base.res comm.base.com];  

% %Fixing time and elec vectors to both begin at 01/01 00:00 instead of 01:00
% % and end at 01/31 at 23:00 instead of 01/01 00:00
temp = datetime(time(1),'ConvertFrom','datenum') - hours(1);
time = [datenum(temp) ; time(1:end-1)];
temp2 = elec(end,:);
elec = [temp2;elec(1:end-1,:)];

datetimev=datevec(time);
 
K = size(elec,2); % K = number of buildings
T = size(elec,1); % T = number of hours 

week_k = 5;
wknd_k = 2;

%Get month, day, and hour from time
month = datetimev(:,2); day = datetimev(:,3); hour = datetimev(:,4);

%Index for day of the week (2=Mon, 3=Tues, 4=Wed, 5=Thu, 6=Fri, 7=Sat, 1=Sun)
[daynumber, dayname] = weekday(time); 

%Find Weekday and Weekend indices 
weekdayidx = find(daynumber ~= 7 & daynumber ~= 1);
weekendidx = find(daynumber == 7 | daynumber == 1);
%Find Summer, Spring, and Winter indices.
summeridx = find(month == 7|month == 8|month == 9 |month == 10); %Summer = Jun, July, Aug, Sep, Oct
winteridx = find(month == 11|month == 12|month == 1|month == 2); %Winter = Nov, Dec, Jan, Feb
springidx = find(month == 3|month == 4|month == 5| month == 6); %Spring = March, Apr, May

%Build Scenarios
winterweekdayidx = intersect(weekdayidx,winteridx);
summerweekdayidx = intersect(weekdayidx,summeridx);
springweekdayidx = intersect(weekdayidx,springidx);
winterweekendidx = intersect(weekendidx,winteridx);
summerweekendidx = intersect(weekendidx,summeridx);
springweekendidx = intersect(weekendidx,springidx);

winterweekdayv = datevec(time(winterweekdayidx));
summerweekdayv = datevec(time(summerweekdayidx));
springweekdayv = datevec(time(springweekdayidx));
winterweekendv = datevec(time(winterweekendidx));
summerweekendv = datevec(time(summerweekendidx));
springweekendv = datevec(time(springweekendidx));

winterweekdaydata =[];summerweekdaydata =[];springweekdaydata =[];winterweekenddata =[];summerweekenddata =[];springweekenddata =[];

for bldg=1:K
    winterweekdaydata(:,bldg) = elec(winterweekdayidx,bldg);
    summerweekdaydata(:,bldg) = elec(summerweekdayidx,bldg);
    springweekdaydata(:,bldg) = elec(springweekdayidx,bldg);
    winterweekenddata(:,bldg) = elec(winterweekendidx,bldg);
    summerweekenddata(:,bldg) = elec(summerweekendidx,bldg);
    springweekenddata(:,bldg) = elec(springweekendidx,bldg);
end 

splitwinterweekday = [];splitsummerweekday = [];splitspringweekday = [];splitwinterweekend = [];splitsummerweekend = [];splitspringweekend = [];

for  bldg=1:K
splitwinterweekday(:,:,bldg) = reshape(winterweekdaydata(:,bldg),24,length(winterweekdaydata)/24)';
splitsummerweekday(:,:,bldg) = reshape(summerweekdaydata(:,bldg),24,length(summerweekdaydata)/24)';
splitspringweekday(:,:,bldg) = reshape(springweekdaydata(:,bldg),24,length(springweekdaydata)/24)';
splitwinterweekend(:,:,bldg) = reshape(winterweekenddata(:,bldg),24,length(winterweekenddata)/24)';
splitsummerweekend(:,:,bldg) = reshape(summerweekenddata(:,bldg),24,length(summerweekenddata)/24)';
splitspringweekend(:,:,bldg) = reshape(springweekenddata(:,bldg),24,length(springweekenddata)/24)';
end

%K-medeoids
%opts = statset('Display','iter');
for bldg = 1:K
[idx1(:,bldg),C1(:,:,bldg),sumd,d,midx,info] = kmedoids(splitsummerweekday(:,:,bldg),week_k,'Distance','cityblock');
[idx2(:,bldg),C2(:,:,bldg),sumd,d,midx,info] = kmedoids(splitsummerweekend(:,:,bldg),wknd_k,'Distance','cityblock');
[idx3(:,bldg),C3(:,:,bldg),sumd,d,midx,info] = kmedoids(splitwinterweekday(:,:,bldg),week_k,'Distance','cityblock');
[idx4(:,bldg),C4(:,:,bldg),sumd,d,midx,info] = kmedoids(splitwinterweekend(:,:,bldg),wknd_k,'Distance','cityblock');
[idx5(:,bldg),C5(:,:,bldg),sumd,d,midx,info] = kmedoids(splitspringweekday(:,:,bldg),week_k,'Distance','cityblock');
[idx6(:,bldg),C6(:,:,bldg),sumd,d,midx,info] = kmedoids(splitspringweekend(:,:,bldg),wknd_k,'Distance','cityblock');
end

elecsamplesplit = [C3;C6;C5;C2;C1;C4]; %Starting on a Week on winter

for bldg=1:K
elecsample(:,bldg) = reshape(elecsamplesplit(:,:,bldg)',[],1);
end

month_week_t = cell(1,12); month_wknd_t = cell(1,12);
for m = 1:12
 month_week_t{:,m} = time(intersect(weekdayidx,find(month==m))); % All hours in month m that are weekdays
 month_wknd_t{:,m} = time(intersect(weekendidx,find(month==m))); % All hours in month m that are weekends
end 

timesample  = [
    month_week_t{:,1}(1:24) % Getting a full winter day from 0 to 23 hours
    month_week_t{:,1}(25:48)
    month_week_t{:,2}(1:24)
    month_week_t{:,2}(25:48)
    month_week_t{:,2}(49:72)
    month_wknd_t{:,3}(1:24)
    month_wknd_t{:,4}(1:24)
    month_week_t{:,4}(25:48)
    month_week_t{:,5}(1:24)
    month_week_t{:,6}(1:24)
    month_week_t{:,6}(25:48)
    month_week_t{:,6}(49:72)
    month_wknd_t{:,7}(1:24)
    month_wknd_t{:,7}(25:48)
    month_week_t{:,8}(1:24)
    month_week_t{:,9}(1:24)
    month_week_t{:,9}(25:48)
    month_week_t{:,10}(1:24)
    month_week_t{:,10}(25:48)
    month_wknd_t{:,11}(1:24)
    month_wknd_t{:,12}(1:24)
    ];
    
datetimesamplev = datevec(timesample);

days_multi = [
    ones(24*week_k,1)*(size(splitwinterweekday,1))/week_k
    ones(24*wknd_k,1)*(size(splitspringweekend,1))/wknd_k
    ones(24*week_k,1)*(size(splitspringweekday,1))/week_k
    ones(24*wknd_k,1)*(size(splitsummerweekend,1))/wknd_k
    ones(24*week_k ,1)*(size(splitsummerweekday,1))/week_k 
    ones(24*wknd_k,1)*(size(splitwinterweekend,1))/wknd_k
    ];


save('elecsample.mat','elecsample')
save('timesample.mat','timesample')
save('days_multi.mat','days_multi')

% timeidx = [];
% for bldg=1 
%     for i=1:length(elecsample)
%         timeidx = find(elec(:,bldg)== elecsample(i,bldg));
%         timesample(i,bldg) = time(timeidx);
%     end
% end

%% Total AEC sampled demand timeseries 
elecAECsample = sum(elecsample,2);
save('elecAECsample.mat', 'elecAECsample')

%% Plots 
close all

for i=1:24
    hourstr{i} = num2str(i);
end

bldg = 2;

t=datetime(datetimev); %Create datetime vector
t.TimeZone = 'America/Los_Angeles';
DST = isdst(t); %Determines if in DayLightsavings time (0=No, 1=Yes)
datetimev(find(month == 3 & day == 8),:);
datetimev(find(month == 11 & day == 2),:);

%K-medoids clustering for Summer Weekday + Weekends
figure;
h1 = plot(splitsummerweekday(idx1(:,bldg)==1,:,bldg)','.','Color',rgb('LightSalmon'),'MarkerSize',10);
hold on
h2 = plot(splitsummerweekday(idx1(:,bldg)==2,:,bldg)','.','Color',rgb('DimGray'),'MarkerSize',10);
hold on
h3 = plot(splitsummerweekday(idx1(:,bldg)==3,:,bldg)','.','Color',rgb('MediumAquamarine'),'MarkerSize',10);
hold on
h4 = plot(splitsummerweekday(idx1(:,bldg)==4,:,bldg)','.','Color',rgb('Orchid'),'MarkerSize',10);
hold on
h5 = plot(splitsummerweekday(idx1(:,bldg)==5,:,bldg)','.','Color',rgb('LightBlue'),'MarkerSize',10);
hold on
h6 = plot(splitsummerweekend(idx2(:,bldg)==1,:,bldg)','.','Color',rgb('Pink'),'MarkerSize',10);
hold on 
h7 = plot(splitsummerweekend(idx2(:,bldg)==2,:,bldg)','.','Color',rgb('PaleGreen'),'MarkerSize',10);
hold on
h8 = plot(C1(1,:,bldg),'o','Color',rgb('FireBrick'),'MarkerSize',7,'LineWidth',1.5);
hold on
h9 = plot(C1(2,:,bldg),'o','Color',rgb('Black'),'MarkerSize',7,'LineWidth',1.5);
hold on
h10 = plot(C1(3,:,bldg),'o','Color',rgb('Teal'),'MarkerSize',7,'LineWidth',1.5);
hold on
h11 = plot(C1(4,:,bldg),'o','Color',rgb('DarkMagenta'),'MarkerSize',7,'LineWidth',1.5);
hold on 
h12 = plot(C1(5,:,bldg),'o','Color',rgb('Navy'),'MarkerSize',7,'LineWidth',1.5);
hold on 
h13 = plot(C2(1,:,bldg),'*','Color',rgb('DeepPink'),'MarkerSize',7,'LineWidth',1.5);
hold on
h14 = plot(C2(2,:,bldg),'*','Color',rgb('LimeGreen'),'MarkerSize',7,'LineWidth',1.5);
legend([h1(1) h2(1) h3(1) h4(1) h5(1) h6(1) h7(1) h8 h9 h10 h11 h12 h13 h14],{'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster 6','Cluster 7','Medoid 1','Medoid 2','Medoid 3','Medoid 4','Medoid 5','Medoid 6','Medoid 7'},'Location','best');
title({'Cluster Assignments and Medoids Summer Weekday + Weekends',[' Building:' , num2str(bldg)]})
hold off

%(Lines) K-medoids clustering for Summer Weekday + Weekends
figure;
h1 = plot(splitsummerweekday(idx1(:,bldg)==1,:,bldg)','Color',rgb('LightSalmon'),'LineWidth',1.0);
hold on
h2 = plot(splitsummerweekday(idx1(:,bldg)==2,:,bldg)','Color',rgb('DimGray'),'LineWidth',1.0);
hold on
h3 = plot(splitsummerweekday(idx1(:,bldg)==3,:,bldg)','Color',rgb('MediumAquamarine'),'LineWidth',1.0);
hold on
h4 = plot(splitsummerweekday(idx1(:,bldg)==4,:,bldg)','Color',rgb('Orchid'),'LineWidth',1.0);
hold on
h5 = plot(splitsummerweekday(idx1(:,bldg)==5,:,bldg)','Color',rgb('LightBlue'),'LineWidth',1.0);
hold on
h6 = plot(splitsummerweekend(idx2(:,bldg)==1,:,bldg)','Color',rgb('Pink'),'LineWidth',1.0);
hold on 
h7 = plot(splitsummerweekend(idx2(:,bldg)==2,:,bldg)','Color',rgb('PaleGreen'),'LineWidth',1.0);
hold on
h8 = plot(C1(1,:,bldg),'Color',rgb('FireBrick'),'MarkerSize',7,'LineWidth',2.0);
hold on
h9 = plot(C1(2,:,bldg),'Color',rgb('Black'),'MarkerSize',7,'LineWidth',2.0);
hold on
h10 = plot(C1(3,:,bldg),'Color',rgb('Teal'),'MarkerSize',7,'LineWidth',2.0);
hold on
h11 = plot(C1(4,:,bldg),'Color',rgb('DarkMagenta'),'MarkerSize',7,'LineWidth',2.0);
hold on 
h12 = plot(C1(5,:,bldg),'Color',rgb('Navy'),'MarkerSize',7,'LineWidth',2.0);
hold on
h13 = plot(C2(1,:,bldg),'--','Color',rgb('DeepPink'),'MarkerSize',7,'LineWidth',2.0);
hold on
h14 = plot(C2(2,:,bldg),'--','Color',rgb('LimeGreen'),'MarkerSize',7,'LineWidth',2.0);
legend([h1(1) h2(1) h3(1) h4(1) h5(1) h6(1) h7(1) h8 h9 h10 h11 h12 h13 h14],{'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster 6','Cluster 7','Medoid 1','Medoid 2','Medoid 3','Medoid 4','Medoid 5','Medoid 6','Medoid 7'},'Location','best');
title({'Cluster Assignments and Medoids Summer Weekday + Weekends',[' Building:' , num2str(bldg)]})
hold off

%K-medoids clustering for Winter Weekday + Weekends
figure;
h1 = plot(splitwinterweekday(idx3(:,bldg)==1,:,bldg)','.','Color',rgb('LightSalmon'),'MarkerSize',10);
hold on
h2 = plot(splitwinterweekday(idx3(:,bldg)==2,:,bldg)','.','Color',rgb('DimGray'),'MarkerSize',10);
hold on
h3 = plot(splitwinterweekday(idx3(:,bldg)==3,:,bldg)','.','Color',rgb('MediumAquamarine'),'MarkerSize',10);
hold on
h4 = plot(splitwinterweekday(idx3(:,bldg)==4,:,bldg)','.','Color',rgb('Orchid'),'MarkerSize',10);
hold on
h5 = plot(splitwinterweekday(idx3(:,bldg)==5,:,bldg)','.','Color',rgb('Orchid'),'MarkerSize',10);
hold on
h6 = plot(splitwinterweekend(idx4(:,bldg)==1,:,bldg)','.','Color',rgb('Pink'),'MarkerSize',10);
hold on 
h7 = plot(splitwinterweekend(idx4(:,bldg)==2,:,bldg)','.','Color',rgb('PaleGreen'),'MarkerSize',10);
hold on
h8 = plot(C3(1,:,bldg),'o','Color',rgb('FireBrick'),'MarkerSize',7,'LineWidth',2.0);
hold on
h9 = plot(C3(2,:,bldg),'o','Color',rgb('Black'),'MarkerSize',7,'LineWidth',1.5);
hold on
h10 = plot(C3(3,:,bldg),'o','Color',rgb('Teal'),'MarkerSize',7,'LineWidth',1.5);
hold on
h11 = plot(C3(4,:,bldg),'o','Color',rgb('DarkMagenta'),'MarkerSize',7,'LineWidth',1.5);
hold on 
h12 = plot(C3(5,:,bldg),'o','Color',rgb('DarkMagenta'),'MarkerSize',7,'LineWidth',1.5);
hold on 
h13 = plot(C4(1,:,bldg),'*','Color',rgb('LimeGreen'),'MarkerSize',7,'LineWidth',1.5);
hold on
h14 = plot(C4(2,:,bldg),'*','Color',rgb('LimeGreen'),'MarkerSize',7,'LineWidth',1.5);
legend([h1(1) h2(1) h3(1) h4(1) h5(1) h6(1) h7(1) h8 h9 h10 h11 h12 h13 h14],{'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster 6','Cluster 7','Medoid 1','Medoid 2','Medoid 3','Medoid 4','Medoid 5','Medoid 6','Medoid 7'},'Location','best');
title({'Cluster Assignments and Medoids Winter Weekday + Weekends',[' Building:' , num2str(bldg)]})
hold off

%(Lines) K-medoids clustering for Winter Weekday + Weekends
figure;
h1 = plot(splitwinterweekday(idx3(:,bldg)==1,:,bldg)','Color',rgb('LightSalmon'),'LineWidth',1.0);
hold on
h2 = plot(splitwinterweekday(idx3(:,bldg)==2,:,bldg)','Color',rgb('DimGray'),'LineWidth',1.0);
hold on
h3 = plot(splitwinterweekday(idx3(:,bldg)==3,:,bldg)','Color',rgb('MediumAquamarine'),'LineWidth',1.0);
hold on
h4 = plot(splitwinterweekday(idx3(:,bldg)==4,:,bldg)','Color',rgb('Orchid'),'LineWidth',1.0);
hold on
h5 = plot(splitwinterweekday(idx3(:,bldg)==5,:,bldg)','Color',rgb('Orchid'),'LineWidth',1.0);
hold on
h6 = plot(splitwinterweekend(idx4(:,bldg)==1,:,bldg)','Color',rgb('PaleGreen'),'LineWidth',1.0);
hold on 
h7 = plot(splitwinterweekend(idx4(:,bldg)==2,:,bldg)','Color',rgb('PaleGreen'),'LineWidth',1.0);
hold on
h8 = plot(C3(1,:,bldg),'Color',rgb('FireBrick'),'MarkerSize',7,'LineWidth',2.0);
hold on
h9 = plot(C3(2,:,bldg),'Color',rgb('Black'),'MarkerSize',7,'LineWidth',2.0);
hold on
h10 = plot(C3(3,:,bldg),'Color',rgb('Teal'),'MarkerSize',7,'LineWidth',2.0);
hold on
h11 = plot(C3(4,:,bldg),'Color',rgb('DarkMagenta'),'MarkerSize',7,'LineWidth',2.0);
hold on 
h12 = plot(C3(4,:,bldg),'Color',rgb('DarkMagenta'),'MarkerSize',7,'LineWidth',2.0);
hold on
h13 = plot(C4(1,:,bldg),'--','Color',rgb('DeepPink'),'MarkerSize',7,'LineWidth',2.0);
hold on
h14 = plot(C4(2,:,bldg),'--','Color',rgb('LimeGreen'),'MarkerSize',7,'LineWidth',2.0);
legend([h1(1) h2(1) h3(1) h4(1) h5(1) h6(1) h7(1) h8 h9 h10 h11 h12 h13 h14],{'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster 6','Cluster 7','Medoid 1','Medoid 2','Medoid 3','Medoid 4','Medoid 5','Medoid 6','Medoid 7'},'Location','best');
title({'Cluster Assignments and Medoids Winter Weekday + Weekends',[' Building:' , num2str(bldg)]})
hold off

%K-medoids clustering for Spring Weekday + Weekends
figure;
h1 = plot(splitspringweekday(idx5(:,bldg)==1,:,bldg)','.','Color',rgb('LightSalmon'),'MarkerSize',10);
hold on
h2 = plot(splitspringweekday(idx5(:,bldg)==2,:,bldg)','.','Color',rgb('DimGray'),'MarkerSize',10);
hold on
h3 = plot(splitspringweekday(idx5(:,bldg)==3,:,bldg)','.','Color',rgb('MediumAquamarine'),'MarkerSize',10);
hold on
h4 = plot(splitspringweekday(idx5(:,bldg)==4,:,bldg)','.','Color',rgb('Orchid'),'MarkerSize',10);
hold on
h5 = plot(splitspringweekday(idx5(:,bldg)==4,:,bldg)','.','Color',rgb('Orchid'),'MarkerSize',10);
hold on
h6 = plot(splitspringweekend(idx6(:,bldg)==1,:,bldg)','.','Color',rgb('Pink'),'MarkerSize',10);
hold on 
h7 = plot(splitspringweekend(idx6(:,bldg)==2,:,bldg)','.','Color',rgb('PaleGreen'),'MarkerSize',10);
hold on
h8 = plot(C5(1,:,bldg),'o','Color',rgb('FireBrick'),'MarkerSize',7,'LineWidth',1.5);
hold on
h9 = plot(C5(2,:,bldg),'o','Color',rgb('Black'),'MarkerSize',7,'LineWidth',1.5);
hold on
h10 = plot(C5(2,:,bldg),'o','Color',rgb('Black'),'MarkerSize',7,'LineWidth',1.5);
hold on
h11 = plot(C5(3,:,bldg),'o','Color',rgb('Teal'),'MarkerSize',7,'LineWidth',1.5);
hold on
h12 = plot(C5(4,:,bldg),'o','Color',rgb('DarkMagenta'),'MarkerSize',7,'LineWidth',1.5);
hold on 
h13 = plot(C6(1,:,bldg),'*','Color',rgb('DeepPink'),'MarkerSize',7,'LineWidth',1.5);
hold on
h14 = plot(C6(2,:,bldg),'*','Color',rgb('LimeGreen'),'MarkerSize',7,'LineWidth',1.5);
legend([h1(1) h2(1) h3(1) h4(1) h5(1) h6(1) h7(1) h8 h9 h10 h11 h12 h13 h14],{'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster 6','Cluster 7','Medoid 1','Medoid 2','Medoid 3','Medoid 4','Medoid 5','Medoid 6','Medoid 7'},'Location','best');
title({'Cluster Assignments and Medoids Spring Weekday + Weekends',[' Building:' , num2str(bldg)]})
hold off

%(Lines) K-medoids clustering for Spring Weekday + Weekends
figure;
h1 = plot(splitspringweekday(idx5(:,bldg)==1,:,bldg)','Color',rgb('LightSalmon'),'LineWidth',1.0);
hold on
h2 = plot(splitspringweekday(idx5(:,bldg)==2,:,bldg)','Color',rgb('DimGray'),'LineWidth',1.0);
hold on
h3 = plot(splitspringweekday(idx5(:,bldg)==3,:,bldg)','Color',rgb('MediumAquamarine'),'LineWidth',1.0);
hold on
h4 = plot(splitspringweekday(idx5(:,bldg)==4,:,bldg)','Color',rgb('Orchid'),'LineWidth',1.0);
hold on
h5 = plot(splitspringweekday(idx5(:,bldg)==4,:,bldg)','Color',rgb('Orchid'),'LineWidth',1.0);
hold on
h6 = plot(splitspringweekend(idx6(:,bldg)==1,:,bldg)','Color',rgb('Pink'),'LineWidth',1.0);
hold on 
h7 = plot(splitspringweekend(idx6(:,bldg)==2,:,bldg)','Color',rgb('PaleGreen'),'LineWidth',1.0);
hold on
h8 = plot(C5(1,:,bldg),'Color',rgb('FireBrick'),'MarkerSize',7,'LineWidth',2.0);
hold on
h9 = plot(C5(2,:,bldg),'Color',rgb('Black'),'MarkerSize',7,'LineWidth',2.0);
hold on
h10 = plot(C5(3,:,bldg),'Color',rgb('Teal'),'MarkerSize',7,'LineWidth',2.0);
hold on
h11 = plot(C5(4,:,bldg),'Color',rgb('DarkMagenta'),'MarkerSize',7,'LineWidth',2.0);
hold on 
h12 = plot(C5(4,:,bldg),'Color',rgb('DarkMagenta'),'MarkerSize',7,'LineWidth',2.0);
hold on 
h13 = plot(C6(1,:,bldg),'--','Color',rgb('DeepPink'),'MarkerSize',7,'LineWidth',2.0);
hold on
h14 = plot(C6(2,:,bldg),'--','Color',rgb('LimeGreen'),'MarkerSize',7,'LineWidth',2.0);
legend([h1(1) h2(1) h3(1) h4(1) h5(1) h6(1) h7(1) h8 h9 h10 h11 h12 h13 h14],{'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster 6','Cluster 7','Medoid 1','Medoid 2','Medoid 3','Medoid 4','Medoid 5','Medoid 6','Medoid 7'},'Location','best');
title({'Cluster Assignments and Medoids Spring Weekday + Weekends',[' Building:' , num2str(bldg)]})
hold off

%Bldg's year-round demand. Colored by scenario
fig = figure; ax = axes('Parent',fig);
h1 = plot(splitsummerweekday(:,:,bldg)','r'); % MATLAB plots each column as a different line
hold on
h2 = plot(splitsummerweekend(:,:,bldg)','r'); % MATLAB plots each column as a different line
hold on
h3 = plot(splitspringweekday(:,:,bldg)','m'); % MATLAB plots each column as a different line
hold on
h4 = plot(splitspringweekend(:,:,bldg)','m'); % MATLAB plots each column as a different line
hold on
h5 = plot(splitwinterweekday(:,:,bldg)','b'); % MATLAB plots each column as a different line
hold on 
h6 = plot(splitwinterweekend(:,:,bldg)','b'); % MATLAB plots each column as a different line
hold off
ax.XTick = 1:24; ax.XTickLabel = hourstr; ax.XLim = [1 24];
title(['Year-Round Demand. Colored by scenario. Building: ' , num2str(bldg),]) 
legend([h1(1) h3(1) h5(1)],{'Summer' ,'Spring' ,'Winter'})
grid on

%Bldg's Sampled demand. Colored by Scenario
fig = figure; ax = axes('Parent',fig);
h = plot(elecsamplesplit(:,:,bldg)');
%Coloring for scenario
for i = 1:18
    if i<=6
        h(i).Color = 'r';
    elseif (7<=i) && (i<=12)
        h(i).Color = 'b';
    else
        h(i).Color = 'm';
    end
end 
%Changing line style for weekends
for i = 1:18
    if i==5 || i==6 || i==11 || i==12 || i==17 || i==18
        h(i).LineStyle = '--';
        h(i).LineWidth = 1.5;
    end
end 

ax.XTick = 1:24; ax.XTickLabel = hourstr; ax.XLim = [1 24];
title(['Sampled Demand. Colored by Scenario. Building:' , num2str(bldg),])
legend([h(1) h(7) h(13)],{'Summer','Winter','Spring'})

% %Demand Curve First 300 hours Timeseries
% figure;
% plot(elec(1:300,bldg))
% title(['Demand Curve Time-Series. First 300 hours. Building:' , num2str(bldg),])

%Sampled Demand Curve Timeseries
figure;
plot(elecsample(:,bldg))
title(['Sampled Demand Time-series. Building:' , num2str(bldg),])

%Total AEC Samppled Demand Timeseries
figure;
plot(elecAECsample)
axis tight
title('Total AEC Sampled Demand Time-series')
ylabel('Total elec (kW)')
xlabel('Optimization Timeframe')

%Total AEC Raw Demand Timeseries
figure;
plot(sum(elec,2))
axis tight
title('Total AEC Raw Demand Time-series')
ylabel('Total elec (kW)')
xlabel('Optimization Timeframe')

%% Plot ALL Bldg year-round demand. Colored by Season
close all 
for bldg =1:K
fig = figure; ax = axes('Parent',fig);
h1 = plot(splitsummerweekday(:,:,bldg)','r'); % MATLAB plots each column as a different line
hold on
h2 = plot(splitsummerweekend(:,:,bldg)','r'); % MATLAB plots each column as a different line
hold on
h3 = plot(splitspringweekday(:,:,bldg)','m'); % MATLAB plots each column as a different line
hold on
h4 = plot(splitspringweekend(:,:,bldg)','m'); % MATLAB plots each column as a different line
hold on
h5 = plot(splitwinterweekday(:,:,bldg)','b'); % MATLAB plots each column as a different line
hold on 
h6 = plot(splitwinterweekend(:,:,bldg)','b'); % MATLAB plots each column as a different line
hold off
ax.XTick = 1:24; ax.XTickLabel = hourstr; ax.XLim = [1 24];
title(['Year-Round Horly Demand. Colored by Season - Building: ' , num2str(bldg),]) 
xlabel('Hour')
ylabel('kW')
legend([h1(1) h3(1) h5(1)],{'Summer' ,'Spring' ,'Winter'},'Location','best')
end 