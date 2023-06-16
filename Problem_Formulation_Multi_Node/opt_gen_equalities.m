%% General equalities
%% Building Electrical Energy Balances
%%For each building k, all timesteps t
%Vectorized
Constraints = [Constraints
    (var_util.import + var_pv.pv_elec + var_ees.ees_dchrg + var_lees.ees_dchrg + var_rees.rees_dchrg + var_lrees.rees_dchrg + var_sofc.sofc_elec + var_dgb.dgb_elec + var_dgc.dgc_elec == elec + var_ees.ees_chrg + var_lees.ees_chrg):'BLDG Electricity Balance'];
