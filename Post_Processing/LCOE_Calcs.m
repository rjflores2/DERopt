clc
SOFC_LCOE = SOFC_Cost/sum(var_sofc.sofc_elec)
LCOE = fval/Total_Load

PV_cost = (M*pv_mthly_debt.*pv_cap_mod'.*var_pv.pv_adopt) ... %%%Capital Cost
 + sum(var_pv.pv_elec + var_pv.pv_nem).*pv_v(3) ...
  - sum(export_price(:,3).*var_pv.pv_nem);


PV_LCOE = PV_cost./sum(var_pv.pv_elec + var_pv.pv_nem + var_rees.rees_chrg + var_lrees.rees_chrg)

utility_LCOE = sum(var_util.import.*import_price(:,3))/sum(var_util.import)

RESS_Cost = sum(rees_mthly_debt*M.*rees_cap_mod'.*var_rees.rees_adopt) ...%%%Capital Cost
            + sum(ees_v(2)*sum(sum(repmat(day_multi,1,K).*var_rees.rees_chrg)))... %%%Charging O&M
            + sum(ees_v(3)*(sum(sum(repmat(day_multi,1,K).*(var_rees.rees_dchrg))))) ...
             - sum(export_price(:,3).*var_rees.rees_dchrg_nem);


EES_Cost = sum(ees_mthly_debt*M.*ees_cap_mod'.* var_ees.ees_adopt) ...%%%Capital Cost
        + sum(ees_v(2)*sum(sum(repmat(day_multi,1,K).* var_ees.ees_chrg))) ...%%%Charging O&M
        + sum(ees_v(3)*sum(sum(repmat(day_multi,1,K).* var_ees.ees_dchrg)));%%%Discharging O&M
    
    
    
% REES_LCOS = RESS_Cost./sum(var_rees.rees_dchrg_nem + var_rees.rees_dchrg)
% EES_LCOS = (EES_Cost)./sum(var_ees.ees_dchrg)


Storage_LCOS = (RESS_Cost + EES_Cost)./sum(var_ees.ees_dchrg + var_rees.rees_dchrg_nem + var_rees.rees_dchrg)
Storage_Shifting_LCOS = ((M*pv_mthly_debt.*pv_cap_mod'.*var_pv.pv_adopt) ... %%%Capital Cost
    + sum(var_pv.pv_elec + var_pv.pv_nem).*pv_v(3))./sum(var_pv.pv_elec + var_pv.pv_nem + var_rees.rees_chrg + var_lrees.rees_chrg) ...
    + EES_LCOS


[LCOE... %%% Total LCOE 
    utility_LCOE...
    SOFC_LCOE...
    PV_LCOE...
    Storage_LCOS...
    Storage_Shifting_LCOS] %%%LCOE for  PV production of 1 kWh, storage of the kWh in a battery, followed by battery discharge at night