if h2_storage_on

    %     h2_ind = find(datetimev(:,4) ~= 12);
    % (var_h2_storage.charge(h2_ind,:) == 0)

    if sum(res_idx)
        Constraints = [Constraints
            (0 <= var_h2_storage.capacity):'H2 Storage Capacity  is > 0'
            (var_h2_storage.capacity(res_idx) <= res_units(res_idx)'.*6*33.3):'H2 Storage Installed Residential Capacity Limit'];
    else
        Constraints = [Constraints
            (0 <= var_h2_storage.capacity):'H2 Storage Capacity  is > 0'];
    end

    if  ~h2_systems_for_resiliency_only
        Constraints = [Constraints
            (0 <= var_h2_storage.soc):'H2 Storage SOC  is > 0'
            (0 <= var_h2_storage.charge):'H2 Storage Chaging is > 0'
            (0 <= var_h2_storage.dicharge):'H2 Storage Discharge is > 0'
            (0 <= var_h2_storage.vent):'H2 Storage Venting is > 0'
            (var_h2_storage.soc(end,:) <= var_h2_storage.soc(1,:)):'H2 Storage Initial SOC = final SOC'
            (var_h2_storage.soc <= repmat(var_h2_storage.capacity,T,1)):'H2 SOC is limited byt adotped capacity'
            (var_h2_storage.soc(2:end,:) == var_h2_storage.soc(1:end-1,:) + var_h2_storage.charge(1:end-1,:) - var_h2_storage.dicharge(1:end-1,:) - var_h2_storage.vent(1:end-1,:)):'H2 Storage Energy Balance'
            (var_h2_storage.vent == var_h2_storage.soc.*h2_storage_v(10)):'Venting is equal to boiloff form the tank'
            (var_dgl.dg_elec./dgl_v(2) <= var_h2_storage.dicharge + var_h2_storage.vent):'H2 generator fuel input is equal to vented hydrogen + discharge'];
    end
end