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

%%%Generator with continuous capacity after binary adoption
if ~isempty(dgb_v)
    for ii=1:size(dgb_v,2)
        dgb_mthly_fixed_debt(ii,1)=dgb_v(1,ii)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));
        dgb_mthly_var_debt(ii,1)=dgb_v(2,ii)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));
    end
end

%%%Generator with continuous capacity 
if ~isempty(dgc_v)
    for ii=1:size(dgc_v,2)
        dgc_mthly_debt(ii,1)=dgc_v(1,ii)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));        
    end
end

%%%Linear DG Model 
if dgl_on
    for ii=1:size(dgl_v,2)
        dgl_mthly_debt(ii,1)=dgl_v(1,ii)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));        
    end
end

%%%Linear DG Model 
if h2_storage_on
    for ii=1:size(dgl_v,2)
        h2_storage_mthly_debt(ii,1)=h2_storage_v(1,ii)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));        
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

%%%Renewable Generic Electrolyzer
if exist('rel_v') && ~isempty(rel_v)
    for ii=1:size(rel_v,2)
        rel_mthly_debt(ii,1)=rel_v(1,ii)*((1-equity)*(interest*(1+interest)^(period*12))...
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


%%%Hydrogen fueling station
if exist('hrs_on') && ~isempty(hrs_on) && hrs_on
    hrs_mthly_debt = hrs_v(1)*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
        /((1+required_return)^(period*12)-1));
end

%%%Utility Scale Solar
if exist('utilpv_v') && ~isempty(utilpv_v)
    for ii=1:size(utilpv_v,2)
        utilpv_mthly_debt(ii,1)=utilpv_v(1,ii)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));
    end
end

%%%Utility Scale wind
if exist('util_wind_v') && ~isempty(util_wind_v)
    for ii=1:size(util_wind_v,2)
        util_wind_mthly_debt(ii,1)=util_wind_v(1,ii)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));
    end
end

%%%Utility Battery Storage
if  exist('util_ees_v') && ~isempty(util_ees_v)
    for ii=1:size(util_ees_v,2)
        util_ees_mthly_debt(ii,1)=util_ees_v(1,ii)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));
    end
end

%%%Generic electrolyzer
if exist('util_el_on') && ~isempty(util_el_on)
    for ii=1:size(util_el_on,2)
        util_el_mthly_debt(ii,1)=util_el_on(1,ii)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));
    end
end
%%%H2 Pipeline Injeciton
if exist('h2_inject_v','var') && ~isempty(h2_inject_v)
    for ii = 1:size(h2_inject_v,2)
        h2_inject_mthly_debt(ii) = h2_inject_v(ii)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));
    end
end

%%%H2 Pipeline Injeciton
if exist('util_h2_inject_v','var') && ~isempty(util_h2_inject_v)
    for ii = 1:size(util_h2_inject_v)
        util_h2_inject_mthly_debt(ii) = util_h2_inject_v(ii)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1))
    end
end

%% Calculating cost scalars for various technologies
%% Solar PV
pv_cap_mod = [];
if ~isempty(pv_v)
    pv_cap_mod = [];
    for i = 1:size(elec,2)
        for ii = 1:size(pv_v,2)
            %%%Applicable tax rate
            if exist('rate')
                if strcmp(rate{i},'R1')
                    tr = tax_rates(1);
                else
                    tr = tax_rates(2);
                end
            else
                tr = max(tax_rates)
            end
            %%% Solar PV Examination
            %%%Maximum PV estimated by either reaching net zero electrical energy
            %%%or installing maximum capacity
            if ~isempty(maxpv)
%               pv_scale_factor = min([sum(elec(:,i)).*(12/length(endpts))./(0.2*8760) maxpv(i)*0.2]);
%                 pv_scale_factor = min([sum(elec(:,i)).*(12/length(endpts))./(0.2*size(elec,1)) maxpv(i)*0.2]);
                pv_scale_factor = min([sum(elec(:,i))./(0.2*size(elec,1)) maxpv(i)*0.2]);
            else
                pv_scale_factor = min([sum(elec(:,i))./(0.2*size(elec,1))]);
            end
            if pv_scale_factor > 1000
                pv_scale_factor = 1000;
            end
            
