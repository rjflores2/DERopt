%%% Continuous DG Cosntraints

if ~isempty(dgb_v)
    Constraints = [Constraints
        (0 <= var_dgb.dgb_adopt):'dgb Adoptiong >= 0'
        (0 <= var_dgb.dgb_capacity):'dgb Capacity >= 0'
        (0 <= var_dgb.dgb_elec):'dgb Elec >= 0'
        (0 <= var_dgb.dgb_fuel):'dgb Fuel >= 0'
        (var_dgb.dgb_capacity <= var_dgb.dgb_adopt.*1000):'dgb Adoption'
        (var_dgb.dgb_elec  <= repmat(var_dgb.dgb_capacity,size(var_dgb.dgb_elec,1),1)):'dgb Output Limits'
        (var_dgb.dgb_elec./dgb_v(3) == var_dgb.dgb_fuel):'dgb Fuel'];
end

%         (var_dgb.dgb_capacity <= var_dgb.dgb_adopt.*max(elec).*3):'dgb Adoption'

%         (var_dgb.dgb_adopt.*dgb_v(4) <= var_dgb.dgb_elec <= var_dgb.dgb_adopt):'dgb Output Limits'
%         (repmat(var_dgb.dgb_capacity.*dgb_v(4),size(var_dgb.dgb_elec,1),1) <= var_dgb.dgb_elec  <= repmat(var_dgb.dgb_capacity,size(var_dgb.dgb_elec,1),1)):'dgb Output Limits'