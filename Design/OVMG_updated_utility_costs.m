for ii = 1:length(bldg_base)
    %%%Apply Residential Rates
    if strcmp(bldg_type(ii),'MFm') || strcmp(bldg_type(ii),'Single-Family Detached') || strcmp(bldg_type(ii),'Residential')
        %         for ii = 1:length(endpts)
        if  strcmp(bldg_type(ii),'Single-Family Detached') && isempty(bldg_base(ii).units)
            bldg_base(ii).units = 1;
        elseif strcmp(bldg_type(ii),'MFm') && isempty(bldg_base(ii).units)
            bldg_base(ii).units = res_units_total(ii);
        end
        fixed_costs(:,1) = (endpts - stpts + 1)/24.*0.031.*bldg_base(ii).units;
        fixed_costs(:,2) = fixed_costs(:,1).*(1-care_energy_rebate);
        
        %%%Climate Credit
        fixed_costs([4 10],:) = fixed_costs([4 10],:) - 37.*bldg_base(ii).units;
        
        %%%Energy Rates
        for jj = 1:length(endpts)
            fn = endpts(jj);
            if jj == 1
                st = 1;
            else
                st = endpts(jj - 1) + 1;
            end
            base_energy_costs(jj,1) = import_price(st:fn,4)'*bldg_base(ii).elec_loads.Total(st:fn);
            energy_costs(jj,1) = import_price(st:fn,4)'*bldg_base(ii).der_systems.import(st:fn) - export_price(st:fn,4)'*(bldg_base(ii).der_systems.pv_ops(st:fn,2) + bldg_base(ii).der_systems.rees_ops(st:fn,4));
        
        end
        %%%CARE Rates
        energy_costs(:,2) = energy_costs(:,1).*(1-care_energy_rebate);
        demand_costs = zeros(size(fixed_costs));
        %%%Apply Commercial Rates
    else

        if ri_num(ii) == 1
            idx = 2;
        else
            idx = 1;            
        end
        fixed_costs(:,1) = (endpts - stpts + 1)/24.*rates_gen.fix(1,idx) + rates_gen.fix(2,idx);
        fixed_costs(:,2) = fixed_costs(:,1);
        
        for jj = 1:length(endpts)
            fn = endpts(jj);
            if jj == 1
                st = 1;
            else
                st = endpts(jj - 1) + 1;
            end
            energy_costs(jj,1) = import_price(st:fn,idx)'*bldg_base(ii).der_systems.import(st:fn) - export_price(st:fn,idx)'*(bldg_base(ii).der_systems.pv_ops(st:fn,2) + bldg_base(ii).der_systems.rees_ops(st:fn,4));
            
            demand_costs(jj,1) = max(bldg_base(ii).der_systems.import(st:fn))*rates_gen.dc(1,idx) + max(onpeak_index(st:fn).*bldg_base(ii).der_systems.import(st:fn))*rates_gen.dc(2,idx) + max(midpeak_index(st:fn).*bldg_base(ii).der_systems.import(st:fn))*rates_gen.dc(3,idx);
            
%             demand_costs(jj,1) = max(var_util.import(st:fn,ii))*rates_gen.dc(1,idx) + max(onpeak_index(st:fn).*var_util.import(st:fn,ii))*rates_gen.dc(2,idx) + max(midpeak_index(st:fn).*var_util.import(st:fn,ii))*rates_gen.dc(3,idx);
           
%             energy_costs(jj,1) = import_price(st:fn,idx)'*elec(st:fn,ii);
%             demand_costs(jj,1) = max(elec(st:fn,ii))*rates_gen.dc(1,idx) + max(onpeak_index(st:fn).*elec(st:fn,ii))*rates_gen.dc(2,idx) + max(midpeak_index(st:fn).*elec(st:fn,ii))*rates_gen.dc(3,idx);
           
            
        end
        demand_costs(:,2) = demand_costs(:,1);
        energy_costs(:,2) = energy_costs(:,1);
        
    end
    bldg_base(ii).costs_elec.ec = energy_costs;
    bldg_base(ii).costs_elec.fc = fixed_costs;
    bldg_base(ii).costs_elec.dc = demand_costs;
    
    bldg_base(ii).costs_elec.total = bldg_base(ii).costs_elec.ec + bldg_base(ii).costs_elec.fc + bldg_base(ii).costs_elec.dc;
    
    cost_compare(ii,:) = sum(bldg_base(ii).costs_elec.total)./sum(bldg(ii).costs_elec.total);


    if adopted.pv(ii) >0 || adopted.ees(ii)>0
    cost_components(ii,:) = [sum(base_energy_costs(:,1)) sum(bldg(ii).costs_gas.total(:,1))...
        sum(energy_costs(:,1)) sum(bldg(ii).costs_gas.total(:,1)) ...
        M*pv_mthly_debt*bldg_base(ii).der_systems.pv_adopt.*bldg_base(ii).der_systems.cap_mods(1) M*ees_mthly_debt*bldg_base(ii).der_systems.cap_mods(2)*(bldg_base(ii).der_systems.ees_adopt+bldg_base(ii).der_systems.rees_adopt-bldg_base(ii).der_systems.sgip_equity)];
    else
    cost_components(ii,:) = [sum(base_energy_costs(:,1)) sum(bldg(ii).costs_gas.total(:,1))...
        sum(base_energy_costs(:,1)) sum(bldg(ii).costs_gas.total(:,1)) ...
        M*pv_mthly_debt*bldg_base(ii).der_systems.pv_adopt.*bldg_base(ii).der_systems.cap_mods(1) M*ees_mthly_debt*bldg_base(ii).der_systems.cap_mods(2)*(bldg_base(ii).der_systems.ees_adopt+bldg_base(ii).der_systems.rees_adopt-bldg_base(ii).der_systems.sgip_equity)];
    end

end