%             pv_scale_factor = pv_scale_factor.*ones(1,size(pv_v,2));
            
            %%%Scaling Factor
            %%%If is low income
%             if exist('low_income') && low_income(i) ~= 1
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
%             else
%                 pv_cap_mod(i,ii) = 1 - somah/pv_v(1,ii);
%                 
%                 %%if SOMAH completely offsets capital costs
%                 if pv_cap_mod(i,ii) < 0
%                     pv_cap_mod(i,ii) = 0;
%                 end
%             end
            
        end
    end
end

%% Calculating cost scalars for various technologies

%% EES
rees_cap_mod = [];
ees_cap_mod = [];
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
            if ~isempty(maxpv)
                pv_scale_factor = min([sum(elec(:,i))./(0.2*8760) maxpv(i)]);
            else
                pv_scale_factor = min([sum(elec(:,i))./(0.2*8760)]);
            end
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
            
        end
    end
end
%% DG - Continuous after binary adoption
dgb_cap_mod = [];
if ~isempty(dgb_v)
    for i = 1:size(elec,2)
        for ii = 1:size(dgb_v,2)
            %%%Applicable tax rate
            if strcmp(rate{i},'R1')
                tr = tax_rates(1);
            else
                tr = tax_rates(2);
            end
            
            %%% Continuous PV Examination
            dgb_scale_factor = mean(elec(:,i));
            
            %%% Apply scaling factor only if we could have a larger fuel cell system
            if dgb_scale_factor > 20
                dgb_scale_factor = dgb_scale_factor*dgb_fin(1,ii);
            else
                dgb_scale_factor = 0;
            end
            
            
            
            %%%Adjsuted PV Costs
            debt=12.*ones(10,1).*(dgb_v(1,ii) + dgb_scale_factor)*((1-equity)*(interest*(1+interest)^(period*12))...
                /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
                req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
                /((1+required_return)^(period*12)-1));
            
            dgb_cap_mod(i,ii) = cap_cost_scaling(tr,dgb_v(:,ii),dgb_fin(:,ii),dgb_scale_factor,debt,discount_rate);
            
            
        end
    end
end
%% DG - Continuous
dgc_cap_mod = [];
if ~isempty(dgc_v)
    for i = 1:size(elec,2)
        for ii = 1:size(dgc_v,2)
            %%%Applicable tax rate
            if strcmp(rate{i},'R1')
                tr = tax_rates(1);
            else
                tr = tax_rates(2);
            end
            
            %%% Continuous PV Examination
            dgc_scale_factor = mean(elec(:,i));
            
            %%% Apply scaling factor only if we could have a larger fuel cell system
            if dgc_scale_factor > 20
                dgc_scale_factor = dgc_scale_factor*dgc_fin(1,ii);
            else
                dgc_scale_factor = 0;
            end
            
            
            
            %%%Adjsuted PV Costs
            debt=12.*ones(10,1).*(dgc_v(1,ii) + dgc_scale_factor)*((1-equity)*(interest*(1+interest)^(period*12))...
                /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
                req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
                /((1+required_return)^(period*12)-1));
            
            dgc_cap_mod(i,ii) = cap_cost_scaling(tr,dgc_v(:,ii),dgc_fin(:,ii),dgc_scale_factor,debt,discount_rate);
            
            
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
            el_scale_factor = 28000
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
%% Renewable Electrolyzer
if ~isempty(rel_v)
    rel_cap_mod = [];
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
            rel_scale_factor = (sum(elec)./0.33*h2_fuel_forced_fraction)/length(elec)*e_adjust;
        else
            rel_scale_factor = (sum(elec)./0.33*0.1)/length(elec)*e_adjust;
        end
        
        if rel_scale_factor >= 28000
            rel_scale_factor = 28000
        end
        %%% Scaling Factor
        if ~low_income(i)
            %%%Decrease in cost due to scale
            rel_scale_factor = rel_scale_factor*rel_fin(1,ii);
            
            %%%Adjsuted PV Costs
            debt =12.*ones(10,1).*(rel_v(1,ii) + rel_scale_factor)*((1-equity)*(interest*(1+interest)^(period*12))...
                /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
                req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
                /((1+required_return)^(period*12)-1));
            
            
            rel_cap_mod(i,ii) = cap_cost_scaling(tr,rel_v(:,ii),rel_fin(:,ii),rel_scale_factor,debt,discount_rate);
        else
        end
        
    end
