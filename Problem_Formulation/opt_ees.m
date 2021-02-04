%%%EES Constraints
%% Grid tied EES
if isempty(ees_v) == 0
    for k=1:K
        %%%SOC Equality / Energy Balance
        Constraints = [Constraints
            ees_soc(2:T,k) == ees_v(10)*ees_soc(1:T-1,k) + ees_v(8)*ees_chrg(2:T,k)  - (1/ees_v(9))*ees_dchrg(2:T,k)  %%%Minus discharging of battery
            ees_v(4)*ees_adopt(k) <= ees_soc(:,k) <= ees_v(5)*ees_adopt(k) %%%Min/Max SOC
            ees_chrg(:,k) <= ees_v(6)*ees_adopt(k) %%%Max Charge Rate
            ees_dchrg(:,k) <= ees_v(7)*ees_adopt(k)]; %%%Max Discharge Rate
        
        %%%Adding sgip constraints
        if sgip_on && find(non_res_rates == find(ismember(rate_labels,rate(k)))) %%%IS nonresidential
            Constraints = [Constraints;( -ees_chrg(:,k)'*sgip_signal(:,2) +  ees_dchrg(:,k)'*sgip_signal(:,2) >= ees_adopt(k)*sgip(1)):'SGIP CO2 Reduciton'];
        end
        %% Renewable Tied EES
        if isempty(pv_v) == 0 && rees_on
            %%%SOC Equality / Energy Balance
            Constraints = [Constraints
                rees_soc(2:T,k) == ees_v(10)*rees_soc(1:T-1,k) + ees_v(8)*rees_chrg(2:T,k)  - (1/ees_v(9))*rees_dchrg(2:T,k)  %%%Minus discharging of battery
                ees_v(4)*rees_adopt(k) <= rees_soc(:,k) <= ees_v(5)*rees_adopt(k) %%%Min/Max SOC
                rees_chrg(:,k) <= ees_v(6)*rees_adopt(k) %%%Max Charge Rate
                rees_dchrg(:,k) <= ees_v(7)*rees_adopt(k)]; %%%Max Discharge Rate
            
            %%%Adding sgip constraints
            if sgip_on && find(non_res_rates == find(ismember(rate_labels,rate(k)))) %%%IS nonresidential
                Constraints = [Constraints;(-rees_chrg(:,k)'*sgip_signal(:,2) +  rees_dchrg(:,k)'*sgip_signal(:,2) >= rees_adopt(k)*sgip(1)):'SGIP CO2 Reduciton'];
            end
        end
    end
end
