%% Plotting for Igiugig results
%% Shawdow Values
% shadow_ror_potential = lambda.ineqlin(end-8761:end-1);
% shadow_ror_swept_area = lambda.ineqlin(end);
% pvfix(0.06,10,shadow_ror_swept_area)./1000
%% Adopted technologies and costs
adopted = [var_pv.pv_adopt var_ees.ees_adopt var_el.el_adopt var_h2es.h2es_adopt]
solution.objval/sum(elec)
shadow_value_ror = [];
if exist('lambda')
    for ii = 1:size(river_power_potential,2)
        ii
        idx = find(model.Aineq == river_power_potential(1,ii));
        
        
        idx = find(model.Aineq >0);
        
        idx = min(find(model.bineq == river_power_potential(1,ii)));
%         [idx idx+length(river_power_potential)- 1]
        shadow_rec(:,ii) = lambda.ineqlin(idx:idx+length(river_power_potential)-1);
        shadow_value_ror(ii) = sum(lambda.ineqlin(idx:idx+length(river_power_potential)-1));
    end
end
shadow_value_ror./1000
pvfix(0.06,10,shadow_value_ror)./1000
%% Time resolved renewable potential
close all, clc
figure
t = tiledlayout(2,1)
ylabel(t,'Normalized Renewable Potential','FontSize',16)
nexttile
hold on
plot(time,river_power_potential.*18./38,'LineWidth',2)
xlim([min(time) max(time)])
set(gca,'FontSize',14)
grid on
box on
% l1 = legend('Site 1','Site 2','Location','NorthWest')
% l1.Title.String = 'River Resources'
datetick('x','mmm','KeepTicks','KeepLimits')
hold off

nexttile
hold on
plot(time, fliplr(solar), 'LineWidth',2)
xlim([min(time) max(time)])
grid on
box on
l2 = legend('1-D Tracking','Fixed','Location','South')
l2.Title.String = 'Solar Resources'
datetick('x','mmm','KeepTicks','KeepLimits')
set(gca,'FontSize',14)
hold off
set(gcf,'Position',[10 10 600 500])

%% Renewable duration curve
% close all, clc
figure
t = tiledlayout(2,1)
ylabel(t,'Normalized Renewable Potential','FontSize',16)
xlabel(t,'Time (%)','FontSize',16)
nexttile
hold on
plot([0:100/8759:100],sort(river_power_potential./30,'descend'),'LineWidth',2)
xlim([0 100])
set(gca,'FontSize',14)
grid on
box on
l1 = legend('Site 1','Site 2','Location','NorthEast')
l1.Title.String = 'River Resources'
hold off

nexttile
hold on
plot([0:100/8759:100],sort(fliplr(solar),'descend'),'LineWidth',2)
xlim([0 100])
grid on
box on
l2 = legend('1-D Tracking','Fixed','Location','NorthEast')
l2.Title.String = 'Solar Resources'
set(gca,'FontSize',14)
hold off
set(gcf,'Position',[10 10 600 500])

%% Igiugig Load
% close all, clc
figure
t = tiledlayout(2,1)
ylabel(t,'Electrical Demand (kW)','FontSize',16)
xlabel(t,'Time (%)','FontSize',16)
nexttile
hold on
plot(time,elec,'LineWidth',2)
xlim([min(time) max(time)])
set(gca,'FontSize',14)
grid on
box on
datetick('x','mmm','KeepTicks','KeepLimits')
hold off

nexttile
hold on
plot([0:100/8759:100],sort(elec,'descend'),'LineWidth',2)
xlim([0 100])
grid on
box on
set(gca,'FontSize',14)
hold off
set(gcf,'Position',[10 10 600 500])

%% Generation & Loads
plot_range = 190*24+[0 7*24];
% plot_range = 71*24+[0 7*24];
% plot_range = 95*24+[0 7*24];
plot_range = 95*24+[0 7*24];

close all
figure
t = tiledlayout(2,1)
nexttile
plot_data = [sum(var_ror_integer.elec,2) + sum(var_run_of_river.electricity,2)...
    sum(var_legacy_diesel.electricity,2) ...
    var_pem.elec ...
        sum(var_pv.pv_elec,2)...
    sum(var_ees.ees_dchrg,2)+var_lees.ees_dchrg];

hold on
a1 = area(time,plot_data)
p1 = plot(time,elec,'k','LineWidth',2)
xlim([time(plot_range)])
set(gca,'FontSize',14,...
    'XTick',[time(plot_range(1))-.5:1:time(plot_range(2))+.5])
