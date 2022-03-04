%% Utility values
var_util.import = value(var_util.import);
var_util.nontou_dc = value(var_util.nontou_dc);
var_util.onpeak_dc = value(var_util.onpeak_dc);
var_util.midpeak_dc = value(var_util.midpeak_dc);

%% Solar PV values
var_pv.pv_elec = value(var_pv.pv_elec);
var_pv.pv_adopt = value(var_pv.pv_adopt);
var_pv.pv_nem = value(var_pv.pv_nem);
%     pv_wholesale = value(pv_wholesale);

%% EES Values
var_ees.ees_adopt = value(var_ees.ees_adopt);
var_ees.ees_soc = value(var_ees.ees_soc);
var_ees.ees_chrg = value(var_ees.ees_chrg);
var_ees.ees_dchrg = value(var_ees.ees_dchrg);

%% Legacy EES Values
var_lees.ees_chrg = value(var_lees.ees_chrg);
var_lees.ees_dchrg = value(var_lees.ees_dchrg);
var_lees.ees_soc = value(var_lees.ees_soc);

%% REES Values
var_rees.rees_adopt = value(var_rees.rees_adopt);
var_rees.rees_soc = value(var_rees.rees_soc);
var_rees.rees_chrg = value(var_rees.rees_chrg);
var_rees.rees_dchrg = value(var_rees.rees_dchrg);
var_rees.rees_dchrg_nem = value(var_rees.rees_dchrg_nem);

%% Legacy REES Value
var_lrees.rees_chrg = value(var_lrees.rees_chrg);
var_lrees.rees_dchrg = value(var_lrees.rees_dchrg);
var_lrees.rees_soc = value(var_lrees.rees_soc);
var_lrees.rees_dchrg_nem = value(var_lrees.rees_dchrg_nem);

%% Resiliency Values
if ~isempty(crit_load_lvl) && crit_load_lvl >0
 var_resiliency.pv_elec =value( var_resiliency.pv_elec );
 var_resiliency.ees_chrg = value(var_resiliency.ees_chrg);
 var_resiliency.ees_dchrg = value(var_resiliency.ees_dchrg);
 var_resiliency.ees_soc = value(var_resiliency.ees_soc);
 var_resiliency.import = value(var_resiliency.import);
 var_resiliency.export = value(var_resiliency.export);
 var_resiliency.Pinj = value(var_resiliency.Pinj);
 var_resiliency.Qinj = value(var_resiliency.Qinj);
 var_resiliency.pflow = value(var_resiliency.pflow);
 var_resiliency.qflow = value(var_resiliency.qflow);
 var_resiliency.bus_voltage = value(var_resiliency.bus_voltage);
 var_resiliency.pv_real = value(var_resiliency.pv_real);
 var_resiliency.pv_reactive = value(var_resiliency.pv_reactive);
 var_resiliency.ees_dchrg_real = value(var_resiliency.ees_dchrg_real);
 var_resiliency.ees_dchrg_reactive = value(var_resiliency.ees_dchrg_reactive);
 var_resiliency.import_reactive = value(var_resiliency.import_reactive);
 var_resiliency.export_reactive = value(var_resiliency.export_reactive);
end
 %% Transformer Values
 var_xfmr.Pinj = value(var_xfmr.Pinj);
 %% LinDistFlow Values
 var_ldf.pflow = value(var_ldf.pflow);
%% SGIP values
if ~isempty(var_sgip.sgip_ees_pbi)
    var_sgip.sgip_ees_pbi = value(var_sgip.sgip_ees_pbi);
else
    var_sgip.sgip_ees_pbi = [0;0;0];
end

if ~isempty(var_sgip.sgip_ees_npbi)
    var_sgip.sgip_ees_npbi = value(var_sgip.sgip_ees_npbi);
else
    var_sgip.sgip_ees_npbi = 0;
end

if ~isempty(var_sgip.sgip_ees_npbi_equity)
    var_sgip.sgip_ees_npbi_equity = value(var_sgip.sgip_ees_npbi_equity);
else
    var_sgip.sgip_ees_npbi_equity=0;
end
