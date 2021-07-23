%% System Evaluation


%%% Solar PV
sum((var_pv.pv_adopt + pv_legacy(2)).*solar./e_adjust)
sum(var_pv.pv_elec)
%%% Energy Source
elec_frac = sum(var_util.import) + sum(var_pv.pv_elec ) + sum(var_ldg.ldg_elec) + sum(var_lbot.lbot_elec) ;
elec_frac = [sum(var_util.import) sum(var_pv.pv_elec ) sum(var_ldg.ldg_elec) sum(var_lbot.lbot_elec)]./elec_frac.*100


close all

%% Gas turbine/NGCC Operation
figure 
hold on
plot(time,(var_ldg.ldg_elec + var_lbot.lbot_elec).*e_adjust./1000,'LineWidth',2)
plot(time,var_ldg.ldg_elec.*e_adjust./1000,'LineWidth',2)
plot(time,var_lbot.lbot_elec.*e_adjust./1000,'LineWidth',2)
ylim([0 20])
xlim([time(1) time(end)])
box on
hold off

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

%% Elec Generation
figure
hold on
plot(time,(var_pv.pv_elec + var_ldg.ldg_elec + var_lbot.lbot_elec).*e_adjust,'LineWidth',2)
plot(time,(var_ldg.ldg_elec + var_lbot.lbot_elec).*e_adjust,'LineWidth',2)
plot(time,var_ldg.ldg_elec.*e_adjust,'LineWidth',2)
plot(time,e_adjust.*elec,'-.','LineWidth',1)
hold off


%% Loads
figure
hold on
plot(time,(e_adjust).*(elec + el_eff.*var_el.el_prod),'LineWidth',2)
plot(time,e_adjust.*elec,'LineWidth',2)
hold off


figure 
hold on
plot(time,(e_adjust).*(el_eff.*var_el.el_prod),'LineWidth',2)
hold off