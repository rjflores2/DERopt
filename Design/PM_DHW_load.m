close all
%% one week in winter 
days_to_look_at = 38;  %February 7th 
xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
figure
hold on
plot_dt = [var_erwh.erwh_elec.*erwh_eff...
     var_gwh.gwh_gas.*gwh_eff...
     var_sofc.sofc_wh...
     var_tes.tes_dchrg];
 a = area(time,plot_dt,'LineStyle',':');
 a(1).FaceColor = [0 0.75 1];  %Electricity 
 a(2).FaceColor = [1.00 0.7 0.03];     %Gas   1.00 0.54 0.00
 a(3).FaceColor = [0.4 0.4 1]; %SOFC
 a(4).FaceColor = [1 0 0.2]; %TES 
plot(time,dhw,'LineWidth',1,'Color','k')
legend({'Electricity','Gas','SOFC','Thermal Enegy Storage'},'Location','northwest','Orientation','horizontal')
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
saveas(gcf,'winter_DHW.fig')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% One week in summer 
days_to_look_at = 213; %August 1st 
xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
figure
hold on
plot_dt = [var_erwh.erwh_elec.*erwh_eff...
     var_gwh.gwh_gas.*gwh_eff...
     var_sofc.sofc_wh...
     var_tes.tes_dchrg];
 a = area(time,plot_dt,'LineStyle',':');
 a(1).FaceColor = [0 0.75 1];  %Electricity 
 a(2).FaceColor = [1.00 0.7 0.03];     %Gas   1.00 0.54 0.00
 a(3).FaceColor = [0.4 0.4 1]; %SOFC
 a(4).FaceColor = [1 0 0.2]; %TES 
%  a(1).FaceColor = [0 0.75 1];  %Electricity 
%  a(2).FaceColor = [1 0.5 0];     %Gas   1.00 0.54 0.00
%  a(3).FaceColor = [0.5 0.3 1]; %SOFC
%  a(4).FaceColor = [0.21 0.6 1]; %TES  [0 0 0.8]
plot(time,dhw,'LineWidth',1,'Color','k')
legend({'Electricity','Gas','SOFC','Thermal Enegy Storage'},'Location','northwest','Orientation','horizontal')
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
saveas(gcf,'summer_DHW.fig')