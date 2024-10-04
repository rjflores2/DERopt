%If resiliency is considered and we're focused on building level resiliency
if crit_load_lvl>0 && ~isempty(opt_resiliency_model) &&  opt_resiliency_model == 1
    %% # of time steps
    T_resiliency_length = T_res(2) - T_res(1) + 1;
    %% Declaring Variables First
    %% Solar PV
    if ~isempty(pv_v) || ~isempty(pv_legacy)
        var_resiliency.pv_elec = sdpvar(size(elec_res(T_res(1):T_res(2),:),1),K,'full');

        Objective = Objective ...
            + pv_v(3)*sum(sum(var_resiliency.pv_elec));
    else
        var_resiliency.pv_elec = zeros(size(elec_res(T_res(1):T_res(2),:),1),K);
    end
    %% Electric Energy Storage
    if lees_on || lrees_on || ~isempty(ees_v)
        var_resiliency.ees_chrg = sdpvar(size(elec_res(T_res(1):T_res(2),:),1),K,'full');
        var_resiliency.ees_dchrg = sdpvar(size(elec_res(T_res(1):T_res(2),:),1),K,'full');
        var_resiliency.ees_soc = sdpvar(size(elec_res(T_res(1):T_res(2),:),1),K,'full');

        Objective = Objective ...
            + ees_v(2)*sum(sum(var_resiliency.ees_chrg)) ...
            + ees_v(3)*sum(sum(var_resiliency.ees_dchrg));

    else

        var_resiliency.ees_chrg = zeros(size(elec_res(T_res(1):T_res(2),:),1),K);
        var_resiliency.ees_dchrg = zeros(size(elec_res(T_res(1):T_res(2),:),1),K);
    end

    %% If a backup Fuel Cell is Available
    if dgl_on
        var_resiliency.dg_elec = sdpvar(size(elec_res(T_res(1):T_res(2),:),1),K,'full');       %%%SOFC electricity produced (kWh)

        if dgl_pipeline_fuel>0
            Objective = Objective ...
                + sum(sum(var_resiliency.dg_elec)).*(dgl_pipeline_fuel./dgl_v(2));
        end

    else
        var_resiliency.dg_elec =  zeros(size(elec_res(T_res(1):T_res(2),:),1),K);
    end

    %% If Onsite H2 Storage is Available
    if h2_storage_on

        h2_storage_number_refills = 1; %%% Number of times LH2 can be refilled

        var_resiliency.h2_soc = sdpvar(size(elec_res(T_res(1):T_res(2),:),1),K,'full'); %%%H2 storage state of charge (kWh)
        var_resiliency.h2_charge = sdpvar(h2_storage_number_refills,K,'full'); %%%H2 Storage Charging
        var_resiliency.h2_discharge = sdpvar(size(elec_res(T_res(1):T_res(2),:),1),K,'full'); %%%H2 Storage Discharging

        Objective = Objective ...
            + (h2_delivery_fuel/h2_storage_v(8)).*sum(sum(var_resiliency.h2_charge)); %%% Fuel Purchase Cost

        %         var_resiliency.charge = sdpvar(size(elec_res(T_res(1):T_res(2),:),1),K,'full'); %%%H2 Storage Charging
    end
    %%
    %%
    %% Resiliency Constraints
    %%
    %%
    %% Energy Balance
    Constraints = [Constraints
        (var_resiliency.pv_elec + var_resiliency.ees_dchrg + var_resiliency.dg_elec == ...
        var_resiliency.ees_chrg + elec_res(T_res(1):T_res(2),:)):'Critical electric load energy balance'];

    %% Solar Limits
    if ~isempty(pv_v) || ~isempty(pv_legacy)
        Constraints = [Constraints
            (0 <= var_resiliency.pv_elec):'Resiliency PV electircity >= 0'
            (var_resiliency.pv_elec <= repmat(solar(T_res(1):T_res(2)),1,K).*repmat(var_pv.pv_adopt,size(elec_res(T_res(1):T_res(2),:),1),1)):'Resiliency PV Production Limited by Capacity and solar potential'];
    end
    %% Battery Constraints
    if lees_on || lrees_on || ~isempty(ees_v)
        Constraints = [Constraints
            (0 <= [var_resiliency.ees_dchrg var_resiliency.ees_chrg var_resiliency.ees_soc]):'Battery resiliency variables are >= 0'
            ((1/ees_v(9)).*var_resiliency.ees_dchrg(end,:) <= var_resiliency.ees_soc(end,:) - ees_v(4).*(var_ees.ees_adopt + var_rees.rees_adopt)):'Fianl Discharge is limited to what is left in the battery'
            (var_resiliency.ees_soc(2:end,:) == ees_v(10)*var_resiliency.ees_soc(1:end-1,:) + ees_v(8).*var_resiliency.ees_chrg(1:end-1,:) - (1/ees_v(9).*var_resiliency.ees_dchrg(1:end-1,:))):'Resiliency Battery SOC energy balance'
            (ees_v(4).*repmat(var_ees.ees_adopt + var_rees.rees_adopt,T_resiliency_length,1) <= var_resiliency.ees_soc <=repmat(var_ees.ees_adopt + var_rees.rees_adopt,T_resiliency_length,1)):'Resiliency Battery SOC is limited by adopted capacity and battery depth of discharge'
            (var_resiliency.ees_chrg <= ees_v(6).*repmat(var_ees.ees_adopt + var_rees.rees_adopt,T_resiliency_length,1)):'Resiliency battery charging limits'
            (var_resiliency.ees_dchrg <= ees_v(7).*repmat(var_ees.ees_adopt + var_rees.rees_adopt,T_resiliency_length,1)):'Resiliency battery charging limits'
            (repmat(var_resiliency.ees_soc(1,:),T,1) <= var_rees.rees_soc + var_ees.ees_soc):'Battery SOC at the start is not higher than the minimum SOC experienced during the year'];


