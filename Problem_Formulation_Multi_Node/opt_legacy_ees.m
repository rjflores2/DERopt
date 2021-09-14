if lees_on
    for k = 1:K
        %%%SOC Equality / Energy Balance
        Constraints = [Constraints
            var_lees.ees_soc(2:T,k) == ees_legacy(9)*var_lees.ees_soc(1:T-1,k) + ees_legacy(7)*var_lees.ees_chrg(2:T,k)  - (1/ees_legacy(8))*var_lees.ees_dchrg(2:T,k)  %%%Minus discharging of battery
            ees_legacy(3)*ees_legacy_cap(k) <= var_lees.ees_soc(:,k) <= ees_legacy(4)*ees_legacy_cap(k) %%%Min/Max SOC
            var_lees.ees_chrg(:,k) <= ees_legacy(5)*ees_legacy_cap(k) %%%Max Charge Rate
            var_lees.ees_dchrg(:,k) <= ees_legacy(6)*ees_legacy_cap(k)]; %%%Max Discharge Rate
        
        
    end
end

if lrees_on
    for k = 1:K
        %%%SOC Equality / Energy Balance
        Constraints = [Constraints
            var_lrees.rees_soc(2:T,k) == rees_legacy(9)*var_lrees.rees_soc(1:T-1,k) + rees_legacy(7)*var_lrees.rees_chrg(2:T,k)  - (1/rees_legacy(8))*(var_lrees.rees_dchrg(2:T,k) + var_lrees.rees_dchrg_nem(2:T,k))  %%%Minus discharging of battery
            rees_legacy(3)*rees_legacy_cap(k) <= var_lrees.rees_soc(:,k) <= rees_legacy(4)*rees_legacy_cap(k) %%%Min/Max SOC
            var_lrees.rees_chrg(:,k) <= rees_legacy(5)*rees_legacy_cap(k) %%%Max Charge Rate
            var_lrees.rees_dchrg(:,k) + var_lrees.rees_dchrg_nem(:,k) <= rees_legacy(6)*rees_legacy_cap(k)]; %%%Max Discharge Rate
        
    end
end
