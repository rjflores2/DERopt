if ~isempty(el_v) || ~isempty(rel_v) || ~isempty(rsoc_v)
    if ~isempty(el_v)
        for i = 1:size(el_v,2)
            Constraints = [Constraints
                (0 <= var_el.el_prod(:,i)  <= var_el.el_adopt(i).*(1/e_adjust)):'Electrolyzer Min/Max Output']; %%%Production is limited by adopted capacity
        end
    elseif  ~isempty(rel_v)
        for i = 1:size(rel_v,2)
            Constraints = [Constraints
                (0 <= var_rel.rel_prod(:,i)  <= var_rel.rel_adopt(i).*(1/e_adjust)):'Renewable Electrolyzer Min/Max Output']; %%%Production is limited by adopted capacity
        end
    end
    
    if ~isempty(h2es_v)
        for ii = 1:size(h2es_v,2)
            Constraints = [Constraints
                (var_h2es.h2es_soc(1,ii) + var_h2es.h2es_dchrg(1,ii) == var_h2es.h2es_soc(end,ii)):'H2ES SOC Start = End'
                (var_h2es.h2es_soc(2:T,ii) == var_h2es.h2es_soc(1:T-1,ii) + var_h2es.h2es_chrg(2:T,ii)  - var_h2es.h2es_dchrg(2:T,ii)):'H2 Storage Balance'  %%%Perfect energy balance
                (h2es_v(4,ii)*var_h2es.h2es_adopt(ii) <= var_h2es.h2es_soc(:,ii) <= h2es_v(5,ii)*var_h2es.h2es_adopt(ii)):'H2 Min/Max SOC' %%%Min/Max SOC
                (var_h2es.h2es_chrg(:,ii) <= h2es_v(6,ii)*var_h2es.h2es_adopt(ii)):'H2 Max Chrg' %%%Max Charge Rate
                (var_h2es.h2es_dchrg(:,ii) <= h2es_v(7,ii)*var_h2es.h2es_adopt(ii)):'H2 Max Dchrg'%%%Max Discharge Rate
                (var_h2es.h2es_dchrg(:,ii) <= var_h2es.h2es_bin(:,ii)*10000):'H2ES Op State'
                (var_h2es.h2es_chrg(:,ii) <= (1-var_h2es.h2es_bin(:,ii))*10000):'H2ES Op State'];
            %                 (var_h2es.h2es_soc(1) == 0):'H2 Starting SOC'
        end
    end
end

