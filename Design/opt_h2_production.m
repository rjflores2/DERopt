if ~isempty(el_v)
    for i = 1:size(el_v,2)
        Constraints = [Constraints
            var_el.el_prod(:,i) + var_h2es.h2es_chrg(:,i) <= var_el.el_adopt(i).*(1/e_adjust)]; %%%Production is limited by adopted capacity
    end
    
    if ~isempty(h2es_v)
        for i = 1:size(h2es_v,2)
            Constraints = [Constraints
                var_h2es.h2es_soc(2:T,ii) == h2es_v(10,ii)*var_h2es.h2es_soc(1:T-1,ii) + h2es_v(8,ii)*var_h2es.h2es_chrg(2:T,ii)  - (1/h2es_v(9,ii))*var_h2es.h2es_dchrg(2:T,ii)  %%%Minus discharging of battery
                h2es_v(4,ii)*var_h2es.h2es_adopt(ii) <= var_h2es.h2es_soc(:,ii) <= h2es_v(5,ii)*var_h2es.h2es_adopt(ii) %%%Min/Max SOC
                var_h2es.h2es_chrg(:,ii) <= h2es_v(6,ii)*var_h2es.h2es_adopt(ii) %%%Max Charge Rate
                var_h2es.h2es_dchrg(:,ii) <= h2es_v(7,ii)*var_h2es.h2es_adopt(ii)]; %%%Max Discharge Rate
            
        end
    end
end

