%% General equalities
%% Building Electrical Energy Balances
%%For each building k, all timesteps t
%Vectorized
Constraints = [Constraints
    (sum(var_util.import,2) + sum(var_pv.pv_elec,2) + sum(var_ees.ees_dchrg,2) + sum(var_rees.rees_dchrg,2) + sum(var_ldg.ldg_elec,2) + sum(var_lbot.lbot_elec,2) == elec + sum(var_ees.ees_chrg,2)):'BLDG Electricity Balance'];
