%% PV Constraints
if isempty(pv_v) == 0
    %% PV Energy balance when curtailment is allowed
    if curtail
        Constraints = [Constraints, (pv_elec + pv_nem + rees_chrg <= repmat(solar,1,K).*repmat(pv_adopt,T,1)):'PV Energy Balance'];
%         Constraints = [Constraints, (pv_wholesale + pv_elec + pv_nem + rees_chrg <= repmat(solar,1,K).*repmat(pv_adopt,T,1)):'PV Energy Balance'];
    else
        Constraints = [Constraints, (pv_elec + pv_nem + rees_chrg == repmat(solar,1,K).*repmat(pv_adopt,T,1)):'PV Energy Balance'];
%         Constraints = [Constraints, (pv_wholesale + pv_elec + pv_nem + rees_chrg == repmat(solar,1,K).*repmat(pv_adopt,T,1)):'PV Energy Balance'];
    end
    %% Min PV to adopt: Forces 3 kW Adopted
    if toolittle_pv ~= 0
        Constraints = [Constraints,(toolittle_pv <= pv_adopt):'toolittle_pv'];
%         for k=1:K
%             Constraints = [Constraints, (implies(pv_adopt(k) <= toolittle_pv, pv_adopt(k) == 0)):'toolittle_pv'];
%         end
    end
    
    %% Max PV to adopt (area constrained)
    if pv_maxarea
%         maxpv = [1296.193592	220.6164316	17.50637663	209.7896814	227.3885864	489.2995255	58.08934062	198.0385724	251.1221256	573.4781479	1552.421324	646.664299	305.9307368	1010.926181	8.639640818	801.0892088	612.9386393	58.4017605	446.1910585	149.054028	36.89108013	15.02661503	45.03358088	50.34471206	110.9415728	40.88830777	142.2994536	341.1152646	1436.337133	14.54546726	61.91076427];
%        maxpv = maxpv(1:length(pv_adopt));
%         maxpv = maxpv(1:size(elec,2));        
        Constraints = [Constraints, (pv_adopt <= maxpv'):'Mav PV area'];
    end
    
    %% Don't curtail for residential
%     residential = find(strcmp(rate,'R1') |strcmp(rate,'R2') | strcmp(rate,'R3')| strcmp(rate,'R4'));   
%     Constraints = [Constraints,...
%         ( solar*pv_adopt(residential) ==  pv_wholesale(:,residential) + pv_elec(:,residential) + pv_nem(:,residential) + rees_chrg(:,residential)):'No residential curtail' ];
end