%%%Constraints that consider resiliency requirements and must meet loads
if ~isempty(crit_load_lvl) && crit_load_lvl >0
    %% Electrical Energy Balance
    Constraints = [Constraints
        (var_resiliency.pv_elec + var_resiliency.ees_dchrg == var_resiliency.ees_chrg + elec_res(T_res(1):T_res(2),:)):'Critical Electric Energy Balance'];
    
    %% PV Production
    if ~isempty(pv_v) || ~isempty(pv_legacy)
        Constraints = [Constraints
            ( var_resiliency.pv_elec  <= (1/e_adjust).*repmat(solar(T_res(1):T_res(2)),1,K).*(repmat(pv_legacy_cap,T_res(2),1) + repmat(var_pv.pv_adopt,T_res(2),1))):'PV Resiliency Production'];
    end
    
    %% Storage
    if lees_on || lrees_on || ~isempty(ees_v)
        for k=1:K
            Constraints = [Constraints
                var_resiliency.ees_soc(2:T_res(2),k) == ees_v(10)*var_resiliency.ees_soc(1:T_res(2)-1,k) + ees_v(8)*var_resiliency.ees_chrg(2:T_res(2),k)  - (1/ees_v(9))*var_resiliency.ees_dchrg(2:T_res(2),k)  %%%Minus discharging of
                ees_v(4)*(var_ees.ees_adopt(k) + var_rees.rees_adopt(k) + ees_legacy_cap(k) + rees_legacy_cap(k)) <= var_resiliency.ees_soc(:,k) <= ees_v(5)*(var_ees.ees_adopt(k) + var_rees.rees_adopt(k) + ees_legacy_cap(k) + rees_legacy_cap(k)) %%%Min/Max SOC
                var_resiliency.ees_chrg(:,k) <= ees_v(6)*(var_ees.ees_adopt(k) + var_rees.rees_adopt(k) + ees_legacy_cap(k) + rees_legacy_cap(k)) %%%Max Charge Rate
                var_resiliency.ees_dchrg(:,k) <= ees_v(7)*(var_ees.ees_adopt(k) + var_rees.rees_adopt(k) + ees_legacy_cap(k) + rees_legacy_cap(k))]; %%%Max Discharge Rate
        end
    end
end