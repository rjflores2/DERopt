%% General equalities
%% Building Electrical Energy Balances
%%For  all timesteps t
%Vectorized
Constraints = [Constraints
    (sum(var_util.import,2) + sum(var_pv.pv_elec,2) + sum(var_ees.ees_dchrg,2) + sum(var_rees.rees_dchrg,2) + sum(var_ldg.ldg_elec,2) + sum(var_lbot.lbot_elec,2) ... %%%Production
    ==...
    elec + sum(var_ees.ees_chrg,2) + var_vc.generic_cool./4  + sum(var_lvc.lvc_cool.*vc_cop,2) + sum(el_eff.*(var_el.el_prod + var_h2es.h2es_chrg),2) ):'Electricity Balance']; %%%Demand

%% Heat Balance
if ~isempty(heat) && sum(heat>0)>0
    Constraints = [Constraints
        (var_boil.boil_rfuel + var_boil.boil_fuel).*boil_legacy(2) + var_ldg.hr_heat == heat];
end

%% Cooling Balance
if ~isempty(cool) && sum(cool)>0
    Constraints = [Constraints
        var_vc.generic_cool + sum(var_ltes.ltes_dchrg,2) + sum(var_lvc.lvc_cool,2) == cool + sum(var_ltes.ltes_chrg,2)];
    
%     Constraints = [Constraints
%         var_vc.generic_cool + sum(var_ltes.ltes_dchrg,2) + sum(vc_size.*var_lvc.lvc_op,2) == cool + sum(var_ltes.ltes_chrg,2)];
end