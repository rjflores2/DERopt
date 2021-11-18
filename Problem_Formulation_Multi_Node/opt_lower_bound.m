%%% Lower Bounds
%% Utility Variables
if utility_exists
    Constraints = [Constraints
        (0 <= var_util.import):'Import value is >= 0'];
    
    if sum(dc_exist)>0
        Constraints = [Constraints
            (0 <= var_util.nontou_dc):'NonTOU Demand is >=0'
            (0 <= var_util.onpeak_dc):'On Peak Demand is >=0'
            (0 <= var_util.midpeak_dc):'Mid Peak Demand is >=0'];
    end
end
%% Solar PV && REES
if isempty(pv_v) == 0
    Constraints = [Constraints
        (0 <= var_pv.pv_elec):'PV production >= 0'
        (0 <= var_pv.pv_adopt):'PV Adoption >= 0'];
    
    if island == 0 && export_on == 1
        Constraints = [Constraints
            (0 <= var_pv.pv_nem):'PV NEM >=0'];
    end
    
    if isempty(ees_v) == 0 && rees_on == 1
        Constraints = [Constraints
            (0 <= var_rees.rees_adopt):'REES Adoptiong >= 0'
            (0 <= var_rees.rees_chrg):'REES Charging >= 0'
            (0 <= var_rees.rees_dchrg):'REES Discharging >= 0'
            (0 <= var_rees.rees_soc):'REES SOC >= 0'];
        
        if island ~= 1 % If not islanded, AEC can export NEM and wholesale for revenue
            Constraints = [Constraints
                (0 <= var_rees.rees_dchrg_nem):'REES NEM >=0'];
        end
    end
end
%% EES
if isempty(ees_v) == 0
    Constraints = [Constraints
        (0 <= var_ees.ees_adopt):'EES Adoptiong >= 0'
        (0 <= var_ees.ees_chrg):'EES Charging >= 0'
        (0 <= var_ees.ees_dchrg):'EES Discharging >= 0'
        (0 <= var_ees.ees_soc):'EES SOC >= 0'];
    if sgip_on
%         Constraints = [Constraints
%             (0 <= var_sgip.sgip_ees_pbi):'SGIP PBI >=0'
%             (0 <= var_sgip.sgip_ees_npbi_equity):'SGIP Equity >=0'
%             (0 <= var_sgip.sgip_ees_npbi):'SGIP NonPBI >=0'];
        Constraints = [Constraints
            (0 <= var_sgip.sgip_ees_pbi)
            (0 <= var_sgip.sgip_ees_npbi_equity)
            (0 <= var_sgip.sgip_ees_npbi)];
    end
end
%% Legacy PV
%%%Only need to add variables if new PV is not considered
if isempty(pv_legacy) == 0 && isempty(pv_v) == 1
    Constraints = [Constraints
        (0 <= var_pv.pv_elec):'LPV production >= 0'];
    if island == 0 && export_on == 1
        Constraints = [Constraints
            (0 <= var_pv.pv_nem):'LPV NEM >=0'];
    end
end
%% Legacy EES
if lees_on
     Constraints = [Constraints
        (0 <= var_lees.ees_chrg):'LEES Charging >= 0'
        (0 <= var_lees.ees_dchrg):'LEES Discharging >= 0'
        (0 <= var_lees.ees_soc):'LEES SOC >= 0'];
end
%% Legacy REES
if lrees_on
     Constraints = [Constraints
        (0 <= var_lrees.rees_chrg):'LREES Charging >= 0'
        (0 <= var_lrees.rees_dchrg):'LREES Discharging >= 0'
        (0 <= var_lrees.rees_dchrg_nem):'LREES Discharging >= 0'
        (0 <= var_lrees.rees_soc):'LREES SOC >= 0'];
end
%% Resiliency
if ~isempty(crit_load_lvl) && crit_load_lvl >0
    if ~isempty(pv_v) || ~isempty(pv_legacy)
        Constraints = [Constraints
            (0 <= var_resiliency.pv_elec):'PV Reseliency >= 0'];
    end
    if lees_on || lrees_on || ~isempty(ees_v)
        Constraints = [Constraints
            (0 <= var_resiliency.ees_chrg):'EES Reseliency Chrg >=0'
            (0 <= var_resiliency.ees_dchrg):'EES Reseliency Dchrg >=0'
            (0 <= var_resiliency.ees_soc):'EES Reseliency SOC >= 0'];
    end
end