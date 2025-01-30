%% Declaring decision variables and setting up cost function
yalmip('clear')
clear var*
Constraints=[];

T = length(time);     %t-th time interval from 1...T
% K = size(elec,2);     %k-kth building from 
M = length(endpts);   %# of months in the simulation

% Objective = [];

%% Utility Electricity
% if isempty(utility_exists) == 0
if utility_exists 
    %%%Electrical Import Variables
    var_util.import = sdpvar(T,1,'full');
    
    %%%Demand Charge Variables
    %%%Only creating variables for # of months and number of applicable
    %%%rates, as defined with the binary dc_on input
    if sum(dc_exist)>0
        %%%Non TOU DC
        var_util.nontou_dc=sdpvar(M,1,'full');
        
        %%%On Peak/ Mid Peak TOU DC
        if onpeak_count > 0
            var_util.onpeak_dc=sdpvar(onpeak_count,1,'full');
            var_util.midpeak_dc=sdpvar(midpeak_count,1,'full');
        else
            var_util.onpeak_dc = 0;
            var_util.midpeak_dc = 0;
        end
    end
    
    %%% Cost of Imports + Demand Charges
    dc_count=1;
    
    %%%Allocating space
    temp_cf = zeros(size(elec));
    
    %%%Find the applicable utility rate
    index=find(ismember(rate_labels,rate(1)));
    
    %%%Import Energy charges
    %     Objective = sum(sum(var_util.import.*temp_cf));
    Objective = sum(sum(var_util.import.*(day_multi.*import_price(:,index))));
    
    %%%Clearing temporary cost function matrix
    clear temp_cf
    
    if dc_exist == 1
        %%%Find the applicable utility rate
        index=find(ismember(rate_labels,rate(1)));
        
        Objective =  Objective ...
            + sum(dc_nontou(index)*var_util.nontou_dc(:,dc_count))... %%%non TOU DC
            + sum(dc_on(index)*var_util.onpeak_dc(:,dc_count)) ... %%%On Peak DC
            + sum(dc_mid(index)*var_util.midpeak_dc(:,dc_count)); %%%Mid Peak DC
        %%% Utility_import * Demand_charge_rate
        
        %%%Index of DCs
        dc_count=dc_count+1;
    end
%     end   
    
else
    Objective = 0;
    %%%Electrical Import Variables
    var_util.import=zeros(T,1);
    
    %%%Non TOU DC
    var_util.nontou_dc=zeros(M,1);
    
    %%%On Peak/ Mid Peak TOU DC
    var_util.onpeak_dc=zeros(T,1);
    var_util.midpeak_dc=zeros(T,1);
end

%% General export
%%% General export allows export from any onsite resource, regardless of
%%% fuel source
if exist('gen_export_on') && gen_export_on
    var_util.gen_export = sdpvar(T,1,'full');
    var_util.import_state = binvar(T,1,'full');
    Objective =  Objective ...
         + -sum(var_util.gen_export.*export_price);
else
    var_util.gen_export = zeros(T,1);
    var_util.import_state = ones(T,1);
end

%% Technologies That Can Be Adopted at Each Building Energy Hub

%% RSOC

if rsoc_on
    var_rsoc.rsoc_electrolyzer = sdpvar(T, size(rsoc_v, 2), 'full');
    var_rsoc.rsoc_capacity = sdpvar(1, size(rsoc_v, 2), 'full');
    var_rsoc.rsoc_fuel_cell = sdpvar(T, size(rsoc_v, 2), 'full');
    var_rsoc.rsoc_switch = intvar(1, size(rsoc_v, 2), 'full');

    Fuel_Cell_OaM = .5*rsoc_monthly_debt;
    Electrolyzer_OaM = Fuel_Cell_OaM;
    start_cost = 500;

    Objective = Objective ...
        + sum(M*(rsoc_monthly_debt+Fuel_Cell_OaM+Electrolyzer_OaM).*4*var_rsoc.rsoc_capacity+start_cost*var_rsoc.rsoc_switch);

    
end
%% Solar PV
if pv_on 
    
    %%%PV Generation to meet building demand (kWh)
    var_pv.pv_elec = sdpvar(T,size(pv_v,2),'full'); %%% PV Production sent to the building
    
    %%%Size of installed System (kW)
    var_pv.pv_adopt= sdpvar(1,size(pv_v,2),'full'); %%%PV Size
    
    %%%PV Cost

    Objective = Objective ...
        + sum(M*pv_mthly_debt.*pv_cap_mod.*var_pv.pv_adopt) ... %%%PV Capital Cost ($/kW installed)
        + sum(sum((pv_v(3,:).*day_multi).*(var_pv.pv_elec)));  %%%PV O&M Cost ($/kWh generated)    
