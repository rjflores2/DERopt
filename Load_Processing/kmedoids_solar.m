%clear all ; close all ; clc 

load bldgdata\mdl_loads 
load 'solar_sna.mat'
datetimev=datevec(time);

T = length(time); % T = number of hours 

%Get month, day, and hour from time
month = datetimev(:,2); day = datetimev(:,3); hour = datetimev(:,4);

%Index for day of the week (2=Mon, 3=Tues, 4=Wed, 5=Thu, 6=Fri, 7=Sat, 1=Sun)
[daynumber, dayname] = weekday(time); 

%Find Summer, Spring, and Winter indices.
summeridx = find(month == 6| month == 7|month == 8|month == 9 |month == 10); %Summer = Jun, July, Aug, Sep, Oct
winteridx = find(month == 11|month == 12|month == 1|month == 2); %Winter = Nov, Dec, Jan, Feb
springidx = find(month == 3|month == 4|month == 5); %Spring = March, Apr, May

summerdata = solar(summeridx);
winterdata = solar(winteridx);
springdata = solar(springidx);

splitsummer(:,:) = reshape(summerdata,24,length(summerdata)/24)';
splitwinter(:,:) = reshape(winterdata,24,length(winterdata)/24)';
splitspring(:,:) = reshape(springdata,24,length(springdata)/24)';

%k-medoids
%opts = statset('Display','iter');
[idx1,C1,sumd,d,midx,info] = kmedoids(splitsummer,7,'Distance','cityblock');
[idx2,C2,sumd,d,midx,info] = kmedoids(splitwinter,7,'Distance','cityblock');
[idx3,C3,sumd,d,midx,info] = kmedoids(splitspring,7,'Distance','cityblock');

solarsamplesplit = [C2(4:7,:);C3;C1;C2(1:3,:)]; %winter, then spring, then summer then winter again data

