%% Utility values
var_util.import = value(var_util.import);
var_util.export = value(var_util.export);
% var_util.net_flow = value(var_util.net_flow);
var_util.nontou_dc = value(var_util.nontou_dc);
var_util.onpeak_dc = value(var_util.onpeak_dc);
var_util.midpeak_dc = value(var_util.midpeak_dc);

%% Solar PV values
var_pv.pv_elec = value(var_pv.pv_elec);
var_pv.pv_adopt = value(var_pv.pv_adopt);
var_somah.somah_capacity = value(var_somah.somah_capacity);

%% dgb Values
var_dgb.dgb_adopt = value(var_dgb.dgb_adopt);
var_dgb.dgb_capacity = value(var_dgb.dgb_capacity);
var_dgb.dgb_elec = value(var_dgb.dgb_elec);
var_dgb.dgb_fuel = value(var_dgb.dgb_fuel);

%% dgc Values
var_dgc.dgc_adopt = value(var_dgc.dgc_adopt);
var_dgc.dgc_elec = value(var_dgc.dgc_elec);
var_dgc.dgc_fuel = value(var_dgc.dgc_fuel);
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

%% Legacy REES Value
var_lrees.rees_chrg = value(var_lrees.rees_chrg);
var_lrees.rees_dchrg = value(var_lrees.rees_dchrg);
var_lrees.rees_soc = value(var_lrees.rees_soc);
%% DGL
if dgl_on
    var_dgl.dg_capacity = value(var_dgl.dg_capacity);
    var_dgl.dg_elec = value(var_dgl.dg_elec);
end

%% H2 storage
if h2_storage_on
    var_h2_storage.capacity = value(var_h2_storage.capacity);
    if ~h2_systems_for_resiliency_only
        var_h2_storage.soc = value(var_h2_storage.soc);
        var_h2_storage.charge = value(var_h2_storage.charge);
        var_h2_storage.dicharge = value(var_h2_storage.dicharge);
        var_h2_storage.vent = value(var_h2_storage.vent);
    end
end

%% Resiliency Values
if ~isempty(crit_load_lvl) && crit_load_lvl >0
    var_resiliency.pv_elec =value( var_resiliency.pv_elec);
    var_resiliency.dg_elec = value(var_resiliency.dg_elec);
%     var_resiliency.dgb_real = value(var_resiliency.dgb_real);
%     var_resiliency.dgb_reactive = value(var_resiliency.dgb_reactive);
%     var_resiliency.dgc_elec = value(var_resiliency.dgc_elec);
%     var_resiliency.dgc_real = value(var_resiliency.dgc_real);
%     var_resiliency.dgc_reactive = value(var_resiliency.dgc_reactive);
    var_resiliency.ees_chrg = value(var_resiliency.ees_chrg);
    var_resiliency.ees_dchrg = value(var_resiliency.ees_dchrg);
    var_resiliency.ees_soc = value(var_resiliency.ees_soc);
%     var_resiliency.import = value(var_resiliency.import);
%     var_resiliency.export = value(var_resiliency.export);
%     var_resiliency.Pinj = value(var_resiliency.Pinj);
%     var_resiliency.Qinj = value(var_resiliency.Qinj);
%     var_resiliency.pflow = value(var_resiliency.pflow);
%     var_resiliency.qflow = value(var_resiliency.qflow);
%     var_resiliency.bus_voltage = value(var_resiliency.bus_voltage);
%     var_resiliency.pv_real = value(var_resiliency.pv_real);
%     var_resiliency.pv_reactive = value(var_resiliency.pv_reactive);
%     var_resiliency.ees_dchrg_real = value(var_resiliency.ees_dchrg_real);
%     var_resiliency.ees_dchrg_reactive = value(var_resiliency.ees_dchrg_reactive);
%     var_resiliency.import_reactive = value(var_resiliency.import_reactive);
%     var_resiliency.export_reactive = value(var_resiliency.export_reactive);
%     var_resiliency.h2_delivery = value(var_resiliency.h2_delivery);
%     var_resiliency.h2_storage = value(var_resiliency.h2_storage);
%     
%     
if h2_storage_on
var_resiliency.h2_soc = value(var_resiliency.h2_soc);
var_resiliency.h2_charge = value(var_resiliency.h2_charge);
var_resiliency.h2_discharge = value(var_resiliency.h2_discharge);
end
if opt_resiliency_model > 1
    var_resiliency.import = value(var_resiliency.import);
    var_resiliency.export = value(var_resiliency.export);
end
% var_resiliency.h2_vent = value(var_resiliency.h2_vent);
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
