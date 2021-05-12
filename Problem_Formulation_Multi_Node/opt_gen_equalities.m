%% General equalities
%% Building Electrical Energy Balances
%%For each building k, all timesteps t
%Vectorized
Constraints = [Constraints
    (import + pv_elec + ees_dchrg + rees_dchrg + ldg_elec == elec + ees_chrg):'BLDG Electricity Balance'];
