 close all 
% days_to_look_at = 200;
% xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
% figure  
% hold on
% plot_dt = [var_util.import ...
%     var_pv.pv_elec ...
%     var_ees.ees_dchrg...
%     var_rees.rees_dchrg ...
%     ]; 
% area(time,plot_dt)
% plot(time,elec,'LineWidth',2,'Color','k')
% plot(time,total_load_building,'LineWidth',2,'Color','r')
% plot(time,total_load_building + var_ees.ees_chrg + var_rees.rees_chrg ,'LineWidth',2,'Color','m')
% plot(time,var_rees.rees_chrg,'LineWidth',2,'Color','g')
% plot(time,var_rees.rees_dchrg_nem,'LineWidth',2,'Color','c')
% legend({'Grid','PV','EES','REES','elec','total(elec+HVAC+DHW)','total+batteries','REES-C','REES-exp'},'Location','northwest','Orientation','horizontal')
% xlim(xlim_range)
% datetick('x','ddd','KeepTicks')
% box on
% grid on
% set(gca,'FontSize',14,...
%     'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
% hold off
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% days_to_look_at = 200;
% xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
% figure  
% hold on
% plot_dt = [var_sofc.sofc_elec ...
%     var_util.import ...
%     var_ees.ees_dchrg...
%     var_rees.rees_dchrg ...
%     var_rees.rees_dchrg_nem ...
%     var_pv.pv_nem ...
%     var_pv.pv_elec  ];
% area(time,plot_dt)
% plot(time,elec,'LineWidth',2,'Color','k')
% plot(time,elec+ var_ees.ees_chrg,'LineWidth',3,'Color','r')
% plot(time,elec+ var_ees.ees_chrg+var_erwh.erwh_elec,'LineWidth',4,'Color','g')
% % plot(time,Building_All_El_Load,'LineWidth',3,'Color','--k')
% legend({'SOFC','Grid','EES','REES','REES EXP','PV EXP','PV','electricity','electricity+EES','electricity+EES+Hotwater'},'Location','northwest','Orientation','horizontal')
% xlim(xlim_range)
% datetick('x','ddd','KeepTicks')
% box on
% grid on
% set(gca,'FontSize',12,...
%     'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
% hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% newcolors = [0 0.5 1; 0.5 0 1; 0.7 0.7 0.7; 0.7 0 1 ;0 1 1];
% colororder(newcolors)
% newcolors = {'#F00','#F80','#FF0','#0B0','#00F','#50F','#A0F'};
% colororder(newcolors)
days_to_look_at = 200;
xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
figure  
hold on
plot_dt = [var_sofc.sofc_elec ...
    var_util.import ...
    var_ees.ees_dchrg...
    var_rees.rees_dchrg ...
    var_pv.pv_elec  ];
a= area(time,plot_dt,'LineStyle',':')
a(1).FaceColor = [0.5 0.3 1];    %SOFC [0.5 0 1]
a(2).FaceColor = [0 0.75 1];  %grid
a(3).FaceColor = [0.7 0.7 0.7];      %EES 0.7 0 1
a(4).FaceColor = [0 1 0];      %REES
a(5).FaceColor = [1 0.1 0.1];        %PV [1 1 0]
% newcolors = [0 0.5 1; 0.5 0 1; 0.7 0.7 0.7; 0.7 0 1 ;0 1 1];
% colororder(newcolors)
plot(time,elec,'LineWidth',3,'Color','k','LineStyle',':')
plot(time,elec+ var_ees.ees_chrg,'LineWidth',3,'Color','c')
plot(time,elec+ var_ees.ees_chrg+var_erwh.erwh_elec,'LineWidth',3,'Color','k','LineStyle','-')
legend({'SOFC',' Grid',' EES',' REES',' PV',' electricity',' electricity + EES-C ',' electricity+ EES-C + Hotwater'},'Location','northwest','Orientation','horizontal')
xlim(xlim_range)
datetick('x','ddd','KeepTicks')

box on
grid on
set(gca,'FontSize',12,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])

hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%