%%
Objective = value(Objective);

%% Solar Variables
var_pv.pv_adopt = value(var_pv.pv_adopt);
var_pv.pv_elec = value(var_pv.pv_elec);
var_pv.pv_nem = value(var_pv.pv_nem);

%% Electrical Energy Storage
var_ees.ees_adopt = value(var_ees.ees_adopt);
var_ees.ees_chrg = value(var_ees.ees_chrg);
var_ees.ees_dchrg = value(var_ees.ees_dchrg);
var_ees.ees_soc = value(var_ees.ees_soc);

%% H2 Production - Electrolyzer
var_el.el_adopt = value(var_el.el_adopt);
var_el.el_prod = value(var_el.el_prod);

%% H2 Production - Storage
var_h2es.h2es_adopt = value(var_h2es.h2es_adopt);
var_h2es.h2es_chrg = value(var_h2es.h2es_chrg);
var_h2es.h2es_dchrg = value(var_h2es.h2es_dchrg);
var_h2es.h2es_soc = value(var_h2es.h2es_soc);
var_h2es.h2es_bin = value(var_h2es.h2es_bin);

%% Legacy technologies %%
%% EES
if ~isempty(ees_legacy)
    var_lees.ees_chrg = value(var_lees.ees_chrg);
    var_lees.ees_dchrg = value(var_lees.ees_dchrg);
    var_lees.ees_soc = value(var_lees.ees_soc);
end

%% Legacy Diesel Generators
var_legacy_diesel.electricity = value(var_legacy_diesel.electricity);

%% Legacy Run of River
var_run_of_river.electricity = value(var_run_of_river.electricity);

%% Dump variables
var_dump.elec_dump = value(var_dump.elec_dump);