classdef CModelVariables < handle

    % Symbolic Variables
    properties (SetAccess = public)

        util_import              % var_util.import
        util_nontou_dc            % var_util.nontou_dc
        util_onpeak_dc            % var_util.onpeak_dc
        util_midpeak_dc         % var_util.midpeak_dc
        util_gen_export         % var_util.gen_export
        util_import_state       % var_util.import_state

        pv_elec                 % var_pv.pv_elec
        pv_adopt                % var_pv.pv_adopt
        pv_nem                  % var_pv.pv_nem

fuel_cell_binary_adopt
fuel_cell_binary_capacity
fuel_cell_binary_elec
fuel_cell_binary_fuel
fuel_cell_binary_hfuel

util_h2

        rees_adopt              % var_rees.rees_adopt
        rees_chrg               % var_rees.rees_chrg
        rees_dchrg              % var_rees.rees_dchrg
        rees_soc                % var_rees.rees_soc
        rees_dchrg_nem          % var_rees.rees_dchrg_nem

        ees_adopt               % var_ees.ees_adopt
        ees_chrg                % var_ees.ees_chrg
        ees_dchrg               % var_ees.ees_dchrg
        ees_soc                 % var_ees.ees_soc
        
        sgip_ees_pbi            % var_sgip.sgip_ees_pbi
        sgip_ees_npbi           % var_sgip.sgip_ees_npbi
        sgip_ees_npbi_equity    % var_sgip.sgip_ees_npbi_equity

        rel_adopt               % var_rel.rel_adopt
        rel_prod                % var_rel.rel_prod
        rel_prod_wheel          % var_rel.rel_prod_wheel
        rel_eff
        
        el_eff
        el_adopt                % var_el.el_adopt
        el_prod                 % var_el.el_prod
        el_prod_wheel           % var_el.el_prod_wheel

        h2es_adopt              % var_h2es.h2es_adopt
        h2es_chrg               % var_h2es.h2es_chrg
        h2es_dchrg              % var_h2es.h2es_dchrg
        h2es_bin                % var_h2es.h2es_bin
        h2es_soc                % var_h2es.h2es_soc
        h2_chrg_eff

        hrs_supply_adopt        % var_hrs.hrs_supply_adopt
        hrs_tube                % var_hrs.hrs_tube
        hrs_supply              % var_hrs.hrs_supply
        hrs_chrg_eff

        h2_inject               % var_h2_inject.h2_inject
        h2_inject_size          % var_h2_inject.h2_inject_size
        h2_inject_adopt         % var_h2_inject.h2_inject_adopt
        h2_store                % var_h2_inject.h2_store

        ldg_elec                % var_ldg.ldg_elec
        ldg_fuel                % var_ldg.ldg_fuel
        ldg_rfuel               % var_ldg.ldg_rfuel
        ldg_sfuel               % var_ldg.ldg_sfuel
        ldg_dfuel               % var_ldg.ldg_dfuel
        ldg_opstate             % var_ldg.ldg_opstate
        ldg_hfuel               % var_ldg.ldg_hfuel
        ldg_elec_ramp           % var_ldg.ldg_elec_ramp
        ldg_off                 % var_ldg.ldg_off

        lbot_elec               % var_lbot.lbot_elec
        lbot_on                 % var_lbot.lbot_on

        hr_heat                 % var_ldg.hr_heat
        db_fire                 % var_ldg.db_fire
        db_rfire                % var_ldg.db_rfire
        db_hfire                % var_ldg.db_hfire

        boil_fuel               % var_boil.boil_fuel
        boil_rfuel              % var_boil.boil_rfuel
        boil_hfuel              % var_boil.boil_hfuel

        generic_cool            % var_vc.generic_cool

        lees_chrg               % var_lees.ees_chrg
        lees_dchrg              % var_lees.ees_dchrg
        lees_soc                % var_lees.ees_soc

        ltes_soc                % var_ltes.ltes_soc
        ltes_chrg               % var_ltes.ltes_chrg
        ltes_dchrg              % var_ltes.ltes_dchrg

        lvc_op                  % var_lvc.lvc_op
        lvc_cool                % var_lvc.lvc_cool
        vc_size
        vc_cop

        elec_dump

        pp_elec_export          % var_pp.pp_elec_export
        pp_elec_import          % var_pp.pp_elec_import
        pp_elec_wheel           % var_pp.pp_elec_wheel
        pp_elec_wheel_lts       % var_pp.pp_elec_wheel_lts
        import_state            % var_pp.import_state

        util_pv_adopt           % var_utilpv.util_pv_adopt
        util_pv_elec            % var_utilpv.util_pv_elec

        util_wind_adopt         % var_util_wind.util_wind_adopt
        util_wind_elec          % var_util_wind.util_wind_elec

        util_ees_adopt          % var_util_ees.ees_adopt
        util_ees_soc            % var_util_ees.ees_soc
        util_ees_chrg           % var_util_ees.ees_chrg
        util_ees_dchrg          % var_util_ees.ees_dchrg

        util_el_eff        
        util_el_adopt           % var_util_el.el_adopt
        util_el_prod            % var_util_el.el_prod

        util_h2_inject          % var_util_h2_inject.h2_inject
        util_h2_inject_size     % var_util_h2_inject.h2_inject_size
        util_h2_inject_adopt    % var_util_h2_inject.h2_inject_adopt
        util_h2_store           % var_util_h2_inject.h2_store

        rsoc_capacity           % var_util_rsoc.rsoc_capacity
        rsoc_elec               % var_util_rsoc.rsoc_elec 
        rsoc_gen                % var_util_rsoc.rsoc_gen  
        rsoc_adopt              % var_util_rsoc.rsoc_adopt
        rsoc_fuel               % var_util_rsoc.rsoc_fuel
        rsoc_hfuel              %var_util_rsoc.rsoc_hfuel
    end

    properties (SetAccess = public)
        Objective
    end

    properties (SetAccess = private)
        T
        M        
    end
    
    properties (Constant)
        rate = {'TOU8'}
        rate_labels = {'TOU8'};
    end

    methods
        
        function obj = CModelVariables(timeInterval, numberOfMonthsInSim)

            yalmip('clear')

            obj.T = timeInterval;
            obj.M = numberOfMonthsInSim;
            obj.Objective = 0;

        end


        

        %% Utility Electricity
        function SetupUtilityElectricity(obj, utility_exists, dc_exist, dayMultiplier, utilityInfo)

            if utility_exists 

                %%%Electrical Import Variables
                obj.util_import = sdpvar(obj.T,1,'full');
                
                %%%Demand Charge Variables
                %%%Only creating variables for # of months and number of applicable
                %%%rates, as defined with the binary dc_on input
                if sum(dc_exist) > 0

                    %%%Non TOU DC
                    obj.util_nontou_dc = sdpvar(obj.M,1,'full');
                    
                    %%%On Peak/ Mid Peak TOU DC
                    if utilityInfo.onpeak_count > 0
                        obj.util_onpeak_dc = sdpvar(onpeak_count,1,'full');
                        obj.util_midpeak_dc = sdpvar(midpeak_count,1,'full');
                    else
                        obj.util_onpeak_dc = 0;
                        obj.util_midpeak_dc = 0;
                    end

                end
                
                %%% Cost of Imports + Demand Charges
                dc_count = 1;
                               
                %%%Find the applicable utility rate
                index = find(ismember(obj.rate_labels,obj.rate(1)));
                
                %%%Import Energy charges
                %     Objective = sum(sum(obj.util_import.*temp_cf));
                obj.Objective = sum(sum(obj.util_import.*(dayMultiplier.*utilityInfo.import_price(:,index))));

                if dc_exist == 1

                    %%%Find the applicable utility rate
                    index = find(ismember(obj.rate_labels,obj.rate(1)));
                    
                    obj.Objective =  obj.Objective ...
                        + sum(utilityInfo.dc_nontou(index)*obj.util_nontou_dc(:,dc_count))... %%%non TOU DC
                        + sum(utilityInfo.dc_on(index)*obj.util_onpeak_dc(:,dc_count)) ... %%%On Peak DC
                        + sum(utilityInfo.dc_mid(index)*obj.util_midpeak_dc(:,dc_count)); %%%Mid Peak DC
                    
                    %%% Utility_import * Demand_charge_rate

                end
            else

                %%%Electrical Import Variables
                obj.util_import = zeros(obj.T,1);
                
                %%%Non TOU DC
                obj.util_nontou_dc = zeros(obj.M,1);
                
                %%%On Peak/ Mid Peak TOU DC
                obj.util_onpeak_dc = zeros(onpeak_count,1);
                obj.util_midpeak_dc = zeros(midpeak_count,1);
                
            end
        end

        %% RSOC

        function SetupUtilityrsoc(obj)

            obj.rsoc_adopt = sdpvar(1, size(rsoc_v, 2), 'full');
            obj.rsoc_capacity = sdpvar(obj.T, size(rsoc_v, 2), 'full');
            obj.rsoc_elec = sdpvar(obj.T, size(rsoc_v, 2), 'full');
            obj.rsoc_gen = sdpvar(obj.T, size(rsoc_v, 2), 'full');
            obj.rsoc_fuel = sdpvar(obj.T, size(rsoc_v, 2), 'full');
            obj.rsoc_hfuel = sdpvar(obj.T, size(rsoc_v, 2), 'full');



            Cost = obj.M*monthly_debt.*mod.*obj.rsoc_adopt;

            OaM = sum((rsoc_v(3,:).*day_multi).*(var_gen.gen_elec));

            obj.Objective = obj.Objective + sum(Cost) + sum(OaM)...
                            + 
        end
        
        %% Utility Hydrogen
        function SetupUtilityHydrogen(obj,h2_cost)
            if h2_cost>0
                obj.util_h2 = sdpvar(obj.T,1,'full');
                obj.Objective = obj.Objective ...
                    + sum(h2_cost.*obj.util_h2);
            else
                obj.util_h2 = zeros(obj.T,1);
            end
        end
            %% General export
            function SetupGeneralExport(obj, gen_export_on, utilityInfo)
                
                % General export allows export from any onsite resource, regardless of fuel source
                if gen_export_on

                obj.util_gen_export = sdpvar(obj.T,1,'full');
                obj.util_import_state = binvar(obj.T,1,'full');
                obj.Objective = obj.Objective + -sum(obj.util_gen_export.*utilityInfo.export_price);
            else

                obj.util_gen_export = zeros(obj.T,1);
                obj.util_import_state = ones(obj.T,1);

            end
        end


        %% General export
        function SetupFuelCellBinary(obj, techSelOnSite, capCostMods, dayMultiplier, ng_cost)
            
            
            if isempty(techSelOnSite.FuelCellBinary_v) == 0
                obj.fuel_cell_binary_adopt =  binvar(1,1,'full');      %%%Is the fuel cell adopted?
                obj.fuel_cell_binary_capacity = sdpvar(1,1,'full'); %%%Fuel Cell Capacity
                obj.fuel_cell_binary_elec = sdpvar(obj.T,1,'full'); %%%Fuel Cell Output
                obj.fuel_cell_binary_fuel = sdpvar(obj.T,1,'full'); %%%Fuel Cell Fuel Input
                obj.fuel_cell_binary_hfuel = sdpvar(obj.T,1,'full'); %%%Fuel Cell Fuel Output
                
                obj.Objective = obj.Objective ...
                    + sum(obj.M*capCostMods.fuel_cell_binary_mthly_debt(1)'*obj.fuel_cell_binary_adopt)... %%%Fuel Cell Initial Install Cost ($)
                    + sum(obj.M*capCostMods.fuel_cell_binary_mthly_debt(2)'*obj.fuel_cell_binary_capacity)... %%%Fuel Cell Capital Cost ($/kW installed)
                    + techSelOnSite.FuelCellBinary_v(3)*(sum(sum(dayMultiplier.*(obj.fuel_cell_binary_elec)))); %%%Fuel Cell O&M Cost ($/kWh generated)


            else
                obj.fuel_cell_binary_adopt =  zeros(1);      %%%Is the fuel cell adopted?
                obj.fuel_cell_binary_capacity = zeros(1); %%%Fuel Cell Capacity
                obj.fuel_cell_binary_elec = zeros(obj.T,1); %%%Fuel Cell Output
                obj.fuel_cell_binary_fuel = zeros(obj.T,1); %%%Fuel Cell Fuel Input
                obj.fuel_cell_binary_hfuel = zeros(obj.T,1); %%%Fuel Cell Fuel Output
            end
            
            
            
        end

        %% Solar PV
        function SetupSolarPV(obj, utility_exists, export_on, rees_on, island, dayMultiplier, techSelOnSite, utilityInfo, capCostMods) %, gen_export_on, utilityInfo)

            % Technologies That Can Be Adopted at Each Building Energy Hub

            if isempty(techSelOnSite.pv_v) == 0
                
                %%%PV Generation to meet building demand (kWh)
                obj.pv_elec = sdpvar(obj.T,1,'full'); %%% PV Production sent to the building
                
                %%%Size of installed System (kW)
                obj.pv_adopt = sdpvar(1,size(techSelOnSite.pv_v,2),'full'); %%%PV Size
                
                if ~isempty(utility_exists) && utility_exists && export_on %If grid tied, then include NEM and wholesale export
                    
                    %%% Variables that exist when grid tied
                    obj.pv_nem = sdpvar(obj.T,1,'full'); %%% PV Production exported w/ NEM
                    
                    %%%PV Export - NEM (kWh)
                    %%%Utility rates for building k
                    index = find(ismember(obj.rate_labels,obj.rate(1)));
                        
                    %%%Adding values to the cost function
                     obj.Objective = obj.Objective...
                         + sum(sum((-dayMultiplier.*utilityInfo.export_price(:,index)).*obj.pv_nem)); %%%NEM Revenue Cost
                     
                else
                    obj.pv_nem = zeros(obj.T,1);
                end
                
                %%%PV Cost
            
                obj.Objective = obj.Objective ...
                    + sum(obj.M*capCostMods.pv_mthly_debt'.*capCostMods.pv_cap_mod.*obj.pv_adopt)... %%%PV Capital Cost ($/kW installed)
                    + techSelOnSite.pv_v(3)*(sum(sum(dayMultiplier.*(obj.pv_elec)))) ... %%%PV O&M Cost ($/kWh generated)    
                    + techSelOnSite.pv_v(3)*(sum(sum(dayMultiplier.*(obj.pv_nem)))); %%%PV O&M Cost ($/kWh generated)
                    % + techSelOnSite.pv_v(3)*(sum(sum(repmat(dayMultiplier,1,K).*(obj.pv_elec + obj.pv_nem + pv_wholesale))) ); %%%PV O&M Cost ($/kWh generated)
            
                %%% Allow for adoption of Renewable paired storage when enabled (REES)
                if isempty(techSelOnSite.ees_v) == 0 && rees_on == 1
                    
                    %%%Adopted REES Size
                    obj.rees_adopt = sdpvar(1,size(techSelOnSite.ees_v,2),'full');
                    %%%REES Charging
                    obj.rees_chrg = sdpvar(obj.T,size(techSelOnSite.ees_v,2),'full');
                    %%%REES discharging
                    obj.rees_dchrg = sdpvar(obj.T,size(techSelOnSite.ees_v,2),'full');                    
                    %%%REES SOC
                    obj.rees_soc = sdpvar(obj.T,size(techSelOnSite.ees_v,2),'full');

                    %%%REES Cost Functions 
                    for ii = 1:size(techSelOnSite.ees_v,2)
                        
                        obj.Objective = obj.Objective...
                            + sum(capCostMods.rees_mthly_debt(ii)*obj.M.*capCostMods.rees_cap_mod(ii)'.*obj.rees_adopt(ii)) ...%%%Capital Cost
                            + techSelOnSite.ees_v(2,ii)*sum(sum(dayMultiplier.*obj.rees_chrg(:,ii)))... %%%Charging O&M
                            + techSelOnSite.ees_v(3,ii)*(sum(sum(dayMultiplier.*(obj.rees_dchrg(:,ii)))));%%%Discharging O&M
                        
                        if export_on ~= 1 % If not islanded, AEC can export NEM and wholesale for revenue

                            %%%REES NEM Export
                            %%%REES discharging to grid
                            obj.rees_dchrg_nem = sdpvar(obj.T,size(techSelOnSite.ees_v,2),'full');

                            %             for k = 1:K
                            %%%Applicable utility rate
                            index = find(ismember(obj.rate_labels,obj.rate(1)));                            
                            % temp_cf(:,k) = dayMultiplier.*(techSelOnSite.ees_v(3,ii) - utilityInfo.export_price(:,index));                            
                            %             end

                            %%% Setting objective function
                            obj.Objective = obj.Objective...
                                + sum(sum((dayMultiplier.*(techSelOnSite.ees_v(3,ii) - utilityInfo.export_price(:,index))).*obj.rees_dchrg_nem(:,ii)));
                            
                            obj.rees_dchrg_nem = zeros(obj.T,1);
                            
                        else
                            obj.rees_dchrg_nem = zeros(obj.T,1);
                        end
                    end
                else
                    obj.rees_adopt = zeros(1,1);
                    obj.rees_chrg = zeros(obj.T,1);
                    obj.rees_dchrg = zeros(obj.T,1);
                    obj.rees_dchrg_nem = zeros(obj.T,1);
                    obj.rees_soc = zeros(obj.T,1);
                end
                
            else
                obj.pv_adopt = zeros([1 1]);
                obj.pv_elec = zeros([obj.T 1]);
                obj.pv_nem = zeros([obj.T 1]);

                % pv_wholesale = zeros([obj.T 1]);

                obj.rees_adopt = zeros(1,1);
                obj.rees_chrg = zeros(obj.T,1);
                obj.rees_dchrg = zeros(obj.T,1);
                obj.rees_dchrg_nem = zeros(obj.T,1);
                obj.rees_soc = zeros(obj.T,1);
            end
        end


        %% Electrical Energy Storage
        function SetupElectricalEnergyStorage(obj, sgip_on, dayMultiplier, techSelOnSite, capCostMods)
            
            if isempty(techSelOnSite.ees_v) == 0
                
                %%%Adopted EES Size
                obj.ees_adopt = sdpvar(1,size(techSelOnSite.ees_v,2),'full');
                %%%EES Charging
                obj.ees_chrg = sdpvar(obj.T,size(techSelOnSite.ees_v,2),'full');
                %%%EES discharging
                obj.ees_dchrg = sdpvar(obj.T,size(techSelOnSite.ees_v,2),'full');
                %%%EES SOC
                obj.ees_soc = sdpvar(obj.T,size(techSelOnSite.ees_v,2),'full');

                for ii = 1:size(techSelOnSite.ees_v,2)

                    %%%EES Cost Functions
                    obj.Objective = obj.Objective...
                        + sum(capCostMods.ees_mthly_debt(ii)*obj.M.*capCostMods.ees_cap_mod(ii)'.*obj.ees_adopt(ii)) ...%%%Capital Cost
                        + techSelOnSite.ees_v(2,ii)*sum(sum(dayMultiplier.*obj.ees_chrg(:,ii))) ...%%%Charging O&M
                        + techSelOnSite.ees_v(3,ii)*sum(sum(dayMultiplier.*obj.ees_dchrg(:,ii)));%%%Discharging O&M
                end

                %%%SGIP rates
                if sgip_on

                    % % Residential Credits
                    % obj.sgip_ees_npbi = sdpvar(1,sum((res_units>0).*(~low_income>0)),'full');
                    % 
                    % % Residential Equity Credits
                    % obj.sgip_ees_npbi_equity = sdpvar(1,sum(low_income>0),'full');
                    % 
                    % obj.Objective = obj.Objective ...
                    %     - sum(sgip(3)*obj.M*obj.sgip_ees_npbi) ...
                    %     - sum(sgip(4)*obj.M*obj.sgip_ees_npbi_equity);
                    % 
                    % if sum(sgip_pbi) > 0
                    % 
                    %     %  Performance based incentives
                    %     obj.sgip_ees_pbi = sdpvar(3,sum(sgip_pbi),'full');
                    % 
                    %     obj.Objective = obj.Objective ...
                    %         - sum(sgip(2)*obj.M*obj.sgip_ees_pbi(1,:)) ...
                    %         - sum(sgip(2)*0.5*obj.M*obj.sgip_ees_pbi(2,:)) ...
                    %         - sum(sgip(2)*0.25*obj.M*obj.sgip_ees_pbi(3,:));
                    % else
                    %     obj.sgip_ees_pbi = zeros(3,1);
                    % end

                else
                    obj.sgip_ees_pbi = zeros(3,1);
                    obj.sgip_ees_npbi = 0;
                    obj.sgip_ees_npbi_equity = 0;
                end
                
            else
                obj.ees_adopt = zeros(1,1);
                obj.ees_soc = zeros(obj.T,1);
                obj.ees_chrg = zeros(obj.T,1);
                obj.ees_dchrg = zeros(obj.T,1);
            end
        end


        %% Renewable Electrolyzer
        function SetupRenewableElectrolyzer(obj, util_pv_wheel_lts, strict_h2es, rel_v,  el_v, h2es_v, capCostMods)
            
            if ~isempty(rel_v)
                
                %%%Electrolyzer efficiency
                obj.rel_eff = ones(obj.T,size(rel_v,2));

                for ii = 1:size(rel_v,2)
                    obj.rel_eff(:,ii) = (1/rel_v(3,ii)).*obj.rel_eff(:,ii);
                end
                
                %%%Adoption technologies
                obj.rel_adopt = sdpvar(1,size(rel_v,2),'full');
                
                %%%Electrolyzer production
                obj.rel_prod = sdpvar(obj.T,size(rel_v,2),'full');
                
                if util_pv_wheel_lts
                    obj.rel_prod_wheel = sdpvar(obj.T,size(el_v,2),'full');
                else
                    obj.rel_prod_wheel = zeros(obj.T,size(rel_v,2));
                end
                
                for ii = 1:size(rel_v,2)
                    
                    %%%Electrolyzer Cost Functions
                    obj.Objective = obj.Objective...
                        + sum(obj.M.*capCostMods.rel_mthly_debt.*obj.rel_adopt) ... %%%Capital Cost
                        + sum(sum(obj.rel_prod + obj.rel_prod_wheel).*rel_v(2,:)); %%%VO&M
                end

                if isempty(el_v) && ~isempty(h2es_v)

                    %%%H2 Storage
                    %%%Adopted EES Size
                    obj.h2es_adopt = sdpvar(1,size(h2es_v,2),'full');
                    %%%EES Charging
                    obj.h2es_chrg = sdpvar(obj.T,size(h2es_v,2),'full');
                    %%%EES discharging
                    obj.h2es_dchrg = sdpvar(obj.T,size(h2es_v,2),'full');
                    
                    %%%H2ES Operational State Binary Variables
                    if strict_h2es
                        obj.h2es_bin = binvar(obj.T,size(h2es_v,2),'full');
                    else
                        obj.h2es_bin = sdpvar(obj.T,size(h2es_v,2),'full');
                    end
                    
                    %%%EES SOC
                    obj.h2es_soc = sdpvar(obj.T,size(h2es_v,2),'full');

                    for ii = 1:size(h2es_v,2)
                        
                        %%%Electrolyzer Cost Functions
                        obj.Objective = obj.Objective...
                            + sum(obj.M.*capCostMods.h2es_mthly_debt.*obj.h2es_adopt) ... %%%Capital Cost
                            + sum(sum(obj.h2es_chrg).*h2es_v(2,:)) ... %%%Charging Cost
                            + sum(sum(obj.h2es_dchrg).*h2es_v(3,:)); %%%Discharging Cost
                    end
                    
                    obj.h2_chrg_eff = 1 - h2es_v(8,:);
                end
                
            else
                obj.rel_adopt = 0;
                obj.rel_prod = zeros(obj.T,1);
                obj.rel_prod_wheel = zeros(obj.T,1);
                obj.rel_eff = 0;

                
                if isempty(h2es_v)
                    obj.h2es_adopt = 0;
                    obj.h2es_chrg = zeros(obj.T,1);
                    obj.h2es_dchrg = zeros(obj.T,1);
                    obj.h2es_bin = zeros(obj.T,1);
                    obj.h2es_soc = zeros(obj.T,1);
                    obj.h2_chrg_eff = 0;
                end
            end
        end


        %% H2 Production and Storage
        function SetupH2ProductionAndStorage(obj, util_pv_wheel_lts, strict_h2es, el_v, h2es_v, capCostMods)
            
            %% H2 energy storage
            if ~isempty(h2es_v)
                 %%%H2 Storage
                    %%%Adopted EES Size
                    obj.h2es_adopt = sdpvar(1,size(h2es_v,2),'full');
                    %%%EES Charging
                    obj.h2es_chrg = sdpvar(obj.T,size(h2es_v,2),'full');
                    %%%EES discharging
                    obj.h2es_dchrg = sdpvar(obj.T,size(h2es_v,2),'full');
                    
                    %%%H2ES Operational State Binary Variables
                    if strict_h2es
                        obj.h2es_bin = binvar(obj.T,size(h2es_v,2),'full');
                    else
                        obj.h2es_bin = sdpvar(obj.T,size(h2es_v,2),'full');
                    end
                    
                    %%%EES SOC
                    obj.h2es_soc = sdpvar(obj.T,size(h2es_v,2),'full');

                    for ii = 1:size(h2es_v,2)
                        
                        %%%Electrolyzer Cost Functions
                        obj.Objective = obj.Objective...
                            + sum(obj.M.*capCostMods.h2es_mthly_debt.*obj.h2es_adopt) ... %%%Capital Cost
                            + sum(sum(obj.h2es_chrg).*h2es_v(2,:)) ... %%%Charging Cost
                            + sum(sum(obj.h2es_dchrg).*h2es_v(3,:)); %%%Discharging Cost
                    end
                    
                    obj.h2_chrg_eff = 1 - h2es_v(8,:);
            end
            
            % Electrolyzer
            if ~isempty(el_v)
                
                %%%Electrolyzer efficiency
                obj.el_eff = ones(obj.T,size(el_v,2));
                
                for ii = 1:size(el_v,2)
                    obj.el_eff(:,ii) = (1/el_v(3,ii)).*obj.el_eff(:,ii);
                end
                
                %%%Adoption technologies
                obj.el_adopt = sdpvar(1,size(el_v,2),'full');
                
                %%%Electrolyzer production
                obj.el_prod = sdpvar(obj.T,size(el_v,2),'full');
                
                if util_pv_wheel_lts
                    obj.el_prod_wheel = sdpvar(obj.T,size(el_v,2),'full');
                else
                    obj.el_prod_wheel = zeros(obj.T,size(el_v,2));
                end
                
                for ii = 1:size(el_v,2)
                    
                    %%%Electrolyzer Cost Functions
                    obj.Objective = obj.Objective...
                        + sum(obj.M.*capCostMods.el_mthly_debt.*obj.el_adopt) ... %%%Capital Cost
                        + sum(sum(obj.el_prod + obj.el_prod_wheel).*el_v(2,:)); %%%VO&M
                end
                
                if ~isempty(h2es_v)

                    %%%H2 Storage
                    %%%Adopted EES Size
                    obj.h2es_adopt = sdpvar(1,size(h2es_v,2),'full');
                    %%%EES Charging
                    obj.h2es_chrg = sdpvar(obj.T,size(h2es_v,2),'full');
                    %%%EES discharging
                    obj.h2es_dchrg = sdpvar(obj.T,size(h2es_v,2),'full');
                    
                    %%%H2ES Operational State Binary Variables
                    if strict_h2es
                        obj.h2es_bin = binvar(obj.T,size(h2es_v,2),'full');
                    else
                        obj.h2es_bin = sdpvar(obj.T,size(h2es_v,2),'full');
                    end
                    
                    %%%EES SOC
                    obj.h2es_soc = sdpvar(obj.T,size(h2es_v,2),'full');

                    for ii = 1:size(h2es_v,2)
                        
                        %%%Electrolyzer Cost Functions
                        obj.Objective = obj.Objective...
                            + sum(obj.M.*capCostMods.h2es_mthly_debt.*obj.h2es_adopt) ... %%%Capital Cost
                            + sum(sum(obj.h2es_chrg).*h2es_v(2,:)) ... %%%Charging Cost
                            + sum(sum(obj.h2es_dchrg).*h2es_v(3,:)); %%%Discharging Cost
                    end
                    
                    obj.h2_chrg_eff = 1 - h2es_v(8,:);
                end
                
            else
                obj.el_adopt = 0;
                obj.el_prod = zeros(obj.T,1);
                obj.el_prod_wheel = zeros(obj.T,1);
                obj.el_eff = zeros(obj.T,1);

                
                if isempty(h2es_v)
                    obj.h2es_adopt = 0;
                    obj.h2es_chrg = zeros(obj.T,1);
                    obj.h2es_dchrg = zeros(obj.T,1);
                    obj.h2es_bin = zeros(obj.T,1);
                    obj.h2es_soc = zeros(obj.T,1);
                    obj.h2_chrg_eff = 0;
                end
            end

        end


        %% HRS equipment
        function SetupHRSEquipment(obj, hrs_on, hrs_v, capCostMods)

            if hrs_on

                %%%Adopt hrs supply equipment?
                obj.hrs_supply_adopt = binvar(1,1,'full');
                
                %%%HRS Supply from a tube trailer
                obj.hrs_tube = sdpvar(obj.T,1,'full');
                
                %%%HRS Supply from CP H2
                obj.hrs_supply = sdpvar(obj.T,1,'full');
                
                obj.Objective = obj.Objective ...
                    + obj.M*capCostMods.hrs_mthly_debt*obj.hrs_supply_adopt ...
                    + sum(obj.hrs_supply)*hrs_v(3) ...
                    + sum(obj.hrs_tube)*hrs_v(4);
                
                    obj.hrs_chrg_eff = 1 - hrs_v(2);
            else
                obj.hrs_supply_adopt = 0;
                obj.hrs_tube = zeros(obj.T,1);
                obj.hrs_supply = zeros(obj.T,1);
                obj.hrs_chrg_eff = 1;
            end

        end
        
        %% H2 Pipeline Injection
        function SetupH2PipelineInjection(obj, h2_inject_on, ng_inject, rng_storage_cost, capCostMods)
    
            if h2_inject_on

                %%%Adopt HRS Equipment
                obj.h2_inject_adopt = binvar(1,1,'full');
                %%%Size of adopted HRS Equipment
                obj.h2_inject_size = sdpvar(1,1,'full');
                %%%Injected Hydrogen
                obj.h2_inject = sdpvar(obj.T,1,'full');
                %%%Stored Hydrogen
                obj.h2_store = sdpvar(obj.T,1,'full');
                
                
                 obj.Objective = obj.Objective ...
                   + obj.M*capCostMods.h2_inject_mthly_debt(1)*obj.h2_inject_adopt ...
                   + obj.M*capCostMods.h2_inject_mthly_debt(2)*obj.h2_inject_size ...
                   - ng_inject.*sum(obj.h2_inject) ...
                   + rng_storage_cost.*sum(obj.h2_store);
            else
                obj.h2_inject = zeros(obj.T,1);
                obj.h2_inject_size = 0;
                obj.h2_inject_adopt = 0;
                obj.h2_store = zeros(obj.T,1);
            end
        end

        %% Renewable Electrolyze

        %% Legacy Technologies

        %% Legacy PV
        function SetupLegacyPv(obj, island, export_on, dayMultiplier, pv_legacy, pv_v, utilityInfo)

            % Only need to add variables if new PV is not considered
            if isempty(pv_legacy) == 0 && sum(pv_legacy(2,:)) > 0 &&  isempty(pv_v)
                
                if island == 0 && export_on == 1 %If grid tied, then include NEM and wholesale export

                    % Variables that exist when grid tied
                    obj.pv_nem = sdpvar(obj.T,1,'full'); %%% PV Production exported w/ NEM
            
                    % Utility rates for building k
                    index = find(ismember(obj.rate_labels,obj.rate(1)));
                        
                    % Adding values to the cost function
                    obj.Objective = obj.Objective...
                            + sum(sum(-day_multi.*utilityInfo.export_price(:,index).*obj.pv_nem)); %%%NEM Revenue Cost
                    
                else
                    obj.pv_nem=zeros(obj.T,1);
                end
                
                %%%PV Generation to meet building demand (kWh)
                obj.pv_elec = sdpvar(obj.T,1,'full'); %%% PV Production sent to the building
                
                % if ~iesmpty(el_v)
                %     modelVars.pv_h2 = sdpvar(obj.T,1,'full'); %%% PV Production sent to the building
                % end

                %%%Operating Costs
                obj.Objective = obj.Objective ...
                    + pv_legacy(1,1)*(sum(sum(dayMultiplier.*(obj.pv_elec + obj.pv_nem))));
                
            elseif isempty(pv_legacy) == 1

                %%%If Legacy PV does not exist, then make the existing pv value zero
                pv_legacy = zeros(2,1);
                %TODO: update object... can't we do this in LegacyTech???
            end

        end


        %% Legacy generator
        function SetupLegacyGenerator(obj, h2_inject_on, util_h2_inject_on, ldg_op_state, dg_legacy, dg_legacy_cyc, el_v, rel_v, ng_cost, rng_cost)

            if ~isempty(dg_legacy)
                
                %%%DG Electrical Output
                obj.ldg_elec = sdpvar(obj.T,size(dg_legacy,2),'full');
                %%%DG Fuel Input
                obj.ldg_fuel = sdpvar(obj.T,size(dg_legacy,2),'full');
                %%%DG Fuel Input
                obj.ldg_rfuel = sdpvar(obj.T,size(dg_legacy,2),'full');
                
                %%%DG Fuel that has been stored in the pipeline
                if h2_inject_on
                    obj.ldg_sfuel = sdpvar(obj.T,size(dg_legacy,2),'full');
                else
                    obj.ldg_sfuel = zeros(obj.T,1);
                end

                %%%DG Fuel that has been stored in the pipeline and directed to the site
                if util_h2_inject_on
                     obj.ldg_dfuel = sdpvar(obj.T,size(dg_legacy,2),'full');
                else
                    obj.ldg_dfuel = zeros(obj.T,1);
                end
                
                %%%DG Operational State
                if ldg_op_state
                    obj.ldg_opstate = binvar(obj.T,size(dg_legacy,2),'full');
                else
                    obj.ldg_opstate = ones(obj.T,size(dg_legacy,2));
                end
                
                %%%DG On/Off State - Number of variables is equal to:
                %%% (Time Instances) / On/Off length
                
                %%%If hydrogen production is an option
                if ~isempty(el_v) || ~isempty(rel_v)
                    obj.ldg_hfuel = sdpvar(obj.T,size(dg_legacy,2),'full');
                else
                    obj.ldg_hfuel = zeros(obj.T,1);
                end
                
                for ii = 1:size(dg_legacy,2)
                    
                    obj.Objective = obj.Objective ...
                        + sum(obj.ldg_elec(:,ii))*dg_legacy(1,ii) ...
                        + sum(obj.ldg_fuel(:,ii))*ng_cost ...
                        + sum(obj.ldg_rfuel(:,ii))*rng_cost;
                end
                
                %%%If including cycling costs
                if ~isempty(dg_legacy_cyc)

                    %%%Only consider if on/off behavior is allowed
                    
                    %%%Ramping costs
                    if ~isempty(dg_legacy_cyc) && dg_legacy_cyc(2,:) > 0 %%%Only include if cycling costs is nonzero
                        obj.ldg_elec_ramp = sdpvar(obj.T - 1,size(dg_legacy,2),'full');
                                    
                        obj.Objective = obj.Objective ...
                            + sum(sum(obj.ldg_elec_ramp).*dg_legacy_cyc(2,:));
                    else
                        obj.ldg_elec_ramp = [];
                    end
                else
                    obj.ldg_elec_ramp = [];
                end
                
                obj.ldg_off = [];       % TODO: should this go here??

            else
                obj.ldg_elec = zeros(obj.T,1);
                obj.ldg_fuel = zeros(obj.T,1);
                obj.ldg_rfuel = zeros(obj.T,1);
                obj.ldg_sfuel = zeros(obj.T,1);
                obj.ldg_dfuel = zeros(obj.T,1);
                obj.ldg_opstate = 1;
                obj.ldg_hfuel = zeros(obj.T,1);
                obj.ldg_elec_ramp = zeros(obj.T,1);
                obj.ldg_off = 1;
                
            end
        end


        %% Legacy bottoming systems
        function SetupLegacyBottomingSystems(obj, bot_legacy)
        
            %%%Bottoming generator is any electricity producing device that operates
            %%%based on heat recovered from another generator
            
            if ~isempty(bot_legacy)

                %%%Bottom electrical output
                obj.lbot_elec = sdpvar(length(elec),size(bot_legacy,2),'full');

                %%%Bottom operational state
                if lbot_op_state
                    obj.lbot_on = binvar(length(elec),size(bot_legacy,2),'full');
                else
                    obj.lbot_on = zeros(obj.T,1);

                end
                %%%Bottoming cycle
                for i=1:size(bot_legacy,2)
                    obj.Objective = obj.Objective +...
                        obj.lbot_elec(:,1)'*(bot_legacy(1,i)*ones(length(time),1));%%%Bottoming cycle O&M
                end
            else
                obj.lbot_elec = zeros(obj.T,1);
                obj.lbot_on = zeros(obj.T,1);
            end
        end

            
        %% Legacy Heat recovery
        function SetupLegacyHeatRecovery(obj, dg_legacy, hr_legacy, ng_cost, rng_cost)

            if ~isempty(dg_legacy) && ~isempty(hr_legacy)

                %%%Heat recovery output
                obj.hr_heat = sdpvar(length(elec),size(hr_legacy,2),'full');
                
                %%%If duct burner or HR heating source is available
                if ~isempty(db_legacy)

                    %%%Duct burner - Conventional
                    obj.db_fire = sdpvar(length(elec),size(db_legacy,2),'full');

                    %%%Duct burner - Renewable
                    obj.db_rfire = sdpvar(length(elec),size(db_legacy,2),'full');
                    
                    %%%If hydrogen production is an option
                    if ~isempty(el_v) || ~isempty(rel_v)
                        obj.db_hfire = sdpvar(obj.T,size(dg_legacy,2),'full');
                    else
                        obj.db_hfire = zeros(obj.T,1);
                    end
                            
                    for ii = 1:size(db_legacy,2)

                        %%%Duct burner and renewable duct burner
                        obj.Objective = obj.Objective ...
                            + obj.db_fire'*((db(1,ii)+ng_cost)*ones(length(time),1)) ...
                            + obj.db_rfire'*((db(1,ii)+rng_cost)*ones(length(time),1)) ...
                            + obj.db_hfire'*((db(1,ii)+rng_cost)*ones(length(time),1));
                    end
                else
                    obj.db_fire = [];
                    obj.db_rfire = [];
                    obj.db_hfire = [];
                end
                
            else
                obj.hr_heat = zeros(obj.T,1);
                obj.db_fire = zeros(obj.T,1);
                obj.db_rfire = zeros(obj.T,1);
                obj.db_hfire = zeros(obj.T,1);
            end
        end

        %% Legacy boiler
        function SetupLegacyBoiler(obj, boil_legacy, ng_cost, rng_cost)

            if ~isempty(boil_legacy)

                %%%Basic boiler
                obj.boil_fuel = sdpvar(length(elec),size(boil_legacy,2),'full');
                obj.boil_rfuel = sdpvar(length(elec),size(boil_legacy,2),'full');
                
                %%%If hydrogen production is an option
                if ~isempty(el_v) || ~isempty(rel_v)
                    obj.boil_hfuel = sdpvar(obj.T,size(boil_legacy,2),'full');
                else
                    obj.boil_hfuel = zeros(obj.T,1);
                end
                
                obj.Objective = obj.Objective ...
                    +  sum(obj.boil_fuel)*(boil_legacy(1) + ng_cost) ...
                    +sum(obj.boil_rfuel)*(boil_legacy(1) + rng_cost)...
                    +sum(obj.boil_hfuel)*(boil_legacy(1) + rng_cost);
            else
                obj.boil_fuel = zeros(obj.T,1);
                obj.boil_rfuel = zeros(obj.T,1);
                obj.boil_hfuel = zeros(obj.T,1);
            end
        end


        %% Legacy Generic Chiller
        function SetupLegacyGenericChiller(obj, cool, vc_legacy)

            if ~isempty(cool) && sum(cool) > 0  && isempty(vc_legacy)
                obj.generic_cool = sdpvar(length(elec),size(boil_legacy,2),'full');
            else
                obj.generic_cool = zeros(obj.T,1);
            end
        end


        %% Legacy EES
        function SetupLegacyEES(obj, dayMultiplier, ees_legacy)
        
            if ~isempty(ees_legacy)

                %%%EES Charging
                obj.lees_chrg = sdpvar(obj.T,size(ees_legacy,2),'full');
                %%%EES discharging
                obj.lees_dchrg = sdpvar(obj.T,size(ees_legacy,2),'full');
                %%%EES SOC
                obj.lees_soc = sdpvar(obj.T,size(ees_legacy,2),'full');
                
                for ii = 1:size(ees_legacy,2)

                    %%%EES Cost Functions
                    obj.Objective = obj.Objective...
                        + ees_legacy(2,ii)*sum(sum(dayMultiplier.*obj.lees_chrg(:,ii))) ...%%%Charging O&M
                        + ees_legacy(3,ii)*sum(sum(dayMultiplier.*obj.lees_dchrg(:,ii)));%%%Discharging O&M
                end
            else
                obj.lees_chrg = zeros(obj.T,1);
                obj.lees_dchrg = zeros(obj.T,1);
                obj.lees_soc = zeros(obj.T,1);
            end
        end


        %% Legacy Cold TES
        function SetupLegacyColdTES(obj, cool, tes_legacy)
        
            if ~isempty(cool) && sum(cool) >0 && ~isempty(tes_legacy)

                %%%TES Energy Storage Vector
                %%%TES State of Charge
                obj.ltes_soc = sdpvar(length(elec),size(tes_legacy,2),'full');

                %%%TES charging/discharging
                obj.ltes_chrg = sdpvar(length(elec),size(tes_legacy,2),'full');
                obj.ltes_dchrg = sdpvar(length(elec),size(tes_legacy,2),'full');
                
                %%%TES
                for i=1:size(tes_legacy,2)

                    obj.Objective = obj.Objective + obj.ltes_chrg(:,i)'*(tes_legacy(2,i)*ones(length(time),1))...
                        + obj.ltes_dchrg(:,i)'*(tes_legacy(3,i)*ones(length(time),1));
                end
                
            else
                obj.ltes_soc = zeros(obj.T,1);
                obj.ltes_chrg = zeros(obj.T,1);
                obj.ltes_dchrg = zeros(obj.T,1);
            end
        end


        %% Legacy Chillers
        function SetupLegacyChillers(obj, onoff_model, cool, vc_legacy)

            if ~isempty(cool) && sum(cool) >0 && ~isempty(vc_legacy)

                %%%Operational windows
                vc_hour_num = ceil(length(time)/4);

                if onoff_model
               
                    obj.vc_size = zeros(length(elec),size(vc_legacy,2));
                    obj.vc_cop = ones(length(elec),size(vc_legacy,2));

                    for i=1:length(elec)

                        obj.vc_cop(i,:)=obj.vc_cop(i,:).*(1./vc_legacy(2,:));
                        obj.vc_size(i,:) = vc_legacy(3,:);
                    end

                    %%%VC Cooling output
                    obj.lvc_cool = sdpvar(length(elec),size(vc_legacy,2),'full');

                    %%%VC Operational State
                    obj.lvc_op = binvar(vc_hour_num,size(vc_legacy,2),'full');
                
                    %%%VC Start
                    % vc_start = binvar(vc_hour_num,size(vc_legacy,2),'full');
                    
                    %%%Electric Vapor Compression
                    for i=1:size(vc_legacy,2)
                        
                        obj.Objective = obj.Objective ...
                            + obj.lvc_cool(:,i)'*(vc_legacy(1,i)*ones(length(time),1));
                        %             + obj.lvc_cool(:,i)'*(vc_legacy(1,i)*ones(length(time),1)); ...
                        %                     + 10*sum(sum(vc_start));
                    end

                else

                    %%%VC Operational State
                    obj.vc_size = vc_legacy(3,:)/e_adjust;
                    obj.vc_cop = (1./vc_legacy(2,:));
                    obj.lvc_op = binvar(vc_hour_num,size(vc_legacy,2),'full');
                    
                end
                
            else
                obj.lvc_op = 0;
                obj.lvc_cool = zeros(obj.T,1);
                obj.vc_cop = 0;
            end
        end


        %% Dump Variables
        function SetupDumpVariables(obj, elec_dump)

            %%These variables should always be zero and are nonzero when you ahve a
            %%poorly conceived problem
            if ~isempty(elec_dump)
                obj.elec_dump = sdpvar(obj.T,1,'full');
            else
                obj.elec_dump = zeros(obj.T,1);
            end
        end
    

        %%-------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        %%                          OFF SITE       
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------

        %% Energy products exported from a power plant
        function SetupPowerPlantExports(obj, util_solar_on, util_ees_on, util_pp_export, util_pp_import, util_pv_wheel, util_pv_wheel_lts)

            if util_solar_on || util_ees_on
                
                if util_pp_export
                    obj.pp_elec_export = sdpvar(obj.T,1,'full'); % Export from the power plant
                else
                    obj.pp_elec_export = zeros(obj.T,1);
                end
                
                % Can the power plant import power at the local node??
                if util_pp_import
                    obj.pp_elec_import = sdpvar(obj.T,1,'full'); % Import at the power plant
                    obj.import_state = binvar(obj.T,1,'full'); % Import State
                else
                    obj.pp_elec_import =   zeros(obj.T,1);
                    obj.import_state = zeros(obj.T,1);
                end
                
                % General wheeling potential
                if util_pv_wheel
                    obj.pp_elec_wheel = sdpvar(obj.T,1,'full');
                else
                    obj.pp_elec_wheel = zeros(obj.T,1);
                end
                
                % Wheeling for long term storage
                if util_pv_wheel_lts
                    obj.pp_elec_wheel_lts = sdpvar(obj.T,1,'full');
                else
                    obj.pp_elec_wheel_lts = zeros(obj.T,1);
                end

                obj.Objective = obj.Objective ...
                    + sum((-lmp_util).*obj.pp_elec_export) ...
                    + sum((lmp_util + 0.015).*obj.pp_elec_import) ...
                    + sum(t_and_d.*(obj.pp_elec_wheel + obj.pp_elec_wheel_lts));
            else
                obj.pp_elec_export = zeros(obj.T,1);
                obj.pp_elec_import = zeros(obj.T,1);
                obj.pp_elec_wheel = zeros(obj.T,1);
                obj.pp_elec_wheel_lts = zeros(obj.T,1);
                obj.import_state = zeros(obj.T,1);
            end

        end
        
        %% Community Scale Solar
        function SetupCommunityScaleSolar(obj, utilpv_v)

            if ~isempty(utilpv_v)

                %%% Adopted Utility Scale PV
                obj.util_pv_adopt = sdpvar(1,size(utilpv_v,2),'full');

                %%% Electricity generated and sent to the grid
                obj.util_pv_elec = sdpvar(obj.T,size(utilpv_v,2),'full');
                
                for ii = 1:size(utilpv_v,2)
                    obj.Objective = obj.Objective ...
                        + sum(obj.M.*utilpv_cap_mod(ii).*utilpv_mthly_debt(ii).*obj.util_pv_adopt(ii)) ...
                        + sum((utilpv_v(3,ii)).*obj.util_pv_elec);
                end
            else
                obj.util_pv_adopt = 0;
                obj.util_pv_elec = zeros(obj.T,1);
            end
        end

        %% Community Scale Wind
        function SetupCommunityScaleWind(obj, util_wind_v)

            if ~isempty(util_wind_v)

                %%% Adopted Utility Scale PV
                obj.util_wind_adopt = sdpvar(1,size(util_wind_v,2),'full');

                %%% Electricity generated and sent to the grid
                obj.util_wind_elec = sdpvar(obj.T,size(util_wind_v,2),'full');

                for ii = 1:size(util_wind_v,2)
                    obj.Objective = obj.Objective ...
                        + sum(obj.M.*util_wind_cap_mod(ii).*util_wind_mthly_debt(ii).*obj.util_wind_adopt(ii)) ...
                        + sum((util_wind_v(2,ii)).*obj.util_wind_elec);
                end
            else
                obj.util_wind_adopt = 0;
                obj.util_wind_elec = zeros(obj.T,1);
            end
        end


        %% Community Scale Storage
        function SetupCommunityScaleStorage(obj, util_ees_v)
            
            if ~isempty(util_ees_v)
                
                %%%Adopted utility scale EES
                obj.util_ees_adopt = sdpvar(1,size(util_ees_v,2),'full');
                %%% Adopted EES SOC
                obj.util_ees_soc = sdpvar(obj.T,size(util_ees_v,2),'full');
                %%% Adopted EES Charging
                obj.util_ees_chrg = sdpvar(obj.T,size(util_ees_v,2),'full');
                %%% Adopted EES Discharging
                obj.util_ees_dchrg = sdpvar(obj.T,size(util_ees_v,2),'full');
                
                for ii = 1:size(util_ees_v,2)
                    obj.Objective = obj.Objective ...
                        + sum(obj.M*util_ees_cap_mod(ii)*util_ees_mthly_debt(ii)*obj.util_ees_adopt(ii)) ...
                        + sum( obj.util_ees_chrg(:,ii))*util_ees_v(2,ii) ...
                        + sum( obj.util_ees_dchrg(:,ii))*util_ees_v(3,ii);
                end
                
            else
                obj.util_ees_adopt = 0;
                obj.util_ees_soc = 0;
                obj.util_ees_chrg = zeros(obj.T,1);
                obj.util_ees_dchrg = zeros(obj.T,1);
            end
        end

        %% Remote Electrolyzer
        function SetupRemoteElectrolyzer(obj, util_el_v, elec)

            if ~isempty(util_el_v)
            
                %%%Electrolyzer efficiency
                obj.util_el_eff = ones(obj.T,size(el_v,2));

                for ii = 1:size(el_v,2)
                    obj.util_el_eff(:,ii) = (1/util_el_v(3,ii)).*obj.util_el_eff(:,ii);
                end

                %%%Adoption technologies
                obj.util_el_adopt = sdpvar(1,size(util_el_v,2),'full');

                %%%Electrolyzer production
                obj.util_el_prod = sdpvar(obj.T,size(util_el_v,2),'full');
                
                
                for ii = 1:size(util_el_v,2)
                    %%%Electrolyzer Cost Functions
                    obj.Objective = obj.Objective...
                        + sum(obj.M.*util_el_mthly_debt.*obj.util_el_adopt) ... %%%Capital Cost
                        + sum(sum(obj.util_el_prod).*util_el_v(2,:)); %%%VO&M
                end
                
            else
                obj.util_el_prod = zeros(size(elec(:,1)));
            end
        end

        %% H2 Pipeline Injection
        function SetupUtilH2PipelineInjection(obj, util_h2_inject_on)
        
            if util_h2_inject_on

                %%%Adopt HRS Equipment
                obj.util_h2_inject_adopt = binvar(1,1,'full');

                %%%Size of adopted HRS Equipment
                obj.util_h2_inject_size = sdpvar(1,1,'full');
                
                %%%Injected Hydrogen
                if util_h2_sale
                    obj.util_h2_inject = sdpvar(obj.T,1,'full');
                else
                    obj.util_h2_inject = zeros(obj.T,1);
                end

                %%%Stored Hydrogen
                if util_h2_pipe_store
                    obj.util_h2_store = sdpvar(obj.T,1,'full');
                else
                    obj.util_h2_store = zeros(obj.T,1);
                end
                
                obj.Objective = obj.Objective ...
                    + obj.M*util_h2_inject_mthly_debt(1)*obj.util_h2_inject_adopt ...
                    + obj.M*util_h2_inject_mthly_debt(2)*obj.util_h2_inject_size ...
                    - ng_inject.*sum(obj.util_h2_inject) ...
                    + rng_storage_cost.*sum(obj.util_h2_store);
            else
                obj.util_h2_inject = zeros(obj.T,1);
                obj.util_h2_inject_size = 0;
                obj.util_h2_inject_adopt = 0;
                obj.util_h2_store = zeros(obj.T,1);
            end
        end

    end
end

