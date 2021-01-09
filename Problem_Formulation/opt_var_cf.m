%% Declaring decision variables and setting up cost function
yalmip('clear')
Constraints=[];

T = length(time);     %t-th time interval from 1...T
K = size(elec,2);     %k-kth building from 
M = length(endpts);   %# of months in the simulation


%% Utility Electricity
if isempty(utility_exists) == 0
    %%%Electrical Import Variables
    import=sdpvar(T,K,'full');
   
    %%%Demand Charge Variables
    %%%Only creating variables for # of months and number of applicable
    %%%rates, as defined with the binary dc_on input

    if sum(dc_exist)>0
        %%%Non TOU DC
        nontou_dc=sdpvar(M,sum(dc_exist),'full');
        
        %%%On Peak/ Mid Peak TOU DC
        onpeak_dc=sdpvar(length(summer_month),sum(dc_exist),'full');
        midpeak_dc=sdpvar(length(summer_month),sum(dc_exist),'full');
    end
    
    %%% Cost of Imports + Demand Charges 
    dc_count=1;
    for i=1:K %%%Going through all buildings
        i
        %%%Find the applicable utility rate
        index=find(ismember(rate_labels,rate(i)));

        %%%Energy rates for the electrical load
        if i == 1
            Objective = import(:,i)'*(day_multi.*import_price(:,index));           
            %Objective = import(:,i)'*import_price(:,index);
        else
            Objective = Objective + ...
            import(:,i)'*(day_multi.*import_price(:,index));        
            %import(:,i)'*import_price(:,index);
        end  
        
        %%%Demand Charges
        if dc_exist(i) == 1
            Objective = Objective + ...
                sum(dc_nontou(index)*nontou_dc(:,dc_count))... %%%non TOU DC
                + sum(dc_on(index)*onpeak_dc(:,dc_count)) ... %%%On Peak DC
                + sum(dc_mid(index)*midpeak_dc(:,dc_count)); %%%Mid Peak DC
            
            %%%Index of DCs
            dc_count=dc_count+1;
        end
    end
end

%% Technologies That Can Be Adopted at Each Building Energy Hub
%% Solar PV
if isempty(pv_v) == 0
    
    %%%PV Generation to meet building demand (kWh)
    pv_elec = sdpvar(T,K,'full'); %%% PV Production sent to the building
    
    %%%Size of installed System (kW)
    pv_adopt= sdpvar(1,K,'full'); %%%PV Size 
    
    if island == 0  %If not islanded,  can export PV for revenue under NEM and wholesale
        
        %%% Variables that exist when grid tied
        pv_nem = sdpvar(T,K,'full'); %%% PV Production exported w/ NEM
        pv_wholesale = sdpvar(T,K,'full'); %%% PV Production exported under NEM rates
        pv_nem_revenue = sdpvar(1,K,'full'); %%%Total NEM Revenue
        pv_w_revenue = sdpvar(1,K,'full'); %%%Total Wholesale Revenue
        
        %%%PV Export - NEM (kWh)
        %%% k index: Building
        for k = 1:K
            k
            index=find(ismember(rate_labels,rate(k)));
            Objective = Objective...
                - (day_multi.*pv_nem(:,k))'*export_price(:,index) ... %%%NEM Revenue csot
                 - ex_wholesale*sum(day_multi.*pv_wholesale(:,k)); %%%Wholesale Revenue cost
            %- pv_nem(:,k)'*export_price(:,index);
            
            pv_nem_revenue(k) = (day_multi.*pv_nem(:,k))'*export_price(:,index);
            pv_w_revenue(k) = ex_wholesale*sum(day_multi.*pv_wholesale(:,k));
        end
        
        %%%PV Export - Wholesale (kWh)
        %%% k index: Building
%         for k = 1:K
%             Objective = Objective...
%                
%             %- ex_wholesale*sum(pv_wholesale(:,k));
%             
%         end
    end
    
    %%%PV Cost
    Objective=Objective ...
        + pv_v(1)*M*sum(pv_adopt)... %%%PV Capital Cost ($/kW installed)
        + pv_v(3)*( sum(sum(repmat(day_multi,1,K).*(pv_elec + pv_nem + pv_wholesale))) ); %%%PV O&M Cost ($/kWh generated)
    %+ pv_v(3)*(sum(sum(pv_elec))+ sum(sum(pv_nem)) + sum(sum(pv_wholesale)) ); %%%PV O&M Cost ($/kWh generated)

