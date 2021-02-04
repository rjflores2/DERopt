%%%NEM Constraints - Limits NEM imports by quantity and credits for
%%%imported electricity
if strcmp(class(pv_nem),'sdpvar') || strcmp(class(rees_dchrg_nem),'sdpvar')
    for k=1:K
        %%%Current Utility Rate
        index=find(ismember(rate_labels,rate(k)));
        
        Constraints = [Constraints
            (export_price(:,index)'*(rees_dchrg_nem(:,k)+pv_nem(:,k)) <= import_price(:,index)'*import(:,k)):'NEM Credits < Import Cost'];
        
        if net_import_on == 1
        %%% Export to be always greater than a percentage of import. Export >= net_import_limit.*import
        %%% net_import_limit = 1 for NET ZERO.

            if nem_annual == 1 
               %%% Calculated annually  
                Constraints=[Constraints
                %(sum(sum(pv_nem)) + sum(sum(pv_wholesale)) + sum(sum(rees_dchrg_nem)) >= net_import_limit.*sum(sum(import))):'ZNE Annual'];  
                (sum(sum(pv_nem)) + sum(sum(pv_wholesale)) + sum(sum(rees_dchrg_nem)) >= net_import_limit.*sum(sum(import)) + sum(ees_soc(1,:)+ rees_soc(1,:))):'ZNE Annual: Import + SOC <= Export'];
             end
            
            if nem_montly == 1 &&  nem_annual == 0      
                %%%Montly NEM export to import for each building k
                %%%Renewable fraction = 1 -> 100% load met with renewable
                for j = 1:length(endpts) %for each month
                    if j == 1 %Jan
                        st=1;
                        fn=endpts(1);
                    elseif j == length(endpts) %Dec
                        st=endpts(j-1)+1;
                        fn=size(elec,1);
                    else
                        st=endpts(j-1)+1;
                        fn=endpts(j);
                    end

                    Constraints = [Constraints
                        (sum(pv_nem(st:fn,k)+ pv_wholesale(st:fn,k))+ rees_dchrg_nem(st:fn,k) >= net_import_limit.*sum(import(st:fn,k))):'ZNE Monthly'];
                end
            end
        end
        
        
    end
end

%% Grid import Limits (kWh)
if grid_import_on == 1 
    Constraints=[Constraints
        (sum(sum(import)) <= import_limit.*sum(sum(elec))):'Grid import limits'];
end

% for i=1:size(elec,2)
%     Constraints=[Constraints
%         import(:,i) <= 2.*elec(:,i)];
% end

%% Island  (open the breaker!) 
if island ==1
   Constraints = [Constraints 
       (sum(import,2) == sum(pv_nem,2) + sum(pv_wholesale,2) + sum(rees_dchrg_nem,2)):'Island'];
   
end