end
%% Utility Scale Solar PV
if ~isempty(utilpv_v)
    utilpv_cap_mod = [];
    for i = 1:size(elec,2)
        for ii = 1:size(utilpv_v,2)
            %%%Applicable tax rate
            if strcmp(rate{i},'R1')
                tr = tax_rates(1);
            else
                tr = tax_rates(2);
            end
            
            %%% Solar PV Examination
            %%%Maximum PV estimated by either reaching net zero electrical energy
            %%%or installing maximum capacity
           % if ~isempty(maxpv)
           %     pv_scale_factor = min([sum(elec(:,i)).*(12/length(endpts))./(0.2*8760) maxpv(i)]);
           % else
           %     pv_scale_factor = min([sum(elec(:,i))./(0.2*8760)]);
           % end
           % if pv_scale_factor > 1000
           %     pv_scale_factor = 1000;
           % end
            
%             pv_scale_factor = pv_scale_factor.*ones(1,size(pv_v,2));
            
            %%%Scaling Factor
            %%%If is low income
            if low_income(i) ~= 1
%                 for ii = 1:length(pv_scale_factor)
                    %%%Decrease in cost due to scale
                    utilpv_scale_factor = utilpv_fin(1,ii);
                    
                    %%%Adjsuted utilpv Costs
                    debt =12.*ones(10,1).*(utilpv_v(1,ii))*((1-equity)*(interest*(1+interest)^(period*12))...
                        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
                        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
                        /((1+required_return)^(period*12)-1));
                    
                    utilpv_cap_mod(i,ii) = cap_cost_scaling(tr,utilpv_v(:,ii),utilpv_fin(:,ii),utilpv_scale_factor,debt,discount_rate);
                    
                    
%                 end
                %%%If is low income
            else
                utilpv_cap_mod(i,ii) = 1 - somah/utilpv_v(1,ii);
            end
            
        end
    end
end

%% Utility Scale Wind
if exist('util_wind_v') && ~isempty(util_wind_v)
    util_wind_cap_mod = [];
    for i = 1:size(elec,2)
        for ii = 1:size(util_wind_v,2)
            %%%Applicable tax rate
            if strcmp(rate{i},'R1')
                tr = tax_rates(1);
            else
                tr = tax_rates(2);
            end
            
            %%% Solar PV Examination
            %%%Maximum PV estimated by either reaching net zero electrical energy
            %%%or installing maximum capacity
           % if ~isempty(maxpv)
           %     pv_scale_factor = min([sum(elec(:,i)).*(12/length(endpts))./(0.2*8760) maxpv(i)]);
           % else
           %     pv_scale_factor = min([sum(elec(:,i))./(0.2*8760)]);
           % end
           % if pv_scale_factor > 1000
           %     pv_scale_factor = 1000;
           % end
            
%             pv_scale_factor = pv_scale_factor.*ones(1,size(pv_v,2));
            
            %%%Scaling Factor
            %%%If is low income
            if low_income(i) ~= 1
%                 for ii = 1:length(pv_scale_factor)
                    %%%Decrease in cost due to scale
                    util_wind_scale_factor = util_wind_fin(1,ii);
                    
                    %%%Adjsuted utilpv Costs
                    debt =12.*ones(10,1).*(util_wind_v(1,ii))*((1-equity)*(interest*(1+interest)^(period*12))...
                        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
                        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
                        /((1+required_return)^(period*12)-1));
                    
                    util_wind_cap_mod(i,ii) = cap_cost_scaling(tr,util_wind_v(:,ii),util_wind_fin(:,ii),util_wind_scale_factor,debt,discount_rate);
                    
                    
%                 end
                %%%If is low income
            else
                util_wind_cap_mod(i,ii) = 1 - somah/util_wind_v(1,ii);
            end
            
        end
    end
