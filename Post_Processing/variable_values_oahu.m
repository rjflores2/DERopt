%%
Objective = value(Objective);

%% Solar Variables
var_pv.pv_adopt = value(var_pv.pv_adopt);
var_pv.pv_elec = value(var_pv.pv_elec);

%% Electrical Energy Storage
var_ees.ees_adopt = value(var_ees.ees_adopt);
var_ees.ees_chrg = value(var_ees.ees_chrg);
var_ees.ees_dchrg = value(var_ees.ees_dchrg);
var_ees.ees_soc = value(var_ees.ees_soc);

%% H2 Production - Electrolyzer
var_el.el_adopt = value(var_el.el_adopt);
var_el.el_prod = value(var_el.el_prod);

%% H2 Production  Electrolyzer Binary
if ~isempty(el_binary_v)
    var_el_binary.el_adopt = value(var_el_binary.el_adopt);
    var_el_binary.el_prod  = value(var_el_binary.el_prod );
    var_el_binary.el_onoff  = value(var_el_binary.el_onoff);
end
%% H2 Production - Storage
if h2es_on
    var_h2es.h2es_adopt = value(var_h2es.h2es_adopt);
    var_h2es.h2es_chrg = value(var_h2es.h2es_chrg);
    var_h2es.h2es_dchrg = value(var_h2es.h2es_dchrg);
    var_h2es.h2es_soc = value(var_h2es.h2es_soc);
    var_h2es.h2es_bin = value(var_h2es.h2es_bin);
end
if pemfc_on
    var_pem.cap = value(var_pem.cap);
    var_pem.elec = value(var_pem.elec);
    if pem_v(4)>0
        var_pem.onoff = value(var_pem.onoff);
    end
end
%% Legacy technologies %%
%% EES
if ~isempty(ees_legacy)
    var_lees.ees_chrg = value(var_lees.ees_chrg);
    var_lees.ees_dchrg = value(var_lees.ees_dchrg);
    var_lees.ees_soc = value(var_lees.ees_soc);
end

%% Legacy Diesel Generators
var_legacy_diesel.electricity = value(var_legacy_diesel.electricity);

%% Legacy Diesel Binary Diesel Generators
var_legacy_diesel_binary.electricity  = value(var_legacy_diesel_binary.electricity );
var_legacy_diesel_binary.operational_state = value(var_legacy_diesel_binary.operational_state);
%% Legacy Run of River
if lror_on
    var_run_of_river.electricity = value(var_run_of_river.electricity)
    var_run_of_river.swept_area = value(var_run_of_river.swept_area);
end
%% New Integer Run of River
if exist('ror_integer_on') && ror_integer_on
    var_ror_integer.units = value(var_ror_integer.units);
    var_ror_integer.elec = value(var_ror_integer.elec);
end
%% wave power
if exist('wave_on') && wave_on
    var_wave.electricity = value(var_wave.electricity);
    var_wave.power = value(var_wave.power);
end

%% Dump variables
var_dump.elec_dump = value(var_dump.elec_dump);
