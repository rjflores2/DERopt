%%%EES Constraints
%% Grid tied EES
if isempty(ees_v) == 0
    for ii = 1:size(ees_v,2)
        %%%SOC Equality / Energy Balance
        Constraints = [Constraints
            (modelVars.eesSoc(1,ii) <= modelVars.eesSoc(T,ii)):'Initial EES SOC <= Final SOC'
            (modelVars.eesSoc(2:T,ii) == ees_v(10,ii)*modelVars.eesSoc(1:T-1,ii) + ees_v(8,ii)*modelVars.eesChrg(2:T,ii)  - (1/ees_v(9,ii))*modelVars.eesDchrg(2:T,ii)):'EES Balance'  %%%Minus discharging of battery
            (ees_v(4,ii)*modelVars.eesAdopt(ii) <= modelVars.eesSoc(:,ii) <= ees_v(5,ii)*modelVars.eesAdopt(ii)):'EES Min/Max SOC' %%%Min/Max SOC
            (modelVars.eesChrg(:,ii) <= ees_v(6,ii)*modelVars.eesAdopt(ii)):'EES Max Chrg'  %%%Max Charge Rate
            (modelVars.eesDchrg(:,ii) <= ees_v(7,ii)*modelVars.eesAdopt(ii)):'EES Max Dchrg']; %%%Max Discharge Rate
        
        %% Renewable Tied EES
        if isempty(pv_v) == 0 && rees_on
            %%%SOC Equality / Energy Balance
            Constraints = [Constraints
                (modelVars.reesSoc(1,ii) <= modelVars.reesSoc(T,ii)):'Initial REES SOC <= Final SOC'
                (modelVars.reesDchrgNem(1,ii) == 0):'No REES NEM in 1st time step'
                (modelVars.reesSoc(2:T,ii) == ees_v(10,ii)*modelVars.reesSoc(1:T-1,ii) + ees_v(8,ii)*modelVars.reesChrg(2:T,ii)  - (1/ees_v(9,ii))*(modelVars.reesDchrg(2:T,ii) + modelVars.reesDchrgNem(2:T,ii))):'REES Balance'  %%%Minus discharging of battery
                (ees_v(4,ii)*modelVars.reesAdopt(ii) <= modelVars.reesSoc(:,ii) <= ees_v(5,ii)*modelVars.reesAdopt(ii)):'REES Min/Max SOC' %%%Min/Max SOC
                (modelVars.reesChrg(:,ii) <= ees_v(6,ii)*modelVars.reesAdopt(ii)):'REES Max Chrg' %%%Max Charge Rate
                (modelVars.reesDchrg(:,ii) <= ees_v(7,ii)*modelVars.reesAdopt(ii)):'REES Max Dchrg']; %%%Max Discharge Rate
            
            %%%Adding sgip constraints
            %             if sgip_on && ~isempty(find(non_res_rates == find(ismember(rate_labels,rate(1))))) %%%IS nonresidential
            %                 Constraints = [Constraints;(-modelVars.reesChrg(:,ii)'*sgip_signal(:,2) +  modelVars.reesDchrg(:,ii)'*sgip_signal(:,2) >= modelVars.reesAdopt(ii)*sgip(1)):'SGIP CO2 Reduciton'];
            %             end
        end
    end
end