grid on
box on
datetick('x','mmm/ddd','KeepTicks','KeepLimits')
legend('River','Diesel','PEMFC','Solar','Battery Discharge','Load','Orientation','Horizontal','Location','SouthOutside','NumColumns',6)
% legend([a1([1 3 4 5]) p1],'River','PEMFC','Solar','Battery Discharge','Load','Orientation','Horizontal','Location','South')
ylabel('Generation (kW)','FontSize',16)
% ylim([0 200])
hold off


nexttile
plot_data = [elec ...
    sum(var_ees.ees_chrg,2)+var_lees.ees_chrg ...
    sum(var_el.el_prod,2)];

hold on
area(time,plot_data)
xlim([time(plot_range)])
set(gca,'FontSize',14,...
    'XTick',[time(plot_range(1))-.5:1:time(plot_range(2))+.5])
grid on
box on
datetick('x','mmm/ddd','KeepTicks','KeepLimits')
legend('Load','Battery Charge','H_2 Electrolyzer','Orientation','Horizontal','Location','SouthOutside')
ylabel('Loads (kW)','FontSize',16)
% ylim([0 200])
hold off

set(gcf,'Position',[10 10 800 500])
%%
plot_range = 95*24+[0 7*24];
close all
figure
tiledlayout(1,1)
nexttile
hold on
plot(time,var_ees.ees_soc - min(var_ees.ees_soc),'LineWidth',2)


ylim([0 190])
xlim([time(plot_range)])
set(gca,'FontSize',14,...
    'XTick',[time(plot_range(1))-.5:1:time(plot_range(2))+.5])
datetick('x','mmm/ddd','KeepTicks','KeepLimits')
grid on
box on
set(gcf,'Position',[10 10 800 225])
ylabel('Battery SOC (kWh)','FontSize',16)
hold off
set(gcf,'Position',[10 10 700 250])


%%
close all
figure
tiledlayout(2,1)
nexttile
hold on
plot(time,var_ees.ees_soc - min(var_ees.ees_soc),'LineWidth',2)

ylim([0 190])
xlim([time(plot_range)])
set(gca,'FontSize',14,...
    'XTick',[time(plot_range(1))-.5:1:time(plot_range(2))+.5])
datetick('x','mmm/ddd','KeepTicks','KeepLimits')
grid on
box on
set(gcf,'Position',[10 10 800 225])
ylabel('Battery SOC (kWh)','FontSize',16)
hold off

nexttile
hold on
plot(time,var_h2es.h2es_soc./39,'LineWidth',2)

xlim([time(plot_range)])
set(gca,'FontSize',14,...
    'XTick',[time(plot_range(1))-.5:1:time(plot_range(2))+.5])
datetick('x','mmm/ddd','KeepTicks','KeepLimits')
grid on
box on
ylabel('H_2 Storage  (kg)','FontSize',16)
hold off
set(gcf,'Position',[10 10 700 500])
%%
% close all
figure
tiledlayout(2,1)
nexttile
hold on
plot(time,var_ees.ees_soc - min(var_ees.ees_soc),'LineWidth',2)
xlim([time(1) time(end)])
ylim([0 190])
set(gca,'FontSize',14,...
    'XTick',[time(1)-.5:30:time(end)+.5])
datetick('x','mmm','KeepTicks','KeepLimits')
grid on
box on
set(gcf,'Position',[10 10 800 225])
ylabel('Battery SOC (kWh)','FontSize',16)
hold off

nexttile
hold on
plot(time,var_h2es.h2es_soc./39,'LineWidth',2)
xlim([time(1) time(end)])
set(gca,'FontSize',14,...
    'XTick',[time(1)-.5:30:time(end)+.5])
datetick('x','mmm','KeepTicks','KeepLimits')
grid on
box on
ylabel('H_2 Storage  (kg)','FontSize',16)
hold off
set(gcf,'Position',[10 10 700 500])
%%
% close all
figure
plot(time,sum(shadow_rec,2),'LineWidth',2)
xlim([time(1) time(end)])
set(gca,'FontSize',14,...
    'XTick',[time(1)-.5:30:time(end)+.5])
datetick('x','mmm','KeepTicks','KeepLimits')
grid on
box on
set(gcf,'Position',[10 10 800 225])
ylabel('Shadow Price ($)','FontSize',16)
%%
% close all
figure
hold on
plot([0:100/8759:100],sort(sum(var_legacy_diesel.electricity,2),'descend'),'LineWidth',2)
xlim([0 100])
grid on
box on
set(gca,'FontSize',14)
ylabel({'Diesel Load','Duration (kW)'},'FontSize',16)
xlabel('Time (%)','FontSize',16)
hold off
set(gcf,'Position',[10 10 600 250])