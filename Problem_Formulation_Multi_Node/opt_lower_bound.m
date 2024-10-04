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
            ];
        if sim_lvl == 3
        Constraints = [Constraints
            ];
        end
    end
    if dgb_on
        Constraints = [Constraints
            
        if sim_lvl == 3
        Constraints = [Constraints
            ];
        end        
    end
    if lees_on || lrees_on || ~isempty(ees_v)
        Constraints = [Constraints
            (0 <= var_resiliency.ees_chrg):'EES Reseliency Chrg >=0'
            (0 <= var_resiliency.ees_dchrg):'EES Reseliency Dchrg >=0'
            (0 <= var_resiliency.ees_soc):'EES Reseliency SOC >= 0'];
        if sim_lvl == 3
            Constraints = [Constraints
                (0 <= var_resiliency.ees_dchrg_real):'EES Real Reseliency >= 0'
                (0 <= var_resiliency.ees_dchrg_reactive):'EES Reactive Reseliency >= 0'];
        end
    end
    
    if sim_lvl == 2 || sim_lvl == 3
        Constraints = [Constraints
            (0 <= var_resiliency.import):'Imports Reseliency Chrg >=0'
            (0 <= var_resiliency.export):'Exports Reseliency Dchrg >=0'];
        
        if sim_lvl == 3
            Constraints = [Constraints
                (0 <= var_resiliency.import_reactive):'Imports Reactive Reseliency Chrg >=0'
                (0 <= var_resiliency.export_reactive):'Exports Reactive Reseliency Dchrg >=0'];
        end
    end
end