end
%% Utility Scale Battery Storage
if ~isempty(util_ees_v)
    util_ees_cap_mod = [];
    for i = 1:size(elec,2)
        for ii = 1:size(util_ees_v,2)
            %%%Applicable tax rate
            if strcmp(rate{i},'R1')
                tr = tax_rates(1);
            else
                tr = tax_rates(2);
            end
            
            %%% Solar PV Examination
            %%%Maximum PV estimated by either reaching net zero electrical energy
            %%%or installing maximum capacity
           % if ~isempty(maxpv)
           %     pv_scale_factor = min([sum(elec(:,i)).*(12/length(endpts))./(0.2*8760) maxpv(i)]);
           % else
           %     pv_scale_factor = min([sum(elec(:,i))./(0.2*8760)]);
           % end
           % if pv_scale_factor > 1000
           %     pv_scale_factor = 1000;
           % end
            
%             pv_scale_factor = pv_scale_factor.*ones(1,size(pv_v,2));
            
            %%%Scaling Factor
            %%%If is low income
            if low_income(i) ~= 1
%                 for ii = 1:length(pv_scale_factor)
                    %%%Decrease in cost due to scale
                    util_ees_scale_factor = util_ees_fin(1,ii);
                    
                    %%%Adjsuted utilpv Costs
                    debt =12.*ones(10,1).*(util_ees_v(1,ii))*((1-equity)*(interest*(1+interest)^(period*12))...
                        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
                        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
                        /((1+required_return)^(period*12)-1));
                    
                    util_ees_cap_mod(i,ii) = cap_cost_scaling(tr,util_ees_v(:,ii),util_ees_fin(:,ii),util_ees_scale_factor,debt,discount_rate);
                    
                    
%                 end
                %%%If is low income
            else
                util_ees_cap_mod(i,ii) = 1 - somah/util_ees_v(1,ii);
            end
            
        end
    end
end

%% Utility Scale Electrolyzer
if exist('util_el_on') && ~isempty(util_el_v)
    util_el_cap_mod = [];
    for i = 1:size(elec,2)
        %%%Applicable tax rate
        if strcmp(rate{i},'R1')
            tr = tax_rates(1);
        else
            tr = tax_rates(2);
        end
        
        %%%Electrolyzer examination
        %%%Generating a h2 fuel fraction when this does not exist
%         if ~isempty(h2_fuel_forced_fraction)
%             util_el_scale_factor = (sum(elec)./0.33*h2_fuel_forced_fraction)/length(elec)*e_adjust;
%         else
%             util_el_scale_factor = (sum(elec)./0.33*0.1)/length(elec)*e_adjust;
%         end
        
%         if util_el_scale_factor >= 28000
%             util_el_scale_factor = 28000
%         end

%%% Assuming maximum scale factor
util_el_scale_factor = 28000
        %%% Scaling Factor
        if ~low_income(i)
            %%%Decrease in cost due to scale
            util_el_scale_factor = util_el_scale_factor*util_el_fin(1,ii);
            
            %%%Adjsuted PV Costs
            debt =12.*ones(10,1).*(util_el_v(1,ii) + util_el_scale_factor)*((1-equity)*(interest*(1+interest)^(period*12))...
                /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
                req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
                /((1+required_return)^(period*12)-1));
            
            
                    util_el_cap_mod(i,ii) = cap_cost_scaling(tr,util_el_v(:,ii),util_el_fin(:,ii),util_el_scale_factor,debt,discount_rate);
        else
         end
        
    end
end

%% Converting incentives to reductions in debt payments
if ~isempty(sgip)
    
    %%%Adjsut SGIP benefits if they are larger than the capital cost
    sgip(sgip(1:4) > ees_v(1)) = ees_v(1);
    
    %%%Large storage benefit
     sgip_mthly_benefit(1)=sgip(2)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));        
        
    %%%Residential storage benefit
     sgip_mthly_benefit(2)=sgip(3)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));        
        
    %%% Equity storage benefit
     sgip_mthly_benefit(3)=sgip(4)*((1-equity)*(interest*(1+interest)^(period*12))...
            /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
            req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
            /((1+required_return)^(period*12)-1));
        
        %%%Adjusting SGIP benefits if they are larger after tax breaks
        
end
