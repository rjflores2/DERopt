%% OVMG Evaluation

%% Solar Utilization
for ii = 1:K
    ovmg_evaluation.solar_utilization(1,ii) = sum((var_pv.pv_adopt(ii) + pv_legacy_cap(ii)).*solar.*(1/e_adjust));
    ovmg_evaluation.solar_utilization(2,ii) = sum(var_pv.pv_elec(:,ii));
    ovmg_evaluation.solar_utilization(3,ii) = sum(var_pv.pv_nem(:,ii));
    ovmg_evaluation.solar_utilization(4,ii) = sum(var_rees.rees_chrg(:,ii));
    ovmg_evaluation.solar_utilization(5,ii) = sum(var_lrees.rees_chrg(:,ii));
end

%% Storage
for ii = 1:K
    ovmg_evaluation.ees_throughput(1,ii) = sum(var_ees.ees_chrg(:,ii));
    ovmg_evaluation.ees_throughput(2,ii) = sum(var_ees.ees_dchrg(:,ii));
    
    ovmg_evaluation.lees_throughput(1,ii) = sum(var_lees.ees_chrg(:,ii));
    ovmg_evaluation.lees_throughput(2,ii) = sum(var_lees.ees_dchrg(:,ii));
    
    ovmg_evaluation.rees_throughput(1,ii) = sum(var_rees.rees_chrg(:,ii));
    ovmg_evaluation.rees_throughput(2,ii) = sum(var_rees.rees_dchrg(:,ii));
    ovmg_evaluation.rees_throughput(3,ii) = sum(var_rees.rees_dchrg_nem(:,ii));
    
    ovmg_evaluation.lrees_throughput(1,ii) = sum(var_lrees.rees_chrg(:,ii));
    ovmg_evaluation.lrees_throughput(2,ii) = sum(var_lrees.rees_dchrg(:,ii));
    ovmg_evaluation.lrees_throughput(3,ii) = sum(var_lrees.rees_dchrg_nem(:,ii));
end

%% Delivery to Buildings
for ii = 1:K
    ovmg_evaluation.to_building(1,ii) = sum(var_util.import(:,ii));
    ovmg_evaluation.to_building(2,ii) = sum(var_ees.ees_chrg(:,ii));
    ovmg_evaluation.to_building(3,ii) = sum(var_lees.ees_chrg(:,ii));
    ovmg_evaluation.to_building(4,ii) = sum(var_pv.pv_elec(:,ii));
    ovmg_evaluation.to_building(5,ii) = sum(var_ees.ees_dchrg(:,ii));
    ovmg_evaluation.to_building(6,ii) = sum(var_lees.ees_dchrg(:,ii));
end

%% Transformer Loadings
%%% Determining active power
xfmr_power = [];
for ii = 1:length(t_rating)
    %%%Buildings connected to the current transformer
        idx = find(t_map == ii);
        
        xfmr_power.active(:,ii) = sum(var_util.import(:,idx),2) - sum(var_pv.pv_nem(:,idx),2) - sum(var_rees.rees_dchrg_nem(:,idx),2);
        xfmr_power.reactive(:,ii) = sum(elec(:,idx).*repmat(tan(acos(pf(idx))),length(elec),1),2);
        xfmr_power.apparent(:,ii) = sqrt(xfmr_power.active(:,ii).^2 + xfmr_power.reactive(:,ii).^2);
        xfmr_power.apparent_pu(:,ii) = xfmr_power.apparent(:,ii)./t_rating(ii);
        
end