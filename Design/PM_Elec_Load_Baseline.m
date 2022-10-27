close all
Updated_EES=readtable('C:\Users\19498\Documents\GitHub\DERopt\Design\PM_Results\Updated_EES.xlsx','Sheet','CZ06_2025_Sc1');
updated_EES_C =Updated_EES.EES_CH;
updated_EES_D =Updated_EES.EES_DCH;
updated_Grid= Updated_EES.Grid_Imp;
%% one week in winter 
days_to_look_at = 44;  %February 7th (Day 38th)
xlim_range = [time(24*(days_to_look_at-1))    time(24*days_to_look_at+ 24*6) ];
figure 
hold on
plot_dt = [var_sofc.sofc_elec ...
    var_pv.pv_elec...
    updated_EES_D...
    var_rees.rees_dchrg ...
    updated_Grid];
a= area(time,plot_dt,'LineStyle',':');
a(1).FaceColor = [0.5 0.3 1];    %SOFC [0.5 0 1]
a(2).FaceColor = [1 0.1 0.1];  %PV [1 1 0]
a(3).FaceColor = [0 0 0.4];      %EES 0.7 0 1  [0.7 0.7 0.7]
a(4).FaceColor = [0 1 0];      %REES
a(5).FaceColor = [0 0.75 1];  %grid       
% newcolors = [0 0.5 1; 0.5 0 1; 0.7 0.7 0.7; 0.7 0 1 ;0 1 1];
% colororder(newcolors)
plot(time,elec,'LineWidth',2,'Color','k','LineStyle','-')
plot(time,elec+ updated_EES_C,'LineWidth',2,'Color','[0 0.6 0]')
plot(time,elec+ updated_EES_C+var_erwh.erwh_elec,'LineWidth',2,'Color','k','LineStyle',':')
legend({'SOFC','PV','EES ','REES ','Grid ',' elec',' elec+EES',' elec+EES+Hot water'},'Location','northwest','Orientation','horizontal')
legend('boxoff') box on
grid on
set(gca,'FontSize',42,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
set(gca,'fontname','Times New Roman')
datetick('x','ddd','KeepTicks')
xlim(xlim_range)
ylabel('Power (kW)')
hold off
saveas(gcf,'winter_electric_load_baseline.fig')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% One week in summer 
days_to_look_at = 212; %August 1st:213
xlim_range = [time(24*(days_to_look_at-1))    time(24*days_to_look_at+ 24*6)];
figure 
hold on
plot_dt = [var_sofc.sofc_elec ...
    var_pv.pv_elec...
    updated_EES_D...
    var_rees.rees_dchrg ...
    updated_Grid];
a= area(time,plot_dt,'LineStyle',':');
a(1).FaceColor = [0.5 0.3 1];    %SOFC [0.5 0 1]
a(2).FaceColor = [1 0.1 0.1];  %PV [1 1 0]
a(3).FaceColor = [0 0 0.4];      %EES 0.7 0 1
a(4).FaceColor = [0 1 0];      %REES
a(5).FaceColor = [0 0.75 1];  %grid       
% newcolors = [0 0.5 1; 0.5 0 1; 0.7 0.7 0.7; 0.7 0 1 ;0 1 1];
% colororder(newcolors)
plot(time,elec,'LineWidth',2,'Color','k','LineStyle','-')
plot(time,elec+ updated_EES_C,'LineWidth',2,'Color','[0 0.6 0]')
plot(time,elec+ updated_EES_C+var_erwh.erwh_elec,'LineWidth',2,'Color','k','LineStyle',':')
legend({'SOFC','PV','EES ','REES ','Grid ',' elec',' elec+EES',' elec+EES+Hot water'},'Location','best','Orientation','horizontal')
legend('boxoff') 

box on
grid on
set(gca,'FontSize',42,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
set(gca,'fontname','Times New Roman')
datetick('x','ddd','KeepTicks')
xlim(xlim_range)

ylabel('Power (kW)')
hold off
saveas(gcf,'summer_electric_load_baseline.fig')

