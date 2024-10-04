if utility_exists
    Constraints = [Constraints
        (0 <= var_util.import):'Electric Imports are >=0'
        (0 <= var_util.export ):'Electric Exports are >=0'
        (var_util.export <= var_pv.pv_elec + var_rees.rees_dchrg + var_lrees.rees_dchrg): 'Exports only occur when there is excess PV or energy in a battery'
        (-sum(var_util.export.*export_value) <= sum(var_util.import.*import_cost)):'Export credit limit limits'];
    

%        

    if util_bin_on
        Constraints = [Constraints
            (var_util.import <= 50.*(1-var_util.elec_sign)):'Import binary constraint'
            (var_util.export <= 50.*(var_util.elec_sign)):'Export binary constraint'];
    end

    if sum(dc_exist)>0
        Constraints = [Constraints
            (0 <= var_util.nontou_dc):'NonTOU Demand is >=0'];

        if onpeak_count > 0
            Constraints = [Constraints
                (0 <= var_util.onpeak_dc):'On Peak Demand is >=0'];
        end
        
        if midpeak_count > 0
            Constraints = [Constraints
                (0 <= var_util.midpeak_dc):'Mid Peak Demand is >=0'];
        end
    end
    
end



%         (-sum(var_util.export.*export_value) <= sum(var_util.import.*import_cost)):'Export credit limit limits'
%                 (var_util.import <= 50.*(1-var_util.elec_sign))
%         (var_util.export <= 50.*(var_util.elec_sign))



% (var_util.net_flow == var_util.import - var_util.export):'Flow of electricity is tied to imports and exports only'
%         (var_util.net_flow <= var_util.import):'Electric imports must be postivie net flow of electricity'
% var_util.elec_sign
% (var_util.net_flow  <= var_util.export):'shit'
%         (var_util.net_flow  <= var_util.export)
%         (var_util.export - var_util.import <= -var_util.net_flow):'Exports only occur when imports are zero and net flow is negative'
