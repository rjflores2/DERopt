classdef CModelConstraints < handle
    
    properties (SetAccess = private)
        T
        M
    end

    properties (SetAccess = public)
        Constraints
    end

    properties (Constant)
        rate = {'TOU8'}
        rate_labels = {'TOU8'};
    end

    methods

        function obj = CModelConstraints(timeInterval, numberOfMonthsInSim)

            obj.T = timeInterval;
            obj.M = numberOfMonthsInSim;
            obj.Constraints = [];
            
        end


        %% General Equality Constraints
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function [elapsedTime] = Calculate_GeneralEquality(obj, onoff_model, modelVars, heat, cool, elec, el_v, rel_v, hrs_on, util_solar_on, util_ees_on, util_pv_wheel_lts)
            tic

            if ~onoff_model

                % TODO:  "opt_gen_equalities_vc_mod"

            end

            %% Building Electrical Energy Balances
            % (For  all timesteps t Vectorized ??)
            obj.Constraints = [obj.Constraints
                (sum(modelVars.fuel_cell_binary_elec,2) + sum(modelVars.util_import,2) + sum(modelVars.pv_elec,2) + sum(modelVars.ees_dchrg,2) + sum(modelVars.lees_dchrg,2) + sum(modelVars.rees_dchrg,2) + sum(modelVars.ldg_elec,2) + sum(modelVars.lbot_elec,2) + sum(modelVars.pp_elec_wheel,2)... %%%Production
                ==...
                elec + sum(modelVars.ees_chrg,2) + sum(modelVars.lees_chrg,2) + modelVars.generic_cool./4  + sum(modelVars.lvc_cool.*modelVars.vc_cop,2) + sum(modelVars.el_eff.*modelVars.el_prod,2) + sum(modelVars.h2_chrg_eff.*modelVars.h2es_chrg,2) + modelVars.util_gen_export + modelVars.hrs_supply.*modelVars.hrs_chrg_eff + modelVars.elec_dump):'Electricity Balance']; %%%Demand
            
            %% Heat Balance
            if ~isempty(heat) && sum(heat > 0) > 0
                obj.Constraints = [obj.Constraints
                    ((modelVars.boil_fuel + modelVars.boil_rfuel + modelVars.boil_hfuel).*boil_legacy(2) + modelVars.hr_heat == heat):'Thermal Balance'];
            end
            
            %% Cooling Balance
            if ~isempty(cool) && sum(cool) > 0
                obj.Constraints = [obj.Constraints
                    (modelVars.generic_cool + sum(modelVars.ltes_dchrg,2) + sum(modelVars.lvc_cool,2) == cool + sum(modelVars.ltes_chrg,2)):'Cooling Balance'];
                
            %     Constraints = [Constraints
            %         modelVars.generic_cool + sum(modelVars.ltes_dchrg,2) + sum(vc_size.*modelVars.lvc_op,2) == cool + sum(modelVars.ltes_chrg,2)];
            end
            
            %% Chemical ennergy conversion balance - Hydrogen
            if ~isempty(el_v) || ~isempty(rel_v)
                obj.Constraints = [obj.Constraints
                   (sum(modelVars.util_h2,2) + sum(modelVars.rel_prod,2) + sum(modelVars.el_prod,2) + sum(modelVars.rel_prod_wheel,2) + sum(modelVars.el_prod_wheel,2) + sum(modelVars.h2es_dchrg,2) == sum(modelVars.fuel_cell_binary_hfuel,2) + sum(modelVars.ldg_hfuel,2) + sum(modelVars.db_hfire,2) + sum(modelVars.boil_hfuel,2) + sum(modelVars.h2es_chrg,2) + modelVars.hrs_supply + modelVars.h2_inject + modelVars.h2_store):'Hydrogen Balance'];
            end
            
            %% H2 Transportation
            if hrs_on
                obj.Constraints = [obj.Constraints
                (modelVars.hrs_supply + var_hrs.hrs_tube == hrs_demand):'HRS Balance'
                modelVars.hrs_supply <=1.5*max(hrs_demand)*modelVars.hrs_supply_adopt];
            end
            
                   

            elapsedTime = toc;
        end


        %% General Inequality Constraints
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function [elapsedTime] = Calculate_GeneralInequality(obj, modelVars, e_adjust, utility_exists, dc_exist, endpts, onpeak_index, midpeak_index, export_on, export_price, import_price, fac_prop, util_pv_wheel, util_ees_on, util_pp_import, h2_fuel_forced_fraction, el_v, h2_fuel_limit, ldg_on, co2_lim, biogas_limit, h2_charging_rec, gen_export_on, co2_import, co2_ng, co2_rng)
            tic
            
            %% Demand Charges
  
            if utility_exists == 1
                
                if dc_exist == 1 % IF that building has demand charges

                    %%Non TOU Demand Charges
                    for i=1:length(endpts) %i counts months

                        if i==1 % for January
                            obj.Constraints=[obj.Constraints
                                (modelVars.util_import(1:endpts(1)).*e_adjust <= modelVars.util_nontou_dc(i)):'Non TOU DC January'];
                        else % for all other months
                            obj.Constraints=[obj.Constraints
                                (modelVars.util_import(endpts(i-1)+1:endpts(i)).*e_adjust <= modelVars.util_nontou_dc(i)):'Non TOU DC'];
                        end
                    end
                    
                    %% TOU On-Peak & Mid-Peak Demand Chargers

                    %%%DC counters
                    on_dc_count = 1;
                    mid_dc_count = 1;

                    for i = 1:length(endpts)

                        %%%Month start/ending
                        if i == 1
                            start = 1;
                            finish = endpts(i);
                        else
                            start = endpts(i-1) + 1;
                            finish = endpts(i);
                        end
                        
                        %%%Checking if On-peak occurs
                        if sum(onpeak_index(start:finish)) > 0 %If onpeak demand charge occurs during the current
                            
                            %%%Indicies for current month on-peak
                            on_index = find(onpeak_index(start:finish)>0) + start - 1;
                            
                            %%%Setting Cosntraints
                            obj.Constraints=[obj.Constraints
                                (modelVars.util_import(on_index).*e_adjust <= modelVars.util_onpeak_dc(on_dc_count)):'TOU DC Onpeak'];
                            
                            %%%Advancing on peak counter
                            on_dc_count = on_dc_count + 1;
                        end
                        
                        %%%Checking if Mid-peak occurs
                        if sum(midpeak_index(start:finish)) > 0 %If onpeak demand charge occurs during the current
                            
                            %%%Indicies for current month on-peak
                            mid_index = find(midpeak_index(start:finish)>0) + start - 1;
                            
                            %%%Setting Cosntraints
                            obj.Constraints=[obj.Constraints
                                (modelVars.util_import(mid_index).*e_adjust <= modelVars.util_midpeak_dc(mid_dc_count)):'TOU DC Midpeak'];
                            
                            %%%Advancing on peak counter
                            mid_dc_count = mid_dc_count + 1;
                        end
                    end
                end
            end
            
            %% Net Energy Metering
            if export_on

                %%%Current Utility Rate
                index = find(ismember(obj.rate_labels,obj.rate(1)));
                
                obj.Constraints = [obj.Constraints
                    (export_price(:,index)'*(sum(modelVars.rees_dchrg_nem,2) + modelVars.pv_nem) <= import_price(:,index)'*modelVars.util_import):'NEM Credits < Import Cost'
                    (sum(sum(modelVars.rees_dchrg_nem,2) + modelVars.pv_nem) <= sum(modelVars.util_import)):'NEM Energy < Import Energy'];
            end
            
            %% General import / export limits
            utility_exists
