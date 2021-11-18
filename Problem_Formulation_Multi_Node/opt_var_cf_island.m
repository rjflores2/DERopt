%% Declaring decision variables and setting up cost function
yalmip('clear')
clear var_util var_pv var_ees var_rees var_sgip
Constraints=[];

T = length(time);     %t-th time interval from 1...T
K = size(elec,2);     %k-kth building from 
M = length(endpts);   %# of months in the simulation

%% Load Met
var_util.load_met = sdpvar(T,K,'full');
Objective = -sum(sum(var_util.load_met));


%% Technologies That Can Be Adopted at Each Building Energy Hub
%% Solar PV
if isempty(pv_v) == 0
    
    %%%PV Generation to meet building demand (kWh)
    var_pv.pv_elec = sdpvar(T,K,'full'); %%% PV Production sent to the building
    
    %%%Size of installed System (kW)
    var_pv.pv_adopt= sdpvar(1,K,'full'); %%%PV Size
    
    if island == 0 && export_on == 1  %If grid tied, then include NEM and wholesale export
        
       
        %%% Variables that exist when grid tied
        var_pv.pv_nem = sdpvar(T,K,'full'); %%% PV Production exported w/ NEM
        %         var_pv.pv_wholesale = sdpvar(T,K,'full'); %%% PV Production exported under NEM rates
        
        %%%PV Export - NEM (kWh)
        temp_cf1 = zeros(size(elec));
        tempc_f2 = zeros(size(elec));
        for k = 1:K
            %%%Utility rates for building k
            index=find(ismember(rate_labels,rate(k)));
             %%%Specify ESA eligible tenant fraction
        esa_frac = sum(apartment_types(k,1:2))/sum(apartment_types(k,:));
        
        if ~esa_on
            esa_frac = 0;
        end
            %%%Filling in temp cost function arrays
            temp_cf1(:,k) = -day_multi.*export_price(:,index).*(1-care_energy_rebate*esa_frac);
            temp_cf1(:,k) = -day_multi.*export_price(:,index);
            %             temp_cf2(:,k) = -day_multi.*ex_wholesale;
            
        end
        
        %%%Adding values to the cost function
        Objective = Objective...
            + sum(sum(temp_cf1.*var_pv.pv_nem)); %%%NEM Revenue Cost
        %              + sum(sum(temp_cf2.*pv_wholesale)); %%%Wholesale Revenue
        
        %%%Clearing temporary variables
        clear temp_cf1 temp_cf2
    else
        pv_nem = [];
    end
    
    %%%PV Cost
    Objective=Objective ...
        + sum(M*pv_mthly_debt.*pv_cap_mod'.*var_pv.pv_adopt)... %%%PV Capital Cost ($/kW installed)
        + pv_v(3)*(sum(sum(repmat(day_multi,1,K).*(var_pv.pv_elec + var_pv.pv_nem)))); %%%PV O&M Cost ($/kWh generated)
%         + pv_v(3)*(sum(sum(repmat(day_multi,1,K).*(pv_elec + pv_nem + pv_wholesale))) ); %%%PV O&M Cost ($/kWh generated)

    %%% Allow for adoption of Renewable paired storage when enabled (REES)
    if isempty(ees_v) == 0 && rees_on == 1
        
        %%%Adopted REES Size
        var_rees.rees_adopt= sdpvar(1,K,'full');
        %rees_adopt= semivar(1,K,'full');
        %%%REES Charging
        var_rees.rees_chrg=sdpvar(T,K,'full');
        %%%REES discharging
        var_rees.rees_dchrg=sdpvar(T,K,'full');
        
        %%%REES SOC
        var_rees.rees_soc=sdpvar(T,K,'full');
        %%%REES Cost Functions        
        Objective = Objective...
            + sum(rees_mthly_debt*M.*rees_cap_mod'.*var_rees.rees_adopt) ...%%%Capital Cost
            + ees_v(2)*sum(sum(repmat(day_multi,1,K).*var_rees.rees_chrg))... %%%Charging O&M
            + ees_v(3)*(sum(sum(repmat(day_multi,1,K).*(var_rees.rees_dchrg))));%%%Discharging O&M
        
        if island ~= 1 % If not islanded, AEC can export NEM and wholesale for revenue
            %%%REES NEM Export
            %%%REES discharging to grid
            var_rees.rees_dchrg_nem=sdpvar(T,K,'full');
            
            %%%Creating temp variables            
            temp_cf = zeros(size(elec));
            
            for k = 1:K
                %%%Applicable utility rate
                index=find(ismember(rate_labels,rate(k)));
                
                %%%Specify ESA eligible tenant fraction
                esa_frac = sum(apartment_types(i,1:2))/sum(apartment_types(i,:));
         %%%Specify ESA eligible tenant fraction
        esa_frac = sum(apartment_types(i,1:2))/sum(apartment_types(i,:));
        
        if ~esa_on
            esa_frac = 0;
        end
                
                temp_cf(:,k) = day_multi.*(ees_v(3) - export_price(:,index).*(1-care_energy_rebate*esa_frac));
                temp_cf(:,k) = day_multi.*(ees_v(3) - export_price(:,index));
               
            end
            %%% Setting objective function
            Objective = Objective...
                + sum(sum(temp_cf.*var_rees.rees_dchrg_nem));
            
        else
             var_rees.rees_dchrg_nem=zeros(T,K);
        end
    else
        var_rees.rees_adopt=zeros(1,K);
        var_rees.rees_chrg=zeros(T,K);
        var_rees.rees_dchrg=zeros(T,K);
        var_rees.rees_dchrg_nem=zeros(T,K);
        var_rees.rees_soc=zeros(T,K);
    end
    
else
    var_pv.pv_adopt=zeros([1 K]);
    var_pv.pv_elec=zeros([T K]);
    var_pv.pv_nem=zeros([T K]);
    var_pv.pv_wholesale=zeros([T K]);
    var_rees.rees_adopt=zeros(1,K);
    var_rees.rees_chrg=zeros(T,K);
    var_rees.rees_dchrg=zeros(T,K);
    var_rees.rees_dchrg_nem=zeros(T,K);
    var_rees.rees_soc=zeros(T,K);
end
toc
%% Electrical Energy Storage
if isempty(ees_v) == 0
    
    %%%Adopted EES Size
    var_ees.ees_adopt= sdpvar(1,K,'full');
    %ees_adopt = semivar(1,K,'full');
    %%%EES Charging
    var_ees.ees_chrg=sdpvar(T,K,'full');
    %%%EES discharging
    var_ees.ees_dchrg=sdpvar(T,K,'full');
    %%%EES SOC
    var_ees.ees_soc=sdpvar(T,K,'full');
    
    %%%EES Cost Functions
    Objective = Objective...
        + sum(ees_mthly_debt*M.*ees_cap_mod'.* var_ees.ees_adopt) ...%%%Capital Cost
        + ees_v(2)*sum(sum(repmat(day_multi,1,K).* var_ees.ees_chrg)) ...%%%Charging O&M
        + ees_v(3)*sum(sum(repmat(day_multi,1,K).* var_ees.ees_dchrg));%%%Discharging O&M
    
    %%%SGIP rates
    if sgip_on
        %%%Residential Credits
        var_sgip.sgip_ees_npbi = sdpvar(1,sum((res_units>0).*(~low_income>0)),'full');
        %%%Residential Equity Credits
        var_sgip.sgip_ees_npbi_equity = sdpvar(1,sum(low_income>0),'full');
        
        Objective = Objective ...
            - sum(sgip_mthly_benefit(2)*M*var_sgip.sgip_ees_npbi) ...
            - sum(sgip_mthly_benefit(3)*M*var_sgip.sgip_ees_npbi_equity);
        
        if sum(sgip_pbi)>0
            %%% Performance based incentives
            var_sgip.sgip_ees_pbi = sdpvar(3,sum(sgip_pbi),'full');
            
            Objective = Objective ...
                - sum(sgip_mthly_benefit(1)*M*var_sgip.sgip_ees_pbi(1,:)) ...
                - sum(sgip_mthly_benefit(1)*0.5*M*var_sgip.sgip_ees_pbi(2,:)) ...
                - sum(sgip_mthly_benefit(1)*0.25*M*var_sgip.sgip_ees_pbi(3,:));
        else
            var_sgip.sgip_ees_pbi = zeros(3,1);
        end
    else
        var_sgip.sgip_ees_pbi = zeros(3,1);
        var_sgip.sgip_ees_npbi = 0;
        var_sgip.sgip_ees_npbi_equity = 0;
    end
    
else
    var_ees.ees_adopt=zeros(1,K);
    var_ees.ees_soc=zeros(T,K);
    var_ees.ees_chrg=zeros(T,K);
    var_ees.ees_dchrg=zeros(T,K);
    var_sgip.sgip_ees_pbi = zeros(3,1);
    var_sgip.sgip_ees_npbi = 0;
    var_sgip.sgip_ees_npbi_equity = 0;
end
toc

%% Legacy Technologies
%% Generic DG
%% Legacy PV
%%%Only need to add variables if new PV is not considered
if isempty(pv_legacy) == 0 && isempty(pv_v) == 1 
    %%%PV Generation to meet building demand (kWh)
    var_pv.pv_elec = sdpvar(T,K,'full'); %%% PV Production sent to the building
    var_pv.pv_nem = zeros(T,K);
end

%% Legacy EES
if lees_on
    
    %ees_adopt = semivar(1,K,'full');
    %%%EES Charging
    var_lees.ees_chrg = sdpvar(T,K,'full');
    %%%EES discharging
    var_lees.ees_dchrg = sdpvar(T,K,'full');
    %%%EES SOC
    var_lees.ees_soc = sdpvar(T,K,'full');
    
else
    
    var_lees.ees_soc=zeros(T,K);
    var_lees.ees_chrg=zeros(T,K);
    var_lees.ees_dchrg=zeros(T,K);
end

%% Legacy REES
if lrees_on
    
    %ees_adopt = semivar(1,K,'full');
    %%%EES Charging
    var_lrees.rees_chrg = sdpvar(T,K,'full');
    %%%EES discharging
    var_lrees.rees_dchrg = sdpvar(T,K,'full');
    %%%EES SOC
    var_lrees.rees_soc = sdpvar(T,K,'full');
    var_lrees.rees_dchrg_nem = zeros(T,K);
    
else
    
    var_lrees.rees_soc=zeros(T,K);
    var_lrees.rees_chrg=zeros(T,K);
    var_lrees.rees_dchrg=zeros(T,K);
    var_lrees.rees_dchrg_nem=zeros(T,K);
end

%% Electrical Infrastructure Constraints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% LDN Transformers %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if xfmr_on
    %%%Real Power
    var_xfmr.Pinj = sdpvar(T,length(t_rating),'full'); %kW
    %%%Reactive Power
    %  var_xfmr.Qinj = sdpvar(T,length(t_map),'full'); %kVAR
else
     var_xfmr.Pinj = 0
end

