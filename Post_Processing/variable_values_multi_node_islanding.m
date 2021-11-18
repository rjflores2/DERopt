%% Utility values - Loads Met
var_util.load_met = value(var_util.load_met);

%% Solar PV values
var_pv.pv_elec = value(var_pv.pv_elec);

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

 
 %% Transformer Values
 var_xfmr.Pinj = value(var_xfmr.Pinj);
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