%             if exist('fac_prop') && (~isempty(utility_exists) || util_pv_wheel)

%                 obj.Constraints = [obj.Constraints
%                     (modelVars.util_import + modelVars.pp_elec_wheel + modelVars.pp_elec_wheel_lts <= modelVars.util_import_state .*fac_prop(1)./e_adjust):'General Import Limits'];
%                 if gen_export_on || export_on
%                     obj.Constraints = [obj.Constraints
%                         (modelVars.util_gen_export <= (1 - modelVars.util_import_state) .*fac_prop(1)./e_adjust):'General Export Limits'];
%                 end
%             end
            
            
            %% Gas Turbine Forced Fuel Input Constraint - Hydrogen
            if ~isempty(h2_fuel_forced_fraction) && ~isempty(el_v)
                
                obj.Constraints = [obj.Constraints
                    (h2_fuel_forced_fraction.*(sum(modelVars.ldg_fuel,2) +  sum(modelVars.ldg_rfuel,2)) <= (1 - h2_fuel_forced_fraction).*(sum(modelVars.ldg_hfuel,2))):'Forced H2 Fuel Requirement'];   
            end
            
            %% Gas Turbine Fuel Input Limit - Hydrogen
            if ~isempty(h2_fuel_limit) && ldg_on
                
                obj.Constraints = [obj.Constraints
                    ((1 - h2_fuel_limit).*modelVars.ldg_hfuel <= h2_fuel_limit.*(modelVars.ldg_fuel + modelVars.ldg_rfuel)):'H2 Fuel Limit in GT'];   
            %         ((1 - h2_fuel_limit).*modelVars.ldg_hfuel <= h2_fuel_limit.*(modelVars.ldg_fuel + modelVars.ldg_rfuel + modelVars.ldg_hfuel)):'H2 Fuel Limit in GT'];   
            end
            
            %% CO2 limit
            if ~isempty(co2_lim)
                
                obj.Constraints = [obj.Constraints
                    ( sum(modelVars.util_import.*co2_import) ... %%%CO2 from imports
                    + co2_ng*(sum(sum(modelVars.fuel_cell_binary_fuel)) + sum(sum(modelVars.ldg_fuel)) + sum(sum(modelVars.db_fire)) + sum(sum(modelVars.boil_fuel)))... %%%CO2 from NG combustion
                    + co2_rng*(sum(sum(modelVars.ldg_rfuel)) + sum(sum(modelVars.db_rfire)) + sum(sum(modelVars.boil_rfuel))) ... %%%CO2 from rNG combustion
                    <= ...
                    co2_lim):'CO2 Limit'];
                   
            end
            
            %% Renewable biogas limit
            if ~isempty(biogas_limit) && ldg_on
                
                %%%(length(endpts)/12) term prorates available biogas to the simulation
                %%%period
                obj.Constraints = [obj.Constraints
                (sum(modelVars.ldg_rfuel  + modelVars.boil_rfuel + modelVars.db_rfire) <= biogas_limit*(length(endpts)/12)):'Renewable biogas limit'];
            end

            %% Total Energy throughput required
            if ~isempty(h2_charging_rec)
                
                obj.Constraints = [obj.Constraints
                    ((length(time)/(24*e_adjust)*h2_charging_rec) <= sum(sum(var_h2es.h2es_chrg))):'Required H2 storage utilization'];
            %         (10 <= sum(var_h2es.h2es_adopt)):'Required H2 storage utilization'];
            end

            elapsedTime = toc;
        end
    

        %% Heat Recovery Inequality Constraints
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function [elapsedTime] = Calculate_HeatRecoveryInequality(obj, modelVars, dg_legacy, hr_legacy, bot_legacy)
            tic
            
            %% Considering heat recovery
            
            if (~isempty(dg_legacy) ) && (~isempty(hr_legacy)) %%%If a generator and heat recovery system exist or can be adopted
                
                %%%Topping Cycle Coefficients
                if ~isempty(dg_legacy)
                    for ii = 1:size(dg_legacy,2)
                        ldg_coef_1 = dg_legacy(9,ii)*ones(obj.T,1);
                        ldg_coef_2 = dg_legacy(10,ii)*ones(obj.T,1);
                    end
                end
                
                %%%Bottoming cycle coefficients
                if ~isempty(bot_legacy)
                    for ii = 1:size(bot_legacy,2)
                        bot_coef(:,ii) = (1/(bot_legacy(4,ii)*bot_legacy(5,ii)))*ones(obj.T,1);
                    end

                    % TODO: is "bot_coef" being overwritten here??
                end
                
                
                %%%Heat recovery
                obj.Constraints = [obj.Constraints
                    (sum(bot_coef.*modelVars.lbot_elec,2) ... %%%Bottoming cycle / Steam turbine
                    + modelVars.hr_heat./hr_legacy(2) ... %%%Heat captured and used for DHW/Space Heating
                    <= (sum(ldg_coef_1.*modelVars.ldg_elec,2) + sum(ldg_coef_2.*modelVars.ldg_opstate,2)) ... %%%Heat generated by any legacy systems
                    + db_legacy(2)*(modelVars.db_fire + modelVars.db_rfire + modelVars.db_hfire)):'Heat Recovery']; %%%Duct burner
                
                if ldg_op_state
                    obj.Constraints = [obj.Constraints
                        ( modelVars.lbot_on <=   sum(modelVars.ldg_opstate,2)):'ST cannot operate w/out GT'];
                end
            end

            elapsedTime = toc;
        end
        
        %% Fuel Cell Binary Adoption Constraints
        function [elapsedTime] = Calculate_FuelCellBinary(obj, modelVars, e_adjust, FuelCellBinary_v, elec)
            obj.Constraints = [obj.Constraints
                (modelVars.fuel_cell_binary_capacity <= modelVars.fuel_cell_binary_adopt.*max(elec)*e_adjust):'Fuel Cell Binary Adoption'
                (repmat(modelVars.fuel_cell_binary_capacity./e_adjust,size(modelVars.fuel_cell_binary_elec,1),1).*FuelCellBinary_v(5) <= modelVars.fuel_cell_binary_elec <= repmat(modelVars.fuel_cell_binary_capacity./e_adjust,size(modelVars.fuel_cell_binary_elec,1),1)):'Fuel Cell Output Limits'
                (modelVars.fuel_cell_binary_elec./FuelCellBinary_v(4) == modelVars.fuel_cell_binary_fuel + modelVars.fuel_cell_binary_hfuel):'Fuel Cell Fuel Input'];
            
            % (var_dgb.dgb_capacity <= var_dgb.dgb_adopt.*1000):'dgb Adoption'
            %         (var_dgb.dgb_elec  <= repmat(var_dgb.dgb_capacity,size(var_dgb.dgb_elec,1),1)):'dgb Output Limits'
