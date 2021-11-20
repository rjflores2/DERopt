%%
Objective = value(Objective);

%% Energy Market Sales
var_sales.wholesale_import = value(var_sales.wholesale_import);
var_sales.wholesale_export = value(var_sales.wholesale_export);

%% DG - Topping Cycle
var_ldg.ldg_elec = value(var_ldg.ldg_elec);
var_ldg.ldg_fuel = value(var_ldg.ldg_fuel);
var_ldg.ldg_rfuel = value(var_ldg.ldg_rfuel);
var_ldg.ldg_hfuel = value(var_ldg.ldg_hfuel);
var_ldg.ldg_elec_ramp = value(var_ldg.ldg_elec_ramp);
var_ldg.ldg_start = value(var_ldg.ldg_start);
var_ldg.ldg_onoff = value(var_ldg.ldg_onoff);


%% Heat Recovery Systems
var_ldg.db_fire = value(var_ldg.db_fire);
var_ldg.db_rfire = value(var_ldg.db_rfire);
var_ldg.db_hfire = value(var_ldg.db_hfire);
%% Bottoming Cycle
var_lbot.lbot_elec = value(var_lbot.lbot_elec);
var_lbot.lbot_on = value(var_lbot.lbot_on);
% %% Utility Variables
% var_util.import = value(var_util.import);
% var_util.nontou_dc = value(var_util.nontou_dc);
% var_util.onpeak_dc = value(var_util.onpeak_dc);
% var_util.midpeak_dc = value(var_util.midpeak_dc);
% var_util.gen_export = value(var_util.gen_export);
% %% Solar Variables
% var_pv.pv_adopt = value(var_pv.pv_adopt);
% var_pv.pv_elec = value(var_pv.pv_elec);
% var_pv.pv_nem = value(var_pv.pv_nem);
% 
% %% Power Plant Energy Trading
% var_pp.pp_elec_export = value(var_pp.pp_elec_export);
% var_pp.pp_elec_import = value(var_pp.pp_elec_import);
% var_pp.pp_elec_wheel = value(var_pp.pp_elec_wheel);
% var_pp.pp_elec_wheel_lts = value(var_pp.pp_elec_wheel_lts);
% var_pp.import_state = value(var_pp.import_state);
% 
% %% Utility Solar Variables
% var_utilpv.util_pv_adopt = value(var_utilpv.util_pv_adopt);
% var_utilpv.util_pv_elec = value(var_utilpv.util_pv_elec);
% 
% %% Utility Battery Storage
% var_util_ees.ees_adopt = value(var_util_ees.ees_adopt);
% var_util_ees.ees_soc = value(var_util_ees.ees_soc);
% var_util_ees.ees_chrg = value(var_util_ees.ees_chrg);
% var_util_ees.ees_dchrg = value(var_util_ees.ees_dchrg);
% 
% %% Renewable Electrical Energy Storage
% var_rees.rees_adopt = value(var_rees.rees_adopt);
% var_rees.rees_chrg = value(var_rees.rees_chrg);
% var_rees.rees_dchrg = value(var_rees.rees_dchrg);
% var_rees.rees_soc = value(var_rees.rees_soc);
% var_rees.rees_dchrg_nem = value(var_rees.rees_dchrg_nem);
% 
% %% Electrical Energy Storage
% var_ees.ees_adopt = value(var_ees.ees_adopt);
% var_ees.ees_chrg = value(var_ees.ees_chrg);
% var_ees.ees_dchrg = value(var_ees.ees_dchrg);
% var_ees.ees_soc = value(var_ees.ees_soc);
% 
% %% H2 Production - Electrolyzer
% var_el.el_adopt = value(var_el.el_adopt);
% var_el.el_prod = value(var_el.el_prod);
% 
% %% H2 Production - Renewable Electrolyzer
% var_rel.rel_adopt = value(var_rel.rel_adopt);
% var_rel.rel_prod = value(var_rel.rel_prod);
% var_rel.rel_prod_wheel = value(var_rel.rel_prod_wheel);
% 
% %% H2 Production - Storage
% var_h2es.h2es_adopt = value(var_h2es.h2es_adopt);
% var_h2es.h2es_chrg = value(var_h2es.h2es_chrg);
% var_h2es.h2es_dchrg = value(var_h2es.h2es_dchrg);
% var_h2es.h2es_soc = value(var_h2es.h2es_soc);
% 
% %% HRS Station
% var_hrs.hrs_supply_adopt = value(var_hrs.hrs_supply_adopt);
% var_hrs.hrs_tube = value(var_hrs.hrs_tube);
% var_hrs.hrs_supply = value(var_hrs.hrs_supply);
% var_hrs.hrs_supply = value(var_hrs.hrs_supply);
% 
% %% H2 Pipeline Injection
% var_h2_inject.h2_inject_adopt = value(var_h2_inject.h2_inject_adopt);
% var_h2_inject.h2_inject_size = value(var_h2_inject.h2_inject_size);
% var_h2_inject.h2_inject = value(var_h2_inject.h2_inject);
% var_h2_inject.h2_store = value(var_h2_inject.h2_store);
% 
% 
% %% Boiler
% var_boil.boil_fuel = value(var_boil.boil_fuel);
% var_boil.boil_rfuel = value(var_boil.boil_rfuel);
% var_boil.boil_hfuel = value(var_boil.boil_hfuel);
% 
% %% EES
% if ~isempty(ees_legacy)
%     var_lees.ees_chrg = value(var_lees.ees_chrg);
%     var_lees.ees_dchrg = value(var_lees.ees_dchrg);
%     var_lees.ees_soc = value(var_lees.ees_soc);
% end
% %% Chillers
% var_lvc.lvc_cool = value(var_lvc.lvc_cool);
% var_lvc.lvc_op = value(var_lvc.lvc_op);
% 
% %% Dump variables
% var_dump.elec_dump = value(var_dump.elec_dump);