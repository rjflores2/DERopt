%% General Inequalities
%% Demand Charges

%%%Checking if e_adjust factor exists
if ~exist('e_adjust','var')
    e_adjust = 1;
end

if utility_exists == 1
    dc_count=1;
    for ii = 1:size(elec,2) %ii loops thorugh buildings
        
        if dc_exist(ii) == 1 % IF that building has demand charges 
            %%Non TOU Demand Charges
            for i=1:length(endpts) %i counts months 
                if i==1 % for January
                    Constraints=[Constraints
                        (var_util.import(1:endpts(1),ii).*e_adjust <= var_util.nontou_dc(i,dc_count)):'Non TOU DC January'];
                else % for all other months 
                    Constraints=[Constraints
                        (var_util.import(endpts(i-1)+1:endpts(i),ii).*e_adjust <= var_util.nontou_dc(i,dc_count)):'Non TOU DC'];
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
                        (var_util.import(on_index,ii).*e_adjust <= var_util.onpeak_dc(on_dc_count,dc_count)):'TOU DC Onpeak'];
                    
                    %%%Advancing on peak counter
                    on_dc_count = on_dc_count + 1;
                end
                
                %%%Checking if Mid-peak occurs
                if sum(midpeak_index(start:finish)) > 0 %If onpeak demand charge occurs during the current
                    %%%Indicies for current month on-peak
                    mid_index = find(midpeak_index(start:finish)>0) + start - 1;
                    
                    %%%Setting Cosntraints
                    Constraints=[Constraints
                        (var_util.import(mid_index,ii).*e_adjust <= var_util.midpeak_dc(mid_dc_count,dc_count)):'TOU DC Midpeak'];
                                        
                    %%%Advancing on peak counter
                    mid_dc_count = mid_dc_count + 1;
                end
            end
            
            %% Advancing DC counter
            dc_count = dc_count + 1;
        end
    end
end



%% Net Energy Metering
%%%NEM 2.0 rules - NEM 2.0 applies and the property has on-site solar or
%%%a battery charged by renewable sources
if nem_rate == 2.0 && (lpv_on || lrees_on || strcmp(class(var_pv.pv_nem),'sdpvar') || strcmp(class(var_rees.rees_dchrg_nem),'sdpvar')) %%%If NEM related decision variables exist
    for k=1:K
        %%%Current Utility Rate
        index=find(ismember(rate_labels,rate(k)));
        
        Constraints = [Constraints
            (export_price(:,index)'*(var_rees.rees_dchrg_nem(:,k) + var_pv.pv_nem(:,k) + var_lrees.rees_dchrg_nem(:,k) + var_sofc.sofc_nem(:,k)) <= import_price(:,index)'*var_util.import(:,k)):'NEM Credits < Import Cost'
            (sum(var_rees.rees_dchrg_nem(:,k) + var_pv.pv_nem(:,k) + var_lrees.rees_dchrg_nem(:,k) + var_sofc.sofc_nem(:,k)) <= sum(var_util.import(:,k))):'NEM Energy < Import Energy'];
        
    end
    
elseif nem_rate == 3.0 && (lpv_on || lrees_on || strcmp(class(var_pv.pv_nem),'sdpvar') || strcmp(class(var_rees.rees_dchrg_nem),'sdpvar')) %%%If NEM related decision variables exist
    for k=1:K
        %%%Current Utility Rate
        index=find(ismember(rate_labels,rate(k)));
        
        Constraints = [Constraints
            (export_price(:,index)'*(var_rees.rees_dchrg_nem(:,k) + var_pv.pv_nem(:,k) + var_lrees.rees_dchrg_nem(:,k) + var_sofc.sofc_nem(:,k)) <= import_price(:,index)'*var_util.import(:,k)):'NEM Credits < Import Cost'];
        
    end
end
 
%%
%%%%%%%% TDV ZNE Constraint 

if sofc_on && tdv_on
    % Net Zero Energy
    Constraints = [Constraints
        (sum(var_util.import.*tdv_elec) +...
        sum((var_sofc.sofc_ng).*tdv_gas.*tdv_gas_mod)+...
        sum(var_gwh.gwh_gas.*tdv_gas.*tdv_gas_mod) + ...
        sum(var_gsph.gsph_gas.*tdv_gas.*tdv_gas_mod) <= sum(var_sofc.sofc_nem.*tdv_elec) +...
        sum(var_pv.pv_nem.*tdv_elec) +...
        sum(var_rees.rees_dchrg_nem.*tdv_elec)):'TDV NZE - Energy requirement'];
    %                              tdv_lim + sum(var_pv.pv_nem.*tdv_elec)+sum (var_sofc.sofc_nem.*tdv_elec) ):'NZE - Electricity requirement'];
elseif ~sofc_on && tdv_on
    % Net Zero Energy
    Constraints = [Constraints
        (sum(var_util.import.*tdv_elec) +...
        sum(var_gwh.gwh_gas.*tdv_gas.*tdv_gas_mod) + ...
        sum(var_gsph.gsph_gas.*tdv_gas.*tdv_gas_mod) <= sum(var_pv.pv_nem.*tdv_elec) +...
        sum(var_rees.rees_dchrg_nem.*tdv_elec)):'TDV NZE - Energy requirement'];
    %                              tdv_lim + sum(var_pv.pv_nem.*tdv_elec)+sum (var_sofc.sofc_nem.*tdv_elec) ):'NZE - Electricity requirement'];
    
end



%Constraints = [Constraints
%     (sum(var_util.import) + var_rees.rees_soc(1) + var_ees.ees_soc(1) <= sum(var_pv.pv_nem.*acc_elec)):'NZE - Electricity requirement'];
