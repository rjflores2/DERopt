%% SGIP for battery energy storage
if isempty(ees_v) == 0 && sgip_on
    
    %%%Limiting SGIP incentivized storage
    %%%Constraints
    Constraints = [Constraints
        sgip_ees_pbi(1,:) <= sgip(end)
        sgip_ees_pbi(2,:) <= sgip(end)
        sgip_ees_pbi(3,:) <= sgip(end)];
    
    %%%Going through all buildings
    ind = 1; %%%Comercial/industrial index    
    ind_r = 1; %%%Residential index
    ind_re = 1; %%%Residential equity index
    for k = 1:K
        if sgip_pbi(k) %%%If SGIP performance based incentives apply
            %%%Requiring for PBI systems to reduce CO2 emissions scaled by
            %%%adopted battery size
            Constraints = [Constraints;(-(rees_chrg(:,k)' + ees_chrg(:,k)')*sgip_signal(:,2) +  (rees_dchrg(:,k)' + ees_dchrg(:,k)')*sgip_signal(:,2) >= (ees_adopt(k) + rees_adopt(k))*sgip(1)):'SGIP CO2 Reduciton'];
            Constraints = [Constraints;(sgip_ees_pbi(1,ind) + sgip_ees_pbi(2,ind) + sgip_ees_pbi(3,ind)<= (ees_adopt(k)+rees_adopt(k))):'SGIP based on adopted battery'];
%             Constraints = [Constraints;(sgip_rees_pbi(1,ind) + sgip_rees_pbi(2,ind) + sgip_rees_pbi(3,ind) <= rees_adopt(k)):'SGIP based on adopted renewable battery'];
            ind = ind + 1;
            
        elseif res_units(k)>0 && ~low_income(k)
            Constraints = [Constraints; (sgip_ees_npbi(ind_r) <= (ees_adopt(k) + rees_adopt(k))):'SGIP system limit'];
            Constraints = [Constraints; (ees_v(7)*(sgip_ees_npbi(ind_r)) <= 5*res_units(k)):'SGIP nonPBI residential unity limit'];
            ind_r = ind_r + 1;
        elseif low_income(k)
            Constraints = [Constraints; (sgip_ees_npbi_equity(ind_re) <= (ees_adopt(k) + rees_adopt(k))):'SGIP system limit'];
            Constraints = [Constraints; (ees_v(7)*(sgip_ees_npbi_equity(ind_re)) <= 5*res_units(k)):'SGIP nonPBI residential unity limit'];
            ind_re = ind_re + 1;
        end
    end
end