%             (repmat(var_resiliency.ees_soc(1,:),T,1) <= var_rees.rees_soc + var_ees.ees_soc):'EES SOC Starts at a lower level'
%             (var_resiliency.ees_soc(1,:) <= var_resiliency.ees_soc(end,:)):'Resiliency Battery end SOC is >= than starting SOC'
    end
    %% DGL Constraints
    if dgl_on
        Constraints = [Constraints
            (0 <=  var_resiliency.dg_elec <= repmat(var_dgl.dg_capacity,T_resiliency_length,1)):'DGL Resiliency limits'];
    end
    %% H2 Energy Storage Constraints
    if h2_storage_on

        h2_storage_index = [1:h2_storage_v(11)-1 h2_storage_v(11)+1:T_resiliency_length-1];
%         h2_storage_index = [1:T_resiliency_length-1];
        h2_charging_index = h2_storage_v(11);

        Constraints = [Constraints
            (0 <= var_resiliency.h2_soc(2:end,:)):'Resiliency H2 Storage SOC  is > 0'
            (0 <= var_resiliency.h2_charge):'Resiliency H2 Storage Chaging is > 0'
            (0 <= var_resiliency.h2_discharge):'Resiliency H2 Storage Discharge is > 0'
            (var_resiliency.dg_elec./dgl_v(2) <= var_resiliency.h2_discharge):'Resiliency H2 generator fuel input is equal to vented hydrogen + discharge'            
            (var_resiliency.h2_soc <= repmat(var_h2_storage.capacity,T_resiliency_length,1)):'Resiliency H2 SOC is limited by adotped capacity'  
            (var_resiliency.h2_soc(1,:) == 0):'H2 Storage Tanks are Initially Empty'
            (var_resiliency.h2_soc(h2_storage_index+1,:) == var_resiliency.h2_soc(h2_storage_index,:) - var_resiliency.h2_discharge(h2_storage_index,:) ):'Resiliency H2 Storage Energy Balance'
            (var_resiliency.h2_soc(h2_charging_index+1,:) == var_resiliency.h2_soc(h2_charging_index,:) + var_resiliency.h2_charge - var_resiliency.h2_discharge(h2_charging_index,:)):'Resiliency H2 Storage Energy Balance - Charging is Allowed'];


% 

           

%          + var_resiliency.h2_vent
% - var_resiliency.h2_vent(h2_storage_index,:)
%         (var_resiliency.h2_vent == var_resiliency.h2_soc.*h2_storage_v(10)):'Resiliency Venting is equal to boiloff form the tank'
%             ];


%             (var_resiliency.h2_soc(1,:) == 0):'Starting SOC is zero - only for LH2 storage'

        %             (var_resiliency.h2_soc(2:end,:) == var_resiliency.h2_soc(1:end-1,:) + var_resiliency.h2_charge(1:end-1,:) - var_resiliency.h2_discharge(1:end-1,:) - var_resiliency.h2_vent(1:end-1,:)):'H2 Storage Energy Balance'

        %     + var_resiliency.h2_charge(1:end-1,:)

        %          Constraints = [Constraints
        %             (var_h2_storage.soc(2:end,:) == var_h2_storage.soc(1:end-1,:) + var_h2_storage.charge(1:end-1,:) - var_h2_storage.dicharge(1:end-1,:) - var_h2_storage.vent(1:end-1,:)):'H2 Storage Energy Balance'
        %             (var_h2_storage.vent == var_h2_storage.soc.*h2_storage_v(10)):'Venting is equal to boiloff form the tank'
        %             (var_dgl.dg_elec./dgl_v(2) <= var_h2_storage.dicharge + var_h2_storage.vent):'H2 generator fuel input is equal to vented hydrogen + discharge'];



    end
end