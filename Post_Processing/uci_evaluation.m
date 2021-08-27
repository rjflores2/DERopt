%% System Evaluation


%%% Solar PV
sum((var_pv.pv_adopt + pv_legacy(2)).*solar./e_adjust);
sum(var_pv.pv_elec);
%%% Energy Source
elec_frac = sum(var_util.import) + sum(var_pv.pv_elec ) + sum(var_ldg.ldg_elec) + sum(var_lbot.lbot_elec) ;
elec_frac = [sum(var_util.import) sum(var_pv.pv_elec ) sum(var_ldg.ldg_elec) sum(var_lbot.lbot_elec)]./elec_frac.*100;


%close all;


%% PV Production
% figure ;
% hold on;
% plot(time,(var_pv.pv_elec + var_pv.pv_nem +sum(var_rees.rees_chrg,2)).*e_adjust./1000,'LineWidth',2);
% plot(time,(var_pv.pv_elec + var_pv.pv_nem ).*e_adjust./1000,'LineWidth',2);
% plot(time,(var_pv.pv_elec).*e_adjust./1000,'LineWidth',2);
% % ylim([0 20])
% xlim([time(1) time(end)]);
% box on;
% hold off;


%% Loads
% figure
% hold on
% plot(time,(e_adjust).*(elec + el_eff.*var_el.el_prod + ),'LineWidth',2)
% plot(time,e_adjust.*elec,'LineWidth',2)
% hold off


% figure ;
% hold on;
% plot(time,(e_adjust).*(el_eff.*var_el.el_prod),'LineWidth',2);
% hold off;

%% Figure properties
xlim_range = [time(1) time(end)];
xlim_range = [737249 737256];
%% loads
%close all;
% f1 = figure;
% hold on;
% plot_data = e_adjust.*[elec ...
%     sum(var_rees.rees_chrg,2)...
%     sum(var_rsoc.rsoc_prod,2) ...
%     sum(h2_chrg_eff.*var_h2es.h2es_chrg,2) ...
%     ]./1000;
% p1 = area(time,plot_data);
% a1 = gca;
%    a1.FontSize = 16;
%    a1.YLabel.String = 'Loads (MWh)';
%    a1.YLabel.FontSize = 20;
% a1.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
% datetick('x','ddd','KeepTicks');
% xlim([xlim_range]);
% legend('Elec Load','REES Charging','RSOC Hydrogen Production','Hydrogen Energy Storage Charge');
% box on;
% grid on;
% hold off;
% title('70% CO2 Reduction Loads Profile');
% ylabel('Loads (MWh)');
%% Fuel input into the GT

% f2 = figure;
% hold on;
% plot_data = e_adjust.*[var_ldg.ldg_fuel ...
%     var_ldg.ldg_rfuel ...
%     var_ldg.ldg_hfuel]./1000;
% 
% p2 = area(time,plot_data);
% a2 = gca;
%  a2.FontSize = 16;
%  a2.YLabel.String = 'GT Fuel Input (MW)';
%  a2.YLabel.FontSize = 20;
% 
% a2.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
% datetick('x','ddd','KeepTicks');
% xlim([xlim_range]);
% box on;
% grid on;
% legend('NG','RNG','H_2');
% % a1.xtick = 1
% hold off;

%% Generation
% f3 = figure;
% hold on;
% plot_data = e_adjust.*[var_ldg.ldg_elec ...
%     var_lbot.lbot_elec ...
%     var_pv.pv_elec ...
%     var_rsoc.rsoc_elec...
%     var_rees.rees_dchrg ...
%     var_util.import]./1000;
% 
% % plot_data = e_adjust.*[var_ldg.ldg_elec ...
% %     var_lbot.lbot_elec ...
% %          var_rees.rees_dchrg... 
% %          var_pv.pv_elec]./1000;
% 
% p3 = area(time,plot_data);
% a3 = gca;
%  a3.FontSize = 16;
%  a3.YLabel.String = 'Electricity (MW)';
%  a3.YLabel.FontSize = 20;
% a3.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
% datetick('x','ddd','KeepTicks');
% xlim([xlim_range])
% box on;
% grid on;
% legend('GT','ST','PV','rSOC','REES','Import');
% % a1.xtick = 1
% set(gcf, 'Position',  [-0, -0, 700, 300]);
% hold off;
% title('70% CO2 Reduction Generation Profile in a Typical Summer Week');
%% Solar Operation
% f4 = figure;
% hold on;
% plot_data = e_adjust.*[var_pv.pv_elec ...
%     var_pv.pv_nem ...
%     sum(var_rees.rees_chrg,2)]./1000;
% 
% p4 = area(time,plot_data);
% plot(time,((sum(pv_legacy(2,:)))*solar + (sum(var_pv.pv_adopt))*solar)./1000,'Color',[0 0 0],'LineWidth',2);
% a4 = gca;
%  a4.FontSize = 16;
%  a4.YLabel.String = 'Solar Utilization (MW)';
%  a4.YLabel.FontSize = 20;
%     
% a4.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
% datetick('x','ddd','KeepTicks');
% xlim([xlim_range]);
% box on;
% grid on;
% legend('To Load','NEM','To REES','Solar Potential');
% % a1.xtick = 1
% hold off;