%         (var_dgb.dgb_elec./dgb_v(3) == var_dgb.dgb_fuel):'dgb Fuel'];
end
        %% Legacy DG Constraints
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function [elapsedTime] = Calculate_LegacyDG(obj, modelVars, dg_legacy, e_adjust, dg_legacy_cyc)
            tic

            %%%Legacy generator constraints
            if ~isempty(dg_legacy)

                for i = 1:size(dg_legacy,2)

                    obj.Constraints = [obj.Constraints
                        (-dg_legacy(2,i)*dg_legacy(5,i) <= modelVars.ldg_elec(2:size(modelVars.ldg_elec,1),i) - modelVars.ldg_elec(1:size(modelVars.ldg_elec,1)-1,i) <= dg_legacy(2,i)*dg_legacy(4,i)):'LDG Ramp Constraints' %Ramp Rates Constraints
                        ((dg_legacy(3,i)*(1/e_adjust)).*modelVars.ldg_opstate(:,i) <= modelVars.ldg_elec(:,i) <= (dg_legacy(2,i)*(1/e_adjust).*modelVars.ldg_opstate(:,i))):'Min/Max Power' %%%Min/Max Power output for generator & on/off behavior
                        (dg_legacy(7,i)*modelVars.ldg_elec(:,i) + dg_legacy(8,i).*modelVars.ldg_opstate(:,i) == (modelVars.ldg_fuel(:,i) + modelVars.ldg_rfuel(:,i) + modelVars.ldg_hfuel(:,i) + modelVars.ldg_sfuel(:,i) + modelVars.ldg_dfuel(:,i))):'LDG Fuel Input']; %%%Fuel Consumption to produce electricity
                           
                    %% If Cycling Costs are included
                    if  ~isempty(dg_legacy_cyc)
                        %%%Ramping Constraints
                        obj.Constraints = [obj.Constraints
                            ((modelVars.ldg_elec(2:end,i) - modelVars.ldg_elec(1:end-1,i)) <= modelVars.ldg_elec_ramp(:,i)):'Cycling Cost Constraints'
                            ((modelVars.ldg_elec(1:end-1,i) - modelVars.ldg_elec(2:end,i)) <= modelVars.ldg_elec_ramp(:,i)):'Cycling Cost Constraints'];
                        
                        
                    end
                end
            end

            elapsedTime = toc;
        end
        
        
        %% Legacy ST Constraints
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function [elapsedTime] = Calculate_LegacyST(obj, modelVars, bot_legacy)
            tic

            if ~isempty(bot_legacy)

                %% Constraints - Bottom Cycle
                for i=1:size(bot_legacy,2)

                    if lbot_op_state
                        obj.Constraints=[obj.Constraints
                            (0 <= modelVars.lbot_elec <= bot_legacy(2,i)./4):'Min/Max ST Output'];%%% Min/Max power output                        
                    else 
                        obj.Constraints=[obj.Constraints
                            (modelVars.lbot_on*(bot_legacy(2,i)*bot_legacy(3,i))./4 <= modelVars.lbot_elec <= modelVars.lbot_on*(bot_legacy(2,i)./4)):'Min/Max ST Output'];%%% Min/Max power output
                    end
                end
            end

            elapsedTime = toc;
        end
        
        
        %% Solar PV Constraints
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function [elapsedTime] = Calculate_SolarPV(obj, modelVars, pv_v, solar, pv_legacy, toolittle_pv, maxpv, curtail, e_adjust)
            tic
            
            %% PV Constraints
            if ~isempty(pv_v) || (~isempty(pv_legacy) && sum(pv_legacy(2,:)) > 0)

                %% PV Energy balance when curtailment is allowed
                if curtail
                    obj.Constraints = [obj.Constraints
                        (modelVars.pv_elec + modelVars.pv_nem + sum(modelVars.rees_chrg,2) + sum(modelVars.rel_eff.*modelVars.rel_prod,2) <= (sum(pv_legacy(2,:))/e_adjust)*solar + (sum(modelVars.pv_adopt))/e_adjust*solar) :'PV Energy Balance - Curtailment Allowed'];
                    % Constraints = [Constraints, (pv_wholesale + pv_elec + pv_nem + rees_chrg <= repmat(solar,1,K).*repmat(pv_adopt,T,1)):'PV Energy Balance'];
                else
                    obj.Constraints = [obj.Constraints
                        (modelVars.pv_elec + modelVars.pv_nem + sum(modelVars.rees_chrg,2) + sum(modelVars.rel_eff.*modelVars.rel_prod,2)  == (sum(pv_legacy(2,:))/e_adjust)*solar + (sum(modelVars.pv_adopt))/e_adjust*solar) :'PV Energy Balance - No Curtailment'];
                    % Constraints = [Constraints, (pv_wholesale + pv_elec + pv_nem + rees_chrg == repmat(solar,1,K).*repmat(pv_adopt,T,1)):'PV Energy Balance'];
                end

                %% Max PV to adopt (capacity constrained)
