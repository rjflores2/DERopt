close all

lcoe = solution.objval/sum(sum(elec))

adopted = [sum(var_pv.pv_adopt)
    sum(var_rees.rees_adopt)+sum(var_ees.ees_adopt)
    sum(var_h2_storage.capacity)./33.3
    sum(var_dgl.dg_capacity)]

%%

dt = [sum(var_resiliency.dg_elec,2) ...
    sum(var_resiliency.pv_elec,2) ...
    sum(var_resiliency.ees_dchrg,2)    ];


figure
tiledlayout(3,1)
nexttile
hold on
area(time(T_res(1):T_res(2)),dt)
plot(time(T_res(1):T_res(2)),sum(elec_res(T_res(1):T_res(2),:),2),'LineWidth',2,'Color',[0 0 0])

xlim(time([T_res(1) T_res(2)]))
set(gca,'FontSize',14,...
    'XTick',[ceil(time(1))+.5:1:floor(time(end))+.5])
grid on
box on
datetick('x','ddd','keeplimits','keepticks')

legend('PEMFC','Solar PV','Battery Dishcarge','Load','Orientation','horizontal')
ylabel('Power (kW)','FontSize',16)
hold off

nexttile
hold on
plot(time(T_res(1):T_res(2)),sum(var_resiliency.h2_soc,2)./33.3,'LineWidth',2)
xlim(time([T_res(1) T_res(2)]))
set(gca,'FontSize',14,...
    'XTick',[ceil(time(1))+.5:1:floor(time(end))+.5])
grid on
box on
ylabel('H_2 Storage (kg)','FontSize',16)
datetick('x','ddd','keeplimits','keepticks')
hold off

nexttile
hold on
plot(time(T_res(1):T_res(2)),sum(var_resiliency.ees_soc,2),'LineWidth',2)
xlim(time([T_res(1) T_res(2)]))
set(gca,'FontSize',14,...
    'XTick',[ceil(time(1))+.5:1:floor(time(end))+.5])
grid on
box on
ylabel('Battery SOC (kWh)','FontSize',16)
datetick('x','ddd','keeplimits','keepticks')
hold off

set(gcf,'Position',[10 10 900 950])