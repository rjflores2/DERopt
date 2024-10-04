%% Declaring decision variables and setting up cost function
yalmip('clear')
clear var_util var_pv var_ees var_rees var_sgip var_sofc
Constraints=[];

T = length(time);     %t-th time interval from 1...T
K = size(elec,2);     %k-kth building from 
M = length(endpts);   %# of months in the simulation

%% Utility Electricity
if utility_exists
    %%%Electrical Import Variables
    var_util.import = sdpvar(T,K,'full'); %%%Electricity Imports
    var_util.export = sdpvar(T,K,'full'); %%%Electricity Export
    %     var_util.net_flow = sdpvar(T,K,'full'); %%%Net Electricity Flow
    if util_bin_on
        var_util.elec_sign = binvar(T,K,'full'); %%%Net Electricity Flow
    end
    
    %%%Demand Charge Variables
    %%%Only creating variables for # of months and number of applicable
    %%%rates, as defined with the binary dc_on input
    if sum(dc_exist)>0
        %%%Non TOU DC
        var_util.nontou_dc=sdpvar(M,sum(dc_exist),'full');
        
        %%%On Peak/ Mid Peak TOU DC
        if onpeak_count > 0
            var_util.onpeak_dc = sdpvar(onpeak_count,sum(dc_exist),'full');
        else
            var_util.onpeak_dc = 0;
        end
        if midpeak_count > 0
            var_util.midpeak_dc=sdpvar(midpeak_count,sum(dc_exist),'full');
        else
            var_util.midpeak_dc = 0;
        end
    else
        var_util.nontou_dc = 0;
        var_util.onpeak_dc = 0;
        var_util.midpeak_dc = 0;
    end
    
    %%% Cost of Imports + Demand Charges
    dc_count=1;
    
    %%%Allocating space
    import_cost = zeros(size(elec));
    export_value = zeros(size(elec));
    for i=1:K %%%Going through all buildings
        
        %%%Specify ESA eligible tenant fraction (Energy Savings Assistance Program (“ESA”)
        esa_frac = sum(apartment_types(i,1:2))/sum(apartment_types(i,:));
        if ~esa_on || isnan(esa_frac)
            esa_frac = 0;
        end
        
        %%%Find the applicable utility rate
        index=find(ismember(rate_labels,rate(i)));
        
        %%%Specifying cost function for Imported Electricity
        import_cost(:,i) = day_multi.*import_price(:,index).*(1-care_energy_rebate*esa_frac);
%         import_cost(:,i) = day_multi.*import_price(:,index);
        
        %%%Specifying cost function for exported Electricity
        export_value(:,i) = -day_multi.*export_price(:,index) - (nem3_0_credit_low_income - nem3_0_credit)*esa_frac;

    end
    
    %%%Import Energy charges
    Objective = sum(sum(var_util.import.*import_cost)) ...
        +  sum(sum(var_util.export.*export_value));

    %%%Clearing temporary cost function matrix
    for i =1:K
        if dc_exist(i) == 1
            %%%Find the applicable utility rate
            index=find(ismember(rate_labels,rate(i)));
            
            Objective =  Objective ...
                + sum(dc_nontou(index)*var_util.nontou_dc(:,dc_count))... %%%non TOU DC
                + sum(dc_on(index)*var_util.onpeak_dc(:,dc_count)) ... %%%On Peak DC
                + sum(dc_mid(index)*var_util.midpeak_dc(:,dc_count)); %%%Mid Peak DC
            %%% Utility_import * Demand_charge_rate
            
            %%%Index of DCs
            dc_count=dc_count+1;
        end
    end   
    
else
    %%%Electrical Import Variables
    var_util.import=zeros(T,K);
    var_util.export=zeros(T,K);
    var_util.net_flow=zeros(T,K);
    
    %%%Non TOU DC
    var_util.nontou_dc=zeros(M,sum(dc_exist));
    
    %%%On Peak/ Mid Peak TOU DC
    var_util.onpeak_dc=zeros(onpeak_count,sum(dc_exist));
    var_util.midpeak_dc=zeros(midpeak_count,sum(dc_exist));
end


%% Technologies That Can Be Adopted at Each Building Energy Hub
%% Solar PV
if isempty(pv_v) == 0
    
    %%%PV Generation to meet building demand (kWh)
    var_pv.pv_elec = sdpvar(T,K,'full'); %%% PV Production sent to the building
    
    %%%Size of installed System (kW)
    var_pv.pv_adopt= sdpvar(1,K,'full'); %%%PV Size
    
    if island == 0 && export_on == 1  %If grid tied, then include NEM and wholesale export
        
    else

    end
    
    %%%PV Cost
    Objective=Objective ...
        + sum(M*pv_mthly_debt.*pv_cap_mod'.*var_pv.pv_adopt)... %%%PV Capital Cost ($/kW installed)
        + pv_v(3)*(sum(sum(repmat(day_multi,1,K).*(var_pv.pv_elec)))); %%%PV O&M Cost ($/kWh generated)

    %%% Allow for adoption of Renewable paired storage when enabled (REES)
    if isempty(ees_v) == 0 && rees_on == 1
        
        %%%Adopted REES Size
        var_rees.rees_adopt= sdpvar(1,K,'full');
        %rees_adopt= semivar(1,K,'full');
        %%%REES Charging
        var_rees.rees_chrg=sdpvar(T,K,'full');
        %%%REES discharging
        var_rees.rees_dchrg=sdpvar(T,K,'full');        
        %%%REES SOC
        var_rees.rees_soc=sdpvar(T,K,'full');
        
        
        %%%REES Binary Variable
        if ees_bin_on
            var_rees.bin = binvar(T,K,'full');
        end
        
        %%%REES Cost Functions        
        Objective = Objective...
            + sum(rees_mthly_debt*M.*rees_cap_mod'.*var_rees.rees_adopt) ...%%%Capital Cost
            + ees_v(2)*sum(sum(repmat(day_multi,1,K).*var_rees.rees_chrg))... %%%Charging O&M
            + ees_v(3)*(sum(sum(repmat(day_multi,1,K).*(var_rees.rees_dchrg))));%%%Discharging O&M
        
    else
        var_rees.rees_adopt=zeros(1,K);
        var_rees.rees_chrg=zeros(T,K);
        var_rees.rees_dchrg=zeros(T,K);
        var_rees.rees_soc=zeros(T,K);
    end
    
else
    var_pv.pv_adopt=zeros([1 K]);
    var_pv.pv_elec=zeros([T K]);
    var_pv.pv_wholesale=zeros([T K]);
    var_rees.rees_adopt=zeros(1,K);
    var_rees.rees_chrg=zeros(T,K);
    var_rees.rees_dchrg=zeros(T,K);
    var_rees.rees_soc=zeros(T,K);
end
toc

%% SOMAH funding for Solar
if somah > 0 && sum(low_income) > 0
    var_somah.somah_capacity = sdpvar(1,sum(low_income>0),'full');
    
    Objective = Objective  ...
        + -sum(M*pv_mthly_debt.*pv_cap_mod(low_income == 1)'.*var_somah.somah_capacity);
    
%     sum(M*pv_mthly_debt.*pv_cap_mod'.*var_pv.pv_adopt)
else
    var_somah.somah_capacity = 0;
end

%% Electrical Energy Storage
if isempty(ees_v) == 0
    
    %%%Adopted EES Size
    var_ees.ees_adopt= sdpvar(1,K,'full');
    %ees_adopt = semivar(1,K,'full');
    %%%EES Charging
    var_ees.ees_chrg=sdpvar(T,K,'full');
    %%%EES discharging
    var_ees.ees_dchrg=sdpvar(T,K,'full');
    %%%EES SOC
    var_ees.ees_soc=sdpvar(T,K,'full');
    
    %%%EES Cost Functions
    Objective = Objective...
        + sum(ees_mthly_debt*M.*ees_cap_mod'.* var_ees.ees_adopt) ...%%%Capital Cost
        + ees_v(2)*sum(sum(repmat(day_multi,1,K).* var_ees.ees_chrg)) ...%%%Charging O&M
        + ees_v(3)*sum(sum(repmat(day_multi,1,K).* var_ees.ees_dchrg));%%%Discharging O&M
    
    %%%SGIP rates
    if sgip_on
        %%%Residential Credits
        var_sgip.sgip_ees_npbi = sdpvar(1,sum((res_units>0).*(~low_income>0)),'full');
        %%%Residential Equity Credits
        var_sgip.sgip_ees_npbi_equity = sdpvar(1,sum(low_income>0),'full');
        
        Objective = Objective ...
            - sum(sgip_mthly_benefit(2)*M*var_sgip.sgip_ees_npbi) ...
            - sum(sgip_mthly_benefit(3)*M*var_sgip.sgip_ees_npbi_equity);
        
        if sum(sgip_pbi)>0
            %%% Performance based incentives
            var_sgip.sgip_ees_pbi = sdpvar(3,sum(sgip_pbi),'full');
            
            Objective = Objective ...
                - sum(sgip_mthly_benefit(1)*M*var_sgip.sgip_ees_pbi(1,:)) ...
                - sum(sgip_mthly_benefit(1)*0.5*M*var_sgip.sgip_ees_pbi(2,:)) ...
                - sum(sgip_mthly_benefit(1)*0.25*M*var_sgip.sgip_ees_pbi(3,:));
        else
            var_sgip.sgip_ees_pbi = zeros(3,1);
        end
    else
        var_sgip.sgip_ees_pbi = zeros(3,1);
        var_sgip.sgip_ees_npbi = 0;
        var_sgip.sgip_ees_npbi_equity = 0;
    end
    
else
    var_ees.ees_adopt=zeros(1,K);
    var_ees.ees_soc=zeros(T,K);
    var_ees.ees_chrg=zeros(T,K);
    var_ees.ees_dchrg=zeros(T,K);
    var_sgip.sgip_ees_pbi = zeros(3,1);
    var_sgip.sgip_ees_npbi = 0;
    var_sgip.sgip_ees_npbi_equity = 0;
end
toc

%% Legacy Technologies
%% Generic DG
%% Legacy PV
%%%Only need to add variables if new PV is not considered
if isempty(pv_legacy) == 0 && isempty(pv_v) == 1
    
    if island == 0 && export_on == 1 %If grid tied, then include NEM and wholesale export
      
    else
     
    end
    
    %%%PV Generation to meet building demand (kWh)
    var_pv.pv_elec = sdpvar(T,K,'full'); %%% PV Production sent to the building
    
    %%%Operating Costs
    Objective=Objective ...
        + pv_legacy(1)*(sum(sum(repmat(day_multi,1,K).*(var_pv.pv_elec))));
    
end

%% Legacy EES
if lees_on
    
    %ees_adopt = semivar(1,K,'full');
    %%%EES Charging
    var_lees.ees_chrg = sdpvar(T,K,'full');
    %%%EES discharging
    var_lees.ees_dchrg = sdpvar(T,K,'full');
    %%%EES SOC
    var_lees.ees_soc = sdpvar(T,K,'full');
    
    %%%EES Cost Functions
    Objective = Objective...
        + ees_legacy(1)*sum(sum(repmat(day_multi,1,K).* var_lees.ees_chrg)) ...%%%Charging O&M
        + ees_legacy(2)*sum(sum(repmat(day_multi,1,K).* var_lees.ees_dchrg));%%%Discharging O&M
    
else
    
    var_lees.ees_soc=zeros(T,K);
    var_lees.ees_chrg=zeros(T,K);
    var_lees.ees_dchrg=zeros(T,K);
end

%% Legacy REES
if lrees_on
    
    %ees_adopt = semivar(1,K,'full');
    %%%EES Charging
    var_lrees.rees_chrg = sdpvar(T,K,'full');
    %%%EES discharging
    var_lrees.rees_dchrg = sdpvar(T,K,'full');
    %%%EES SOC
    var_lrees.rees_soc = sdpvar(T,K,'full');
    
    %%%EES Cost Functions
    Objective = Objective...
        + rees_legacy(1)*sum(sum(repmat(day_multi,1,K).* var_lrees.rees_chrg)) ...%%%Charging O&M
        + rees_legacy(2)*sum(sum(repmat(day_multi,1,K).* var_lrees.rees_dchrg));%%%Discharging O&M
    
    
    if island ~= 1 % If not islanded, AEC can export NEM and wholesale for revenue

        
    else

    end
    
else
    
    var_lrees.rees_soc=zeros(T,K);
    var_lrees.rees_chrg=zeros(T,K);
    var_lrees.rees_dchrg=zeros(T,K);

end

%% Electrical Infrastructure Constraints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% LDN Transformers %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if xfmr_on && acpf_sim < 1
    N = length(unique(xfmr_subset));
    %%%Real Power
    var_xfmr.Pinj = sdpvar(N,T,'full'); %kW
    %%%Reactive Power
    %  var_xfmr.Qinj = sdpvar(T,length(t_map),'full'); %kVAR
else
     var_xfmr.Pinj = 0
end

%% LinDistFlow
if acpf_sim == 1
    N = length(bb_lbl) - 1;
    B = size(branch_bus,1);
    var_ldf.pflow = sdpvar(B,T,'full');
     var_xfmr.Pinj = sdpvar(N,T,'full'); %kW
   
else
    var_ldf.pflow = zeros(T,1);
end

%% SOFC
if sofc_on
    % Declaring Variables    
    var_sofc.sofc_adopt = sdpvar(1,K,'full');      %%%SOFC installed capacity (kW)
    var_sofc.sofc_elec = sdpvar(T,K,'full');       %%%SOFC electricity produced (kWh) 
    var_sofc.sofc_heat = sdpvar(T,K,'full');       %%%SOFC heat produced (kWh) 
    var_sofc.sofc_fuel = sdpvar(T,K,'full');       %%%Fuel consumption (kWh) 
    var_sofc.sofc_CO2 = sdpvar(T,K,'full');        %%%CO2 saving (kg)
    
    % SOFC cost function
    
else
    var_sofc.sofc_adopt = zeros(1,1);      %%%SOFC installed capacity (kW)
    var_sofc.sofc_elec = zeros(T,K);       %%%SOFC electricity produced (kWh)
    var_sofc.sofc_heat = zeros(T,1);       %%%SOFC heat produced (kWh)
    var_sofc.sofc_fuel = zeros(T,1);       %%%Fuel consumption (kWh)
    var_sofc.sofc_CO2 = zeros(T,1);        %%%CO2 saving (kg)
end

%% DGL - Linear DG Model
if dgl_on
   
    var_dgl.dg_capacity = sdpvar(1,K,'full');      %%%SOFC installed capacity (kW)

dgl_cap_mod = ones(size(var_dgl.dg_capacity ));
dgl_cap_mod(res_idx) = 3300/2000;
dgl_cap_mod(~res_idx) = 1500/2000;


    Objective = Objective ...
        + sum(M.*dgl_mthly_debt.*dgl_cap_mod.*var_dgl.dg_capacity);

    if ~h2_systems_for_resiliency_only
        var_dgl.dg_elec = sdpvar(T,K,'full');       %%%SOFC electricity produced (kWh)
        if dgl_pipeline_fuel>0
            Objective = Objective ...
                + sum(sum(var_dgl.dg_elec)).*(dgl_pipeline_fuel./dgl_v(2));
        end
    else
        var_dgl.dg_elec = zeros(T,K);
    end
else
    var_dgl.dg_elec = zeros(T,K);
end

%% H2 Energy Storage
if h2_storage_on
    var_h2_storage.capacity = sdpvar(1,K,'full');      %%%H2 storage installed capacity (kWh)

     Objective = Objective ...
        + sum(M.*h2_storage_mthly_debt.*var_h2_storage.capacity); %%%H2 Storage Capital Cost
    
    if ~h2_systems_for_resiliency_only
        var_h2_storage.soc = sdpvar(T,K,'full'); %%%H2 storage state of charge (kWh)
        var_h2_storage.charge = sdpvar(T,K,'full'); %%%H2 Storage Charging
        var_h2_storage.dicharge = sdpvar(T,K,'full'); %%%H2 Storage Discharging
        var_h2_storage.vent = sdpvar(T,K,'full'); %%%H2 Storage Discharging

         Objective = Objective ...
             + (h2_delivery_fuel/h2_storage_v(8)).*sum(sum(var_h2_storage.charge)); %%% Fuel Purchase Cost
    end
end
%% DG - Continuous Capacity after Binary Adoption
if dgb_on
    %Variables
    %     var_dgb.dgb_adopt = binvar(1,K,'full');      %%%SOFC installed capacity (kW)
    %     var_dgb.dgb_capacity = sdpvar(1,K,'full');      %%%SOFC installed capacity (kW)
    %     var_dgb.dgb_elec = sdpvar(T,K,'full');       %%%SOFC electricity produced (kWh)
    %     var_dgb.dgb_fuel = sdpvar(T,K,'full');       %%%Fuel consumption (kWh)
    
    
    var_dgb.dgb_adopt = binvar(1,1,'full');      %%%SOFC installed capacity (kW)
    var_dgb.dgb_capacity = sdpvar(1,1,'full');      %%%SOFC installed capacity (kW)
    var_dgb.dgb_elec = sdpvar(T,1,'full');       %%%SOFC electricity produced (kWh)
    var_dgb.dgb_fuel = sdpvar(T,1,'full');       %%%Fuel consumption (kWh)
    
    
    var_dgb.dgb_adopt = [var_dgb.dgb_adopt zeros(1,K-1)];
    var_dgb.dgb_capacity = [var_dgb.dgb_capacity zeros(1,K-1)];
    var_dgb.dgb_elec = [var_dgb.dgb_elec zeros(T,K-1)];
    var_dgb.dgb_fuel = [var_dgb.dgb_fuel zeros(T,K-1)];
    
    %%%Cost funciton
    Objective = Objective...
        + sum(dgb_mthly_fixed_debt*M.*var_dgb.dgb_adopt) ...%%%Capital Cost - Capacity
        + sum(dgb_mthly_var_debt*M.*var_dgb.dgb_capacity) ...%%%Capital Cost - Capacity
        + 0.*sum(sum(var_dgb.dgb_elec)) ... %%% O&M Cost
        + sum(ng_cost'.*sum(var_dgb.dgb_fuel)); %%%Fuel Costs
    
else
    %Variables
    var_dgb.dgb_adopt = zeros(1,1);     %%%SOFC installed capacity (kW)
    var_dgb.dgb_capacity = zeros(1,1);
    var_dgb.dgb_elec = zeros(1,1);       %%%SOFC electricity produced (kWh)
    var_dgb.dgb_fuel = zeros(1,1);       %%%Fuel consumption (kWh)
end

%% DG - Continuous
if dgc_on
    var_dgc.dgc_adopt = sdpvar(1,K,'full');      %%%SOFC installed capacity (kW)
    var_dgc.dgc_elec = sdpvar(T,K,'full');       %%%SOFC electricity produced (kWh)
    var_dgc.dgc_fuel = sdpvar(T,K,'full');       %%%Fuel consumption (kWh)
    
    %%%Cost funciton
    Objective = Objective...
        + sum(dgc_mthly_debt*M.*var_dgc.dgc_adopt) ...%%%Capital Cost - Capacity
        + dgc_v(2).*sum(sum(var_dgc.dgc_elec)) ... %%% O&M Cost
        + sum(ng_cost'.*sum(var_dgc.dgc_fuel)); %%%Fuel Costs
    
else
    var_dgc.dgc_adopt = zeros(1,1);     %%%SOFC installed capacity (kW)
    var_dgc.dgc_elec = zeros(1,1);       %%%SOFC electricity produced (kWh)
    var_dgc.dgc_fuel = zeros(1,1);       %%%Fuel consumption (kWh)
end