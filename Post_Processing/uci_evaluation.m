%% System Evaluation


%%% Solar PV
sum((var_pv.pv_adopt + pv_legacy(2)).*solar./e_adjust)
sum(var_pv.pv_elec)
%%% Energy Source
elec_frac = sum(var_util.import) + sum(var_pv.pv_elec ) + sum(var_ldg.ldg_elec) + sum(var_lbot.lbot_elec) ;
elec_frac = [sum(var_util.import) sum(var_pv.pv_elec ) sum(var_ldg.ldg_elec) sum(var_lbot.lbot_elec)]./elec_frac.*100


close all


%% PV Production
figure 
hold on
plot(time,(var_pv.pv_elec + var_pv.pv_nem +sum(var_rees.rees_chrg,2)).*e_adjust./1000,'LineWidth',2)
plot(time,(var_pv.pv_elec + var_pv.pv_nem ).*e_adjust./1000,'LineWidth',2)
plot(time,(var_pv.pv_elec).*e_adjust./1000,'LineWidth',2)
% ylim([0 20])
xlim([time(1) time(end)])
box on
hold off


%% Loads
% figure
% hold on
% plot(time,(e_adjust).*(elec + el_eff.*var_el.el_prod + ),'LineWidth',2)
% plot(time,e_adjust.*elec,'LineWidth',2)
% hold off


figure 
hold on
plot(time,(e_adjust).*(el_eff.*var_el.el_prod),'LineWidth',2)
hold off

%% Figure properties
xlim_range = [time(1) time(end)];
xlim_range = [737249 737256];
%% loads
close all
f1 = figure;
hold on
plot_data = e_adjust.*[elec ...
    sum(var_ees.ees_chrg,2)...
    sum(el_eff.*var_el.el_prod,2) ...
    sum(h2_chrg_eff.*var_h2es.h2es_chrg,2) ...
    var_dump.elec_dump
    ]./1000;
p1 = area(time,plot_data);
a1 = gca
a1.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
datetick('x','ddd','KeepTicks')
xlim([xlim_range])
legend('Elec Load','EES Charging','Electrolyzer','H_2 Storage Compression','Dump')
box on
grid on
hold off
%% Fuel input into the GT

f2 = figure
hold on
plot_data = e_adjust.*[var_ldg.ldg_fuel ...
    var_ldg.ldg_rfuel ...
    var_ldg.ldg_hfuel]./1000;

p2 = area(time,plot_data)
a2 = gca
 a2.FontSize = 16;
 a2.YLabel.String = 'GT Fuel Input (MW)';
 a2.YLabel.FontSize = 20;

a2.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
datetick('x','ddd','KeepTicks')
xlim([xlim_range])
box on
grid on
legend('NG','RNG','H_2')
% a1.xtick = 1
hold off

%% Generation
f3 = figure
hold on
plot_data = e_adjust.*[var_ldg.ldg_elec ...
    var_lbot.lbot_elec ...
    var_pv.pv_elec ...
    var_rsoc.rsoc_elec...
    var_ees.ees_dchrg ...
    var_rees.rees_dchrg ...
    var_util.import]./1000;

% plot_data = e_adjust.*[var_ldg.ldg_elec ...
%     var_lbot.lbot_elec ...
%          var_rees.rees_dchrg... 
%          var_pv.pv_elec]./1000;

p3 = area(time,plot_data)
a3 = gca
 a3.FontSize = 16;
 a3.YLabel.String = 'Electricity (MW)';
 a3.YLabel.FontSize = 20;
a3.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
datetick('x','ddd','KeepTicks')
% xlim([xlim_range])
box on
grid on
legend('GT','ST','PV','rSOC')
% a1.xtick = 1
set(gcf, 'Position',  [-0, -0, 700, 300])
hold off

%% Solar Operation
f4 = figure
hold on
plot_data = e_adjust.*[var_pv.pv_elec ...
    var_pv.pv_nem ...
    sum(var_rees.rees_chrg,2)]./1000;

