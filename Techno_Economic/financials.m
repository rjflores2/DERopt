%%%Financial Review

%% Investment costs for DER
pv_equity=pv_cap.*equity;

pv_debt = pv_cap.*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1));

%% Costs
costs.baseline=zeros(size(elec,2),4);
costs.import=costs.baseline;
costs.equity=zeros(size(elec,2),size(pv_v,2));

costs.pv_debt=costs.equity;
costs.pv_om=zeros(size(elec,2),size(pv_v,2));
costs.pv_nem=zeros(size(elec,2),size(pv_v,2));
costs.pv_wholesale = zeros(size(elec,2),size(pv_v,2));
peaks.before=zeros(length(endpts),size(elec,2));
peaks.after=peaks.before;

for i=1:size(elec,2)
    %% Utility Costs
    %%%Rate Index
    index=find(ismember(rate_labels,rate(i)));
    %%%Electricity Costs
    costs.baseline(i,1) = elec(:,i)'*import_price(:,index);
    costs.import(i,1) = import(:,i)'*import_price(:,index);
    
    %%%Demand Charges
    if dc_exist(i) == 1
        for j = 1:length(endpts)
            if j ==1
                %%%nonTOU DC
                costs.baseline(i,2) = costs.baseline(i,2) + max(elec(1:endpts(1),i)) * dc_nontou(index);
                %%%On Peak DC
                costs.baseline(i,3) = costs.baseline(i,3) + max((elec(1:endpts(1),i)).*dc_on_index(1:endpts(1))) * dc_on(index);
                %%%mid Peak DC
                costs.baseline(i,4) = costs.baseline(i,4) + max((elec(1:endpts(1),i)).*dc_mid_index(1:endpts(1))) * dc_mid(index);
                
                peaks.before(i,j) = max(elec(1:endpts(1),i));
                peaks.after(i,j) = max(import(1:endpts(1),i));
                
                
%                 if i == 1
%                     clc
%                     max((import(1:endpts(1),i)).*dc_on_index(1:endpts(1)))
%                     max((import(1:endpts(1),i)).*dc_on_index(1:endpts(1)))
%                 end
                
                 %%%nonTOU DC
                costs.import(i,2) = costs.import(i,2) + max(import(1:endpts(1),i)) * dc_nontou(index);
                %%%On Peak DC
                costs.import(i,3) = costs.import(i,3) + max((import(1:endpts(1),i)).*dc_on_index(1:endpts(1))) * dc_on(index);
                %%%mid Peak DC
                costs.import(i,4) = costs.import(i,4) + max((import(1:endpts(1),i)).*dc_on_index(1:endpts(1))) * dc_mid(index);
            else
                costs.baseline(i,2) = costs.baseline(i,2) + max(elec(endpts(j-1)+1:endpts(j),i)) * dc_nontou(index);
                %%%On Peak DC
                costs.baseline(i,3) = costs.baseline(i,3) + max((elec(endpts(j-1)+1:endpts(j),i)).*dc_on_index(endpts(j-1)+1:endpts(j))) * dc_on(index);
                %%%On Peak DC
                costs.baseline(i,4) = costs.baseline(i,4) + max((elec(endpts(j-1)+1:endpts(j),i)).*dc_mid_index(endpts(j-1)+1:endpts(j))) * dc_mid(index);
                
                 costs.import(i,2) = costs.import(i,2) + max(import(endpts(j-1)+1:endpts(j),i)) * dc_nontou(index);
                %%%On Peak DC
                costs.import(i,3) = costs.import(i,3) + max((import(endpts(j-1)+1:endpts(j),i)).*dc_on_index(endpts(j-1)+1:endpts(j))) * dc_on(index);
                %%%On Peak DC
                costs.import(i,4) = costs.import(i,4) + max((import(endpts(j-1)+1:endpts(j),i)).*dc_mid_index(endpts(j-1)+1:endpts(j))) * dc_mid(index);
                
                peaks.before(i,j) = max(elec(endpts(j-1)+1:endpts(j),i));
                peaks.after(i,j) = max(import(endpts(j-1)+1:endpts(j),i));
%                 if i == 1
%                    max((import(endpts(j-1)+1:endpts(j),i)).*dc_on_index(endpts(j-1)+1:endpts(j)))
%                     max((import(endpts(j-1)+1:endpts(j),i)).*dc_mid_index(endpts(j-1)+1:endpts(j)))
%                 end
                
            end
        end
    end
    
    %% PV Costs
    
    for j=1:size(pv_v,2)
        %%%Invest Cost
        costs.equity(i,1) = costs.equity(i,1) + pv_equity(j) * pv_adopt(1,i,j);
        %%%Recurring debt payment
        costs.debt(i,j) =  pv_debt(j) * pv_adopt(1,i,j)*length(endpts);
        
        %%%O&M
        costs.pv_om(i,j) = sum(pv_elec(:,i,j))*pv_v(3,j);
        %%%NEM
%         costs.pv_nem(i,j) = pv_nem(:,i,j)'*export_price(:,index);
        
        %%%Wholesale
        costs.pv_wholesale(i,j) = sum(pv_wholesale(:,i,j))*ex_wholesale;
        
    end
    
    
    
    
end
%%%Cost of electricity
coe.baseline = sum(costs.baseline,2)'./sum(elec);
coe.import = sum(costs.import,2)'./sum(import);

spb= [sum(costs.baseline,2) ...
     (sum(costs.import,2)...
    + sum(costs.pv_om,2)...
    - sum(costs.pv_nem,2)...
    - sum(costs.pv_wholesale,2)...
    + sum(costs.debt,2))];

spb(:,3) = costs.equity./(spb(:,1)-spb(:,2))
%% CF componenets

sum(costs.baseline)

x'*model.f
% x(1:8780)'*model.f(1:8780)+...   %%%Utility costs
% x(8781:17540)'*model.f(8781:17540)+... %%%PV O&M
% x(17541)'*model.f(17541)+... %%%PV Adopted
% x(17542:26301)'*model.f(17542:26301)+... %%%PV NEM
% x(26302:end)'*model.f(26302:end)