%                 if ~isempty(maxpv) && ~isempty(pv_v) 
% 
%                     obj.Constraints = [obj.Constraints
%                         (modelVars.pv_adopt' <= maxpv'):'Mav PV Capacity'];  
%                 end
                
                %% Don't curtail for residential
                % residential = find(strcmp(rate,'R1') |strcmp(rate,'R2') | strcmp(rate,'R3')| strcmp(rate,'R4'));   
                % Constraints = [Constraints,...
                %        ( solar*pv_adopt(residential) ==  pv_wholesale(:,residential) + pv_elec(:,residential) + pv_nem(:,residential) + rees_chrg(:,residential)):'No residential curtail' ];
            end

            elapsedTime = toc;
        end
        
        
        %% EES Constraints
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function [elapsedTime] = Calculate_EES(obj, modelVars, ees_v, pv_v, rees_on,export_on)
            tic

            %% Grid tied EES
            if isempty(ees_v) == 0

                for ii = 1:size(ees_v,2)

                    %%%SOC Equality / Energy Balance
                    obj.Constraints = [obj.Constraints
                        (modelVars.ees_soc(1,ii) <= modelVars.ees_soc(obj.T,ii)):'Initial EES SOC <= Final SOC'
                        (modelVars.ees_soc(2:obj.T,ii) == ees_v(10,ii)*modelVars.ees_soc(1:obj.T-1,ii) + ees_v(8,ii)*modelVars.ees_chrg(2:obj.T,ii)  - (1/ees_v(9,ii))*modelVars.ees_dchrg(2:obj.T,ii)):'EES Balance'  %%%Minus discharging of battery
                        (ees_v(4,ii)*modelVars.ees_adopt(ii) <= modelVars.ees_soc(:,ii) <= ees_v(5,ii)*modelVars.ees_adopt(ii)):'EES Min/Max SOC' %%%Min/Max SOC
                        (modelVars.ees_chrg(:,ii) <= ees_v(6,ii)*modelVars.ees_adopt(ii)):'EES Max Chrg'  %%%Max Charge Rate
                        (modelVars.ees_dchrg(:,ii) <= ees_v(7,ii)*modelVars.ees_adopt(ii)):'EES Max Dchrg']; %%%Max Discharge Rate
                    
                    %% Renewable Tied EES
                    if isempty(pv_v) == 0 && rees_on

                        %%%SOC Equality / Energy Balance
                        obj.Constraints = [obj.Constraints
                            (modelVars.rees_soc(1,ii) <= modelVars.rees_soc(obj.T,ii)):'Initial REES SOC <= Final SOC'
                            (modelVars.rees_soc(2:obj.T,ii) == ees_v(10,ii)*modelVars.rees_soc(1:obj.T-1,ii) + ees_v(8,ii)*modelVars.rees_chrg(2:obj.T,ii)  - (1/ees_v(9,ii))*(modelVars.rees_dchrg(2:obj.T,ii) + modelVars.rees_dchrg_nem(2:obj.T,ii))):'REES Balance'  %%%Minus discharging of battery
                            (ees_v(4,ii)*modelVars.rees_adopt(ii) <= modelVars.rees_soc(:,ii) <= ees_v(5,ii)*modelVars.rees_adopt(ii)):'REES Min/Max SOC' %%%Min/Max SOC
                            (modelVars.rees_chrg(:,ii) <= ees_v(6,ii)*modelVars.rees_adopt(ii)):'REES Max Chrg' %%%Max Charge Rate
                            (modelVars.rees_dchrg(:,ii) <= ees_v(7,ii)*modelVars.rees_adopt(ii)):'REES Max Dchrg']; %%%Max Discharge Rate
                        
                        
                        if export_on
                            obj.Constraints = [obj.Constraints
                                (modelVars.rees_dchrg_nem(1,ii) == 0):'No REES NEM in 1st time step'];
                        end
                        %%%Adding sgip constraints
                        %             if sgip_on && ~isempty(find(non_res_rates == find(ismember(rate_labels,rate(1))))) %%%IS nonresidential
                        %                 Constraints = [Constraints;(-modelVars.rees_chrg(:,ii)'*sgip_signal(:,2) +  modelVars.rees_dchrg(:,ii)'*sgip_signal(:,2) >= modelVars.rees_adopt(ii)*sgip(1)):'SGIP CO2 Reduciton'];
                        %             end
                    end
                end
            end

            elapsedTime = toc;
        end
        
        
        %% Legacy EES Constraints
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function [elapsedTime] = Calculate_LegacyEES(obj, modelVars, ees_legacy)
            tic

            %% Grid tied EES
            if ~isempty(ees_legacy)

                for ii = 1:size(ees_legacy,2)

                    %%%SOC Equality / Energy Balance
                    obj.Constraints = [obj.Constraints
                        (modelVars.lees_soc(2:obj.T,ii) == ees_legacy(10,ii)*modelVars.lees_soc(1:obj.T-1,ii) + ees_legacy(8,ii)*modelVars.lees_chrg(2:obj.T,ii)  - (1/ees_legacy(9,ii))*modelVars.lees_dchrg(2:obj.T,ii)):'Legacy EES Balance'  %%%Legacy EES Balance
                        (ees_legacy(4,ii)*ees_legacy(1,ii) <= modelVars.lees_soc(:,ii) <= ees_legacy(5,ii)*ees_legacy(1,ii)):'Legacy EES Min/Max SOC' %%%Legacy Min/Max SOC
                        (modelVars.lees_chrg(:,ii) <= ees_legacy(6,ii)*ees_legacy(1,ii)):'Legacy EES Max Chrg'  %%%Legacy Max Charge Rate
                        (modelVars.lees_dchrg(:,ii) <= ees_legacy(7,ii)*ees_legacy(1,ii)):'Legacy EES Max Dchrg']; %%%Legacy Max Discharge Rate
                    
                    %% Renewable Tied EES
                    % if isempty(pv_v) == 0 && rees_on
                    % 
                    %     %%%SOC Equality / Energy Balance
                    %     obj.Constraints = [obj.Constraints
                    %         (modelVars.rees_dchrg_nem(1,ii) == 0):'Initial REES SOC'
                    %         (modelVars.rees_soc(2:obj.T,ii) == ees_v(10,ii)*modelVars.rees_soc(1:obj.T-1,ii) + ees_v(8,ii)*var_rees.rees_chrg(2:obj.T,ii)  - (1/ees_v(9,ii))*(modelVars.rees_dchrg(2:T,ii) + modelVars.rees_dchrg_nem(2:T,ii))):'REES Balance'  %%%Minus discharging of battery
                    %         (ees_v(4,ii)*var_rees.rees_adopt(ii) <= modelVars.rees_soc(:,ii) <= ees_v(5,ii)*var_rees.rees_adopt(ii)):'REES Min/Max SOC' %%%Min/Max SOC
                    %         (var_rees.rees_chrg(:,ii) <= ees_v(6,ii)*var_rees.rees_adopt(ii)):'REES Max Chrg' %%%Max Charge Rate
                    %         (modelVars.rees_dchrg(:,ii) <= ees_v(7,ii)*var_rees.rees_adopt(ii)):'REES Max Dchrg']; %%%Max Discharge Rate
                    % 
                    %     %%%Adding sgip constraints
                    %     % if sgip_on && ~isempty(find(non_res_rates == find(ismember(obj.rate_labels,obj.rate(1))))) %%%IS nonresidential
                    %     %     obj.Constraints = [obj.Constraints;...
                    %     %         (-var_rees.rees_chrg(:,ii)'*sgip_signal(:,2) +  modelVars.rees_dchrg(:,ii)'*sgip_signal(:,2) >= var_rees.rees_adopt(ii)*sgip(1)):'SGIP CO2 Reduciton'];
                    %     % end
                    % end
                end
            end

            elapsedTime = toc;
        end
        
        
        %% Legacy VC Constraints
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function [elapsedTime] = Calculate_LegacyVC(obj, modelVars, onoff_model, cool, vc_legacy)
            tic

            if onoff_model

                if ~isempty(cool) && sum(cool) > 0  && isempty(vc_legacy)
    
                    for i=1:size(vc_legacy,2)
    
                        lgth = round(length(time)/vc_hour_num);
    
                        for j = 1:vc_hour_num
                            
                            if j == 1
                                st = 1;
                                fn = j*lgth;
                            elseif j == vc_hour_num
                                st = (j-1)*lgth + 1;
                                fn = length(elec);
                            else
                                st = (j-1)*lgth + 1;
                                fn = j*lgth;
                            end
                            obj.Constraints=[obj.Constraints
                                ((1/e_adjust).*vc_legacy(3,i)*vc_legacy(4,i).*modelVars.lvc_op(j,i) <= modelVars.lvc_cool(st:fn,i) <= (1/e_adjust).*vc_legacy(3,i).*modelVars.lvc_op(j,i)):'VC Min/Max Output'];         %%% VC Min/Max output
                            %         vc_op(2:length(elec),i)-vc_op(1:length(elec)-1,i)<=vc_start(2:length(elec),i)];%%% VC Startup
                        end
                    end
                end
            end

            elapsedTime = toc;
        end
        
        
        %% Legacy TES Constraints
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function [elapsedTime] = Calculate_LegacyTES(obj, modelVars, cool, tes_legacy)
            tic

            if ~isempty(cool) && sum(cool) >0 && ~isempty(tes_legacy)
                
                for i = 1:size(tes_legacy,2)
                    
                    obj.Constraints=[obj.Constraints
                        (modelVars.ltes_soc(2:length(elec),i) == tes_legacy(10,i).*modelVars.ltes_soc(1:length(elec)-1,i)+modelVars.ltes_chrg(2:length(elec),i).*(tes_legacy(8,i))-modelVars.ltes_dchrg(2:length(elec),i).*(1/tes_legacy(9,i))):'TES Balance' %%%State of charge
                        ((tes_legacy(1,i)*tes_legacy(4,i)) <= modelVars.ltes_soc(:,i) <= (tes_legacy(1,i)*tes_legacy(5,i))):'TES Min/Max SOC'%%%Min/max SOC
                        (modelVars.ltes_chrg <= (tes_legacy(1,i)*tes_legacy(6,i))):'TES Mac Chrg'%%%Min/Max charge rate
                        (modelVars.ltes_dchrg <= (tes_legacy(1,i)*tes_legacy(7,i))):'TES Mac Dchrg'];%%%Min/Max
                    
                end
            end

            elapsedTime = toc;
        end
        
        
        %% DER Incentives
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function [elapsedTime] = Calculate_DERIncentives(obj, modelVars, ees_v, sgip_on)
            tic
            
            %% SGIP for battery energy storage
            if isempty(ees_v) == 0 && sgip_on
                
                %%%Limiting SGIP incentivized storage
                %%%Constraints
                obj.Constraints = [obj.Constraints
                    modelVars.sgip_ees_pbi(1,:) <= sgip(end)
                    modelVars.sgip_ees_pbi(2,:) <= sgip(end)
                    modelVars.sgip_ees_pbi(3,:) <= sgip(end)];
                
                %%%Going through all buildings
                ind = 1; %%%Comercial/industrial index
                ind_r = 1; %%%Residential index
                ind_re = 1; %%%Residential equity index

                %     for k = 1:K
                if sgip_pbi(1) %%%If SGIP performance based incentives apply

                    %%%Requiring for PBI systems to reduce CO2 emissions scaled by
                    %%%adopted battery size
                    obj.Constraints = [obj.Constraints;(-(sum(modelVars.rees_chrg,2)' + sum(modelVars.ees_chrg,2)')*sgip_signal(:,2) +  (sum(modelVars.rees_dchrg,2)' + sum(obj.ees_dchrg,2)')*sgip_signal(:,2) >= (sum(modelVars.ees_adopt) + sum(modelVars.rees_adopt))*sgip(1)):'SGIP CO2 Reduciton'];
                    obj.Constraints = [obj.Constraints;(modelVars.sgip_ees_pbi(1,ind) + modelVars.sgip_ees_pbi(2,ind) + modelVars.sgip_ees_pbi(3,ind)<= (modelVars.ees_adopt(k) + modelVars.rees_adopt(k))):'SGIP based on adopted battery'];
                    %             Constraints = [Constraints;(sgip_rees_pbi(1,ind) + sgip_rees_pbi(2,ind) + sgip_rees_pbi(3,ind) <= rees_adopt(k)):'SGIP based on adopted renewable battery'];
                    % ind = ind + 1;
                    
                elseif res_units(1)>0 && ~low_income(1)
                    obj.Constraints = [obj.Constraints; (modelVars.sgip_ees_npbi(ind_r) <= (sum(modelVars.ees_adopt) + sum(modelVars.rees_adopt))):'SGIP system limit'];
                    obj.Constraints = [obj.Constraints; (ees_v(7)*(modelVars.sgip_ees_npbi(ind_r)) <= 5*res_units):'SGIP nonPBI residential unity limit'];
                    % ind_r = ind_r + 1;
                elseif low_income(1)
                    obj.Constraints = [obj.Constraints; (modelVars.sgip_ees_npbi_equity(ind_re) <= (sum(modelVars.ees_adopt) + sum(modelVars.rees_adopt))):'SGIP system limit'];
                    obj.Constraints = [obj.Constraints; (ees_v(7)*(sgip_ees_npbi_equity(ind_re)) <= 5*res_units(k)):'SGIP nonPBI residential unity limit'];
                    % ind_re = ind_re + 1;                    
                end
                %     end
            end

            elapsedTime = toc;
        end
        
        
        %% H2 production Constraints
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function [elapsedTime] = Calculate_H2production(obj, modelVars, el_v, rel_v, h2es_v, e_adjust)
            tic
            
            if ~isempty(el_v) || ~isempty(rel_v)

                if ~isempty(el_v)
                    for i = 1:size(el_v,2)
                        obj.Constraints = [obj.Constraints
                            (0 <= modelVars.el_prod(:,i) + modelVars.el_prod_wheel(:,i)   <= modelVars.el_adopt(i).*(1/e_adjust)):'Electrolyzer Min/Max Output']; %%%Production is limited by adopted capacity
                    end
                end
                
                if  ~isempty(rel_v)
                    for i = 1:size(rel_v,2)
                                               
                        obj.Constraints = [obj.Constraints
                            (0 <= modelVars.rel_prod(:,i) + modelVars.rel_prod_wheel(:,i) <= modelVars.rel_adopt(i).*(1/e_adjust)):'Renewable Electrolyzer Min/Max Output']; %%%Production is limited by adopted capacity
                    end
                end
                
                if ~isempty(h2es_v)
                    for ii = 1:size(h2es_v,2)
                        obj.Constraints = [obj.Constraints
                            (modelVars.h2es_soc(1,ii) == modelVars.h2es_soc(end,ii)):'H2ES SOC Start = End'
                            (modelVars.h2es_soc(2:obj.T,ii) == modelVars.h2es_soc(1:obj.T-1,ii) + modelVars.h2es_chrg(2:obj.T,ii)  - modelVars.h2es_dchrg(2:obj.T,ii)):'H2 Storage Balance'  %%%Perfect energy balance
                            (h2es_v(4,ii)*modelVars.h2es_adopt(ii) <= modelVars.h2es_soc(:,ii) <= h2es_v(5,ii)*modelVars.h2es_adopt(ii)):'H2 Min/Max SOC' %%%Min/Max SOC
                            (modelVars.h2es_chrg(:,ii) <= h2es_v(6,ii)*modelVars.h2es_adopt(ii)):'H2 Max Chrg' %%%Max Charge Rate
                            (modelVars.h2es_dchrg(:,ii) <= h2es_v(7,ii)*modelVars.h2es_adopt(ii)):'H2 Max Dchrg'%%%Max Discharge Rate
                            (modelVars.h2es_dchrg(:,ii) <= modelVars.h2es_bin(:,ii)*10000):'H2ES Op State'
                            (modelVars.h2es_chrg(:,ii) <= (1-modelVars.h2es_bin(:,ii))*10000):'H2ES Op State' ];
                        %                 (modelVars.h2es_soc(1) == 0):'H2 Starting SOC'
                    end
                end
            end

            elapsedTime = toc;
        end
        
       
        
        %% H2 Pipeline Injection
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        function [elapsedTime] = Calculate_H2PipelineInjection(obj, modelVars, h2_inject_on)
            tic

            if h2_inject_on

                obj.Constraints = [obj.Constraints
                    (modelVars.h2_inject + modelVars.h2_store <= 1e6*modelVars.h2_inject_adopt):'H2 Injection is Adopted'
                    (modelVars.h2_inject + modelVars.h2_store <= modelVars.h2_inject_size.*(1/e_adjust)):'H2 Injection Capacity'
                    (sum(modelVars.ldg_sfuel) <= sum(modelVars.h2_store)):'Fuel pulled from storage is less than equal what has been stored'];
            end

            elapsedTime = toc;
        end


    end
end

