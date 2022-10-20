close all
%% one week in winter 
days_to_look_at = 38; %February 7th 
xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
figure  
hold on
plot_dt = [var_sofc.sofc_elec ...
    var_pv.pv_elec...
    var_ees.ees_dchrg...
    var_rees.rees_dchrg ...
    var_util.import ];
a= area(time,plot_dt,'LineStyle',':');
a(1).FaceColor = [0.5 0.3 1];    %SOFC [0.5 0 1]
a(2).FaceColor = [1 0.1 0.1];  %PV [1 1 0]
a(3).FaceColor = [0 0 0.4];      %EES 0.7 0 1  [0.7 0.7 0.7]
a(4).FaceColor = [0 1 0];      %REES
a(5).FaceColor = [0 0.75 1];  %grid       
% newcolors = [0 0.5 1; 0.5 0 1; 0.7 0.7 0.7; 0.7 0 1 ;0 1 1];
% colororder(newcolors)
plot(time,elec,'LineWidth',2,'Color','k','LineStyle','-')
plot(time,elec+ var_ees.ees_chrg,'LineWidth',2,'Color','[0 0.6 0]')
plot(time,elec+ var_ees.ees_chrg+var_erwh.erwh_elec,'LineWidth',2,'Color','k','LineStyle',':')
legend({'SOFC','PV','EES ','REES ','Grid ',' elec',' elec+EES',' elec+EES+Hot water'},'Location','northwest','Orientation','horizontal')
legend('boxoff') 
xlim(xlim_range)
datetick('x','ddd','KeepTicks')

box on
grid on
set(gca,'FontSize',20,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
set(gca,'fontname','Times New Roman')

xlabel('Days') 
ylabel('Power (kW)')
hold off
saveas(gcf,'winter_electric_load.fig')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% One week in summer 
days_to_look_at = 213; %August 1st
xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
figure  
hold on
plot_dt = [var_sofc.sofc_elec ...
    var_pv.pv_elec...
    var_ees.ees_dchrg...
    var_rees.rees_dchrg ...
    var_util.import ];
a= area(time,plot_dt,'LineStyle',':');
a(1).FaceColor = [0.5 0.3 1];    %SOFC [0.5 0 1]
a(2).FaceColor = [1 0.1 0.1];  %PV [1 1 0]
a(3).FaceColor = [0 0 0.4];      %EES 0.7 0 1
a(4).FaceColor = [0 1 0];      %REES
a(5).FaceColor = [0 0.75 1];  %grid       
% newcolors = [0 0.5 1; 0.5 0 1; 0.7 0.7 0.7; 0.7 0 1 ;0 1 1];
% colororder(newcolors)
plot(time,elec,'LineWidth',2,'Color','k','LineStyle','-')
plot(time,elec+ var_ees.ees_chrg,'LineWidth',2,'Color','[0 0.6 0]')
plot(time,elec+ var_ees.ees_chrg+var_erwh.erwh_elec,'LineWidth',2,'Color','k','LineStyle',':')
legend({'SOFC','PV','EES ','REES ','Grid ',' elec',' elec+EES',' elec+EES+Hot water'},'Location','northwest','Orientation','horizontal')
legend('boxoff') 
xlim(xlim_range)
datetick('x','ddd','KeepTicks')

box on
grid on
set(gca,'FontSize',20,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
set(gca,'fontname','Times New Roman')

xlabel('Days') 
ylabel('Power (kW)')
hold off
saveas(gcf,'summer_electric_load.fig')