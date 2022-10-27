close all
% %% one week in winter 
% days_to_look_at = 38;  %February 7th 
% xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
% figure
% hold on
%  plot_dt = [var_rees.rees_chrg...
%      var_ees.ees_chrg...
%      var_rees.rees_dchrg...
%      var_ees.ees_dchrg...
%      var_pv.pv_elec];
%  a = area(time,plot_dt,'LineStyle',':');
%  a(1).FaceColor = [1 1 0];    %REES charge by PV
%  a(2).FaceColor = [0 0.75 1]; %EES charge by grid
%  a(3).FaceColor = [0 1 0];    %REES for building load
%  a(4).FaceColor = [0 0 0.4];  %EES for building
%  a(5).FaceColor = [1 0.1 0.1];   %PV for building 
% plot(time,var_pv.pv_elec + var_pv.pv_nem + var_rees.rees_chrg ,'LineWidth',2,'Color','r')
% exp_plot_dt =[-var_rees.rees_dchrg_nem ... 
%               -var_pv.pv_nem ];
% e = area(time,exp_plot_dt); 
% e(1).FaceColor = [0 0.6 0];  %REES export
% e(2).FaceColor = [1.00 0.70 0.00];  %PV export
% legend({'REES C-PV','EES C-grid','REES D-load','EES D-load','PV-load','PV','REES-exp','PV-exp'},'Location','northwest','Orientation','horizontal','boxoff')
% legend('boxoff') 
% xlim(xlim_range)
% datetick('x','ddd','KeepTicks')
% box on
% grid on
% set(gca,'FontSize',36,...
%     'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
% set(gca,'fontname','Times New Roman')
% 
% xlabel('Days') 
% ylabel('Energy (kWh)')
% hold off
% saveas(gcf,'winter_EES_REES_SOC.fig')
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% One week in winter - better plot
%% one week in winter 
days_to_look_at = 44;  %February 7th (Day 38th)
xlim_range = [time(24*(days_to_look_at-1))    time(24*days_to_look_at+ 24*6) ];
figure 
hold on
 plot_dt = [var_rees.rees_chrg...
     var_pv.pv_elec...
     var_rees.rees_dchrg...
     var_ees.ees_dchrg...
     var_ees.ees_chrg];
 a = area(time,plot_dt,'LineStyle',':');
 a(1).FaceColor = [1 1 0];    %REES charge by PV
 a(2).FaceColor = [1 0.1 0.1];   %PV for building 
 a(3).FaceColor = [0 1 0];    %REES for building load
 a(4).FaceColor = [0 0 0.4];  %EES for building
 a(5).FaceColor = [0 0.75 1]; %EES charge by grid
plot(time,var_pv.pv_elec + var_pv.pv_nem + var_rees.rees_chrg ,'LineWidth',2,'Color','r')
plot(time,tdv_elec,'LineWidth',3,'Color','m','LineStyle','-')
exp_plot_dt =[-var_rees.rees_dchrg_nem ... 
              -var_pv.pv_nem ];
e = area(time,exp_plot_dt); 
e(1).FaceColor = [0 0.6 0];  %REES export
e(2).FaceColor = [1.00 0.70 0.00];  %PV export
legend({'REES C','load','REES D','EES D','EES C','PV','TDV','REES-exp','PV-exp'},'Location','northwest','Orientation','horizontal','boxoff')
legend('boxoff') 
box on
grid on
set(gca,'FontSize',38,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
set(gca,'fontname','Times New Roman')
datetick('x','ddd','KeepTicks')
xlim(xlim_range)
ylim([-2 2])
ylabel('Energy (kWh)')
hold off
saveas(gcf,'winter_EES_REES_SOC.fig')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% one week in Summer - changed the order  
days_to_look_at = 212; %August 1st:213
xlim_range = [time(24*(days_to_look_at-1))    time(24*days_to_look_at+ 24*6)];
figure 
hold on
 plot_dt = [var_rees.rees_chrg...
     var_pv.pv_elec...
     var_rees.rees_dchrg...
     var_ees.ees_dchrg...
     var_ees.ees_chrg];
 a = area(time,plot_dt,'LineStyle',':');
 a(1).FaceColor = [1 1 0];    %REES charge by PV
 a(2).FaceColor = [1 0.1 0.1];   %PV for building 
 a(3).FaceColor = [0 1 0];    %REES for building load
 a(4).FaceColor = [0 0 0.4];  %EES for building
 a(5).FaceColor = [0 0.75 1]; %EES charge by grid
plot(time,var_pv.pv_elec + var_pv.pv_nem + var_rees.rees_chrg ,'LineWidth',2,'Color','r')
plot(time,tdv_elec,'LineWidth',3,'Color','m','LineStyle','-')
exp_plot_dt =[-var_rees.rees_dchrg_nem ... 
              -var_pv.pv_nem ];
e = area(time,exp_plot_dt); 
e(1).FaceColor = [0 0.6 0];  %REES export
e(2).FaceColor = [1.00 0.70 0.00];  %PV export
legend({'REES C','load','REES D','EES D','EES C','PV','TDV','REES-exp','PV-exp'},'Location','northwest','Orientation','horizontal','boxoff')
legend('boxoff') 
box on
grid on
set(gca,'FontSize',38,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
set(gca,'fontname','Times New Roman')
datetick('x','ddd','KeepTicks')
xlim(xlim_range)
ylim([-2 2])
ylabel('Energy (kWh)')
hold off
saveas(gcf,'summer_EES_REES_SOC.fig')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% SOC
%% one week in winter 
days_to_look_at = 44;  %February 7th (Day 38th)
xlim_range = [time(24*(days_to_look_at-1))    time(24*days_to_look_at+ 24*6)];
figure  
hold on
plot(time,var_ees.ees_soc.*100./max(var_ees.ees_soc),'LineWidth',2,'Color','k','LineStyle','-')
plot(time,var_rees.rees_soc.*100./max(var_rees.rees_soc),'LineWidth',2,'Color','[0 0.6 0]')
legend({'EES','REES'},'Location','northwest','Orientation','vertical')
legend('boxoff') 
box on
grid on
set(gca,'FontSize',38,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
set(gca,'fontname','Times New Roman')
datetick('x','ddd','KeepTicks')
xlim(xlim_range)
ylabel('State of Charge (%)')
ylim([0 100])
hold off
saveas(gcf,'winter_%_SOC.fig')
%%
%% One week in summer 
days_to_look_at = 212; %August 1st:213
xlim_range = [time(24*(days_to_look_at-1))    time(24*days_to_look_at+ 24*6)];
figure 
hold on
plot(time,var_ees.ees_soc.*100./max(var_ees.ees_soc),'LineWidth',2,'Color','k','LineStyle','-')
plot(time,var_rees.rees_soc.*100./max(var_rees.rees_soc),'LineWidth',2,'Color','[0 0.6 0]')
legend({'EES','REES'},'Location','northwest','Orientation','vertical')
legend('boxoff') 
box on
grid on
set(gca,'FontSize',38,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
set(gca,'fontname','Times New Roman')
datetick('x','ddd','KeepTicks')
xlim(xlim_range)
ylabel('State of Charge (%)')
ylim([0 100])
hold off
saveas(gcf,'summer_%_SOC.fig')

%% TDV
%% one week in winter 
days_to_look_at = 44;  %February 7th (Day 38th)
xlim_range = [time(24*(days_to_look_at-1))    time(24*days_to_look_at+ 24*6)];
figure  
hold on
plot(time,tdv_elec,'LineWidth',2,'Color','b','LineStyle','-')
box on
grid on
set(gca,'FontSize',24,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
set(gca,'fontname','Times New Roman')
datetick('x','ddd','KeepTicks')
xlim(xlim_range)
ylabel('TDV electricity (kWh/kWh)')
ylim([0 2])
hold off
saveas(gcf,'winter_TDV.fig')
%%
%% One week in summer 
days_to_look_at = 212; %August 1st:213
xlim_range = [time(24*(days_to_look_at-1))    time(24*days_to_look_at+ 24*6)];
figure 
hold on
plot(time,tdv_elec,'LineWidth',2,'Color','m','LineStyle','-')
box on
grid on
set(gca,'FontSize',24,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
set(gca,'fontname','Times New Roman')
datetick('x','ddd','KeepTicks')
xlim(xlim_range)
ylabel('TDV electricity (kWh/kWh)')
ylim([0 2])
hold off
saveas(gcf,'summer_TDV.fig')