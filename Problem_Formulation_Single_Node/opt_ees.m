%%%EES Constraints
%% Grid tied EES
if isempty(ees_v) == 0
    for ii = 1:size(ees_v,2)
        %%%SOC Equality / Energy Balance
        Constraints = [Constraints
            (var_ees.ees_soc(1,ii) <= var_ees.ees_soc(T,ii)):'Initial EES SOC <= Final SOC'
            (var_ees.ees_soc(2:T,ii) == ees_v(10,ii)*var_ees.ees_soc(1:T-1,ii) + ees_v(8,ii)*var_ees.ees_chrg(2:T,ii)  - (1/ees_v(9,ii))*var_ees.ees_dchrg(2:T,ii)):'EES Balance'  %%%Minus discharging of battery
            (ees_v(4,ii)*var_ees.ees_adopt(ii) <= var_ees.ees_soc(:,ii) <= ees_v(5,ii)*var_ees.ees_adopt(ii)):'EES Min/Max SOC' %%%Min/Max SOC
            (var_ees.ees_chrg(:,ii) <= ees_v(6,ii)*var_ees.ees_adopt(ii)):'EES Max Chrg'  %%%Max Charge Rate
            (var_ees.ees_dchrg(:,ii) <= ees_v(7,ii)*var_ees.ees_adopt(ii)):'EES Max Dchrg']; %%%Max Discharge Rate
        
        %% Renewable Tied EES
        if isempty(pv_v) == 0 && rees_on
            %%%SOC Equality / Energy Balance
            Constraints = [Constraints
                (var_rees.rees_soc(1,ii) <= var_rees.rees_soc(T,ii)):'Initial REES SOC <= Final SOC'
                (var_rees.rees_dchrg_nem(1,ii) == 0):'No REES NEM in 1st time step'
                (var_rees.rees_soc(2:T,ii) == ees_v(10,ii)*var_rees.rees_soc(1:T-1,ii) + ees_v(8,ii)*var_rees.rees_chrg(2:T,ii)  - (1/ees_v(9,ii))*(var_rees.rees_dchrg(2:T,ii) + var_rees.rees_dchrg_nem(2:T,ii))):'REES Balance'  %%%Minus discharging of battery
                (ees_v(4,ii)*var_rees.rees_adopt(ii) <= var_rees.rees_soc(:,ii) <= ees_v(5,ii)*var_rees.rees_adopt(ii)):'REES Min/Max SOC' %%%Min/Max SOC
                (var_rees.rees_chrg(:,ii) <= ees_v(6,ii)*var_rees.rees_adopt(ii)):'REES Max Chrg' %%%Max Charge Rate
                (var_rees.rees_dchrg(:,ii) <= ees_v(7,ii)*var_rees.rees_adopt(ii)):'REES Max Dchrg']; %%%Max Discharge Rate
            
            %%%Adding sgip constraints
            %             if sgip_on && ~isempty(find(non_res_rates == find(ismember(rate_labels,rate(1))))) %%%IS nonresidential
            %                 Constraints = [Constraints;(-var_rees.rees_chrg(:,ii)'*sgip_signal(:,2) +  var_rees.rees_dchrg(:,ii)'*sgip_signal(:,2) >= var_rees.rees_adopt(ii)*sgip(1)):'SGIP CO2 Reduciton'];
            %             end
        end
    end
end
