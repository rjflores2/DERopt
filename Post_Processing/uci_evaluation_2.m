%% mth idx
close all
mth_idx = 1;

x_lim_range = [time(stpts(mth_idx)) time(endpts(mth_idx)) ];
x_lim_range = [time(day_stpts(mth_idx)) time(day_endpts(mth_idx+7)) ];
% %% Adopted technologies

adopted.pv = var_pv.pv_adopt;
adopted.ees = var_ees.ees_adopt;
adopted.rees =var_rees.rees_adopt;
adopted.el = var_el.el_adopt;
adopted.rel = var_rel.rel_adopt;
adopted.h2es = var_h2es.h2es_adopt;
adopted.h2_inject = var_h2_inject.h2_inject_size;
adopted.util_pv = var_utilpv.util_pv_adopt;
adopted.util_wind = var_util_wind.util_wind_adopt;
adopt.util_ees = var_util_ees.ees_adopt; 
adopt.util_el = var_util_el.el_adopt; 
adopt.util_h2_inject = var_util_h2_inject.h2_inject_size;
adopted

%% CO2 production
co2_emissions = [sum(var_util.import.*co2_import)
    co2_ng*(sum(sum(var_ldg.ldg_fuel)) + sum(sum(var_ldg.db_fire)) + sum(sum(var_boil.boil_fuel)))
    co2_rng*(sum(sum(var_ldg.ldg_rfuel)) + sum(sum(var_ldg.db_rfire)) + sum(sum(var_boil.boil_rfuel)))]

co2_emissions_total = sum(co2_emissions)

%% Biogas use / fuel uses
if ~isempty(biogas_limit)
    biogas_utilization = sum(var_ldg.ldg_rfuel  + var_boil.boil_rfuel + var_ldg.db_rfire)/(biogas_limit*(length(endpts)/12))
end
gt_fuel_source = sum([var_ldg.ldg_fuel ...
    var_ldg.ldg_rfuel ...
    var_ldg.ldg_hfuel])./sum(sum([var_ldg.ldg_fuel ...
    var_ldg.ldg_rfuel ...
    var_ldg.ldg_hfuel]))

%% Gas Splits - Conventional vs Renewable vs Hydrogen
if  ~exist('ldg_on','var')
    ldg_on = 0;    
end
if ldg_on
biogas_frac = sum(var_ldg.ldg_rfuel)./sum(var_ldg.ldg_fuel + var_ldg.ldg_rfuel)
if isnan(biogas_frac)
    biogas_frac = 0;
end
con_frac = sum(var_ldg.ldg_fuel)./sum(var_ldg.ldg_fuel + var_ldg.ldg_rfuel)
if isnan(con_frac)
    con_frac = 0;
end
h2_frac = var_ldg.ldg_hfuel./(var_ldg.ldg_fuel + var_ldg.ldg_rfuel + var_ldg.ldg_hfuel);
h2_frac(isnan(h2_frac)) = 0;
non_h2_frac = 1 - h2_frac;
% non_h2_frac(isnan(non_h2_frac)) = 0;
end
%% Plotting Generation

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
    plot_data = e_adjust.*[var_ldg.ldg_elec.*non_h2_frac.*con_frac ...
        var_ldg.ldg_elec.*non_h2_frac.*biogas_frac ...
        var_ldg.ldg_elec.*h2_frac ...
        var_lbot.lbot_elec ...
        var_pv.pv_elec ...
        var_rees.rees_dchrg + var_ees.ees_dchrg + var_lees.ees_dchrg...
        var_util.import ...
        var_pp.pp_elec_wheel...
        var_pp.pp_elec_wheel_lts]./1000;
