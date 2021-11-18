%% Plotting Generation
close all


x_lim_range = [time(day_stpts(mth_idx))+3 time(day_endpts(mth_idx+7))+2 ];

f3 = figure;
hold on
if exist('var_pp')
    if  ~isfield(var_pp,'pp_elec_wheel')
        var_pp.pp_elec_wheel = zeros(size(elec));
    end
    if  ~isfield(var_pp,'pp_elec_wheel_lts')
        var_pp.pp_elec_wheel_lts = zeros(size(elec));
    end
end
plot_data = [];
if ldg_on
    plot_data = e_adjust.*[var_ldg.ldg_elec.*non_h2_frac.*con_frac + var_ldg.ldg_elec.*non_h2_frac.*biogas_frac ...
        var_ldg.ldg_elec.*h2_frac ...
        var_lbot.lbot_elec ...
        var_pv.pv_elec ...
        var_util.import ...
        var_pp.pp_elec_wheel ...
        sum(var_ees.ees_chrg,2) + sum(var_lees.ees_chrg,2) +  sum(var_rees.rees_chrg,2) ...
        var_rees.rees_dchrg + var_ees.ees_dchrg + var_lees.ees_dchrg]./1000;
else
    plot_data = e_adjust.*[zeros(length( var_pv.pv_elec),4) ...
        var_rees.rees_dchrg + var_ees.ees_dchrg + var_lees.ees_dchrg...
    var_pv.pv_elec ...
    var_util.import]./1000;
end

p3 = area(time,plot_data);
plot(time,e_adjust.*elec./1000,'LineWidth',2,'Color',[0 0 0])
a3 = gca;
 a3.FontSize = 16;
 a3.YLabel.String = 'Electricity (MW)';
 a3.YLabel.FontSize = 20;
a3.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
% a3.XTick = [0 1]
datetick('x','ddd','KeepTicks')
xlim([x_lim_range])
box on
grid on
legend('GT - NG','GT - H_2','ST','PV to Load','General Utility Import','UC Procured Import','Battery Charge','Battery Discharge','Orientation','Horizontal','Location','SouthOutside')
% a1.xtick = 1
set(gcf, 'Position',  [-1500, -150, 900, 400])
xlim([x_lim_range])
% ylim([0 22])
hold off