clc, clear all, close all
dt0 = load("diesel_baseline.mat");
dt1 = load("diesel_8000.mat");
dt2 = load("diesel_4000.mat");
dt3 = load("diesel_2000.mat");
dt4 = load("nodiesel_8000.mat");
dt5 = load("nodiesel_4000.mat");
dt6 = load("nodiesel_2000.mat");
%%

co2_factor = (3.6) ... %%% Convert from kWh to MJ
        .*(1/135.6) ... %%% Convert from MJ to Gallons diesel fuel
        .*(10.19); %%%Convert from gallons to kg CO2


lcoe = [dt0.solution.objval/sum(dt0.elec)
    dt1.solution.objval/sum(dt0.elec)
    dt2.solution.objval/sum(dt0.elec)
    dt3.solution.objval/sum(dt0.elec)
    dt4.solution.objval/sum(dt0.elec)
    dt5.solution.objval/sum(dt0.elec)
    dt6.solution.objval/sum(dt0.elec)]

co2_emissions = [ sum(dt0.var_legacy_diesel_binary.electricity)
    sum(dt1.var_legacy_diesel_binary.electricity)
    sum(dt2.var_legacy_diesel_binary.electricity)
    sum(dt3.var_legacy_diesel_binary.electricity)
    sum(dt4.var_legacy_diesel_binary.electricity)
    sum(dt5.var_legacy_diesel_binary.electricity)
    sum(dt6.var_legacy_diesel_binary.electricity)].*co2_factor; %kg

co2_emissions_intensity = co2_emissions./sum(dt0.elec) %kg/kWh

adoped_tech = [dt1.var_ror_integer.units dt1.var_pv.pv_adopt dt1.var_ees.ees_adopt dt1.var_pem.cap dt1.var_el_binary.el_adopt dt1.var_h2es.h2es_adopt
    dt2.var_ror_integer.units dt2.var_pv.pv_adopt dt2.var_ees.ees_adopt dt2.var_pem.cap dt2.var_el_binary.el_adopt dt2.var_h2es.h2es_adopt
    dt3.var_ror_integer.units dt3.var_pv.pv_adopt dt3.var_ees.ees_adopt dt3.var_pem.cap dt3.var_el_binary.el_adopt dt3.var_h2es.h2es_adopt
    dt4.var_ror_integer.units dt4.var_pv.pv_adopt dt4.var_ees.ees_adopt dt4.var_pem.cap dt4.var_el_binary.el_adopt dt4.var_h2es.h2es_adopt
    dt5.var_ror_integer.units dt5.var_pv.pv_adopt dt5.var_ees.ees_adopt dt5.var_pem.cap dt5.var_el_binary.el_adopt dt5.var_h2es.h2es_adopt
    dt6.var_ror_integer.units dt6.var_pv.pv_adopt dt6.var_ees.ees_adopt dt6.var_pem.cap dt6.var_el_binary.el_adopt dt6.var_h2es.h2es_adopt]


adoped_tech(:,end) = adoped_tech(:,end)./38.89;

%% with Diesel Operation (no diesl ops starts in line 404)
close all
plot_data = [];
total_data = [sum(dt1.var_ror_integer.elec,2) ...
    sum(dt1.var_pv.pv_elec,2)...
    dt1.var_legacy_diesel_binary.electricity...
    dt1.var_pem.elec ...
    sum(dt1.var_ees.ees_dchrg + dt1.var_lees.ees_dchrg,2)
    ]./1000;
for ii = 1:length(dt1.endpts)
    plot_data1(ii,:) = [sum(dt1.elec(dt1.stpts(ii):dt1.endpts(ii))) sum(total_data(dt1.stpts(ii):dt1.endpts(ii),:))];
end


total_data = [sum(dt2.var_ror_integer.elec,2) ...
    sum(dt2.var_pv.pv_elec,2)...
    dt2.var_legacy_diesel_binary.electricity...
    dt2.var_pem.elec ...
    sum(dt2.var_ees.ees_dchrg + dt2.var_lees.ees_dchrg,2)
    ]./1000;
for ii = 1:length(dt1.endpts)
    plot_data2(ii,:) = [sum(dt2.elec(dt2.stpts(ii):dt2.endpts(ii))) sum(total_data(dt1.stpts(ii):dt1.endpts(ii),:))];
end