else
    plot_data = e_adjust.*[var_ldg.ldg_elec ...
        var_ldg.ldg_elec ...
        var_ldg.ldg_elec ...
        var_lbot.lbot_elec ...
        var_pv.pv_elec ...
        var_rees.rees_dchrg + var_ees.ees_dchrg + var_lees.ees_dchrg...
        var_util.import ...
        var_pp.pp_elec_wheel...
        var_pp.pp_elec_wheel_lts]./1000;
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
legend('GT - NG','GT - rNG','GT - H_2','ST','PV to Load','EES Discharge','Import','Wheeled','Wheeled-H_2')
% a1.xtick = 1
set(gcf, 'Position',  [-1500, -150, 900, 400])
xlim([x_lim_range])
% ylim([0 22])
hold off



figure;
hold on
plot(time,co2_import,'LineWidth',2);
a3 = gca;
 a3.FontSize = 16;
 a3.YLabel.String = {'Grid Emissions','Factor (lb/kWh)'};
 a3.YLabel.FontSize = 20;
a3.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
datetick('x','ddd','KeepTicks')
xlim([x_lim_range])
box on
grid on
% legend('GT - NG','GT - rNG','GT - H_2','ST','PV to Load','EES Discharge','Import')
% a1.xtick = 1
set(gcf, 'Position',  [-1500, -150, 900, 250])
xlim([x_lim_range])
% ylim([0 22])
hold off

%% Plotting Load
f4 = figure;
hold on
plot_data = [];
plot_data = e_adjust.*[elec ...
    sum(var_ees.ees_chrg,2) + sum(var_lees.ees_chrg,2) ...
    sum(var_rees.rees_chrg,2) ...
    sum(el_eff.*var_el.el_prod,2) ...
    sum(h2_chrg_eff.*var_h2es.h2es_chrg,2) ...
    var_util.gen_export...
    var_hrs.hrs_supply.*hrs_chrg_eff]./1000;
p4 = area(time,plot_data);
a4 = gca;
 a4.FontSize = 16;
 a4.YLabel.String = 'Electricity (MW)';
 a4.YLabel.FontSize = 20;
a4.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
box on
grid on
legend('Load','BEES - Grid','BEES - Solar','H_2 Produciton','H_2 Compression','Export')
datetick('x','ddd','KeepTicks')
xlim([x_lim_range])
set(gcf, 'Position',  [-1500, -150, 900, 400])
% ylim([0 22])
hold off


%% Plotting Heating
if ~isempty(heat) && sum(heat) > 0
f5 = figure;

hold on
plot_data = [];
plot_data = e_adjust.*[var_boil.boil_fuel.*boil_legacy(2) ...
    var_boil.boil_rfuel.*boil_legacy(2) ...
    var_boil.boil_hfuel.*boil_legacy(2) ...
    var_ldg.hr_heat]./1000;
p4 = area(time,plot_data);
a4 = gca;
 a4.FontSize = 16;
 a4.YLabel.String = 'Heat (MW)';
 a4.YLabel.FontSize = 20;
a4.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
box on
grid on
legend('Boiler','Boiler - Biogas','Boiler - H_2','HRSG')
datetick('x','ddd','KeepTicks')
xlim([x_lim_range])
set(gcf, 'Position',  [-1500, -150, 900, 400])
ylim([0 15])
hold off
end
%% Plotting H2 Production
f6 = figure;

if ~exist('var_h2_inject')
    if  ~isfield('var_h2_inject','h2_inject')
        var_h2_inject.h2_inject = zeros(size(elec));
    end
end
hold on
plot_data = e_adjust.*[var_ldg.ldg_hfuel ...
    var_ldg.db_hfire ...
    var_boil.boil_hfuel ...
    var_h2es.h2es_chrg ...
    var_h2_inject.h2_inject]./1000;
p6 = area(time,plot_data);
a6 = gca;
a6.FontSize = 16;
a6.YLabel.String = 'H_2 Use (MW)';
a6.YLabel.FontSize = 20;
a6.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
box on
grid on
legend('GT','DB','Boiler','To Storage','To Pipeline')
datetick('x','ddd','KeepTicks')
xlim([x_lim_range])
set(gcf, 'Position',  [-1500, -150, 900, 400])
ylim([0 1.1*sum(max(plot_data))+1])
hold off