%%% Continuous DG Cosntraints

if ~isempty(dgc_v)
    Constraints = [Constraints
        (0 <= var_dgc.dgc_adopt):'dgb Adoptiong >= 0'
        (0 <= var_dgc.dgc_elec):'dgb Elec >= 0'
        (0 <= var_dgc.dgc_fuel):'dgb Fuel >= 0'
        (repmat(var_dgc.dgc_adopt.*dgc_v(4),size(var_dgc.dgc_elec,1),1) <= var_dgc.dgc_elec  <= repmat(var_dgc.dgc_adopt,size(var_dgc.dgc_elec,1),1)):'DGC Output Limits'
        (var_dgc.dgc_elec./dgc_v(3) == var_dgc.dgc_fuel):'DGC Fuel'];
end

%         (var_dgc.dgc_capacity <= var_dgc.dgc_adopt.*max(elec).*3):'DGC Adoption'

%         (var_dgc.dgc_adopt.*dgc_v(4) <= var_dgc.dgc_elec <= var_dgc.dgc_adopt):'DGC Output Limits'
%         (repmat(var_dgc.dgc_capacity.*dgc_v(4),size(var_dgc.dgc_elec,1),1) <= var_dgc.dgc_elec  <= repmat(var_dgc.dgc_capacity,size(var_dgc.dgc_elec,1),1)):'DGC Output Limits'