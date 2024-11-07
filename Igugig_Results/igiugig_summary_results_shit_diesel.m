%%
close all

107
month_num = 1

dt1_potential = dt1.var_ror_integer.units.*dt1.river_power_potential.*18;
dt2_potential = dt2.var_ror_integer.units.*dt1.river_power_potential.*18;


dt1_slr_potential = dt1.var_pv.pv_adopt.*dt1.solar;
dt2_slr_potential = dt2.var_pv.pv_adopt.*dt2.solar;
% dt2_potential = dt2.var_ror_integer.units.*dt1.river_power_potential.*18;

% month_num = 11
x_days = [15+30*(month_num-1)];
plot_data = [];
plot_data = [sum(dt1.var_ror_integer.elec,2) ...
    sum(dt1.var_pv.pv_elec,2)...
    dt1.var_legacy_diesel_binary.electricity...
    dt1.var_pem.elec ...
    sum(dt1.var_ees.ees_dchrg + dt1.var_lees.ees_dchrg,2) ...
    sum(dt1_potential,2) - sum(dt1.var_ror_integer.elec,2) ...
    sum(dt1_slr_potential,2) - sum(dt1.var_pv.pv_elec,2)
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
'XTick',[floor(dt1.time(1))+.5:1:floor(dt1.time(end))+.5])
xlim([dt1.time((x_days-1)*24+1)  dt1.time((x_days+6)*24)])
if dt1.ldiesel_binary_on
% legend(a1([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
% legend(a1([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 100])
hold off


plot_data = [sum(dt2.var_ror_integer.elec,2) ...
    sum(dt2.var_pv.pv_elec,2)...
    dt2.var_legacy_diesel_binary.electricity...
    dt2.var_pem.elec ...
    sum(dt2.var_ees.ees_dchrg + dt2.var_lees.ees_dchrg,2)...
    sum(dt2_potential,2) - sum(dt2.var_ror_integer.elec,2)
    ];
nexttile
hold on

a2 = area(dt1.time,plot_data)
plot(dt1.time,dt1.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt1.time(1))+.5:1:floor(dt1.time(end))+.5])
xlim([dt1.time((x_days-1)*24+1)  dt1.time((x_days+6)*24)])
if dt1.ldiesel_binary_on
% legend(a2([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
% legend(a2([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
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
    sum(dt1.var_ees.ees_dchrg + dt1.var_lees.ees_dchrg,2) ...
    sum(dt1_potential,2) - sum(dt1.var_ror_integer.elec,2) ...
    sum(dt1_slr_potential,2) - sum(dt1.var_pv.pv_elec,2)
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
'XTick',[floor(dt1.time(1))+.5:1:floor(dt1.time(end))+.5])
xlim([dt1.time((x_days-1)*24+1)  dt1.time((x_days+6)*24)])
if dt1.ldiesel_binary_on
% legend(a1([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
% legend(a1([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 110])

hold off


plot_data = [sum(dt2.var_ror_integer.elec,2) ...
    sum(dt2.var_pv.pv_elec,2)...
    dt2.var_legacy_diesel_binary.electricity...
    dt2.var_pem.elec ...
    sum(dt2.var_ees.ees_dchrg + dt2.var_lees.ees_dchrg,2)...
    sum(dt2_potential,2) - sum(dt2.var_ror_integer.elec,2) ...
    sum(dt2_slr_potential,2) - sum(dt2.var_pv.pv_elec,2)
    ];
nexttile
hold on

a2 = area(dt1.time,plot_data)
plot(dt1.time,dt1.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt1.time(1))+.5:1:floor(dt1.time(end))+.5])
xlim([dt1.time((x_days-1)*24+1)  dt1.time((x_days+6)*24)])
if dt1.ldiesel_binary_on
% legend(a2([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
% legend(a2([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 110])

hold off

%%%%%%

plot_data = [sum(dt1.var_ror_integer.elec,2) ...
    sum(dt1.var_pv.pv_elec,2)...
    dt1.var_legacy_diesel_binary.electricity...
    dt1.var_pem.elec ...
    sum(dt1.var_ees.ees_dchrg + dt1.var_lees.ees_dchrg,2) ...
    sum(dt1_potential,2) - sum(dt1.var_ror_integer.elec,2) ...
    sum(dt1_slr_potential,2) - sum(dt1.var_pv.pv_elec,2)
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
'XTick',[floor(dt1.time(1))+.5:1:floor(dt1.time(end))+.5])
xlim([dt1.time((x_days-1)*24+1)  dt1.time((x_days+6)*24)])
if dt1.ldiesel_binary_on
% legend(a1([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
% legend(a1([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 110])

hold off


plot_data = [sum(dt2.var_ror_integer.elec,2) ...
    sum(dt2.var_pv.pv_elec,2)...
    dt2.var_legacy_diesel_binary.electricity...
    dt2.var_pem.elec ...
    sum(dt2.var_ees.ees_dchrg + dt2.var_lees.ees_dchrg,2)...
    sum(dt2_potential,2) - sum(dt2.var_ror_integer.elec,2)...
    sum(dt2_slr_potential,2) - sum(dt2.var_pv.pv_elec,2)
    ];
nexttile
hold on

a2 = area(dt1.time,plot_data)
p1 = plot(dt1.time,dt1.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt1.time(1))+.5:1:floor(dt1.time(end))+.5])
xlim([dt1.time((x_days-1)*24+1)  dt1.time((x_days+6)*24)])
if dt1.ldiesel_binary_on
% legend(a2([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
% legend(a2([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 110])
legend([a2([1 2 3 4 5 6 7]) p1],'Hydrokinetic','Solar PV','Diesel','PEMFC','Battery Discharge','Curtailed HKT','Curtailed PV','Igiugig Community Load','Orientation','horizontal','Location','southoutside','NumColumns',4)
hold off


set(gcf,'Position',[10 10 450 600])
set(gcf,'Position',[10 10 1075 750])