%         + sum(sum((pv_v(3,:).*day_multi).*(var_pv.pv_nem))); %%%PV O&M Cost ($/kWh generated)
%         + pv_v(3)*(sum(sum(repmat(day_multi,1,K).*(var_pv.pv_elec + var_pv.pv_nem + pv_wholesale))) ); %%%PV O&M Cost ($/kWh generated)

    %%% Allow for adoption of Renewable paired storage when enabled (REES)
    if isempty(ees_v) == 0 && rees_on == 1
        
        %%%Adopted REES Size
        var_rees.rees_adopt= sdpvar(1,size(ees_v,2),'full');
        %var_rees.rees_adopt= semivar(1,K,'full');
        %%%REES Charging
        var_rees.rees_chrg=sdpvar(T,size(ees_v,2),'full');
        %%%REES discharging
        var_rees.rees_dchrg=sdpvar(T,size(ees_v,2),'full');
        
        %%%REES SOC
        var_rees.rees_soc=sdpvar(T,size(ees_v,2),'full');
        %%%REES Cost Functions 
        for ii = 1:size(ees_v,2)
            Objective = Objective...
                + sum(rees_mthly_debt(ii)*M.*rees_cap_mod(ii)'.*var_rees.rees_adopt(ii)) ...%%%Capital Cost
                + ees_v(2,ii)*sum(sum(day_multi.*var_rees.rees_chrg(:,ii)))... %%%Charging O&M
                + ees_v(3,ii)*(sum(sum(day_multi.*(var_rees.rees_dchrg(:,ii)))));%%%Discharging O&M
            
            
        end
    else
        var_rees.rees_adopt=zeros(1,1);
        var_rees.rees_chrg=zeros(T,size(pv_v,2));
        var_rees.rees_dchrg=zeros(T,1);
        var_rees.rees_soc=zeros(T,1);
    end
    
else
    var_pv.pv_adopt=zeros([1 1]);
    var_pv.pv_elec=zeros([T 1]);
    var_rees.rees_adopt=zeros(1,1);
    var_rees.rees_chrg=zeros(T,1);
    var_rees.rees_dchrg=zeros(T,1);
    var_rees.rees_soc=zeros(T,1);
end
%% Electrical Energy Storage
if isempty(ees_v) == 0
    
    %%%Adopted EES Size
    var_ees.ees_adopt= sdpvar(1,size(ees_v,2),'full');
    %var_ees.ees_adopt = semivar(1,K,'full');
    %%%EES Charging
    var_ees.ees_chrg=sdpvar(T,size(ees_v,2),'full');
    %%%EES discharging
    var_ees.ees_dchrg=sdpvar(T,size(ees_v,2),'full');
    %%%EES SOC
    var_ees.ees_soc=sdpvar(T,size(ees_v,2),'full');
    
    
    for ii = 1:size(ees_v,2)
        %%%EES Cost Functions
        Objective = Objective...
            + sum(ees_mthly_debt(ii)*M.*ees_cap_mod(ii)'.*var_ees.ees_adopt(ii)) ...%%%Capital Cost
            + ees_v(2,ii)*sum(sum(day_multi.*var_ees.ees_chrg(:,ii))) ...%%%Charging O&M
            + ees_v(3,ii)*sum(sum(day_multi.*var_ees.ees_dchrg(:,ii)));%%%Discharging O&M
    end
    %%%SGIP rates
    if exist('sgip_on') && sgip_on
        
% % %         Begin comments here
%         %%%Residential Credits
%         var_sgip.sgip_ees_npbi = sdpvar(1,sum((res_units>0).*(~low_income>0)),'full');
%         %%%Residential Equity Credits
%         var_sgip.sgip_ees_npbi_equity = sdpvar(1,sum(low_income>0),'full');
%         
%         Objective = Objective ...
%             - sum(sgip(3)*M*var_sgip.sgip_ees_npbi) ...
%             - sum(sgip(4)*M*var_sgip.sgip_ees_npbi_equity);
%         
%         if sum(sgip_pbi)>0
%             %%% Performance based incentives
%             var_sgip.sgip_ees_pbi = sdpvar(3,sum(sgip_pbi),'full');
%             
%             Objective = Objective ...
%                 - sum(sgip(2)*M*var_sgip.sgip_ees_pbi(1,:)) ...
%                 - sum(sgip(2)*0.5*M*var_sgip.sgip_ees_pbi(2,:)) ...
%                 - sum(sgip(2)*0.25*M*var_sgip.sgip_ees_pbi(3,:));
%         else
%             var_sgip.sgip_ees_pbi = zeros(3,1);
%         end
        
        %%% End Comments Here
    else
        var_sgip.sgip_ees_pbi = zeros(3,1);
        var_sgip.sgip_ees_npbi = 0;
        var_sgip.sgip_ees_npbi_equity = 0;
    end
    
else
    var_ees.ees_adopt = zeros(1,1);
    var_ees.ees_soc = zeros(T,1);
    var_ees.ees_chrg = zeros(T,1);
    var_ees.ees_dchrg = zeros(T,1);
end


%% Renewable Electrolyzer
if ~isempty(rel_v)
    
    %%%Electrolyzer efficiency
    rel_eff = ones(T,size(rel_v,2));
    for ii = 1:size(rel_v,2)
        rel_eff(:,ii) = (1/rel_v(3,ii)).*rel_eff(:,ii);
    end
    
    %%%Adoption technologies
    var_rel.rel_adopt = sdpvar(1,size(rel_v,2),'full');
    %%%Electrolyzer production
    var_rel.rel_prod = sdpvar(T,size(rel_v,2),'full');
    
    % if util_pv_wheel_lts
    %     var_rel.rel_prod_wheel = sdpvar(T,size(el_v,2),'full');
    % else
    %     var_rel.rel_prod_wheel = zeros(T,size(el_v,2));
    % end
    
    for ii = 1:size(rel_v,2)
        %%%Electrolyzer Cost Functions
        Objective = Objective...
            + sum(M.*rel_mthly_debt.*var_rel.rel_adopt) ... %%%Capital Cost
            + sum(sum(var_rel.rel_prod + var_rel.rel_prod_wheel).*rel_v(2,:)); %%%VO&M
    end
    
    
    
    if isempty(el_v) && ~isempty(h2es_v)
        %%%Clearing prior values
        var_h2es.h2es_chrg = [];
        var_h2es.h2es_dchrg = [];
        %%%H2 Storage
        %%%Adopted EES Size
        var_h2es.h2es_adopt = sdpvar(1,size(h2es_v,2),'full');
        %var_ees.ees_adopt = semivar(1,K,'full');
        %%%EES Charging
        var_h2es.h2es_chrg = sdpvar(T,size(h2es_v,2),'full');
        %%%EES discharging
        var_h2es.h2es_dchrg = sdpvar(T,size(h2es_v,2),'full');
        
        %%%H2ES Operational State Binary Variables
        if strict_h2es
            var_h2es.h2es_bin = binvar(T,size(h2es_v,2),'full');
        else
            var_h2es.h2es_bin = sdpvar(T,size(h2es_v,2),'full');
        end
        
        %%%EES SOC
        var_h2es.h2es_soc = sdpvar(T,size(h2es_v,2),'full');
        for ii = 1:size(h2es_v,2)
            %%%Electrolyzer Cost Functions
            Objective = Objective...
                + sum(M.*h2es_mthly_debt.*var_h2es.h2es_adopt) ... %%%Capital Cost
                + sum(sum(var_h2es.h2es_chrg).*h2es_v(2,:)) ... %%%Charging Cost
                + sum(sum(var_h2es.h2es_dchrg).*h2es_v(3,:)); %%%Discharging Cost
        end
        
        h2_chrg_eff = 1 - h2es_v(8,:);
    end
    
else
    var_rel.rel_adopt = 0;
    var_rel.rel_prod = zeros(T,size(pv_v,2));
    var_rel.rel_prod_wheel = zeros(T,1);
    var_h2es.h2es_chrg = zeros(T,1);
    var_h2es.h2es_dchrg = zeros(T,1);
    el_eff = zeros(T,1);
    rel_eff = 0;
end
%% Electrolyzer - binary model
if ~isempty(el_binary_v)

    %%%Electrolyzer efficiency
    el_binary_eff = ones(T,size(el_binary_v,2));
    for ii = 1:size(el_binary_v,2)
        el_binary_eff(:,ii) = (1/el_binary_v(3,ii)).*el_binary_eff(:,ii);
    end

    %%%Adoption technologies
    var_el_binary.el_adopt = sdpvar(1,size(el_binary_v,2),'full');
    %%%Electrolyzer production
    var_el_binary.el_prod = sdpvar(T,size(el_binary_v,2),'full');
    %%%Electrolyzer on/off
    var_el_binary.el_onoff = binvar(T,size(el_binary_v,2),'full');


    for ii = 1:size(el_binary_eff,2)
        %%%Electrolyzer Cost Functions
        Objective = Objective...
            + sum(M.*el_binary_mthly_debt.*var_el_binary.el_adopt) ... %%%Capital Cost
            + sum(sum(var_el_binary.el_prod ).*el_binary_v(2,:)); %%%VO&M
    end
else
    %%%Electrolyzer efficiency
    el_binary_eff = zeros(T,size(el_binary_v,2));
    var_el_binary.el_prod = zeros(T,size(el_binary_v,2));
end
%% H2 storage
 if ~isempty(h2es_v)
        %%%H2 Storage
        %%%Adopted EES Size
        var_h2es.h2es_adopt = sdpvar(1,size(h2es_v,2),'full');
        %var_ees.ees_adopt = semivar(1,K,'full');
        %%%EES Charging
        var_h2es.h2es_chrg = sdpvar(T,size(h2es_v,2),'full');
        %%%EES discharging
        var_h2es.h2es_dchrg = sdpvar(T,size(h2es_v,2),'full');
        
        %%%H2ES Operational State Binary Variables
        if exist('strict_h2es') && strict_h2es
            var_h2es.h2es_bin = binvar(T,size(h2es_v,2),'full');
        else
            var_h2es.h2es_bin = sdpvar(T,size(h2es_v,2),'full');
        end
        
        %%%EES SOC
        var_h2es.h2es_soc = sdpvar(T,size(h2es_v,2),'full');
        for ii = 1:size(h2es_v,2)
            %%%Electrolyzer Cost Functions
            Objective = Objective...
                + sum(M.*h2es_mthly_debt.*var_h2es.h2es_adopt) ... %%%Capital Cost
                + sum(sum(var_h2es.h2es_chrg).*h2es_v(2,:)) ... %%%Charging Cost
                + sum(sum(var_h2es.h2es_dchrg).*h2es_v(3,:)); %%%Discharging Cost
        end
        
        h2_chrg_eff = 1 - h2es_v(8,:);
    end
%% H2 Production and Storage

%%%Electrolyzer
if ~isempty(el_v)
    
    %%%Electrolyzer efficiency
    el_eff = ones(T,size(el_v,2));
    for ii = 1:size(el_v,2)
        el_eff(:,ii) = (1/el_v(3,ii)).*el_eff(:,ii);
    end
    
    %%%Adoption technologies
    var_el.el_adopt = sdpvar(1,size(el_v,2),'full');
    %%%Electrolyzer production
    var_el.el_prod = sdpvar(T,size(el_v,2),'full');
    
    if exist('util_pv_wheel_lts') && util_pv_wheel_lts
        var_el.el_prod_wheel = sdpvar(T,size(el_v,2),'full');
    else
        var_el.el_prod_wheel = zeros(T,size(el_v,2));
    end
    
    for ii = 1:size(el_v,2)
        %%%Electrolyzer Cost Functions
        Objective = Objective...
            + sum(M.*el_mthly_debt.*var_el.el_adopt) ... %%%Capital Cost
            + sum(sum(var_el.el_prod + var_el.el_prod_wheel).*el_v(2,:)); %%%VO&M
    end
    
    if ~isempty(h2es_v)
        %%%H2 Storage
        %%%Adopted EES Size
        var_h2es.h2es_adopt = sdpvar(1,size(h2es_v,2),'full');
        %var_ees.ees_adopt = semivar(1,K,'full');
        %%%EES Charging
        var_h2es.h2es_chrg = sdpvar(T,size(h2es_v,2),'full');
        %%%EES discharging
        var_h2es.h2es_dchrg = sdpvar(T,size(h2es_v,2),'full');
        
        %%%H2ES Operational State Binary Variables
        if exist('strict_h2es') && strict_h2es
            var_h2es.h2es_bin = binvar(T,size(h2es_v,2),'full');
        else
            var_h2es.h2es_bin = sdpvar(T,size(h2es_v,2),'full');
        end
        
        %%%EES SOC
        var_h2es.h2es_soc = sdpvar(T,size(h2es_v,2),'full');
        for ii = 1:size(h2es_v,2)
            %%%Electrolyzer Cost Functions
            Objective = Objective...
                + sum(M.*h2es_mthly_debt.*var_h2es.h2es_adopt) ... %%%Capital Cost
                + sum(sum(var_h2es.h2es_chrg).*h2es_v(2,:)) ... %%%Charging Cost
                + sum(sum(var_h2es.h2es_dchrg).*h2es_v(3,:)); %%%Discharging Cost
        end
        
        h2_chrg_eff = 1 - h2es_v(8,:);
    end
    
else
    h2_chrg_eff = 0;
    var_el.el_adopt = 0;
    var_el.el_prod = zeros(T,1);
    var_el.el_prod_wheel = zeros(T,1);
    el_eff = zeros(T,1);
end

%%
if exist('pemfc_on') && pemfc_on
    var_pem.cap = sdpvar(1,1,'full');
    var_pem.elec = sdpvar(T,1,'full');
    
if pem_v(4)>0
    var_pem.onoff = binvar(T,1,'full');
else
    var_pem.onoff = [];
end


    Objective = Objective ...
        + sum(M.*pem_mthly_debt.*var_pem.cap) ... %PEM Capital Cost
        + sum(pem_v(3).*var_pem.elec); %Varable O&M

    
else
    var_pem.cap = 0;
    var_pem.elec = zeros(T,1);
    var_pem.onoff = [];
end

%% HRS equipment
if exist('hrs_on') && hrs_on
    %%%Adopt hrs supply equipment?
    var_hrs.hrs_supply_adopt = binvar(1,1,'full');
    
    %%%HRS Supply from a tube trailer
    var_hrs.hrs_tube = sdpvar(T,1,'full');
    
    %%%HRS Supply from CP H2
    var_hrs.hrs_supply = sdpvar(T,1,'full');
    
    Objective = Objective ...
        + M*hrs_mthly_debt*var_hrs.hrs_supply_adopt ...
        + sum(var_hrs.hrs_supply)*hrs_v(3) ...
        + sum(var_hrs.hrs_tube)*hrs_v(4);
    
        hrs_chrg_eff = 1 - hrs_v(2);
else
    var_hrs.hrs_supply_adopt = 0;
    var_hrs.hrs_tube = zeros(T,1);
    var_hrs.hrs_supply = zeros(T,1);
    hrs_chrg_eff = 1;
end

%% H2 Pipeline Injection
if exist('h2_inject_on') && h2_inject_on
    %%%Adopt HRS Equipment
    var_h2_inject.h2_inject_adopt = binvar(1,1,'full');
    %%%Size of adopted HRS Equipment
    var_h2_inject.h2_inject_size = sdpvar(1,1,'full');
    %%%Injected Hydrogen
    var_h2_inject.h2_inject = sdpvar(T,1,'full');
    %%%Stored Hydrogen
    var_h2_inject.h2_store = sdpvar(T,1,'full');
    
    
     Objective = Objective ...
       + M*h2_inject_mthly_debt(1)*var_h2_inject.h2_inject_adopt ...
       + M*h2_inject_mthly_debt(2)*var_h2_inject.h2_inject_size ...
       - ng_inject.*sum(var_h2_inject.h2_inject) ...
       + rng_storage_cost.*sum(var_h2_inject.h2_store);
else
    var_h2_inject.h2_inject = zeros(T,1);
    var_h2_inject.h2_inject_size = 0;
    var_h2_inject.h2_inject_adopt = 0;
    var_h2_inject.h2_store = zeros(T,1);
end
    
%% Run of river options
if exist('ror_integer_on') && ror_integer_on
    var_ror_integer.units = intvar(1,size(river_power_potential,2),'full');
    var_ror_integer.elec = sdpvar(T,size(river_power_potential,2),'full');

    Objective = Objective ...
        + sum(M.*ror_mthly_debt.*ror_integer_v(2,:).*var_ror_integer.units);
else
    var_ror_integer.units = 0;
    var_ror_integer.elec = zeros(T,1);
end
%% Wave_ Power
if exist('wave_on') && wave_on 
   var_wave.electricity = sdpvar(T,size(wave_power_potential,2),'full');
   var_wave.power = sdpvar(1,size(wave_power_potential,2),'full');
   
    Objective=Objective ...
        + sum(sum(wave_v.*var_wave.electricity)) ...
        + 0.*sum(var_wave.power);
   
else
    var_wave.electricity = zeros(T,1);
end

%% Renewable Electrolyze
%% Legacy Technologies
%% Legacy Generic generator 
if exist('ldiesel_on') && ldiesel_on
    var_legacy_diesel.electricity = sdpvar(T,size(ldiesel_v,2),'full');
    
    Objective = Objective ...
       + sum(sum(var_legacy_diesel.electricity,1).*(ldiesel_v(3,:) + (1./ldiesel_v(2,:)).*diesel_cost));
else
    var_legacy_diesel.electricity = zeros(T,1);
end

%% Legacy Generic Generator that has part load constraint
if exist('ldiesel_binary_on') && ldiesel_binary_on
    var_legacy_diesel_binary.electricity = sdpvar(T,size(ldiesel_binary_v,2),'full');
    var_legacy_diesel_binary.operational_state = intvar(T,size(ldiesel_binary_v,2),'full');
    
    Objective = Objective ...
       + sum(sum(var_legacy_diesel_binary.electricity,1).*(ldiesel_binary_v(3,:) + (1./ldiesel_binary_v(2,:)).*diesel_cost));
else
    var_legacy_diesel_binary.electricity = zeros(T,1);
    var_legacy_diesel_binary.operational_state = zeros(T,1);
end

%% Legacy PV
%%%Only need to add variables if new PV is not considered
if lpv_on && ~pv_on %%exist('pv_legacy') && isempty(pv_legacy) == 0 && sum(pv_legacy(2,:)) > 0 &&  isempty(pv_v)
    
    if island == 0 && export_on == 1 %If grid tied, then include NEM and wholesale export
        %%% Variables that exist when grid tied
        var_pv.pv_nem = [];
        var_pv.pv_nem = sdpvar(T,1,'full'); %%% PV Production exported w/ NEM

            %%%Utility rates for building k
            index=find(ismember(rate_labels,rate(1)));
            
            %%%Adding values to the cost function
            Objective = Objective...
                + sum(sum(-day_multi.*export_price(:,index).*var_pv.pv_nem)); %%%NEM Revenue Cost
        
    else
        var_pv.pv_nem=zeros(T,1);
    end
    
    %%%PV Generation to meet building demand (kWh)
    var_pv.pv_elec = [];
    var_pv.pv_elec = sdpvar(T,1,'full'); %%% PV Production sent to the building
    
    %%%Operating Costs
    Objective=Objective ...
        + pv_legacy(1,1)*(sum(sum(day_multi.*(var_pv.pv_elec + var_pv.pv_nem))));
    
else
    %%%If Legacy PV does not exist, then make the existing pv value zero
%     pv_legacy = zeros(1,size(pv_v,2));
end

%% LEgacy Run-of-river system
if lror_on && exist('river_power_potential')
   var_run_of_river.electricity = sdpvar(T,size(river_power_potential,2),'full');
   var_run_of_river.swept_area = sdpvar(1,size(river_power_potential,2),'full');
   
    Objective=Objective ...
        + sum(sum(l_run_of_river_v.*var_run_of_river.electricity)) ...
        + 0.*sum(var_run_of_river.swept_area);
   
else
    var_run_of_river.electricity = zeros(T,1);
end

%% Legacy generator
if exist('dg_legacy') &&  ~isempty(dg_legacy)
    %%%DG Electrical Output
    var_ldg.ldg_elec = sdpvar(T,size(dg_legacy,2),'full');
    %%%DG Fuel Input
    var_ldg.ldg_fuel = sdpvar(T,size(dg_legacy,2),'full');
    %%%DG Fuel Input
    var_ldg.ldg_rfuel = sdpvar(T,size(dg_legacy,2),'full');
    %%%DG Fuel that has been stored in the pipeline
    if h2_inject_on
        var_ldg.ldg_sfuel = sdpvar(T,size(dg_legacy,2),'full');
    else
        var_ldg.ldg_sfuel = zeros(T,1);
    end
    %%%DG Fuel that has been stored in the pipeline and directed to the
    %%%site
    if util_h2_inject_on
         var_ldg.ldg_dfuel = sdpvar(T,size(dg_legacy,2),'full');
    else
        var_ldg.ldg_dfuel = zeros(T,1);
    end
    
    %%%DG Operational State
    if ldg_op_state
        var_ldg.ldg_opstate = binvar(T,size(dg_legacy,2),'full');
    else
        var_ldg.ldg_opstate = ones(T,size(dg_legacy,2));
    end
    
    
    %%%DG On/Off State - Number of variables is equal to:
    %%% (Time Instances) / On/Off length
    %     (dg_legacy(end,i)/t_step)
    %     ldg_off=binvar(ceil(length(time)/(dg_legacy(end,i)/t_step)),K,'full');
    
    %%%If hydrogen production is an option
    if ~isempty(el_v) || ~isempty(rel_v)
        var_ldg.ldg_hfuel = sdpvar(T,size(dg_legacy,2),'full');
    else
        var_ldg.ldg_hfuel = zeros(T,1);
    end
    
    for ii = 1:size(dg_legacy,2)
        Objective=Objective ...
            + sum(var_ldg.ldg_elec(:,ii))*dg_legacy(1,ii) ...
            + sum(var_ldg.ldg_fuel(:,ii))*ng_cost ...
            + sum(var_ldg.ldg_rfuel(:,ii))*rng_cost;
    end
    
    %%%If including cycling costs
    if ~isempty(dg_legacy_cyc)
        %%%Only consider if on/off behavior is allowed
        
        %%%Ramping costs
        if ~isempty(dg_legacy_cyc) && dg_legacy_cyc(2,:) > 0 %%%Only include if cycling costs is nonzero
            var_ldg.ldg_elec_ramp = sdpvar(T - 1,size(dg_legacy,2),'full');
                        
            Objective=Objective ...
                + sum(sum(var_ldg.ldg_elec_ramp).*dg_legacy_cyc(2,:));
        else
            var_ldg.ldg_elec_ramp = [];
        end
    else
        var_ldg.ldg_elec_ramp = [];
    end
    
else
    var_ldg.ldg_elec = zeros(T,1);
    var_ldg.ldg_rfuel = zeros(T,1);
    var_ldg.ldg_hfuel = zeros(T,1);
    var_ldg.ldg_sfuel = zeros(T,1);
    var_ldg.ldg_dfuel = zeros(T,1);
    var_ldg.ldg_fuel = [];
    var_ldg.ldg_off = [];
    var_ldg.ldg_opstate = 1;
    var_ldg.ldg_off = 1;
    var_ldg.ldg_elec_ramp = [];
end
%% Legacy bottoming systems
%%%Bottoming generator is any electricity producing device that operates
%%%based on heat recovered from another generator

if exist('bot_legacy') && ~isempty(bot_legacy)
    %%%Bottom electrical output
    var_lbot.lbot_elec = sdpvar(length(elec),size(bot_legacy,2),'full');
    %%%Bottom operational state
    if lbot_op_state
        var_lbot.lbot_on = binvar(length(elec),size(bot_legacy,2),'full');
    else
        var_lbot.lbot_on = zeros(T,1);
    end
    %%%Bottoming cycle
    for i=1:size(bot_legacy,2)
        Objective=Objective+var_lbot.lbot_elec(:,1)'*(bot_legacy(1,i)*ones(length(time),1));%%%Bottoming cycle O&M
    end
else
    var_lbot.lbot_elec = zeros(T,1);
    var_lbot.lbot_on = zeros(T,1);
end
%% Legacy Heat recovery
if exist('dg_legacy') && ~isempty(dg_legacy) && ~isempty(hr_legacy)
    %%%Heat recovery output
    var_ldg.hr_heat=sdpvar(length(elec),size(hr_legacy,2),'full');
    
    %%%If duct burner or HR heating source is available
    if ~isempty(db_legacy)
        %%%Duct burner - Conventional
        var_ldg.db_fire=sdpvar(length(elec),size(db_legacy,2),'full');
        %%%Duct burner - Renewable
        var_ldg.db_rfire=sdpvar(length(elec),size(db_legacy,2),'full');
        
        %%%If hydrogen production is an option
        if ~isempty(el_v) || ~isempty(rel_v)
            var_ldg.db_hfire = sdpvar(T,size(dg_legacy,2),'full');
        else
            var_ldg.db_hfire = zeros(T,1);
        end
                
        for ii = 1:size(db_legacy,2)
            %%%Duct burner and renewable duct burner
            Objective=Objective ...
                + var_ldg.db_fire'*((db(1,ii)+ng_cost)*ones(length(time),1)) ...
                + var_ldg.db_rfire'*((db(1,ii)+rng_cost)*ones(length(time),1)) ...
                + var_ldg.db_hfire'*((db(1,ii)+rng_cost)*ones(length(time),1));
        end
    else
        var_ldg.db_fire = [];
        var_ldg.db_rfire = [];
        var_ldg.db_hfire = [];
    end
    
else
    var_ldg.hr_heat = zeros(T,1);
    var_ldg.db_fire = zeros(T,1);
    var_ldg.db_rfire = zeros(T,1);
        var_ldg.db_hfire = zeros(T,1);
end
%% Legacy boiler
if exist('boil_legacy') && ~isempty(boil_legacy)
    %%%Basic boiler
    var_boil.boil_fuel = sdpvar(length(elec),size(boil_legacy,2),'full');
    var_boil.boil_rfuel = sdpvar(length(elec),size(boil_legacy,2),'full');
    
    %%%If hydrogen production is an option
    if ~isempty(el_v) || ~isempty(rel_v)
        var_boil.boil_hfuel = sdpvar(T,size(boil_legacy,2),'full');
    else
        var_boil.boil_hfuel = zeros(T,1);
    end
    
    Objective=Objective ...
        +  sum(var_boil.boil_fuel)*(boil_legacy(1) + ng_cost) ...
        +sum(var_boil.boil_rfuel)*(boil_legacy(1) + rng_cost)...
        +sum(var_boil.boil_hfuel)*(boil_legacy(1) + rng_cost);
else
    var_boil.boil_fuel = zeros(T,1);
    var_boil.boil_rfuel = zeros(T,1);
    var_boil.boil_hfuel = zeros(T,1);
end

%% Legacy Generic Chiller
if ~isempty(cool) && sum(cool) > 0  && isempty(vc_legacy)
    var_vc.generic_cool = sdpvar(length(elec),size(boil_legacy,2),'full');
else
    var_vc.generic_cool = zeros(T,1);
end


%% Legacy EES
if ~isempty(ees_legacy)
    %%%EES Charging
    var_lees.ees_chrg = sdpvar(T,size(ees_legacy,2),'full');
    %%%EES discharging
    var_lees.ees_dchrg = sdpvar(T,size(ees_legacy,2),'full');
    %%%EES SOC
    var_lees.ees_soc = sdpvar(T,size(ees_legacy,2),'full');
    
    for ii = 1:size(ees_legacy,2)
        %%%EES Cost Functions
        Objective = Objective...
            + ees_legacy(2,ii)*sum(sum(day_multi.*var_lees.ees_chrg(:,ii))) ...%%%Charging O&M
            + ees_legacy(3,ii)*sum(sum(day_multi.*var_lees.ees_dchrg(:,ii)));%%%Discharging O&M
    end
else
    var_lees.ees_chrg = zeros(T,1);
    var_lees.ees_dchrg = zeros(T,1);
    var_lees.ees_soc = zeros(T,1);
end
   
%% Legacy Cold TES
if ~isempty(cool) && sum(cool) >0 && ~isempty(tes_legacy)
    %%%TES Energy Storage Vector
    %%%TES State of Charge
    var_ltes.ltes_soc = sdpvar(length(elec),size(tes_legacy,2),'full');
    %%%TES charging/discharging
    var_ltes.ltes_chrg = sdpvar(length(elec),size(tes_legacy,2),'full');
    var_ltes.ltes_dchrg = sdpvar(length(elec),size(tes_legacy,2),'full');
    
    %%%TES
    for i=1:size(tes_legacy,2)
        Objective=Objective + var_ltes.ltes_chrg(:,i)'*(tes_legacy(2,i)*ones(length(time),1))...
            + var_ltes.ltes_dchrg(:,i)'*(tes_legacy(3,i)*ones(length(time),1));
    end
    
else
    var_ltes.ltes_soc = zeros(T,1);
    var_ltes.ltes_chrg = zeros(T,1);
    var_ltes.ltes_dchrg = zeros(T,1);
end

%% Legacy Chillers
onoff_model = 1;

if ~isempty(cool) && sum(cool) >0 && ~isempty(vc_legacy)
     %%%Operational windows
    vc_hour_num = ceil(length(time)/4);
   
    
    
    if onoff_model
   
        vc_size = zeros(length(elec),size(vc_legacy,2));
        vc_cop=ones(length(elec),size(vc_legacy,2));
        for i=1:length(elec)
            vc_cop(i,:)=vc_cop(i,:).*(1./vc_legacy(2,:));
            vc_size(i,:) = vc_legacy(3,:);
        end
        
        
    %%%VC Cooling output
    var_lvc.lvc_cool = sdpvar(length(elec),size(vc_legacy,2),'full');
    %%%VC Operational State
    var_lvc.lvc_op = binvar(vc_hour_num,size(vc_legacy,2),'full');

    %%%VC Start
%     vc_start=binvar(vc_hour_num,size(vc_legacy,2),'full');
    
    %%%Electric Vapor Compression
    for i=1:size(vc_legacy,2)
        Objective = Objective ...
            + var_lvc.lvc_cool(:,i)'*(vc_legacy(1,i)*ones(length(time),1));
        %             + var_lvc.lvc_cool(:,i)'*(vc_legacy(1,i)*ones(length(time),1)); ...
        %                     + 10*sum(sum(vc_start));
    end
    
    
    
    else
        %%%VC Operational State
        vc_size = vc_legacy(3,:)/e_adjust;
        vc_cop = (1./vc_legacy(2,:));
    var_lvc.lvc_op = binvar(vc_hour_num,size(vc_legacy,2),'full');
        
    end
    
else
    var_lvc.lvc_op = 0;
    var_lvc.lvc_cool = zeros(T,1);
    vc_cop = 0;
end

%%
%%
%%
%% Dump Variables
%%%These variables should always be zero and are nonzero when you ahve a
%%%poorly conceived problem
if ~isempty(elec_dump)
    var_dump.elec_dump = sdpvar(T,1,'full');
else
    var_dump.elec_dump = zeros(T,1);
end