total_data = [sum(dt3.var_ror_integer.elec,2) ...
    sum(dt3.var_pv.pv_elec,2)...
    dt3.var_legacy_diesel_binary.electricity...
    dt3.var_pem.elec ...
    sum(dt3.var_ees.ees_dchrg + dt3.var_lees.ees_dchrg,2)
    ]./1000;
for ii = 1:length(dt1.endpts)
    plot_data3(ii,:) = [sum(dt3.elec(dt3.stpts(ii):dt3.endpts(ii))) sum(total_data(dt1.stpts(ii):dt1.endpts(ii),:))];
end



figure
hold on

b1 = bar([1:12]-.14,plot_data1(:,2:4),'stacked','BarWidth',.25)
b2 = bar([1:12]+.14,plot_data2(:,2:4),'stacked','BarWidth',.25)
b2(1).FaceColor = b1(1).FaceColor;
b2(2).FaceColor = b1(2).FaceColor;
b2(3).FaceColor = b1(3).FaceColor;

fc_alpha = 0.6
b2(1).FaceAlpha = fc_alpha;
b2(2).FaceAlpha = fc_alpha;
b2(3).FaceAlpha = fc_alpha;


set(gca,'FontSize',14,...
    'XTick',[1:12],...
    'XTickLabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sept','Oct','Nov','Dec'})
ylabel('Generation (MWh)','FontSize',16)
legend(b2,'Hydrokinetic','Solar PV','Diesel','Orientation','horizontal','Location','south')
box on
grid on

xlim([0.5 12.5])
set(gcf,'Position',[10 10 900 300])
%%
close all

107
month_num = 1

month_num = 11
x_days = [15+30*(month_num-1)];
plot_data = [];
plot_data = [sum(dt1.var_ror_integer.elec,2) ...
    sum(dt1.var_pv.pv_elec,2)...
    dt1.var_legacy_diesel_binary.electricity...
    dt1.var_pem.elec ...
    sum(dt1.var_ees.ees_dchrg + dt1.var_lees.ees_dchrg,2)
    ];
figure
tiledlayout(1,2)
% tiledlayout(2,1)
nexttile
hold on

