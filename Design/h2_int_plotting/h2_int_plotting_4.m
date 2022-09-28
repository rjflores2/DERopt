
close all

f1 = figure;
adopted_tech_3(5,1) = 0;
adopted_tech_4(5,1) = 0;
subplot(1,2,1)
hold on
% yyaxis left
plot((co2_lim_0(1) - co2_lim_0)./co2_lim_0(1).*100,adopted_tech_0(1,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0.93 .69 .13])
plot((co2_lim_1(1) - co2_lim_1)./co2_lim_1(1).*100,adopted_tech_1(1,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 .45 0.75],'Color',[0 .45 .75]) 
box on
grid on
set(gca,'FontSize',16)
ylabel('On-Site Solar (MW)','FontSize',20)
legend('Current Baseline','Current System + H_2','Location','NorthWest')
xlim([0 100])
hold off


subplot(1,2,2)

hold on
yyaxis left

plot(0,0,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1],'Color',[0 0 0])
plot(0,0,'--s','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1],'Color',[0 0 0])
plot((co2_lim_0(1) - co2_lim_0)./co2_lim_0(1).*100,adopted_tech_0(2,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0.93 .69 .13])
plot((co2_lim_1(1) - co2_lim_1)./co2_lim_1(1).*100,adopted_tech_1(2,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 .45 0.75],'Color',[0 .45 .75]) 
box on
grid on
set(gca,'FontSize',16)
ylabel('Battery Storage (MWh)','FontSize',20)
yyaxis right
plot((co2_lim_1(1) - co2_lim_1)./co2_lim_1(1).*100,adopted_tech_1(3,:)./1000,'--s','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 .45 .75],'Color',[0 .45 .75])
ylabel('Electrolyzer Capacity (MW)','FontSize',20)

legend('Battery Storage','Electrolyzer Capacity','Location','NorthWest')
% legend('Sc 0 Battery','Sc 1 Battery','Sc 1 Electrolyzer','Location','NorthWest')
xlim([0 100])
hold off



f1.Position = [100 100 1800 600];
%%

close all

f2 = figure;
adopted_tech_3(5,1) = 0;
adopted_tech_4(5,1) = 0;
subplot(1,2,1)
hold on
yyaxis left
plot((co2_lim_2(1) - co2_lim_2)./co2_lim_2(1).*100,adopted_tech_2(1,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0.93 .69 .13])
plot((co2_lim_3(1) - co2_lim_3)./co2_lim_3(1).*100,adopted_tech_3(1,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 .45 0.75],'Color',[0 .45 .75])
plot((co2_lim_4(1) - co2_lim_4)./co2_lim_4(1).*100,adopted_tech_4(1,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.85 .33 .1],'Color',[0.85 .33 .1])

plot(0,0,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1],'Color',[0 0 0])
plot(0,0,'--s','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1],'Color',[0 0 0])



ylabel('On-Site Solar (MW)','FontSize',20)
yyaxis right
plot((co2_lim_2(1) - co2_lim_2)./co2_lim_2(1).*100,adopted_tech_2(5,:)./1000,'--s','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0.93 .69 .13])
plot((co2_lim_3(1) - co2_lim_3)./co2_lim_3(1).*100,adopted_tech_3(5,:)./1000,'--s','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 .45 0.75],'Color',[0 .45 .75]) 
plot((co2_lim_4(1) - co2_lim_4)./co2_lim_4(1).*100,adopted_tech_4(5,:)./1000,'--s','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.85 .33 .1],'Color',[0.85 .33 .1]) 
ylabel('Off-Site Solar (MW)','FontSize',20)
box on



grid on
set(gca,'FontSize',16)
legend('Future Baseline','Future + H_2','Future + H_2 + Pipeline Injeciton','On Site PV','Off Site PV','Location','NorthWest')

hold off


subplot(1,2,2)
% close all
hold on
yyaxis left


plot(0,0,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1],'Color',[0 0 0])
plot(0,0,'--s','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1],'Color',[0 0 0])
plot((co2_lim_2(1) - co2_lim_2)./co2_lim_2(1).*100,adopted_tech_2(2,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0.93 .69 .13])
plot((co2_lim_3(1) - co2_lim_3)./co2_lim_3(1).*100,adopted_tech_3(2,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 .45 0.75],'Color',[0 .45 .75])
plot((co2_lim_4(1) - co2_lim_4)./co2_lim_4(1).*100,adopted_tech_4(2,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.85 .33 .1],'Color',[0.85 .33 .1])

% plot((co2_lim_0(1) - co2_lim_0)./co2_lim_0(1).*100,adopted_tech_0(2,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0.93 .69 .13])
% plot((co2_lim_1(1) - co2_lim_1)./co2_lim_1(1).*100,adopted_tech_1(2,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 .45 0.75],'Color',[0 .45 .75]) 
box on
grid on
set(gca,'FontSize',16)
ylabel('Battery Storage (MWh)','FontSize',20)
yyaxis right


% plot((co2_lim_2(1) - co2_lim_2)./co2_lim_2(1).*100,adopted_tech_2(3,:)./1000,'--o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0.93 .69 .13])
plot((co2_lim_3(1) - co2_lim_3)./co2_lim_3(1).*100,adopted_tech_3(3,:)./1000,'--s','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 .45 0.75],'Color',[0 .45 .75])
plot((co2_lim_4(1) - co2_lim_4)./co2_lim_4(1).*100,adopted_tech_4(3,:)./1000,'--s','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.85 .33 .1],'Color',[0.85 .33 .1])

% plot((co2_lim_1(1) - co2_lim_1)./co2_lim_1(1).*100,adopted_tech_1(3,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.85 .33 .1],'Color',[0.85 .33 .1])
ylabel('Electrolyzer Capacity (MW)','FontSize',20)

legend('Battery Storage','Electrolyzer Capacity','Location','NorthWest')
hold off



f2.Position = [100 100 1800 600];

%%

f4 = figure;
hold on
plot((co2_lim_0(1) - co2_lim_0)./co2_lim_0(1).*100,(total_cost_0 - total_cost_0(1))./total_cost_0(1).*100,'--o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0 0 0])
plot((co2_lim_1(1) - co2_lim_1)./co2_lim_1(1).*100,(total_cost_1 - total_cost_1(1))./total_cost_1(1).*100,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 .45 0.75],'Color',[0 .45 .75]) 
plot((co2_lim_2(1) - co2_lim_2)./co2_lim_2(1).*100,(total_cost_2 - total_cost_2(1))./total_cost_2(1).*100,'--s','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.85 .33 .1],'Color',[0.85 .33 .1])
plot((co2_lim_3(1) - co2_lim_3)./co2_lim_3(1).*100,(total_cost_3 - total_cost_3(1))./total_cost_3(1).*100,'-s','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0.93 .69 .13])
plot((co2_lim_4(1) - co2_lim_4)./co2_lim_4(1).*100,(total_cost_4 - total_cost_4(1))./total_cost_4(1).*100,'-s','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.49 .18 .56],'Color',[0.49 .18 .56])
box on
grid on
set(gca,'FontSize',16)
ylabel('Change in Cost of Energy (%)','FontSize',20)
xlabel('CO_2 Reduction (%)','FontSize',20)
ylim([0 750])
legend('Current Baseline','Current Engine + H_2','Future Baseline','Future + H_2','Future + H_2 + H_2 Injection','Location','NorthWest')
hold off
f4.Position = [100 100 800 425];