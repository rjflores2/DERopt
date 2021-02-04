%% General Inequalities
%% Demand Charges
if utility_exists == 1
    dc_count=1;
    for ii = 1:size(elec,2) %ii loops thorugh buildings
        
        if dc_exist(ii) == 1 % IF that building has demand charges 
            %%Non TOU Demand Charges
            for i=1:length(endpts) %i counts months 
                if i==1 % for January
                    Constraints=[Constraints
                        (import(1:endpts(1),ii) <= nontou_dc(i,dc_count)):'Non TOU DC January'];
                else % for all other months 
                    Constraints=[Constraints
                        (import(endpts(i-1)+1:endpts(i),ii) <= nontou_dc(i,dc_count)):'Non TOU DC'];
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
                        (import(on_index,ii) <= onpeak_dc(on_dc_count,dc_count)):'TOU DC Onpeak'];
                    
                    %%%Advancing on peak counter
                    on_dc_count = on_dc_count + 1;
                end
                
                %%%Checking if Mid-peak occurs
                if sum(midpeak_index(start:finish)) > 0 %If onpeak demand charge occurs during the current
                    %%%Indicies for current month on-peak
                    mid_index = find(midpeak_index(start:finish)>0) + start - 1;
                    
                    %%%Setting Cosntraints
                    Constraints=[Constraints
                        (import(mid_index,ii) <= midpeak_dc(mid_dc_count,dc_count)):'TOU DC Midpeak'];
                                        
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
if strcmp(class(pv_nem),'sdpvar') || strcmp(class(rees_dchrg_nem),'sdpvar') %%%If NEM related decision variables exist
    for k=1:K
        %%%Current Utility Rate
        index=find(ismember(rate_labels,rate(k)));
        
        Constraints = [Constraints
            (export_price(:,index)'*(rees_dchrg_nem(:,k)+pv_nem(:,k)) <= import_price(:,index)'*import(:,k)):'NEM Credits < Import Cost'];
        
%         if net_import_on == 1
%             %%% Export to be always greater than a percentage of import. Export >= net_import_limit.*import
%             %%% net_import_limit = 1 for NET ZERO.
%             
%             if nem_annual == 1
%                 %%% Calculated annually
%                 Constraints=[Constraints
%                     %(sum(sum(pv_nem)) + sum(sum(pv_wholesale)) + sum(sum(rees_dchrg_nem)) >= net_import_limit.*sum(sum(import))):'ZNE Annual'];
%                     (sum(sum(pv_nem)) + sum(sum(pv_wholesale)) + sum(sum(rees_dchrg_nem)) >= net_import_limit.*sum(sum(import)) + sum(ees_soc(1,:)+ rees_soc(1,:))):'ZNE Annual: Export Revenue <= Import Energy Cost'];
%             end
%         end
    end
end