close all
%% one week in winter 
days_to_look_at = 44;  %February 7th (Day 38th)
xlim_range = [time(24*(days_to_look_at-1))    time(24*days_to_look_at+ 24*6) ];
figure 
hold on
plot_dt = [var_erwh.erwh_elec...
     var_gwh.gwh_gas];
 a = area(time,plot_dt,'LineStyle',':');
 a(1).FaceColor = [0 0.75 1];  %Electricity 
 a(2).FaceColor = [1.00 0.7 0.03];     %Gas   1.00 0.54 0.00
 plot(time,dhw,'LineWidth',1,'Color','k')
legend({'Electricity','Gas','SOFC','Thermal Enegy Storage'},'Location','northwest','Orientation','horizontal')
legend('boxoff') 
box on
grid on
set(gca,'FontSize',42,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
set(gca,'fontname','Times New Roman')
datetick('x','ddd','KeepTicks')
xlim(xlim_range)
ylim([0 8])
ylabel('Power (kW)')
hold off
saveas(gcf,'winter_DHW_NO_SOFC.fig')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% One week in summer 
days_to_look_at = 212; %August 1st:213
xlim_range = [time(24*(days_to_look_at-1))    time(24*days_to_look_at+ 24*6)];
figure 
hold on
plot_dt = [var_erwh.erwh_elec...
     var_gwh.gwh_gas];
 a = area(time,plot_dt,'LineStyle',':');
 a(1).FaceColor = [0 0.75 1];  %Electricity 
 a(2).FaceColor = [1.00 0.7 0.03];     %Gas   1.00 0.54 0.00
 plot(time,dhw,'LineWidth',1,'Color','k')
legend({'Electricity','Gas','SOFC','Thermal Enegy Storage'},'Location','northwest','Orientation','horizontal')
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
saveas(gcf,'summer_DHW_NO_SOFC.fig')