%% LEgacy Battery Operation
%close all
% f5 = figure;
% subplot(2,1,1);
% hold on;
% plot_data_1 = var_lees.ees_chrg.*e_adjust;
% plot_data_2 = -var_lees.ees_dchrg.*e_adjust;
% 
% p5_1 = area(time,plot_data_1);
% p5_2 = area(time,plot_data_2);
% a5 = gca;
%  a5.FontSize = 16;
%  a5.YLabel.String = 'Legacy EES Power (kW)';
%  a5.YLabel.FontSize = 20;
% a5.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
% a5.XTickLabels={};
% xlim([xlim_range]);
%     
% a5.XTick = [];
% box on;
% grid on;
% hold off;
% subplot(2,1,2);
% plot_data_1 = var_lees.ees_soc;
% p5_3 = area(time,plot_data_1);
% a5 = gca;
%  a5.FontSize = 16;
%  a5.YLabel.String = 'Legacy EES SOC (kWh)';
%  a5.YLabel.FontSize = 20;
% a5.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
% datetick('x','ddd','KeepTicks');
% xlim([xlim_range]);
% box on
% grid on
% 
% set(gcf, 'Position',  [-1500, -150, 1000, 750]);
%% CO2 production
co2_emissions = [sum(var_util.import.*co2_import)
 co2_ng*(sum(sum(var_ldg.ldg_fuel)) + sum(sum(var_ldg.db_fire)) + sum(sum(var_boil.boil_fuel)))
 co2_rng*(sum(sum(var_ldg.ldg_rfuel)) + sum(sum(var_ldg.db_rfire)) + sum(sum(var_boil.boil_rfuel)))];
 
 sum(co2_emissions)/3.7401e+07;
 
 %% Biogas use / fuel uses
 
% biogas_utilization = sum(var_ldg.ldg_rfuel  + var_boil.boil_rfuel + var_ldg.db_rfire)./(biogas_limit*(length(endpts)/12));
% 
% gt_fuel_source = sum([var_ldg.ldg_fuel ...
%     var_ldg.ldg_rfuel ...
%     var_ldg.ldg_hfuel])./sum(sum([var_ldg.ldg_fuel ...
%     var_ldg.ldg_rfuel ...
%     var_ldg.ldg_hfuel]));
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
    sum(var_ldg.ldg_hfuel,2)  sum(var_ldg.db_hfire,2)  sum(var_boil.boil_hfuel,2)  sum(var_h2es.h2es_chrg,2) sum(var_rsoc.rsoc_elec./rsoc_v(4),2)];

%% cyc Plots
% RSOC Hydrogen Production
figure;
plot(time, var_rsoc.rsoc_prod)
% Hydrogen Storage
% plot_data_3 = sum(var_h2es.h2es_soc,2).*e_adjust./1000;
% figure;
% plot(time, plot_data_3);
% a6 = gca;
%  a6.FontSize = 16;
%  a6.YLabel.String = 'Hydrogen Energy Storage (MWh)';
%  a6.YLabel.FontSize = 20;
% a6.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
% datetick('x','ddd','KeepTicks');
% box on;
% grid on;
% title('70% CO2 Reduction Hydrogen Storage in a Typical Summer Week');
% xlim([xlim_range]);

% Electrical Energy Storage
% plot_data_4 = sum(var_rees.rees_soc,2).*e_adjust./1000;
% figure;
% plot(time, plot_data_4);
% a7 = gca;
%  a7.FontSize = 16;
%  a7.YLabel.String = 'Electrical Energy Storage (MWh)';
%  a7.YLabel.FontSize = 20;
% a7.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
% datetick('x','ddd','KeepTicks');
% box on;
% grid on;
% title('70% CO2 Reduction Electrical Energy Storage in a Typical Summer Week');
% xlim([xlim_range]);

% RSOC fuel and elec Prod vs Time
% plot_data_3 = var_rsoc.rsoc_prod.*e_adjust;
% plot_data_4 = var_rsoc.rsoc_elec.*e_adjust;
% plot(time, plot_data_3)%var_rsoc.rsoc_prod)
% hold on;
% plot(time, plot_data_4);%var_rsoc.rsoc_elec)
% hold off;
% a6 = gca;
%  a6.FontSize = 16;
%  a6.YLabel.String = 'RSOC Production (MWh)';
%  a6.YLabel.FontSize = 20;
% a6.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
% datetick('x','ddd','KeepTicks')
% legend('Fuel Production','Electricity Production');
% xlabel('Time per year (Date)');
% title('RSOC Fuel and Electricity Production Daily Profile in 2018');
% sum(var_rsoc.rsoc_prod)
% sum(var_rsoc.rsoc_elec)

% p6_1 = area(time,plot_data_3)
% p6_2 = area(time,plot_data_4)
% a6 = gca
%  a6.FontSize = 16;
%  a6.YLabel.String = 'Legacy EES Power (kW)';
%  a6.YLabel.FontSize = 20;
% a6.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
% 
% a6.XTickLabels={};
% xlim([xlim_range])
% a6.XTick = [];
% 
% 
% box on
% grid on
% hold off
% plot_data_5 = var_lees.ees_soc;
% p6_3 = area(time,plot_data_5)
% a5 = gca
%  a5.FontSize = 16;
%  a5.YLabel.String = 'Legacy EES SOC (kWh)';
%  a5.YLabel.FontSize = 20;
% a5.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
% 
% set(gcf, 'Position',  [-1500, -150, 1000, 750])
