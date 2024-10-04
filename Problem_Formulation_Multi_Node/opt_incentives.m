%% SGIP for battery energy storage
if isempty(ees_v) == 0 && sgip_on

    if sum(sgip_pbi)>0
        %%%Limiting SGIP incentivized storage  pbi: Performance Based Incentive
        %%%Constraints
        Constraints = [Constraints
            (0 <=  var_sgip.sgip_ees_pbi(1,:) <= sgip(end)):'SGIP Installed Capacity Limits'
            (0 <=  var_sgip.sgip_ees_pbi(2,:) <= sgip(end)):'SGIP Installed Capacity Limits'
            (0 <=  var_sgip.sgip_ees_pbi(3,:) <= sgip(end)):'SGIP Installed Capacity Limits'];
    end
    
    %%%Going through all buildings
    ind = 1; %%%Comercial/industrial index    
    ind_r = 1; %%%Residential index
    ind_re = 1; %%%Residential equity index
    for k = 1:K
        if sgip_pbi(k) %%%If SGIP performance based incentives apply
            %%%Requiring for PBI systems to reduce CO2 emissions scaled by
            %%%adopted battery size
            Constraints = [Constraints;(-(var_rees.rees_chrg(:,k)' + var_ees.ees_chrg(:,k)')*sgip_signal(:,2) +  (var_rees.rees_dchrg(:,k)' + var_ees.ees_dchrg(:,k)')*sgip_signal(:,2) >= (var_ees.ees_adopt(k) + var_rees.rees_adopt(k))*sgip(1)):'SGIP CO2 Reduciton'];
            Constraints = [Constraints;(var_sgip.sgip_ees_pbi(1,ind) + var_sgip.sgip_ees_pbi(2,ind) + var_sgip.sgip_ees_pbi(3,ind)<= (var_ees.ees_adopt(k) + var_rees.rees_adopt(k))):'SGIP based on adopted battery'];
%             Constraints = [Constraints;(sgip_rees_pbi(1,ind) + sgip_rees_pbi(2,ind) + sgip_rees_pbi(3,ind) <= rees_adopt(k)):'SGIP based on adopted renewable battery'];
            ind = ind + 1;
            
        elseif res_units(k)>0 && ~low_income(k)
            Constraints = [Constraints; (var_sgip.sgip_ees_npbi(ind_r) <= (var_ees.ees_adopt(k) + var_rees.rees_adopt(k))):'SGIP system limit'];
            Constraints = [Constraints; (ees_v(7)*(var_sgip.sgip_ees_npbi(ind_r)) <= 5*res_units(k)):'SGIP nonPBI residential unity limit'];
            Constraints = [Constraints; ((52*size(elec,1)/8760)*var_sgip.sgip_ees_npbi(ind_r) <= sum(var_ees.ees_dchrg(:,k) + var_rees.rees_dchrg(:,k))):'SGIP nonPBI Cycling Requirement'];
            ind_r = ind_r + 1;
        elseif low_income(k)
            Constraints = [Constraints; (var_sgip.sgip_ees_npbi_equity(ind_re) <= (var_ees.ees_adopt(k) + var_rees.rees_adopt(k))):'SGIP system limit'];
            Constraints = [Constraints; (ees_v(7)*(var_sgip.sgip_ees_npbi_equity(ind_re)) <= 5*res_units(k)):'SGIP nonPBI residential unity limit'];
            Constraints = [Constraints; ((52*size(elec,1)/8760)*var_sgip.sgip_ees_npbi_equity(ind_re) <= sum(var_ees.ees_dchrg(:,k) + var_rees.rees_dchrg(:,k))):'SGIP nonPBI Cycling Requirement'];
            ind_re = ind_re + 1;
        end
    end
end

%% From when we had REES Dchrg Nem
%%%% For not low income residential
%  Constraints = [Constraints; ((52*size(elec,1)/8760)*var_sgip.sgip_ees_npbi(ind_r) <= sum(var_ees.ees_dchrg(:,k) + var_rees.rees_dchrg(:,k) + var_rees.rees_dchrg_nem(:,k))):'SGIP nonPBI Cycling Requirement'];
%%% For Low income Residential
%  Constraints = [Constraints; ((52*size(elec,1)/8760)*var_sgip.sgip_ees_npbi_equity(ind_re) <= sum(var_ees.ees_dchrg(:,k) + var_rees.rees_dchrg(:,k) + var_rees.rees_dchrg_nem(:,k))):'SGIP nonPBI Cycling Requirement'];
           
           