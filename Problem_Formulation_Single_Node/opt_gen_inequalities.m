%% General Inequalities
%% Demand Charges

%%%Checking if e_adjust factor exists
if ~exist('e_adjust','var')
    e_adjust = 1;
end

if utility_exists == 1
    
    if dc_exist == 1 % IF that building has demand charges
        %%Non TOU Demand Charges
        for i=1:length(endpts) %i counts months
            if i==1 % for January
                Constraints=[Constraints
                    (var_util.import(1:endpts(1)).*e_adjust <= var_util.nontou_dc(i)):'Non TOU DC January'];
            else % for all other months
                Constraints=[Constraints
                    (var_util.import(endpts(i-1)+1:endpts(i)).*e_adjust <= var_util.nontou_dc(i)):'Non TOU DC'];
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
                Constraints=[Constraints
                    (var_util.import(on_index).*e_adjust <= var_util.onpeak_dc(on_dc_count)):'TOU DC Onpeak'];
                
                %%%Advancing on peak counter
                on_dc_count = on_dc_count + 1;
            end
            
            %%%Checking if Mid-peak occurs
            if sum(midpeak_index(start:finish)) > 0 %If onpeak demand charge occurs during the current
                %%%Indicies for current month on-peak
                mid_index = find(midpeak_index(start:finish)>0) + start - 1;
                
                %%%Setting Cosntraints
                Constraints=[Constraints
                    (var_util.import(mid_index).*e_adjust <= var_util.midpeak_dc(mid_dc_count)):'TOU DC Midpeak'];
                
                %%%Advancing on peak counter
                mid_dc_count = mid_dc_count + 1;
            end
        end
    end
end

%% Net Energy Metering
if export_on
    %%%Current Utility Rate
    index=find(ismember(rate_labels,rate(1)));
    
    Constraints = [Constraints
        (export_price(:,index)'*(sum(var_rees.rees_dchrg_nem,2) + var_pv.pv_nem) <= import_price(:,index)'*var_util.import):'NEM Credits < Import Cost'
        (sum(sum(var_rees.rees_dchrg_nem,2) + var_pv.pv_nem) <= sum(var_util.import)):'NEM Energy < Import Energy'];
end

%% General import / export limits
if exist('fac_prop') && (~isempty(utility_exists) || util_pv_wheel)
    Constraints = [Constraints
        (var_util.import + var_pp.pp_elec_wheel + var_pp.pp_elec_wheel_lts <= var_util.import_state .*fac_prop(1)./e_adjust):'General Import Limits'];
    if gen_export_on || export_on
        Constraints = [Constraints
            (var_util.gen_export <= (1 - var_util.import_state) .*fac_prop(1)./e_adjust):'General Export Limits'];
    end
end

%% Power Plant import/export limits
if util_ees_on && util_pp_import
    Constraints = [Constraints
    (var_pp.pp_elec_import <= var_pp.import_state.*1e6):'Power Plant Import State'
    (var_pp.pp_elec_export + var_pp.pp_elec_wheel + var_pp.pp_elec_wheel_lts <= (1 - var_pp.import_state).*1e6):'Power Plant Export State'];
    
end
%% Gas Turbine Forced Fuel Input Constraint - Hydrogen
if ~isempty(h2_fuel_forced_fraction) && ~isempty(el_v)
    Constraints = [Constraints
        (h2_fuel_forced_fraction.*(sum(var_ldg.ldg_fuel,2) +  sum(var_ldg.ldg_rfuel,2)) <= (1 - h2_fuel_forced_fraction).*(sum(var_ldg.ldg_hfuel,2))):'Forced H2 Fuel Requirement'];   
end

%% Gas Turbine Fuel Input Limit - Hydrogen
if ~isempty(h2_fuel_limit) && ldg_on
    Constraints = [Constraints
        ((1 - h2_fuel_limit).*var_ldg.ldg_hfuel <= h2_fuel_limit.*(var_ldg.ldg_fuel + var_ldg.ldg_rfuel)):'H2 Fuel Limit in GT'];   
%         ((1 - h2_fuel_limit).*var_ldg.ldg_hfuel <= h2_fuel_limit.*(var_ldg.ldg_fuel + var_ldg.ldg_rfuel + var_ldg.ldg_hfuel)):'H2 Fuel Limit in GT'];   
end

%% CO2 limit
if ~isempty(co2_lim)
    Constraints = [Constraints
        ( sum(var_util.import.*co2_import) ... %%%CO2 from imports
        + co2_ng*(sum(sum(var_ldg.ldg_fuel)) + sum(sum(var_ldg.db_fire)) + sum(sum(var_boil.boil_fuel)))... %%%CO2 from NG combustion
        + co2_rng*(sum(sum(var_ldg.ldg_rfuel)) + sum(sum(var_ldg.db_rfire)) + sum(sum(var_boil.boil_rfuel))) ... %%%CO2 from rNG combustion
        <= ...
        co2_lim):'CO2 Limit'];
    
%      Constraints = [Constraints
%         ( sum(var_util.import.*co2_import) ... %%%CO2 from imports
%         + co2_ng*(sum(sum(var_ldg.ldg_fuel)) + sum(sum(var_ldg.db_fire)) + sum(sum(var_boil.boil_fuel)))... %%%CO2 from NG combustion
%         + co2_rng*(sum(sum(var_ldg.ldg_rfuel)) + sum(sum(var_ldg.db_rfire)) + sum(sum(var_boil.boil_rfuel))) ... %%%CO2 from rNG combustion
%         + sum(var_pp.pp_elec_export.*co2_import) ...%%%Imports at a power plant
%         <= ...
%         sum(var_pp.pp_elec_import.*co2_import) ...%%%Exports at a power plant
%         + co2_ng*sum(var_h2_inject.h2_inject) ... %%%H2 Pipeline Injection
%         + co2_lim):'CO2 Limit'];
    
end

%% Renewable biogas limit
if ~isempty(biogas_limit)
    %%%(length(endpts)/12) term prorates available biogas to the simulation
    %%%period
    Constraints = [Constraints
    (sum(var_ldg.ldg_rfuel  + var_boil.boil_rfuel + var_ldg.db_rfire) <= biogas_limit*(length(endpts)/12)):'Renewable biogas limit'];
end
%% Total Energy throughput required
if ~isempty(h2_charging_rec)
    Constraints = [Constraints
        ((length(time)/(24*e_adjust)*h2_charging_rec) <= sum(sum(var_h2es.h2es_chrg))):'Required H2 storage utilization'];
%         (10 <= sum(var_h2es.h2es_adopt)):'Required H2 storage utilization'];
end
