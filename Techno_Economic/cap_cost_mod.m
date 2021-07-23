%%%Calculating how capital costs are handled at each building/site
%% Financing CRAP
interest=0.08; %%%Interest rates on any loans
interest=nthroot(interest+1,12)-1; %Converting from annual to monthly rate for compounding interest
period=10;%%%Length of any loans (years)
equity=0.2; %%%Percent of investment made by investors
required_return=.12; %%%Required return on equity investment
required_return=nthroot(required_return+1,12)-1; % Converting from annual to monthly rate for compounding required return
equity_return=10;% Length at which equity + required return will be paid off (Years)
discount_rate = 0.08;

%%%Tax Rates
tax_rates = [0.2 0.3]; %%%Residential and commercial rates

%% Debt Payments for full cost system
%%%Solar PV
if ~isempty(pv_v)
    for ii=1:size(pv_v,2)
        pv_mthly_debt(ii,1)=pv_v(1,ii)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));
    end
end

%%%EES
if ~isempty(ees_v)
    for ii=1:size(ees_v,2)
        ees_mthly_debt(ii,1)=ees_v(1,ii)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));
    end
    if ~isempty(pv_v) && rees_on == 1
        for ii=1:size(ees_v,2)
            rees_mthly_debt(ii,1)=ees_v(1,ii)*((1-equity)*(interest*(1+interest)^(period*12))...
                /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
                req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
                /((1+required_return)^(period*12)-1));
        end
    end
end

%%%Generic electrolyzer
if ~isempty(el_v)
    for ii=1:size(el_v,2)
        el_mthly_debt(ii,1)=el_v(1,ii)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));
    end
end

%%%Generic Hydrogen energy storage
if ~isempty(h2es_v)
    for ii=1:size(h2es_v,2)
        h2es_mthly_debt(ii,1)=h2es_v(1,ii)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));
    end
end

%% Calculating cost scalars for various technologies
%% Solar PV
if ~isempty(pv_v)
    pv_cap_mod = [];
    for i = 1:size(elec,2)
        for ii = 1:size(pv_v,2)
            %%%Applicable tax rate
            if strcmp(rate{i},'R1')
                tr = tax_rates(1);
            else
                tr = tax_rates(2);
            end
            
            %%% Solar PV Examination
            %%%Maximum PV estimated by either reaching net zero electrical energy
            %%%or installing maximum capacity
            pv_scale_factor = min([sum(elec(:,i))./(0.2*8760) maxpv(i)]);
            if pv_scale_factor > 1000
                pv_scale_factor = 1000;
            end
            
%             pv_scale_factor = pv_scale_factor.*ones(1,size(pv_v,2));
            
            %%%Scaling Factor
            %%%If is low income
            if low_income(i) ~= 1
%                 for ii = 1:length(pv_scale_factor)
                    %%%Decrease in cost due to scale
                    pv_scale_factor = pv_scale_factor*pv_fin(1,ii);
                    
                    %%%Adjsuted PV Costs
                    debt =12.*ones(10,1).*(pv_v(1,ii) + pv_scale_factor)*((1-equity)*(interest*(1+interest)^(period*12))...
                        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
                        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
                        /((1+required_return)^(period*12)-1));
                    
                    pv_cap_mod(i,ii) = cap_cost_scaling(tr,pv_v(:,ii),pv_fin(:,ii),pv_scale_factor,debt,discount_rate);
                    
                    
%                 end
                %%%If is low income
            else
                pv_cap_mod(i,ii) = 1 - somah/pv_v(1,ii);
            end
            
        end
    end
end

%% EES
if ~isempty(ees_v)
    ees_cap_mod = [];
    for i = 1:size(elec,2)
        for ii = 1:size(ees_v,2)
            %%%Applicable tax rate
            if strcmp(rate{i},'R1')
                tr = tax_rates(1);
            else
                tr = tax_rates(2);
            end
            
            %%% Solar PV Examination
            %%%Maximum PV estimated by either reaching net zero electrical energy
            %%%or installing maximum capacity
            pv_scale_factor = min([sum(elec(:,i))./(0.2*8760) maxpv(i)]);
            if pv_scale_factor > 1000
                pv_scale_factor = 1000;
            end
            
            ees_scale_factor = pv_scale_factor*2.5; %%%Assume 2.5 kWh storage per kW of PV
            if ees_scale_factor > 2000
                ees_scale_factor = 2000;
            end
            ees_scale_factor_rec(i,1) = ees_scale_factor;
            
            
            %%%Scaling Factor
            %%%If is low income
            if ~low_income(i)
                
                %%%Decrease in cost due to scale
                ees_scale_factor = ees_scale_factor*ees_fin(1,ii);
                
                %%%Adjsuted PV Costs
                debt=12.*ones(10,1).*(ees_v(1,ii) + ees_scale_factor)*((1-equity)*(interest*(1+interest)^(period*12))...
                    /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
                    req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
                    /((1+required_return)^(period*12)-1));
                
                ees_cap_mod(i,ii) = cap_cost_scaling(tr,ees_v(:,ii),ees_fin(:,ii),ees_scale_factor,debt,discount_rate);
                
                if ~isempty(pv_v) && rees_on == 1
                    rees_cap_mod(i,ii) = cap_cost_scaling(tr,ees_v(:,ii),rees_fin(:,ii),ees_scale_factor,debt,discount_rate);
                end
                
                %%%If is low income
            else
                
            end
        end
    end
end
%% Electrolyzer
if ~isempty(el_v)
    el_cap_mod = [];
    for i = 1:size(elec,2)
        %%%Applicable tax rate
        if strcmp(rate{i},'R1')
            tr = tax_rates(1);
        else
            tr = tax_rates(2);
        end
        
        %%%Electrolyzer examination
        %%%Generating a h2 fuel fraction when this does not exist
        if ~isempty(h2_fuel_forced_fraction)
            el_scale_factor = (sum(elec)./0.33*h2_fuel_forced_fraction)/length(elec)*e_adjust;
        else
            el_scale_factor = (sum(elec)./0.33*0.1)/length(elec)*e_adjust;
        end
        
        if el_scale_factor >= 28000
            el_scale_factor = 2800
        end
        %%% Scaling Factor
        if ~low_income(i)
            %%%Decrease in cost due to scale
            el_scale_factor = el_scale_factor*el_fin(1,ii);
            
            %%%Adjsuted PV Costs
            debt =12.*ones(10,1).*(el_v(1,ii) + el_scale_factor)*((1-equity)*(interest*(1+interest)^(period*12))...
                /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
                req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
                /((1+required_return)^(period*12)-1));
            
            
                    el_cap_mod(i,ii) = cap_cost_scaling(tr,el_v(:,ii),el_fin(:,ii),el_scale_factor,debt,discount_rate);
        else
         end
        
    end
end