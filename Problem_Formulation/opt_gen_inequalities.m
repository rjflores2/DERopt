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
                        %import(startofmonth,endofmonth) <= nontou_dc(month,every_bldg_dc_exists)
                        (import(endpts(i-1)+1:endpts(i),ii) <= nontou_dc(i,dc_count)):'Non TOU DC'];
                end
            end
                        
            %% TOU Demand Charges
            for i=1:length(summer_month) % i loops through every SUMMER month
                %%%Finding start/finish of each summer month
                if summer_month(i)==1
                    start=1;
                    finish=endpts(summer_month(i));
                else
                    start=endpts(summer_month(i)-1)+1;
                    finish=endpts(summer_month(i));
                end
                
                %%%finding applicable indicies
                %dc_on_index (864x1) flags the intervals in the day that demand charges apply 
                on_index = find(dc_on_index > 0); %(48x1)%returns column array with all days # in the year where dc_on = 1 
                on_index = on_index(find(on_index >= start & on_index < finish)); %returns column array with the day# where dc_on = 1 in the summer month
                
                mid_index = find(dc_mid_index > 0); %(72x1)%returns column array with all days # in the year where dc_mid = 1 
                mid_index = mid_index(find(mid_index >= start & mid_index < finish)); %returns column array with the day# where dc_mid = 1 in the summer month
                
                Constraints=[Constraints
                    % For each building (ii), the import for the days on summer that incur dc needs to be <= onpeak_dc [summer_months,sum(dc_exist)] variable 
                    (import(on_index,ii) <= onpeak_dc(i,dc_count)):'TOU DC Onpeak'
                    (import(mid_index,ii) <= midpeak_dc(i,dc_count)):'TOU DC Midpeak'];
                    %import(on_index,ii) <= onpeak_dc(i,ii)
                    %import(mid_index,ii) <= midpeak_dc(i,ii)];
            end
            
            %%%Moving to next DC variable set
            dc_count = dc_count+1;
        end
    end
end