p4 = area(time,plot_data)
plot(time,((sum(pv_legacy(2,:)))*solar + (sum(var_pv.pv_adopt))*solar)./1000,'Color',[0 0 0],'LineWidth',2)
a4 = gca
 a4.FontSize = 16;
 a4.YLabel.String = 'Solar Utilization (MW)';
 a4.YLabel.FontSize = 20;
    
a4.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
datetick('x','ddd','KeepTicks')
xlim([xlim_range])
box on
grid on
legend('To Load','NEM','To REES','Solar Potential')
% a1.xtick = 1
hold off

%% LEgacy Battery Operation
%close all
f5 = figure
subplot(2,1,1)
hold on
plot_data_1 = var_lees.ees_chrg.*e_adjust;
plot_data_2 = -var_lees.ees_dchrg.*e_adjust;

p5_1 = area(time,plot_data_1)
p5_2 = area(time,plot_data_2)
a5 = gca
 a5.FontSize = 16;
 a5.YLabel.String = 'Legacy EES Power (kW)';
 a5.YLabel.FontSize = 20;
a5.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
a5.XTickLabels={};
xlim([xlim_range])
    
a5.XTick = [];
box on
grid on
hold off
subplot(2,1,2)
plot_data_1 = var_lees.ees_soc;
p5_3 = area(time,plot_data_1)
a5 = gca
 a5.FontSize = 16;
 a5.YLabel.String = 'Legacy EES SOC (kWh)';
 a5.YLabel.FontSize = 20;
a5.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
datetick('x','ddd','KeepTicks')
xlim([xlim_range])
box on
grid on

set(gcf, 'Position',  [-1500, -150, 1000, 750])
%% CO2 production
co2_emissions = [sum(var_util.import.*co2_import)
 co2_ng*(sum(sum(var_ldg.ldg_fuel)) + sum(sum(var_ldg.db_fire)) + sum(sum(var_boil.boil_fuel)))
 co2_rng*(sum(sum(var_ldg.ldg_rfuel)) + sum(sum(var_ldg.db_rfire)) + sum(sum(var_boil.boil_rfuel)))]
 
 sum(co2_emissions)/3.7401e+07
 
 %% Biogas use / fuel uses
 
biogas_utilization = sum(var_ldg.ldg_rfuel  + var_boil.boil_rfuel + var_ldg.db_rfire)./(biogas_limit*(length(endpts)/12))

gt_fuel_source = sum([var_ldg.ldg_fuel ...
    var_ldg.ldg_rfuel ...
    var_ldg.ldg_hfuel])./sum(sum([var_ldg.ldg_fuel ...
    var_ldg.ldg_rfuel ...
    var_ldg.ldg_hfuel]))
%% Adopted technologies

adopted.pv = var_pv.pv_adopt;
adopted.ees = var_ees.ees_adopt;
adopted.rees =var_rees.rees_adopt;
adopted.el = var_el.el_adopt;
adopted.rel = var_rel.rel_adopt;
adopted.h2es = var_h2es.h2es_adopt;
adopted.rsoc = var_rsoc.rsoc_adopt;
adopted


%% H2 Energy Balance
h2_e_balance = [sum(var_el.el_prod,2) sum(var_el.el_prod,2)  sum(var_h2es.h2es_dchrg,2) sum(var_rsoc.rsoc_prod,2) ...
    sum(var_ldg.ldg_hfuel,2)  sum(var_ldg.db_hfire,2)  sum(var_boil.boil_hfuel,2)  sum(var_h2es.h2es_chrg,2) sum(rsoc_v(3).*var_rsoc.rsoc_elec,2)];

%% rSOC Operation
rSOC_ops = [var_rsoc.rsoc_prod var_rsoc.rsoc_elec]; 
rsoc_double_duty = find(rSOC_ops(:,1)>0 & rSOC_ops(:,2)>0)