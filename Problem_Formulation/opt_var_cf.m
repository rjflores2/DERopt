%% Declaring decision variables and setting up cost function
yalmip('clear')
Constraints=[];

T = length(time);     %t-th time interval from 1...T
K = size(elec,2);     %k-kth building from 
M = length(endpts);   %# of months in the simulation

% Objective = [];

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
        onpeak_dc=sdpvar(onpeak_count,sum(dc_exist),'full');
        midpeak_dc=sdpvar(midpeak_count,sum(dc_exist),'full');
    end
    
    %%% Cost of Imports + Demand Charges
    dc_count=1;
    
    %%%Allocating space
    temp_cf = zeros(size(elec));
    
    for i=1:K %%%Going through all buildings
        %%%Find the applicable utility rate
        index=find(ismember(rate_labels,rate(i)));
        
        %%%Specifying cost function
        temp_cf(:,i) = day_multi.*import_price(:,index);
    end
    
    %%%Import Energy charges
    Objective = sum(sum(import.*temp_cf));

    %%%Clearing temporary cost function matrix
    clear temp_cf

    for i =1:K
        if dc_exist(i) == 1
            %%%Find the applicable utility rate
            index=find(ismember(rate_labels,rate(i)));
            
            Objective =  Objective ...
                + sum(dc_nontou(index)*nontou_dc(:,dc_count))... %%%non TOU DC
                + sum(dc_on(index)*onpeak_dc(:,dc_count)) ... %%%On Peak DC
                + sum(dc_mid(index)*midpeak_dc(:,dc_count)); %%%Mid Peak DC
            %%% Utility_import * Demand_charge_rate
            
            %%%Index of DCs
            dc_count=dc_count+1;
        end
    end   
    
else
    %%%Electrical Import Variables
    import=zeros(T,K);
    
    %%%Non TOU DC
    nontou_dc=zeros(M,sum(dc_exist));
    
    %%%On Peak/ Mid Peak TOU DC
    onpeak_dc=zeros(onpeak_count,sum(dc_exist));
    midpeak_dc=zeros(midpeak_count,sum(dc_exist));
end


%% Technologies That Can Be Adopted at Each Building Energy Hub
%% Solar PV
if isempty(pv_v) == 0
    
    %%%PV Generation to meet building demand (kWh)
    pv_elec = sdpvar(T,K,'full'); %%% PV Production sent to the building
    
    %%%Size of installed System (kW)
    pv_adopt= sdpvar(1,K,'full'); %%%PV Size
    
    if island == 0 && export_on == 1  %If grid tied, then include NEM and wholesale export
        
        %%% Variables that exist when grid tied
        pv_nem = sdpvar(T,K,'full'); %%% PV Production exported w/ NEM
%         pv_wholesale = sdpvar(T,K,'full'); %%% PV Production exported under NEM rates
        
        %%%PV Export - NEM (kWh)
        temp_cf1 = zeros(size(elec));
        tempc_f2 = zeros(size(elec));
        for k = 1:K
            %%%Utility rates for building k
            index=find(ismember(rate_labels,rate(k)));
            
            %%%Filling in temp cost function arrays 
            temp_cf1(:,k) = -day_multi.*export_price(:,index);
%             temp_cf2(:,k) = -day_multi.*ex_wholesale;
            
        end

        %%%Adding values to the cost function
         Objective = Objective...
             + sum(sum(temp_cf1.*pv_nem)); %%%NEM Revenue Cost
%              + sum(sum(temp_cf2.*pv_wholesale)); %%%Wholesale Revenue
         
         %%%Clearing temporary variables
         clear temp_cf1 temp_cf2
    else
        pv_nem = [];
    end
    
    %%%PV Cost