a1 = area(dt1.time,plot_data)
plot(dt1.time,dt1.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt4.time(1))+.5:1:floor(dt4.time(end))+.5])
xlim([dt4.time((x_days-1)*24+1)  dt4.time((x_days+6)*24)])
if dt1.ldiesel_binary_on
% legend(a1([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
legend(a1([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 100])
hold off


plot_data = [sum(dt2.var_ror_integer.elec,2) ...
    sum(dt2.var_pv.pv_elec,2)...
    dt2.var_legacy_diesel_binary.electricity...
    dt2.var_pem.elec ...
    sum(dt2.var_ees.ees_dchrg + dt2.var_lees.ees_dchrg,2)
    ];
nexttile
hold on

a2 = area(dt1.time,plot_data)
plot(dt1.time,dt1.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt4.time(1))+.5:1:floor(dt4.time(end))+.5])
xlim([dt4.time((x_days-1)*24+1)  dt4.time((x_days+6)*24)])
if dt1.ldiesel_binary_on
% legend(a2([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
legend(a2([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 100])
hold off


set(gcf,'Position',[10 10 450 600])
set(gcf,'Position',[10 10 1075 300])

%%
%%
close all

107
month_num = 1

% month_num = 11
x_days = [15+30*(month_num-1)];
plot_data = [];
plot_data = [sum(dt1.var_ror_integer.elec,2) ...
    sum(dt1.var_pv.pv_elec,2)...
    dt1.var_legacy_diesel_binary.electricity...
    dt1.var_pem.elec ...
    sum(dt1.var_ees.ees_dchrg + dt1.var_lees.ees_dchrg,2)
    ];
figure
tiledlayout(3,2)
% tiledlayout(2,1)
nexttile
hold on

a1 = area(dt1.time,plot_data)
plot(dt1.time,dt1.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt4.time(1))+.5:1:floor(dt4.time(end))+.5])
xlim([dt4.time((x_days-1)*24+1)  dt4.time((x_days+6)*24)])
if dt1.ldiesel_binary_on
% legend(a1([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
legend(a1([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 100])
hold off


plot_data = [sum(dt2.var_ror_integer.elec,2) ...
    sum(dt2.var_pv.pv_elec,2)...
    dt2.var_legacy_diesel_binary.electricity...
    dt2.var_pem.elec ...
    sum(dt2.var_ees.ees_dchrg + dt2.var_lees.ees_dchrg,2)
    ];
nexttile
hold on

a2 = area(dt1.time,plot_data)
plot(dt1.time,dt1.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt4.time(1))+.5:1:floor(dt4.time(end))+.5])
xlim([dt4.time((x_days-1)*24+1)  dt4.time((x_days+6)*24)])
if dt1.ldiesel_binary_on
% legend(a2([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
legend(a2([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 100])
hold off


%%%%%%

plot_data = [sum(dt1.var_ror_integer.elec,2) ...
    sum(dt1.var_pv.pv_elec,2)...
    dt1.var_legacy_diesel_binary.electricity...
    dt1.var_pem.elec ...
    sum(dt1.var_ees.ees_dchrg + dt1.var_lees.ees_dchrg,2)
    ];
month_num = 5

x_days = [15+30*(month_num-1)];
nexttile
hold on

a1 = area(dt1.time,plot_data)
plot(dt1.time,dt1.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt4.time(1))+.5:1:floor(dt4.time(end))+.5])
xlim([dt4.time((x_days-1)*24+1)  dt4.time((x_days+6)*24)])
if dt1.ldiesel_binary_on
% legend(a1([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
legend(a1([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 100])
hold off


plot_data = [sum(dt2.var_ror_integer.elec,2) ...
    sum(dt2.var_pv.pv_elec,2)...
    dt2.var_legacy_diesel_binary.electricity...
    dt2.var_pem.elec ...
    sum(dt2.var_ees.ees_dchrg + dt2.var_lees.ees_dchrg,2)
    ];
nexttile
hold on

a2 = area(dt1.time,plot_data)
plot(dt1.time,dt1.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt4.time(1))+.5:1:floor(dt4.time(end))+.5])
xlim([dt4.time((x_days-1)*24+1)  dt4.time((x_days+6)*24)])
if dt1.ldiesel_binary_on
% legend(a2([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
legend(a2([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 100])
hold off

%%%%%%

plot_data = [sum(dt1.var_ror_integer.elec,2) ...
    sum(dt1.var_pv.pv_elec,2)...
    dt1.var_legacy_diesel_binary.electricity...
    dt1.var_pem.elec ...
    sum(dt1.var_ees.ees_dchrg + dt1.var_lees.ees_dchrg,2)
    ];
month_num = 11

x_days = [15+30*(month_num-1)];
nexttile
hold on

a1 = area(dt1.time,plot_data)
plot(dt1.time,dt1.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt4.time(1))+.5:1:floor(dt4.time(end))+.5])
xlim([dt4.time((x_days-1)*24+1)  dt4.time((x_days+6)*24)])
if dt1.ldiesel_binary_on
% legend(a1([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
legend(a1([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 100])
hold off


plot_data = [sum(dt2.var_ror_integer.elec,2) ...
    sum(dt2.var_pv.pv_elec,2)...
    dt2.var_legacy_diesel_binary.electricity...
    dt2.var_pem.elec ...
    sum(dt2.var_ees.ees_dchrg + dt2.var_lees.ees_dchrg,2)
    ];
nexttile
hold on

a2 = area(dt1.time,plot_data)
plot(dt1.time,dt1.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt4.time(1))+.5:1:floor(dt4.time(end))+.5])
xlim([dt4.time((x_days-1)*24+1)  dt4.time((x_days+6)*24)])
if dt1.ldiesel_binary_on
% legend(a2([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
legend(a2([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 100])
hold off


set(gcf,'Position',[10 10 450 600])
set(gcf,'Position',[10 10 1075 600])

%%
close all 
figure

plot_data = [sum(dt2.var_ror_integer.elec,2) ...
    sum(dt2.var_pv.pv_elec,2)...
    dt2.var_legacy_diesel_binary.electricity...
    dt2.var_pem.elec ...
    sum(dt2.var_ees.ees_dchrg + dt2.var_lees.ees_dchrg,2)
    ];

hold on

a2 = area(dt1.time,plot_data)
p1 = plot(dt1.time,dt1.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt4.time(1))+.5:1:floor(dt4.time(end))+.5])
xlim([dt4.time((x_days-1)*24+1)  dt4.time((x_days+6)*24)])
if dt1.ldiesel_binary_on
legend([a2([1:3 5]) p1],'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Load','Orientation','horizontal','Location','southoutside')
else
legend(a2([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 100])
hold off


set(gcf,'Position',[10 10 1075 600])

%%
%% No Diesel Operation 
close all
total_gen = [];
plot_data1 = [];
total_data = [sum(dt4.var_ror_integer.elec,2) ...
    sum(dt4.var_pv.pv_elec,2)...
    dt4.var_legacy_diesel_binary.electricity...
    dt4.var_pem.elec ...
    sum(dt4.var_ees.ees_dchrg + dt4.var_lees.ees_dchrg,2)
    ]./1000;
for ii = 1:length(dt4.endpts)
    plot_data1(ii,:) = [sum(dt4.elec(dt4.stpts(ii):dt4.endpts(ii))) sum(total_data(dt4.stpts(ii):dt4.endpts(ii),:))];
end

total_gen(1,:) = sum(plot_data1);


total_data = [sum(dt5.var_ror_integer.elec,2) ...
    sum(dt5.var_pv.pv_elec,2)...
    dt5.var_legacy_diesel_binary.electricity...
    dt5.var_pem.elec ...
    sum(dt5.var_ees.ees_dchrg + dt5.var_lees.ees_dchrg,2)
    ]./1000;
for ii = 1:length(dt1.endpts)
    plot_data2(ii,:) = [sum(dt5.elec(dt5.stpts(ii):dt5.endpts(ii))) sum(total_data(dt1.stpts(ii):dt1.endpts(ii),:))];
end
total_gen(2,:) = sum(plot_data2);


total_data = [sum(dt6.var_ror_integer.elec,2) ...
    sum(dt6.var_pv.pv_elec,2)...
    dt6.var_legacy_diesel_binary.electricity...
    dt6.var_pem.elec ...
    sum(dt6.var_ees.ees_dchrg + dt6.var_lees.ees_dchrg,2)
    ]./1000;
plot_data3 = [];
for ii = 1:length(dt1.endpts)
    plot_data3(ii,:) = [sum(dt6.elec(dt6.stpts(ii):dt6.endpts(ii))) sum(total_data(dt1.stpts(ii):dt1.endpts(ii),:))];
end
total_gen(3,:) = sum(plot_data3);



figure
tiledlayout(4,1)
nexttile
hold on

b1 = bar([1:12]-.14,plot_data1(:,2:4),'stacked','BarWidth',.25)
% b2 = bar([1:12]+.14,plot_data2(:,2:4),'stacked','BarWidth',.25)
b3 = bar([1:12]+.14,plot_data3(:,2:4),'stacked','BarWidth',.25)
% b2(1).FaceColor = b1(1).FaceColor;
% b2(2).FaceColor = b1(2).FaceColor;
% b2(3).FaceColor = b1(3).FaceColor;

b3(1).FaceColor = b1(1).FaceColor;
b3(2).FaceColor = b1(2).FaceColor;
b3(3).FaceColor = b1(3).FaceColor;

fc_alpha = 0.6
b3(1).FaceAlpha = fc_alpha;
b3(2).FaceAlpha = fc_alpha;
b3(3).FaceAlpha = fc_alpha;


set(gca,'FontSize',14,...
    'XTick',[1:12],...
    'XTickLabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sept','Oct','Nov','Dec'})
ylabel({'Primary Generation','(MWh)'},'FontSize',16)
legend(b1,'Hydrokinetic','Solar PV','Orientation','horizontal','Location','southeast')
box on
grid on
ylim([0 60])
xlim([0.5 12.5])
hold off




plot_data = [];
plot_data1 = [];
total_data = [];
total_data = [dt4.elec ...
    sum(dt4.var_ees.ees_chrg,2)+ sum(dt4.var_lees.ees_chrg,2)  ...
    sum(dt4.el_binary_eff.*dt4.var_el_binary.el_prod,2)    ]./1000;
for ii = 1:length(dt4.endpts)
    plot_data1(ii,:) = [sum(total_data(dt4.stpts(ii):dt4.endpts(ii),:))];
end

total_data = [];
plot_data3 = [];
total_data = [dt6.elec ...
    sum(dt6.var_ees.ees_chrg,2)+ sum(dt6.var_lees.ees_chrg,2)  ...
    sum(dt6.el_binary_eff.*dt6.var_el_binary.el_prod,2)    ]./1000;
for ii = 1:length(dt4.endpts)
    plot_data3(ii,:) = [sum(total_data(dt4.stpts(ii):dt4.endpts(ii),:))];
end

nexttile
hold on

b1 = bar([1:12]-.14,plot_data1,'stacked','BarWidth',.25)
% b2 = bar([1:12]+.14,plot_data2(:,2:4),'stacked','BarWidth',.25)
b3 = bar([1:12]+.14,plot_data3,'stacked','BarWidth',.25)
% b2(1).FaceColor = b1(1).FaceColor;
% b2(2).FaceColor = b1(2).FaceColor;
% b2(3).FaceColor = b1(3).FaceColor;

b3(1).FaceColor = b1(1).FaceColor;
b3(2).FaceColor = b1(2).FaceColor;
b3(3).FaceColor = b1(3).FaceColor;

fc_alpha = 0.6
b3(1).FaceAlpha = fc_alpha;
b3(2).FaceAlpha = fc_alpha;
b3(3).FaceAlpha = fc_alpha;


set(gca,'FontSize',14,...
    'XTick',[1:12],...
    'XTickLabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sept','Oct','Nov','Dec'})
ylabel('Loads (MWh)','FontSize',16)
legend(b1,'Igiugig Community','Battery Charging','Electrolyzer','Orientation','horizontal','Location','southeast')
box on
grid on
ylim([0 60])

xlim([0.5 12.5])
hold off



plot_data = [];
plot_data1 = [];
total_data = [];
total_data = [sum(dt4.var_ees.ees_chrg,2)+ sum(dt4.var_lees.ees_chrg,2)  ...
    sum(dt4.var_pem.elec,2)]./1000;
for ii = 1:length(dt4.endpts)
    plot_data1(ii,:) = [sum(total_data(dt4.stpts(ii):dt4.endpts(ii),:))];
end

total_data = [];
plot_data3 = [];
total_data = [sum(dt6.var_ees.ees_chrg,2)+ sum(dt6.var_lees.ees_chrg,2)  ...
    sum(dt6.var_pem.elec,2)]./1000;
for ii = 1:length(dt4.endpts)
    plot_data3(ii,:) = [sum(total_data(dt4.stpts(ii):dt4.endpts(ii),:))];
end
nexttile
hold on

b1 = bar([1:12]-.14,plot_data1,'stacked','BarWidth',.25)
% b2 = bar([1:12]+.14,plot_data2(:,2:4),'stacked','BarWidth',.25)
b3 = bar([1:12]+.14,plot_data3,'stacked','BarWidth',.25)
% b2(1).FaceColor = b1(1).FaceColor;
% b2(2).FaceColor = b1(2).FaceColor;
% b2(3).FaceColor = b1(3).FaceColor;

b3(1).FaceColor = b1(1).FaceColor;
b3(2).FaceColor = b1(2).FaceColor;
% b3(3).FaceColor = b1(3).FaceColor;

fc_alpha = 0.6
b3(1).FaceAlpha = fc_alpha;
b3(2).FaceAlpha = fc_alpha;
% b3(3).FaceAlpha = fc_alpha;


set(gca,'FontSize',14,...
    'XTick',[1:12],...
    'XTickLabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sept','Oct','Nov','Dec'})
ylabel({'Storage Discharge','(MWh)'},'FontSize',16)
legend(b1,'Battery Discharge','PEMFC','Orientation','horizontal','Location','northeast')
box on
grid on

xlim([0.5 12.5])
hold off



% close all
nexttile
hold on
plot(dt6.time,dt6.var_h2es.h2es_soc./dt6.var_h2es.h2es_adopt.*100,'LineWidth',2)
plot(dt4.time,dt4.var_h2es.h2es_soc./dt4.var_h2es.h2es_adopt.*100,'LineWidth',2)
box on
grid on
set(gca,'FontSize',14,...
    'XTick',dt1.time(round((dt1.stpts+dt1.endpts)./2)),...
    'XTickLabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sept','Oct','Nov','Dec'},...
    'YTick',[0:25:100])
xlim([dt1.time(1) dt1.time(end)])
ylabel({'H_2 Storage','SOC (%)'})

l1 = legend('$8000/kW','$4000 & $2000/kW','Location','North')

l1.Title.String = 'Hydrokinetic Cost'

set(gcf,'Position',[10 10 800 900])