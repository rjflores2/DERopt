%% General equalities
%% Building Electrical Energy Balances
%%For each building k, all timesteps t
%Vectorized
Constraints = [Constraints
    (var_pv.pv_elec + var_lees.ees_dchrg + var_lrees.rees_dchrg == var_util.load_met + var_lees.ees_chrg):'BLDG Electricity Balance'];