%     mod_val = 0.7
%     mod_val*pv_cap
%      mod_val*(pv_v(1)*M*cap_mod.pv - cap_scalar.pv)
    Objective=Objective ...
        + sum(M*pv_mthly_debt.*pv_cap_mod'.*pv_adopt)... %%%PV Capital Cost ($/kW installed)
        + pv_v(3)*(sum(sum(repmat(day_multi,1,K).*(pv_elec + pv_nem)))); %%%PV O&M Cost ($/kWh generated)
%         + pv_v(3)*(sum(sum(repmat(day_multi,1,K).*(pv_elec + pv_nem + pv_wholesale))) ); %%%PV O&M Cost ($/kWh generated)

    %%% Allow for adoption of Renewable paired storage when enabled (REES)
    if isempty(ees_v) == 0 && rees_on == 1
        
        %%%Adopted REES Size
        rees_adopt= sdpvar(1,K,'full');
        %rees_adopt= semivar(1,K,'full');
        %%%REES Charging
        rees_chrg=sdpvar(T,K,'full');
        %%%REES discharging
        rees_dchrg=sdpvar(T,K,'full');
        
        %%%REES SOC
        rees_soc=sdpvar(T,K,'full');
        %%%REES Cost Functions        
        Objective = Objective...
            + sum(ees_v(1)*M.*rees_cap_mod'.*rees_adopt) ...%%%Capital Cost
            + ees_v(2)*sum(sum(repmat(day_multi,1,K).*rees_chrg))... %%%Charging O&M
            + ees_v(3)*(sum(sum(repmat(day_multi,1,K).*(rees_dchrg))));%%%Discharging O&M
        
        if island ~= 1 % If not islanded, AEC can export NEM and wholesale for revenue
            %%%REES NEM Export
            %%%REES discharging to grid
            rees_dchrg_nem=sdpvar(T,K,'full');
            
            %%%Creating temp variables            
            temp_cf = zeros(size(elec));
            
            for k = 1:K
                %%%Applicable utility rate
                index=find(ismember(rate_labels,rate(k)));
                
                temp_cf(:,k) = day_multi.*(ees_v(3) - export_price(:,index));
               
            end
            %%% Setting objective function
            Objective = Objective...
                + sum(sum(temp_cf.*rees_dchrg_nem));
            
        else
            rees_dchrg_nem=zeros(T,K);
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
toc
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
        + sum(ees_v(1)*M.*ees_cap_mod'.*ees_adopt) ...%%%Capital Cost
        + ees_v(2)*sum(sum(repmat(day_multi,1,K).*ees_chrg)) ...%%%Charging O&M
        + ees_v(3)*sum(sum(repmat(day_multi,1,K).*ees_dchrg));%%%Discharging O&M
    
    %%%SGIP rates
    if sgip_on
        %%%Residential Credits
        sgip_ees_npbi = sdpvar(1,sum((res_units>0).*(~low_income>0)),'full');
        %%%Residential Equity Credits
        sgip_ees_npbi_equity = sdpvar(1,sum(low_income>0),'full');
        
        Objective = Objective ...
            - sum(sgip(3)*M*sgip_ees_npbi) ...
            - sum(sgip(4)*M*sgip_ees_npbi_equity);
        
        if sum(sgip_pbi)>0
            %%% Performance based incentives
            sgip_ees_pbi = sdpvar(3,sum(sgip_pbi),'full');
            
            Objective = Objective ...
                - sum(sgip(2)*M*sgip_ees_pbi(1,:)) ...
                - sum(sgip(2)*0.5*M*sgip_ees_pbi(2,:)) ...
                - sum(sgip(2)*0.25*M*sgip_ees_pbi(3,:));
        else
            sgip_ees_pbi = zeros(3,1);
        end
    else
        sgip_ees_pbi = zeros(3,1);
        sgip_ees_npbi = 0;
        sgip_ees_npbi_equity = 0;
    end
    
else
    ees_adopt=zeros(1,K);
    ees_soc=zeros(T,K);
    ees_chrg=zeros(T,K);
    ees_dchrg=zeros(T,K);
end
toc

%% Legacy Technologies
%% Generic DG

%% Legacy PV
%%%Only need to add variables if new PV is not considered
if isempty(pv_legacy) == 0 && isempty(pv_v) == 1
    
    if island == 0 && export_on == 1 %If grid tied, then include NEM and wholesale export
        %%% Variables that exist when grid tied
        pv_nem = sdpvar(T,K,'full'); %%% PV Production exported w/ NEM
        for k = 1:K
            %%%Utility rates for building k
            index=find(ismember(rate_labels,rate(k)));
            
            %%%Adding values to the cost function
            Objective = Objective...
                + sum(sum(-day_multi.*export_price(:,index).*pv_nem)); %%%NEM Revenue Cost
        end
    else
        pv_nem = [];
    end
    
    %%%PV Generation to meet building demand (kWh)
    pv_elec = sdpvar(T,K,'full'); %%% PV Production sent to the building
    
    %%%Operating Costs
    Objective=Objective ...
        + pv_v(3)*(sum(sum(repmat(day_multi,1,K).*(pv_elec + pv_nem))));
    
elseif isempty(pv_legacy) == 1
    %%%If Legacy PV does not exist, then make the existing pv value zero
    pv_legacy = zeros(2,K);
end

%% Legacy DG
if ~isempty(dg_legacy)
    %%%DG Electrical Output
    ldg_elec = sdpvar(T,K,'full');
    %%%DG Fuel Input
    ldg_fuel = sdpvar(T,K,'full');
    %%%DG On/Off State - Number of variables is equal to:
    %%% (Time Instances) / On/Off length
%     (dg_legacy(end,i)/t_step)
%     ldg_off=binvar(ceil(length(time)/(dg_legacy(end,i)/t_step)),K,'full');
    
    for ii = 1:K
        Objective=Objective ...
            + sum(ldg_elec(:,ii))*dg_legacy(1,ii) ...
            + sum(ldg_fuel(:,ii))*ng_cost;
    end
else
    ldg_elec = [];
    ldg_fuel = [];
    ldg_off = [];
    
end
