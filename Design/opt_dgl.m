if dgl_on

    if sum(res_idx) > 0
    Constraints = [Constraints
        (0 <= var_dgl.dg_capacity):'DGL Capacity is greater than zero'
        (var_dgl.dg_capacity(res_idx) <= res_units(res_idx)'.*5):'Fuel Cell Installed Residential Capacity Limit'];
    else
         Constraints = [Constraints
        (0 <= var_dgl.dg_capacity):'DGL Capacity is greater than zero'];
    end
    
    if  ~h2_systems_for_resiliency_only
        Constraints = [Constraints
            (0 <= var_dgl.dg_elec):'DGL Production is greater than zero'
            (var_dgl.dg_elec <= repmat(var_dgl.dg_capacity,T,1)):'DGL Electric Production is limited by adotped capacity'];
    end
end