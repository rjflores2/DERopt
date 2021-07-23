%% PV Constraints
if ~isempty(pv_v) || (~isempty(pv_legacy) && sum(pv_legacy(2,:)) > 0)
    %% PV Energy balance when curtailment is allowed
    if curtail
        Constraints = [Constraints
            (var_pv.pv_elec + var_pv.pv_nem + sum(var_rees.rees_chrg,2) <= (sum(pv_legacy(2,:))/e_adjust)*solar + (sum(var_pv.pv_adopt))/e_adjust*solar) :'PV Energy Balance'];
%         Constraints = [Constraints, (pv_wholesale + pv_elec + pv_nem + rees_chrg <= repmat(solar,1,K).*repmat(pv_adopt,T,1)):'PV Energy Balance'];
    else
         Constraints = [Constraints
            (var_pv.pv_elec + var_pv.pv_nem + sum(var_rees.rees_chrg,2) == (sum(pv_legacy(2,:))/e_adjust)*solar + (sum(var_pv.pv_adopt))/e_adjust*solar) :'PV Energy Balance'];
%         Constraints = [Constraints, (pv_wholesale + pv_elec + pv_nem + rees_chrg == repmat(solar,1,K).*repmat(pv_adopt,T,1)):'PV Energy Balance'];
    end
    %% Min PV to adopt: Forces 3 kW Adopted
    if toolittle_pv ~= 0
        Constraints = [Constraints,(toolittle_pv <= sum(var_pv.pv_adopt)):'toolittle_pv'];
%         for k=1:K
%             Constraints = [Constraints, (implies(pv_adopt(k) <= toolittle_pv, pv_adopt(k) == 0)):'toolittle_pv'];
%         end
    end
    
    %% Max PV to adopt (capacity constrained)
    if ~isempty(maxpv)    
        Constraints = [Constraints
            (var_pv.pv_adopt' <= maxpv'):'Mav PV Capacity'];  
%         Constraints = [Constraints, (sum(var_pv.pv_adopt) <= maxpv'):'Mav PV Capacity'];
    end
    
    %% Don't curtail for residential
%     residential = find(strcmp(rate,'R1') |strcmp(rate,'R2') | strcmp(rate,'R3')| strcmp(rate,'R4'));   
%     Constraints = [Constraints,...
%         ( solar*pv_adopt(residential) ==  pv_wholesale(:,residential) + pv_elec(:,residential) + pv_nem(:,residential) + rees_chrg(:,residential)):'No residential curtail' ];
end