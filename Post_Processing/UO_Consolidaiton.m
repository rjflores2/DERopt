for ii = 1:lenght(bldg)
    
    if size(elec,1) == 8760
        bldg(ii).der.pv_capacity = pv_legacy_cap(ii); %kW
        bldg(ii).der.ees_capacity = ees_legacy_cap(ii); %kWh
        bldg(ii).der.rees_capacity = rees_legacy_cap(ii); %kWh
        
        bldg(ii).der.tech_specs.pv = pv_v;
        bldg(ii).der.tech_specs.ees = ees_v;
        
        bldg(ii).der.costs.pv_mod = pv_cap_mod(ii);
        bldg(ii).der.costs.ees_mod = ees_cap_mod(ii);
        bldg(ii).der.costs.rees_mod = rees_cap_mod(ii);
    else
        bldg(ii).der.ops.utility_import = var_util.import(ii,:);
        bldg(ii).der.ops.pv_elec = var_pv.pv_elec(ii,:);
        bldg(ii).der.ops.pv_nem = var_pv.pv_nem(ii,:);
        bldg(ii).der.ops.rees_soc = var_lrees.rees_soc(ii,:);
        bldg(ii).der.ops.rees_dchrg = var_lrees.rees_dchrg(ii,:);
        bldg(ii).der.ops.rees_chrg = var_lrees.rees_chrg(ii,:);
        bldg(ii).der.ops.rees_dchrg_nem = var_lrees.rees_dchrg_nem(ii,:);
        bldg(ii).der.ops.ees_soc = var_lees.rees_soc(ii,:);
        bldg(ii).der.ops.ees_dchrg = var_lees.rees_dchrg(ii,:);
        bldg(ii).der.ops.ees_chrg = var_lees.rees_chrg(ii,:);
        bldg(ii).der.ops.ees_dchrg_nem = var_lees.rees_dchrg_nem(ii,:);
    end
end

