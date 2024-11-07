%%
% close all

107
month_num = 2

dt4_potential = dt4.var_ror_integer.units.*dt4.river_power_potential.*18;
dt6_potential = dt6.var_ror_integer.units.*dt4.river_power_potential.*18;


dt4_slr_potential = dt4.var_pv.pv_adopt.*dt4.solar;
dt6_slr_potential = dt6.var_pv.pv_adopt.*dt6.solar;
% dt6_potential = dt6.var_ror_integer.units.*dt4.river_power_potential.*18;

% month_num = 11
x_days = [15+30*(month_num-1)];
plot_data = [];
plot_data = [sum(dt4.var_ror_integer.elec,2) ...
    sum(dt4.var_pv.pv_elec,2)...
    dt4.var_legacy_diesel_binary.electricity...
    dt4.var_pem.elec ...
    sum(dt4.var_ees.ees_dchrg + dt4.var_lees.ees_dchrg,2) ...
    sum(dt4_potential,2) - sum(dt4.var_ror_integer.elec,2) ...
    sum(dt4_slr_potential,2) - sum(dt4.var_pv.pv_elec,2)
    ];
figure
tiledlayout(3,2)
% tiledlayout(2,1)
nexttile
hold on

a1 = area(dt4.time,plot_data)
plot(dt4.time,dt4.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt4.time(1))+.5:1:floor(dt4.time(end))+.5])
xlim([dt4.time((x_days-1)*24+1)  dt4.time((x_days+6)*24)])
if dt4.ldiesel_binary_on
% legend(a1([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
% legend(a1([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 210])
hold off


plot_data = [sum(dt6.var_ror_integer.elec,2) ...
    sum(dt6.var_pv.pv_elec,2)...
    dt6.var_legacy_diesel_binary.electricity...
    dt6.var_pem.elec ...
    sum(dt6.var_ees.ees_dchrg + dt6.var_lees.ees_dchrg,2)...
    sum(dt6_potential,2) - sum(dt6.var_ror_integer.elec,2)
    ];
nexttile
hold on

a2 = area(dt4.time,plot_data)
plot(dt4.time,dt4.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt4.time(1))+.5:1:floor(dt4.time(end))+.5])
xlim([dt4.time((x_days-1)*24+1)  dt4.time((x_days+6)*24)])
if dt4.ldiesel_binary_on
% legend(a2([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
% legend(a2([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 210])

hold off


%%%%%%

plot_data = [sum(dt4.var_ror_integer.elec,2) ...
    sum(dt4.var_pv.pv_elec,2)...
    dt4.var_legacy_diesel_binary.electricity...
    dt4.var_pem.elec ...
    sum(dt4.var_ees.ees_dchrg + dt4.var_lees.ees_dchrg,2) ...
    sum(dt4_potential,2) - sum(dt4.var_ror_integer.elec,2) ...
    sum(dt4_slr_potential,2) - sum(dt4.var_pv.pv_elec,2)
    ];
month_num = 6

x_days = [15+30*(month_num-1)];
nexttile
hold on

a1 = area(dt4.time,plot_data)
plot(dt4.time,dt4.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt4.time(1))+.5:1:floor(dt4.time(end))+.5])
xlim([dt4.time((x_days-1)*24+1)  dt4.time((x_days+6)*24)])
if dt4.ldiesel_binary_on
% legend(a1([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
% legend(a1([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 250])

hold off


plot_data = [sum(dt6.var_ror_integer.elec,2) ...
    sum(dt6.var_pv.pv_elec,2)...
    dt6.var_legacy_diesel_binary.electricity...
    dt6.var_pem.elec ...
    sum(dt6.var_ees.ees_dchrg + dt6.var_lees.ees_dchrg,2)...
    sum(dt6_potential,2) - sum(dt6.var_ror_integer.elec,2) ...
    sum(dt6_slr_potential,2) - sum(dt6.var_pv.pv_elec,2)
    ];
nexttile
hold on

a2 = area(dt4.time,plot_data)
plot(dt4.time,dt4.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt4.time(1))+.5:1:floor(dt4.time(end))+.5])
xlim([dt4.time((x_days-1)*24+1)  dt4.time((x_days+6)*24)])
if dt4.ldiesel_binary_on
% legend(a2([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
% legend(a2([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 250])

hold off

%%%%%%

plot_data = [sum(dt4.var_ror_integer.elec,2) ...
    sum(dt4.var_pv.pv_elec,2)...
    dt4.var_legacy_diesel_binary.electricity...
    dt4.var_pem.elec ...
    sum(dt4.var_ees.ees_dchrg + dt4.var_lees.ees_dchrg,2) ...
    sum(dt4_potential,2) - sum(dt4.var_ror_integer.elec,2) ...
    sum(dt4_slr_potential,2) - sum(dt4.var_pv.pv_elec,2)
    ];
month_num = 10

x_days = [15+30*(month_num-1)];
nexttile
hold on

a1 = area(dt4.time,plot_data)
plot(dt4.time,dt4.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt4.time(1))+.5:1:floor(dt4.time(end))+.5])
xlim([dt4.time((x_days-1)*24+1)  dt4.time((x_days+6)*24)])
if dt4.ldiesel_binary_on
% legend(a1([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
% legend(a1([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 275])

hold off


plot_data = [sum(dt6.var_ror_integer.elec,2) ...
    sum(dt6.var_pv.pv_elec,2)...
    dt6.var_legacy_diesel_binary.electricity...
    dt6.var_pem.elec ...
    sum(dt6.var_ees.ees_dchrg + dt6.var_lees.ees_dchrg,2)...
    sum(dt6_potential,2) - sum(dt6.var_ror_integer.elec,2)...
    sum(dt6_slr_potential,2) - sum(dt6.var_pv.pv_elec,2)
    ];
nexttile
hold on

a2 = area(dt4.time,plot_data)
p1 = plot(dt4.time,dt4.elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(dt4.time(1))+.5:1:floor(dt4.time(end))+.5])
xlim([dt4.time((x_days-1)*24+1)  dt4.time((x_days+6)*24)])
if dt4.ldiesel_binary_on
% legend(a2([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south','NumColumns',2)
else
% legend(a2([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
ylim([0 250])
legend([a2([1 2 4 5 6 7]) p1],'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Curtailed HKT','Curtailed PV','Igiugig Community Load','Orientation','horizontal','Location','southoutside','NumColumns',4)
hold off


set(gcf,'Position',[10 10 450 600])
set(gcf,'Position',[10 10 1075 750])