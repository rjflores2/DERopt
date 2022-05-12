%% General equalities
%% Building Electrical Energy Balances
%%For each building k, all timesteps t
%Vectorized
if ~isempty(elec)
    Constraints = [Constraints
        (var_util.import + var_pv.pv_elec + var_ees.ees_dchrg + var_lees.ees_dchrg + var_rees.rees_dchrg + var_lrees.rees_dchrg + var_sofc.sofc_elec == elec + var_ees.ees_chrg + var_lees.ees_chrg + var_erwh.erwh_elec + var_ersph.ersph_elec):'BLDG Electricity Balance'];
end

%% Building Hot water Balances
%For each building k, all timesteps t
if ~isempty(hotwater)
    Constraints = [Constraints
        (var_erwh.erwh_elec.*erwh_v(2) + var_gwh.gwh_gas.*gwh_v(2) + var_sofc.sofc_wh == hotwater):'BLDG HotWater Balance'];
end

%% Building Heat Balances
%For each building k, all timesteps t
if ~isempty(heat)
    Constraints = [Constraints
        (var_gsph.gsph_gas.*gsph_v(2) + var_ersph.ersph_elec.*ersph_v(2) == heat):'BLDG Heat Balance'];
end