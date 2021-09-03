%% Utility EES Constraints
if ~isempty(util_ees_v)
    Constraints = [Constraints
            (var_util_ees.ees_soc(1,ii) <= var_util_ees.ees_soc(T,ii)):'Initial Utility EES SOC <= Final SOC'
            (var_util_ees.ees_soc(2:T,ii) == util_ees_v(10,ii)*var_util_ees.ees_soc(1:T-1,ii) + util_ees_v(8,ii)*var_util_ees.ees_chrg(2:T,ii)  - (1/util_ees_v(9,ii))*var_util_ees.ees_dchrg(2:T,ii)):'Utility EES Balance'  %%%Minus discharging of battery
            (util_ees_v(4,ii)*var_util_ees.ees_adopt(ii) <= var_util_ees.ees_soc(:,ii) <= util_ees_v(5,ii)*var_util_ees.ees_adopt(ii)):'Utility EES Min/Max SOC' %%%Min/Max SOC
            (var_util_ees.ees_chrg(:,ii) <= util_ees_v(6,ii)*var_util_ees.ees_adopt(ii)):'Utility EES Max Chrg'  %%%Max Charge Rate
            (var_util_ees.ees_dchrg(:,ii) <= util_ees_v(7,ii)*var_util_ees.ees_adopt(ii)):'Utility EES Max Dchrg']; %%%Max Discharge Rate
    
end