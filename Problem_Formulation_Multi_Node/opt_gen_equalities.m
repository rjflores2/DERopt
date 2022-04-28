%% General equalities
%% Building Electrical Energy Balances
%%For each building k, all timesteps t
%Vectorized
Constraints = [Constraints
    (var_util.import + var_pv.pv_elec + var_ees.ees_dchrg + var_lees.ees_dchrg + var_rees.rees_dchrg + var_lrees.rees_dchrg + var_sofc.sofc_elec == elec + var_ees.ees_chrg + var_lees.ees_chrg + var_erwh.erwh_elec):'BLDG Electricity Balance'];


%% Building Hot water Balances
%For each building k, all timesteps t
if gwh_on && erwh_on ==1
Constraints = [Constraints
    (var_erwh.erwh_heat + var_gwh.gwh_heat == hotwater):'BLDG HotWater Balance'];
   
end