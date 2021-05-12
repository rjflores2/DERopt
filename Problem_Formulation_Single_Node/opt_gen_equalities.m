%% General equalities
%% Building Electrical Energy Balances
%%For  all timesteps t
%Vectorized
Constraints = [Constraints
    (sum(var_util.import,2) + sum(var_pv.pv_elec,2) + sum(var_ees.ees_dchrg,2) + sum(var_rees.rees_dchrg,2) + sum(var_ldg.ldg_elec,2) + sum(var_lbot.lbot_elec,2) == elec + sum(var_ees.ees_chrg,2)):'BLDG Electricity Balance'];

%% Building energy balance

if ~isempty(heat) && sum(heat>0)>0
    Constraints = [Constraints
        (var_boil.boil_rfuel + var_boil.boil_fuel).*boil_legacy(2) + var_ldg.hr_heat == heat];
end