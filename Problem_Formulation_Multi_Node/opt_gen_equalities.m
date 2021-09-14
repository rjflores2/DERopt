%% General equalities
%% Building Electrical Energy Balances
%%For each building k, all timesteps t
%Vectorized
Constraints = [Constraints
    (var_util.import + var_pv.pv_elec + var_ees.ees_dchrg + var_lees.ees_dchrg + var_rees.rees_dchrg + var_lrees.rees_dchrg == elec + var_ees.ees_chrg + var_lees.ees_chrg):'BLDG Electricity Balance'];