%%% Allow for adoption of Renewable paired storage when enabled (REES)
if isempty(ees_v) == 0 && rees_exist == 1

    %%%Adopted REES Size
    rees_adopt= sdpvar(1,K,'full');
    %rees_adopt= semivar(1,K,'full');
    %%%REES Charging
    rees_chrg=sdpvar(T,K,'full');
    %%%REES discharging
    rees_dchrg=sdpvar(T,K,'full');
    %%%REES discharging to grid
    rees_dchrg_nem=sdpvar(T,K,'full');
    %%%REES SOC
    rees_soc=sdpvar(T,K,'full');
    %%%REES Cost Functions
    Objective = Objective...
        + ees_v(1)*M*sum(rees_adopt)...%%%Capital Cost
        + ees_v(2)*sum(sum(repmat(day_multi,1,K).*rees_chrg))... %%%Charging O&M
        + ees_v(3)*(sum(sum(repmat(day_multi,1,K).*(rees_dchrg + rees_dchrg_nem))));%%%Discharging O&M   
        %+ ees_v(3)*sum(sum(repmat(day_multi,1,K).*rees_dchrg));%%%Discharging O&M 
        %+ ees_v(2)*sum(sum(rees_chrg(:,:)))... %%%Charging O&M
        %+ ees_v(3)*sum(sum(rees_dchrg(:,:)));%%%Discharging O&M
 
if island == 0 % If not islanded, AEC can export NEM and wholesale for revenue
    %%%REES NEM Export
    
    rees_revenue = sdpvar(1,K,'full'); 
    rees_revenue_h = sdpvar(T,K,'full');
    for k = 1:K
        %%%Applicable utility rate
        index=find(ismember(rate_labels,rate(k)));
        Objective = Objective...
            - (day_multi.*rees_dchrg_nem(:,k))'*export_price(:,index);        
            %- rees_dchrg_nem(:,k)'*export_price(:,index);
                  
        rees_revenue(k) = (day_multi.*rees_dchrg_nem(:,k))'*export_price(:,index);
        rees_revenue_h(:,k) = rees_dchrg_nem(:,k).*export_price(:,index);
    end
end 
    
else
    rees_adopt=zeros(1,K);
    rees_chrg=zeros(T,K);
    rees_dchrg=zeros(T,K);
    rees_dchrg_nem=zeros(T,K);
    rees_soc=zeros(T,K);    
end        
               
else
    pv_adopt=zeros([1 K]);
    pv_elec=zeros([T K]);
    pv_nem=zeros([T K]);
    pv_wholesale=zeros([T K]);
    rees_adopt=zeros(1,K);
    rees_chrg=zeros(T,K);
    rees_dchrg=zeros(T,K);
    rees_dchrg_nem=zeros(T,K);
    rees_soc=zeros(T,K);   
end        

%% Electrical Energy Storage 
if isempty(ees_v) == 0
    
    %%%Adopted EES Size
    ees_adopt= sdpvar(1,K,'full');
    %ees_adopt = semivar(1,K,'full');
    %%%EES Charging
    ees_chrg=sdpvar(T,K,'full');
    %%%EES discharging
    ees_dchrg=sdpvar(T,K,'full');
    %%%EES SOC
    ees_soc=sdpvar(T,K,'full');

    %%%EES Cost Functions
    Objective = Objective...
        + ees_v(1)*M*sum(ees_adopt)...%%%Capital Cost
        + ees_v(2)*sum(sum(repmat(day_multi,1,K).*ees_chrg))...%%%Charging O&M
        + ees_v(3)*sum(sum(repmat(day_multi,1,K).*ees_dchrg));%%%Discharging O&M
        %+ ees_v(2)*sum(sum(ees_chrg))...%%%Charging O&M
        %+ ees_v(3)*sum(sum(ees_dchrg));%%%Discharging O&M
    
else
    ees_adopt=zeros(1,K);
    ees_soc=zeros(T,K);
    ees_chrg=zeros(T,K);
    ees_dchrg=zeros(T,K);
end

%% Inverter

% Sinv_r = sdpvar(1,K,'full');
% 
%     Objective = Objective + inv_v(1)*sum(Sinv_r); %%%Inverter Capital Cost
    
    