solarsample = reshape(solarsamplesplit',[],1);

save('solarsample.mat','solarsample')

%% Plots 
close all

for i=1:24
    hourstr{i} = num2str(i);
end

%K-medoids clustering for Summer 
figure;
h1=plot(splitsummer(idx1==1,:)','.','Color',rgb('LightSalmon'),'MarkerSize',10);
hold on
h2=plot(splitsummer(idx1==2,:)','.','Color',rgb('DimGray'),'MarkerSize',10);
hold on
h3=plot(splitsummer(idx1==3,:)','.','Color',rgb('MediumAquamarine'),'MarkerSize',10);
hold on
h4=plot(splitsummer(idx1==4,:)','.','Color',rgb('Orchid'),'MarkerSize',10);
hold on
h5=plot(splitsummer(idx1==5,:)','.','Color',rgb('Pink'),'MarkerSize',10);
hold on 
h6=plot(splitsummer(idx1==6,:)','.','Color',rgb('PaleGreen'),'MarkerSize',10);
hold on
h7=plot(splitsummer(idx1==7,:)','.','Color',rgb('LightBlue'),'MarkerSize',10);
hold on
h8=plot(C1(1,:),'o','Color',rgb('FireBrick'),'MarkerSize',7,'LineWidth',2.0);
hold on
h9=plot(C1(2,:),'o','Color',rgb('Black'),'MarkerSize',7,'LineWidth',1.5);
hold on
h10=plot(C1(3,:),'o','Color',rgb('Teal'),'MarkerSize',7,'LineWidth',1.5);
hold on
h11=plot(C1(4,:),'o','Color',rgb('DarkMagenta'),'MarkerSize',7,'LineWidth',1.5);
hold on 
h12=plot(C1(5,:),'o','Color',rgb('DeepPink'),'MarkerSize',7,'LineWidth',1.5);
hold on
h13=plot(C1(6,:),'o','Color',rgb('LimeGreen'),'MarkerSize',7,'LineWidth',1.5);
hold on
h14=plot(C1(7,:),'o','Color',rgb('Navy'),'MarkerSize',7,'LineWidth',1.5);
legend([h1(1) h2(1) h3(1) h4(1) h5(1) h6(1) h7(1) h8 h9 h10 h11 h12 h13 h14],{'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster 6','Cluster 7','Medoid 1','Medoid 2','Medoid 3','Medoid 4','Medoid 5','Medoid 6','Medoid 7'},'Location','best');
title('Cluster Assignments and Medoids for Summer')
hold off

%(Lines) K-medoids clustering for Summer 
figure;
h1=plot(splitsummer(idx1==1,:)','Color',rgb('LightSalmon'),'LineWidth',1.0);
hold on
h2=plot(splitsummer(idx1==2,:)','Color',rgb('DimGray'),'LineWidth',1.0);
hold on
h3=plot(splitsummer(idx1==3,:)','Color',rgb('MediumAquamarine'),'LineWidth',1.0);
hold on
h4=plot(splitsummer(idx1==4,:)','Color',rgb('Orchid'),'LineWidth',1.0);
hold on
h5=plot(splitsummer(idx1==5,:)','Color',rgb('Pink'),'LineWidth',1.0);
hold on 
h6=plot(splitsummer(idx1==6,:)','Color',rgb('PaleGreen'),'LineWidth',1.0);
hold on
h7=plot(splitsummer(idx1==7,:)','Color',rgb('LightBlue'),'LineWidth',1.0);
hold on
h8=plot(C1(1,:),'Color',rgb('FireBrick'),'MarkerSize',7,'LineWidth',2.0);
hold on
h9=plot(C1(2,:),'Color',rgb('Black'),'MarkerSize',7,'LineWidth',2.0);
hold on
h10=plot(C1(3,:),'Color',rgb('Teal'),'MarkerSize',7,'LineWidth',2.0);
hold on
h11=plot(C1(4,:),'Color',rgb('DarkMagenta'),'MarkerSize',7,'LineWidth',2.0);
hold on 
h12=plot(C1(5,:),'Color',rgb('DeepPink'),'MarkerSize',7,'LineWidth',1.5);
hold on
h13=plot(C1(6,:),'Color',rgb('LimeGreen'),'MarkerSize',7,'LineWidth',1.5);
hold on
h14=plot(C1(7,:),'Color',rgb('Navy'),'MarkerSize',7,'LineWidth',1.5);
legend([h1(1) h2(1) h3(1) h4(1) h5(1) h6(1) h7(1) h8 h9 h10 h11 h12 h13 h14],{'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster 6','Cluster 7','Medoid 1','Medoid 2','Medoid 3','Medoid 4','Medoid 5','Medoid 6','Medoid 7'},'Location','best');
title('Cluster Assignments and Medoids for Summer')
hold off

%K-medoids clustering for Winter
figure;
h1=plot(splitwinter(idx2==1,:)','.','Color',rgb('LightSalmon'),'MarkerSize',10);
hold on
h2=plot(splitwinter(idx2==2,:)','.','Color',rgb('DimGray'),'MarkerSize',10);
hold on
h3=plot(splitwinter(idx2==3,:)','.','Color',rgb('MediumAquamarine'),'MarkerSize',10);
hold on
h4=plot(splitwinter(idx2==4,:)','.','Color',rgb('Orchid'),'MarkerSize',10);
hold on
h5=plot(splitwinter(idx2==5,:)','.','Color',rgb('Pink'),'MarkerSize',10);
hold on 
h6=plot(splitwinter(idx2==6,:)','.','Color',rgb('PaleGreen'),'MarkerSize',10);
hold on
h7=plot(splitwinter(idx2==7,:)','.','Color',rgb('LightBlue'),'MarkerSize',10);
hold on
h8=plot(C2(1,:),'o','Color',rgb('FireBrick'),'MarkerSize',7,'LineWidth',2.0);
hold on
h9=plot(C2(2,:),'o','Color',rgb('Black'),'MarkerSize',7,'LineWidth',1.5);
hold on
h10=plot(C2(3,:),'o','Color',rgb('Teal'),'MarkerSize',7,'LineWidth',1.5);
hold on
h11=plot(C2(4,:),'o','Color',rgb('DarkMagenta'),'MarkerSize',7,'LineWidth',1.5);
hold on 
h12=plot(C2(5,:),'o','Color',rgb('DeepPink'),'MarkerSize',7,'LineWidth',1.5);
hold on
h13=plot(C2(6,:),'o','Color',rgb('LimeGreen'),'MarkerSize',7,'LineWidth',1.5);
hold on
h14=plot(C2(7,:),'o','Color',rgb('Navy'),'MarkerSize',7,'LineWidth',1.5);
legend([h1(1) h2(1) h3(1) h4(1) h5(1) h6(1) h7(1) h8 h9 h10 h11 h12 h13 h14],{'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster 6','Cluster 7','Medoid 1','Medoid 2','Medoid 3','Medoid 4','Medoid 5','Medoid 6','Medoid 7'},'Location','best');
title('Cluster Assignments and Medoids for Winter')
hold off

%(Lines) K-medoids clustering for Winter 
figure;
h1=plot(splitwinter(idx2==1,:)','Color',rgb('LightSalmon'),'LineWidth',1.0);
hold on
h2=plot(splitwinter(idx2==2,:)','Color',rgb('DimGray'),'LineWidth',1.0);
hold on
h3=plot(splitwinter(idx2==3,:)','Color',rgb('MediumAquamarine'),'LineWidth',1.0);
hold on
h4=plot(splitwinter(idx2==4,:)','Color',rgb('Orchid'),'LineWidth',1.0);
hold on
h5=plot(splitwinter(idx2==5,:)','Color',rgb('Pink'),'LineWidth',1.0);
hold on 
h6=plot(splitwinter(idx2==6,:)','Color',rgb('PaleGreen'),'LineWidth',1.0);
hold on
h7=plot(splitwinter(idx2==7,:)','Color',rgb('LightBlue'),'LineWidth',1.0);
hold on
h8=plot(C2(1,:),'Color',rgb('FireBrick'),'MarkerSize',7,'LineWidth',2.0);
hold on
h9=plot(C2(2,:),'Color',rgb('Black'),'MarkerSize',7,'LineWidth',2.0);
hold on
h10=plot(C2(3,:),'Color',rgb('Teal'),'MarkerSize',7,'LineWidth',2.0);
hold on
h11=plot(C2(4,:),'Color',rgb('DarkMagenta'),'MarkerSize',7,'LineWidth',2.0);
hold on 
h12=plot(C2(5,:),'Color',rgb('DeepPink'),'MarkerSize',7,'LineWidth',2.0);
hold on
h13=plot(C2(6,:),'Color',rgb('LimeGreen'),'MarkerSize',7,'LineWidth',2.0);
hold on
h14=plot(C2(7,:),'Color',rgb('Navy'),'MarkerSize',7,'LineWidth',2.0);
legend([h1(1) h2(1) h3(1) h4(1) h5(1) h6(1) h7(1) h8 h9 h10 h11 h12 h13 h14],{'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster 6','Cluster 7','Medoid 1','Medoid 2','Medoid 3','Medoid 4','Medoid 5','Medoid 6','Medoid 7'},'Location','best');
title('Cluster Assignments and Medoids for Winter')
hold off

%K-medoids clustering for Spring
figure;
h1=plot(splitspring(idx3==1,:)','.','Color',rgb('LightSalmon'),'MarkerSize',10);
hold on
h2=plot(splitspring(idx3==2,:)','.','Color',rgb('DimGray'),'MarkerSize',10);
hold on
h3=plot(splitspring(idx3==3,:)','.','Color',rgb('MediumAquamarine'),'MarkerSize',10);
hold on
h4=plot(splitspring(idx3==4,:)','.','Color',rgb('Orchid'),'MarkerSize',10);
hold on
h5=plot(splitspring(idx3==5,:)','.','Color',rgb('Pink'),'MarkerSize',10);
hold on 
h6=plot(splitspring(idx3==6,:)','.','Color',rgb('PaleGreen'),'MarkerSize',10);
hold on
h7=plot(splitspring(idx3==7,:)','.','Color',rgb('LightBlue'),'MarkerSize',10);
hold on
h8=plot(C3(1,:),'o','Color',rgb('FireBrick'),'MarkerSize',7,'LineWidth',2.0);
hold on
h9=plot(C3(2,:),'o','Color',rgb('Black'),'MarkerSize',7,'LineWidth',1.5);
hold on
h10=plot(C3(3,:),'o','Color',rgb('Teal'),'MarkerSize',7,'LineWidth',1.5);
hold on
h11=plot(C3(4,:),'o','Color',rgb('DarkMagenta'),'MarkerSize',7,'LineWidth',1.5);
hold on 
h12=plot(C3(5,:),'o','Color',rgb('DeepPink'),'MarkerSize',7,'LineWidth',1.5);
hold on
h13=plot(C3(6,:),'o','Color',rgb('LimeGreen'),'MarkerSize',7,'LineWidth',1.5);
hold on
h14=plot(C3(7,:),'o','Color',rgb('Navy'),'MarkerSize',7,'LineWidth',1.5);
legend([h1(1) h2(1) h3(1) h4(1) h5(1) h6(1) h7(1) h8 h9 h10 h11 h12 h13 h14],{'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster 6','Cluster 7','Medoid 1','Medoid 2','Medoid 3','Medoid 4','Medoid 5','Medoid 6','Medoid 7'},'Location','best');
title('Cluster Assignments and Medoids for Spring')
hold off

%(Lines) K-medoids clustering for Spring 
figure;
h1=plot(splitspring(idx3==1,:)','Color',rgb('LightSalmon'),'LineWidth',1.0);
hold on
h2=plot(splitspring(idx3==2,:)','Color',rgb('DimGray'),'LineWidth',1.0);
hold on
h3=plot(splitspring(idx3==3,:)','Color',rgb('MediumAquamarine'),'LineWidth',1.0);
hold on
h4=plot(splitspring(idx3==4,:)','Color',rgb('Orchid'),'LineWidth',1.0);
hold on
h5=plot(splitspring(idx3==5,:)','Color',rgb('Pink'),'LineWidth',1.0);
hold on 
h6=plot(splitspring(idx3==6,:)','Color',rgb('PaleGreen'),'LineWidth',1.0);
hold on
h7=plot(splitspring(idx3==7,:)','Color',rgb('LightBlue'),'LineWidth',1.0);
hold on
h8=plot(C3(1,:),'Color',rgb('FireBrick'),'MarkerSize',7,'LineWidth',2.0);
hold on
h9=plot(C3(2,:),'Color',rgb('Black'),'MarkerSize',7,'LineWidth',2.0);
hold on
h10=plot(C3(3,:),'Color',rgb('Teal'),'MarkerSize',7,'LineWidth',2.0);
hold on
h11=plot(C3(4,:),'Color',rgb('DarkMagenta'),'MarkerSize',7,'LineWidth',2.0);
hold on 
h12=plot(C3(5,:),'Color',rgb('DeepPink'),'MarkerSize',7,'LineWidth',2.0);
hold on
h13=plot(C3(6,:),'Color',rgb('LimeGreen'),'MarkerSize',7,'LineWidth',2.0);
hold on
h14=plot(C3(7,:),'Color',rgb('Navy'),'MarkerSize',7,'LineWidth',2.0);
legend([h1(1) h2(1) h3(1) h4(1) h5(1) h6(1) h7(1) h8 h9 h10 h11 h12 h13 h14],{'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster 6','Cluster 7','Medoid 1','Medoid 2','Medoid 3','Medoid 4','Medoid 5','Medoid 6','Medoid 7'},'Location','best');
title('Cluster Assignments and Medoids for Spring')
hold off

%Bldg's year-round demand. Colored by scenario
fig = figure; ax = axes('Parent',fig);
h1 = plot(splitsummer','r'); % MATLAB plots each column as a different line
hold on
h2 = plot(splitspring','m'); 
hold on
h3 = plot(splitwinter','b'); 
hold on 
ax.XTick = 1:24; ax.XTickLabel = hourstr; ax.XLim = [1 24];
title('Year-Round Solar. Colored by scenario') 
legend([h1(1) h2(1) h3(1)], {'Summer' ,'Spring' ,'Winter'})
grid on

%Bldg's Sampled demand. Colored by Scenario
fig = figure; ax = axes('Parent',fig);
h = plot(solarsamplesplit');
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
ax.XTick = 1:24; ax.XTickLabel = hourstr; ax.XLim = [1 24];
title('Sampled Solar. Colored by Scenario')
legend([h(1) h(7) h(13)],{'Summer','Winter','Spring'})

% %Demand Curve First 300 hours Timeseries
% figure;
% plot(elec(1:300,bldg))
% title(['Demand Curve Time-Series. First 300 hours. Building:' , num2str(bldg),])

%Sampled Demand Curve Timeseries
figure;
plot(solarsample)
title('Sampled Solar. Time-series')
axis tight

figure;
plot(solar)
axis tight
title('Original Solar. Time-series')