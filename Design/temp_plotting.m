clear all, close all

load baseline_retest_2B_v2_5_w_pump_CL_3
%%
sol_output.lcoe = fval/sum(sum(elec))

sol_output.pv_capacity = sum(var_pv.pv_adopt);

sol_output.ees_capacity = sum(var_ees.ees_adopt) +  sum(var_rees.rees_adopt);

sol_output.utility_costs = sum(elec.*import_price(:,3)) - (sum(var_util.import.*import_price(:,3))-sum((var_pv.pv_nem+var_rees.rees_dchrg_nem).*export_price(:,3)))
sol_output.pv_costs = var_pv.pv_adopt*pv_mthly_debt*M

sol_output.LCOE_original = sum(elec.*import_price(:,3))./sum(elec)
sol_output.LCOE_after = (sum(var_util.import.*import_price(:,3))-sum((var_pv.pv_nem+var_rees.rees_dchrg_nem).*export_price(:,3)) + var_pv.pv_adopt.*pv_cap_mod'*pv_mthly_debt*M)./sum(elec)


(1 - sol_output.LCOE_after./sol_output.LCOE_original).*100

(1 - sol_output.lcoe./(sum(sum(elec.*import_price(:,3)))./sum(sum(elec)))).*100

%% plotting dispatch
close all,clc
% idx = [1:50]
idx = 2;
day_idx = 6;
% day_idx = 244;
% (day_idx-1)*24+1
figure
hold on 
area(time,[var_util.import(:,idx)   var_pv.pv_elec(:,idx) var_ees.ees_dchrg(:,idx)+var_rees.rees_dchrg(:,idx)+var_lrees.rees_dchrg(:,idx)])
plot(time,elec(:,idx),'k','LineWidth',1)


set(gca,'XTick',[round(min(time))-0.5:1:round(max(time)+0.5)],'FontSize',14)
grid on
box on
ylabel('Electrcity (kW)','FontSize',16)
xlim([time((day_idx-1)*24+1) time((day_idx-1)*24+7*24)])
datetick('x','ddd','KeepTicks','KeepLimits')
legend('Utility','PV','Battery Discharge','Building Loads','Orientation','Horizontal','Location','north')
set(gcf,'Position',[10 10 900 350])
hold off

figure
hold on
area(time,[var_ees.ees_chrg(:,idx) + var_lees.ees_chrg(:,idx) var_rees.rees_chrg(:,idx)+var_lrees.rees_chrg(:,idx) var_pv.pv_nem(:,idx)+var_rees.rees_dchrg_nem(:,idx)])

set(gca,'XTick',[round(min(time))-0.5:1:round(max(time)+0.5)],'FontSize',14)
grid on
box on
ylabel('Electrcity (kW)','FontSize',16)
xlim([time((day_idx-1)*24+1) time((day_idx-1)*24+7*24)])
datetick('x','ddd','KeepTicks','KeepLimits')
legend('Battery Charging from Grid','Battery Charging from PV','Export to Grid','Orientation','Horizontal','Location','north')
set(gcf,'Position',[10 10 900 350])
hold off



figure
hold on
plot(time,export_price(:,3),'k','LineWidth',1)
grid on
box on
ylabel({'Export Credit','($/kWh)'},'FontSize',16)
xlim([time((day_idx-1)*24+1) time((day_idx-1)*24+7*24)])
datetick('x','ddd','KeepTicks','KeepLimits')
set(gcf,'Position',[10 10 900/2 350/2])
hold off

% figure
% hold on
% plot(time,[var_rees.rees_soc(:,idx) var_rees.rees_chrg(:,idx) var_rees.rees_dchrg(:,idx) var_rees.rees_dchrg_nem(:,idx)])
% xlim([time((day_idx-1)*24+1) time((day_idx-1)*24+7*24)])
% legend('SOC','Chrg','dchrg','dchrgNEM')

figure
hold on
plot(time,elec(:,idx),'LineWidth',1)
plot(time,elec_resiliency_full(:,idx),'LineWidth',1)
grid on
box on
ylabel({'Electricity (kWh)'},'FontSize',16)
xlim([time((day_idx-1)*24+1) time((day_idx-1)*24+7*24)])
datetick('x','ddd','KeepTicks','KeepLimits')
set(gcf,'Position',[10 10 900 350])
hold off


figure
hold on
plot(time,elec(:,idx),'LineWidth',1)
plot(time,elec_resiliency_full(:,idx),'LineWidth',1)
grid on
box on
set(gca,'XTick',[round(min(time))-0.5:1:round(max(time)+0.5)],'FontSize',14)
ylabel({'Electricity (kWh)'},'FontSize',16)
xlim([time((day_idx-1)*24+1) time((day_idx-1)*24+7*24)])
datetick('x','ddd','KeepTicks','KeepLimits')
set(gcf,'Position',[10 10 900 350])
legend('Full Residential Load','Critical Residential Load','Orientation','Horizontal','Location','north')
hold off


figure
hold on
plot(time(1:length(var_resiliency.ees_soc)),var_resiliency.ees_soc(:,idx),'LineWidth',1)
% plot(time,elec_resiliency_full(:,idx),'LineWidth',1)
grid on
box on
set(gca,'XTick',[round(min(time))-0.5:1:round(max(time)+0.5)],'FontSize',14)
ylabel({'Battery State of Charge (kWh)'},'FontSize',16)
xlim([time((day_idx-1)*24+1) time((day_idx-1)*24+7*24)])
datetick('x','ddd','KeepTicks','KeepLimits')
set(gcf,'Position',[10 10 900 350])
% legend('Full Residential Load','Critical Residential Load','Orientation','Horizontal','Location','north')
hold off


figure
hold on
plot(time(1:length(var_resiliency.ees_soc)),sum(var_resiliency.ees_soc,2).*(2/4),'LineWidth',1)
% plot(time,elec_resiliency_full(:,idx),'LineWidth',1)
grid on
box on
set(gca,'XTick',[round(min(time))-0.5:1:round(max(time)+0.5)],'FontSize',14)
ylabel({'Battery State of Charge (kWh)'},'FontSize',16)
xlim([time((day_idx-1)*24+1) time((day_idx-1)*24+7*24)])
datetick('x','ddd','KeepTicks','KeepLimits')
set(gcf,'Position',[10 10 900 350])
% legend('Full Residential Load','Critical Residential Load','Orientation','Horizontal','Location','north')
hold off


%%
close all
figure
hold on
plot(time(1:length(var_resiliency.ees_soc)),[var_resiliency.dgb_real(:,1)],'LineWidth',1)
plot(time(1:length(var_resiliency.ees_soc)),var_resiliency.dgb_reactive(:,1),'LineWidth',1)
plot(time(1:length(var_resiliency.ees_soc)),var_resiliency.dgb_elec(:,1),'LineWidth',1)
% plot(time,elec_resiliency_full(:,idx),'LineWidth',1)
grid on
box on
set(gca,'XTick',[round(min(time))-0.5:1:round(max(time)+0.5)],'FontSize',14)
ylabel({'PEMFC Output (kW/kVar/kVa)'},'FontSize',16)
xlim([time((day_idx-1)*24+1) time((day_idx-1)*24+7*24)])
datetick('x','ddd','KeepTicks','KeepLimits')
set(gcf,'Position',[10 10 900 350])
legend('Real','Reactive','Apparent','Orientation','Horizontal','Location','best')
hold off