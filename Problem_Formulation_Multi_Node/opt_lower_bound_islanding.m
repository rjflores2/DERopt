%%% Lower Bounds
%% Utility Variables
Constraints = [Constraints
    (0 <= var_util.load_met):'Load Met >= 0'];

%% Legacy PV
%%%Only need to add variables if new PV is not considered
if isempty(pv_legacy) == 0 && isempty(pv_v) == 1
    Constraints = [Constraints
        (0 <= var_pv.pv_elec):'LPV production >= 0'];
end
%% Legacy EES
if lees_on
     Constraints = [Constraints
        (0 <= var_lees.ees_chrg):'LEES Charging >= 0'
        (0 <= var_lees.ees_dchrg):'LEES Discharging >= 0'
        (0 <= var_lees.ees_soc):'LEES SOC >= 0'];
end
%% Legacy REES
if lrees_on
     Constraints = [Constraints
        (0 <= var_lrees.rees_chrg):'LREES Charging >= 0'
        (0 <= var_lrees.rees_dchrg):'LREES Discharging >= 0'
        (0 <= var_lrees.rees_soc):'LREES SOC >= 0'];
end