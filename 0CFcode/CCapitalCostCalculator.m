classdef CCapitalCostCalculator < handle

    properties (SetAccess = public)

        pv_mthly_debt = [];
        ees_mthly_debt = [];
        rees_mthly_debt = [];
        el_mthly_debt = [];
        rel_mthly_debt = [];
        h2es_mthly_debt = [];
        hrs_mthly_debt = [];
        h2_inject_mthly_debt = [];

        utilpv_mthly_debt = [];
        util_wind_mthly_debt = [];
        util_ees_mthly_debt = [];
        util_el_mthly_debt = [];
        util_h2_inject_mthly_debt = [];

        sgip_mthly_benefit = [];

        pv_cap_mod = [];
        rees_cap_mod = [];
        ees_cap_mod = [];
        ees_scale_factor_rec = [];
        el_cap_mod = [];
        rel_cap_mod = [];
        utilpv_cap_mod = [];
        util_wind_cap_mod = [];
        util_ees_cap_mod = [];
        util_el_cap_mod = [];

    end

    properties (SetAccess = private)
        interest
        period
        equity
        required_return
        equity_return
        discount_rate
        tax_rates
        req_return_on
        debtCoeficient
    end
    
    properties (Constant)
        rate = {'TOU8'}
    end


    methods
        function obj = CCapitalCostCalculator(interestRateOnLoans, lengthOfLoansYears, requiredReturnCapitalPayment)
            
            % Financing CRAP
            obj.interest = interestRateOnLoans;
            obj.interest = nthroot(obj.interest + 1, 12)-1; % Converting from annual to monthly rate for compounding interest
            obj.period = lengthOfLoansYears;
            obj.equity = 0.2;   % Percent of investment made by investors
            obj.required_return = .12; % Required return on equity investment
            obj.required_return = nthroot(obj.required_return + 1, 12)-1; % Converting from annual to monthly rate for compounding required return
            obj.equity_return = 10; % Length at which equity + required return will be paid off (Years)
            obj.discount_rate = 0.08;
            
            % Tax Rates
            obj.tax_rates = [0.2 0.3]; %%%Residential and commercial rates

            obj.req_return_on = requiredReturnCapitalPayment;

            % Calculate coeficients...

            obj.debtCoeficient = ((1-obj.equity)*(obj.interest*(1+obj.interest)^(obj.period*12))/((1+obj.interest)^(obj.period*12)-1)+...%%%Money to pay back bank  
                                requiredReturnCapitalPayment*(obj.equity)*(obj.required_return*(1+obj.required_return)^(obj.period*12))...
                                /((1+obj.required_return)^(obj.period*12)-1));


        end
        
        function DebtPaymentsFullCostSystem(obj, pv_v, ees_v, el_v, rel_v, h2es_v, hrs_v, h2_inject_v, utilpv_v, util_wind_v, util_ees_v, util_el_on, util_h2_inject_v, rees_on)

            % Solar PV
            if ~isempty(pv_v)
                for ii=1:size(pv_v,2)
                    obj.pv_mthly_debt(ii,1) = pv_v(1,ii) * obj.debtCoeficient;
                end
            end            

            %%%EES
            if ~isempty(ees_v)
                for ii=1:size(ees_v,2)
                    obj.ees_mthly_debt(ii,1) = ees_v(1,ii)*obj.debtCoeficient;
                end
                if ~isempty(pv_v) && rees_on == 1
                    for ii=1:size(ees_v,2)
                        obj.rees_mthly_debt(ii,1) = ees_v(1,ii)*obj.debtCoeficient;
                    end
                end
            end
            
            %%%Generic electrolyzer
            if ~isempty(el_v)
                for ii=1:size(el_v,2)
                    obj.el_mthly_debt(ii,1) = el_v(1,ii)*obj.debtCoeficient;
                end
            end
            
            %%%Renewable Generic Electrolyzer
            if ~isempty(rel_v)
                for ii=1:size(rel_v,2)
                    obj.rel_mthly_debt(ii,1) = rel_v(1,ii)*obj.debtCoeficient;
                end
            end
            
            %%%Generic Hydrogen energy storage
            if ~isempty(h2es_v)
                for ii=1:size(h2es_v,2)
                    obj.h2es_mthly_debt(ii,1) = h2es_v(1,ii)*obj.debtCoeficient;
                end
            end
            
            
            %%%Hydrogen fueling station
            if ~isempty(hrs_v)
                obj.hrs_mthly_debt = hrs_v(1)*obj.debtCoeficient;
            end
            
            %---------------------------------------------------------------------------------------------

            %%%Utility Scale Solar
            if ~isempty(utilpv_v)
                for ii=1:size(utilpv_v,2)
                    obj.utilpv_mthly_debt(ii,1) = utilpv_v(1,ii)*obj.debtCoeficient;
                end
            end
            
            %%%Utility Scale wind
            if ~isempty(util_wind_v)
                for ii=1:size(util_wind_v,2)
                    obj.util_wind_mthly_debt(ii,1) = util_wind_v(1,ii)*obj.debtCoeficient;
                end
            end
            
            %%%Utility Battery Storage
            if ~isempty(util_ees_v)
                for ii=1:size(util_ees_v,2)
                    obj.util_ees_mthly_debt(ii,1) = util_ees_v(1,ii)*obj.debtCoeficient;
                end
            end
            
            %%%Generic electrolyzer
            if ~isempty(util_el_on)
                for ii=1:size(util_el_on,2)
                    obj.util_el_mthly_debt(ii,1) = util_el_on(1,ii)*obj.debtCoeficient;
                end
            end
            %%%H2 Pipeline Injeciton
            if ~isempty(h2_inject_v)
                for ii = 1:size(h2_inject_v,2)
                    obj.h2_inject_mthly_debt(ii) = h2_inject_v(ii)*obj.debtCoeficient;
                end
            end
            
            %%%H2 Pipeline Injeciton
            if ~isempty(util_h2_inject_v)
                for ii = 1:size(util_h2_inject_v)
                    obj.util_h2_inject_mthly_debt(ii) = util_h2_inject_v(ii)*obj.debtCoeficient;
                end
            end

        end


        function ConvertIncentivesToReductions(obj, sgip, ees_v)

            %% Converting incentives to reductions in debt payments
            if ~isempty(sgip)
                
                %%%Adjsut SGIP benefits if they are larger than the capital cost
                sgip(sgip(1:4) > ees_v(1)) = ees_v(1);
                
                 %%%Large storage benefit
                 obj.sgip_mthly_benefit(1) = sgip(2)*obj.debtCoeficient;        
                    
                 %%%Residential storage benefit
                 obj.sgip_mthly_benefit(2) = sgip(3)*obj.debtCoeficient;        
                    
                 %%% Equity storage benefit
                 obj.sgip_mthly_benefit(3) = sgip(4)*obj.debtCoeficient;

            end

        end

        function CalcCostScalars_SolarPV(obj, pv_v, pv_fin, somah, elec, maxpv, low_income)

            if ~isempty(pv_v)

                obj.pv_cap_mod = [];

                for i = 1:size(elec,2)

                    for ii = 1:size(pv_v,2)

                        %%%Applicable tax rate
                        if strcmp(obj.rate{i},'R1')
                            tr = obj.tax_rates(1);
                        else
                            tr = obj.tax_rates(2);
                        end
                        %%% Solar PV Examination
                        %%%Maximum PV estimated by either reaching net zero electrical energy
                        %%%or installing maximum capacity
                        if ~isempty(maxpv)
            %               pv_scale_factor = min([sum(elec(:,i)).*(12/length(endpts))./(0.2*8760) maxpv(i)*0.2]);
            %                 pv_scale_factor = min([sum(elec(:,i)).*(12/length(endpts))./(0.2*size(elec,1)) maxpv(i)*0.2]);
                            pv_scale_factor = min([sum(elec(:,i))./(0.2*size(elec,1)) maxpv(i)*0.2]);
                        else
                            pv_scale_factor = min(sum(elec(:,i))./(0.2*size(elec,1)));
                        end
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
                                debt = 12.*ones(10,1).*(pv_v(1,ii) + pv_scale_factor)*obj.debtCoeficient;
                                
                                obj.pv_cap_mod(i,ii) = obj.CapCostScaling(tr, pv_v(:,ii), pv_fin(:,ii), pv_scale_factor, debt, obj.discount_rate);
                                
                                
            %                 end
                            %%%If is low income
                        else
                            obj.pv_cap_mod(i,ii) = 1 - somah/pv_v(1,ii);
                        end
                        
                    end
                end
            end

        end

        
        function CalcCostScalars_EES(obj, ees_v, ees_fin, rees_fin, pv_v, elec, maxpv, rees_on)

            if ~isempty(ees_v)
                
                obj.ees_cap_mod = [];

                for i = 1:size(elec,2)
                    for ii = 1:size(ees_v,2)

                        %%%Applicable tax rate
                        if strcmp(obj.rate{i},'R1')
                            tr = obj.tax_rates(1);
                        else
                            tr = obj.tax_rates(2);
                        end
                        
                      %%% Solar PV Examination
                        %%%Maximum PV estimated by either reaching net zero electrical energy
                        %%%or installing maximum capacity
                        if ~isempty(maxpv)
                            pv_scale_factor = min([sum(elec(:,i))./(0.2*8760) maxpv(i)]);
                        else
                            pv_scale_factor = min(sum(elec(:,i))./(0.2*8760));
                        end
                        if pv_scale_factor > 1000
                            pv_scale_factor = 1000;
                        end
                        
                        ees_scale_factor = pv_scale_factor*2.5; %%%Assume 2.5 kWh storage per kW of PV
                        if ees_scale_factor > 2000
                            ees_scale_factor = 2000;
                        end
                        obj.ees_scale_factor_rec(i,1) = ees_scale_factor;
                        
                        
                        %%%Scaling Factor
                        %%%If is low income
                        %%%Decrease in cost due to scale
                        ees_scale_factor = ees_scale_factor*ees_fin(1,ii);
                        
                        %%%Adjsuted PV Costs
                        debt=12.*ones(10,1).*(ees_v(1,ii) + ees_scale_factor)*obj.debtCoeficient;
                        
                        obj.ees_cap_mod(i,ii) = obj.CapCostScaling(tr,ees_v(:,ii),ees_fin(:,ii),ees_scale_factor,debt,obj.discount_rate);
                        
                        if ~isempty(pv_v) && rees_on == 1
                            obj.rees_cap_mod(i,ii) = obj.CapCostScaling(tr,ees_v(:,ii),rees_fin(:,ii),ees_scale_factor,debt,obj.discount_rate);
                        end
                        
                    end
                end
            end
        end


        function CalcCostScalars_Electrolizer(obj, el_v, el_fin, elec, h2_fuel_forced_fraction, low_income, e_adjust)
            
            if ~isempty(el_v)

                obj.el_cap_mod = [];

                for i = 1:size(elec,2)
                    %%%Applicable tax rate
                    if strcmp(obj.rate{i},'R1')
                        tr = obj.tax_rates(1);
                    else
                        tr = obj.tax_rates(2);
                    end
                    
                    %%%Electrolyzer examination
                    %%%Generating a h2 fuel fraction when this does not exist
                    if ~isempty(h2_fuel_forced_fraction)
                        el_scale_factor = (sum(elec)./0.33*h2_fuel_forced_fraction)/length(elec)*e_adjust;
                    else
                        el_scale_factor = (sum(elec)./0.33*0.1)/length(elec)*e_adjust;
                    end
                    
                    if el_scale_factor >= 28000
                        el_scale_factor = 28000;
                    end

                    %%% Scaling Factor
                    if ~low_income(i)

                        %TODO: fix this section. there is no variable "ii",
                        %something is wrong!!
                        ii = 1;

                        %%%Decrease in cost due to scale
                        el_scale_factor = el_scale_factor*el_fin(1,ii);
                        
                        %%%Adjsuted PV Costs
                        debt =12.*ones(10,1).*(el_v(1,ii) + el_scale_factor)*obj.debtCoeficient;

                        obj.el_cap_mod(i,ii) = obj.CapCostScaling(tr,el_v(:,ii),el_fin(:,ii),el_scale_factor,debt,obj.discount_rate);
                    end
                    
                end
            end

        end        


        function CalcCostScalars_RenewableElectrolizer(obj, rel_v, rel_fin, elec, h2_fuel_forced_fraction, low_income, e_adjust)
                                        
            if ~isempty(rel_v)

                obj.rel_cap_mod = [];

                for i = 1:size(elec,2)
                    
                    %%%Applicable tax rate
                    if strcmp(obj.rate{i},'R1')
                        tr = obj.tax_rates(1);
                    else
                        tr = obj.tax_rates(2);
                    end
                    
                    %%%Electrolyzer examination
                    %%%Generating a h2 fuel fraction when this does not exist
                    if ~isempty(h2_fuel_forced_fraction)
                        rel_scale_factor = (sum(elec)./0.33*h2_fuel_forced_fraction)/length(elec)*e_adjust;
                    else
                        rel_scale_factor = (sum(elec)./0.33*0.1)/length(elec)*e_adjust;
                    end
                    
                    if rel_scale_factor >= 28000
                        rel_scale_factor = 28000;
                    end
                    %%% Scaling Factor
                    if ~low_income(i)

                        %TODO: fix this section. there is no variable "ii",
                        %something is wrong!!
                        ii = 1;

                        %%%Decrease in cost due to scale
                        rel_scale_factor = rel_scale_factor*rel_fin(1,ii);
                        
                        %%%Adjsuted PV Costs
                        debt =12.*ones(10,1).*(rel_v(1,ii) + rel_scale_factor)*obj.debtCoeficient;
                                                
                        obj.rel_cap_mod(i,ii) = obj.CapCostScaling(tr,rel_v(:,ii),rel_fin(:,ii),rel_scale_factor,debt,obj.discount_rate);
                    else
                    end
                    
                end
            end
    
        end      

        %--------------------------------------------------

        function CalcCostScalars_UtilityScaleSolarPV(obj, utilpv_v, utilpv_fin, elec, somah, low_income)
            
            if ~isempty(utilpv_v)

                obj.utilpv_cap_mod = [];
                
                for i = 1:size(elec,2)

                    for ii = 1:size(utilpv_v,2)

                        %%%Applicable tax rate
                        if strcmp(obj.rate{i},'R1')
                            tr = obj.tax_rates(1);
                        else
                            tr = obj.tax_rates(2);
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
                                debt =12.*ones(10,1).*(utilpv_v(1,ii))*obj.debtCoeficient;
                                
                                obj.utilpv_cap_mod(i,ii) = obj.CapCostScaling(tr,utilpv_v(:,ii),utilpv_fin(:,ii),utilpv_scale_factor,debt,obj.discount_rate);

            %                 end
                            %%%If is low income
                        else
                            obj.utilpv_cap_mod(i,ii) = 1 - somah/utilpv_v(1,ii);
                        end
                        
                    end
                end
            end
        end      


        function CalcCostScalars_UtilityScaleWind(obj, util_wind_v, util_wind_fin, elec, somah)

            if~isempty(util_wind_v)

                obj.util_wind_cap_mod = [];

                for i = 1:size(elec,2)

                    for ii = 1:size(util_wind_v,2)
                        
                        %%%Applicable tax rate
                        if strcmp(obj.rate{i},'R1')
                            tr = obj.tax_rates(1);
                        else
                            tr = obj.tax_rates(2);
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
                                debt =12.*ones(10,1).*(util_wind_v(1,ii))*obj.debtCoeficient;
                                
                                obj.util_wind_cap_mod(i,ii) = obj.CapCostScaling(tr,util_wind_v(:,ii),util_wind_fin(:,ii),util_wind_scale_factor,debt,obj.discount_rate);
                                
                                
            %                 end
                            %%%If is low income
                        else
                            obj.util_wind_cap_mod(i,ii) = 1 - somah/util_wind_v(1,ii);
                        end
                        
                    end
                end
            end
        end      


        function CalcCostScalars_UtilityScaleBatteryStorage(obj, util_ees_v, util_ees_fin, elec, somah)

            if ~isempty(util_ees_v)

                obj.util_ees_cap_mod = [];

                for i = 1:size(elec,2)

                    for ii = 1:size(util_ees_v,2)

                        %%%Applicable tax rate
                        if strcmp(obj.rate{i},'R1')
                            tr = obj.tax_rates(1);
                        else
                            tr = obj.tax_rates(2);
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
                                debt =12.*ones(10,1).*(util_ees_v(1,ii))*obj.debtCoeficient;
                                
                                obj.util_ees_cap_mod(i,ii) = obj.CapCostScaling(tr,util_ees_v(:,ii),util_ees_fin(:,ii),util_ees_scale_factor,debt,obj.discount_rate);
                                
            %                 end
                            %%%If is low income
                        else
                            obj.util_ees_cap_mod(i,ii) = 1 - somah/util_ees_v(1,ii);
                        end
                        
                    end
                end
            end
        end      


        function CalcCostScalars_UtilityScaleElectrolyzer(obj, util_el_v, util_el_fin, elec)

            if ~isempty(util_el_v)

                obj.util_el_cap_mod = [];

                for i = 1:size(elec,2)

                    %%%Applicable tax rate
                    if strcmp(obj.rate{i},'R1')
                        tr = obj.tax_rates(1);
                    else
                        tr = obj.tax_rates(2);
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
                    util_el_scale_factor = 28000;

                    %%% Scaling Factor
                    if ~low_income(i)

                        %TODO: fix this section. there is no variable "ii",
                        %something is wrong!!
                        ii = 1;

                        %%%Decrease in cost due to scale
                        util_el_scale_factor = util_el_scale_factor*util_el_fin(1,ii);
                        
                        %%%Adjsuted PV Costs
                        debt =12.*ones(10,1).*(util_el_v(1,ii) + util_el_scale_factor)*obj.debtCoeficient;

                        obj.util_el_cap_mod(i,ii) = obj.CapCostScaling(tr,util_el_v(:,ii),util_el_fin(:,ii),util_el_scale_factor,debt,obj.discount_rate);
                    end                    
                end
            end
        end   


        function [cost_scale] = CapCostScaling(obj, tr, tech_v, fin_v, scale_factor, debt, discount_rate)
        
            %% MARCS Schedules
            %%%5 year schedule
            macrs5 = [0.2   %yr1
                0.32        %yr2
                0.192       %yr3
                0.1152      %yr4
                0.1152      %yr5
                0.0576      %yr6
                0           %yr7
                0           %yr8
                0           %yr9
                0];         %yr10
            
            %%%7 year schedule
            macrs7 = [0.1429%yr1
                0.2449      %yr2
                0.1749      %yr3
                0.1249      %yr4
                0.0893      %yr5
                0.0892      %yr6
                0.0893      %yr7
                0.0446      %yr8
                0           %yr9
                0];         %yr10
            
            %% MACRS
            if fin_v(2) == 5
                macrs = macrs5.*(tech_v(1) + scale_factor)*tr;
            elseif fin_v(2) == 7
                macrs = macrs7.*(tech_v(1) + scale_factor)*tr;
            else
                macrs = zeros(size(macrs5));
            end
            
            %% ITC
            itc = (tech_v(1) + scale_factor)*tr*fin_v(3);
            
            %% Cashflows
            cashflow = debt - macrs;
            cashflow(1) = cashflow(1) - itc;
            
            %%%Adjsuted Cost
            npv_cost = pvvar(cashflow,discount_rate);
            
            %% Cost Scaling
            cost_scale = npv_cost/tech_v(1);
            
            if cost_scale < 0
                cost_scale = 0;
            end

        end

    end
end

