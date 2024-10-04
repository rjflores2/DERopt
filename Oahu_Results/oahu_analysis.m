total_data = [sum(var_wave.electricity,2) ...
    sum(var_pv.pv_elec,2)...
    var_legacy_diesel.electricity...
    var_pem.elec ...
    sum(var_ees.ees_dchrg + var_lees.ees_dchrg,2)
    ]./1000;

month_num = 6
x_days = [15+30*(month_num-1)];
close all
figure
hold on
area(time,total_data)
plot(time,elec./1000,'LineWidth',2,'Color',[0 0 0])
box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(time(1))+.5:1:floor(time(end))+.5])
xlim([time((x_days-1)*24+1)  time((x_days+26)*24)])
