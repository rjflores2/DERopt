for ii = 1:K
    %%%Apply Residential Rates
    if strcmp(bldg_type(ii),'MFm') || strcmp(bldg_type(ii),'Single-Family Detached') || strcmp(bldg_type(ii),'Residential')
        %         for ii = 1:length(endpts)
        if  strcmp(bldg_type(ii),'Single-Family Detached') && isempty(bldg(ii).units)
            bldg(ii).units = 1;
        end
        fixed_costs(:,1) = (endpts - stpts + 1)/24.*0.031.*bldg(ii).units;
        fixed_costs(:,2) = fixed_costs(:,1).*(1-care_energy_rebate);
        
        %%%Climate Credit
        fixed_costs([4 10],:) = fixed_costs([4 10],:) - 37.*bldg(ii).units;
        
        %%%Energy Rates
        for jj = 1:length(endpts)
            fn = endpts(jj);
            if jj == 1
                st = 1;
            else
                st = endpts(jj - 1) + 1;
            end
            base_energy_costs(jj,1) = import_price(st:fn,4)'*elec(st:fn,ii);
            energy_costs(jj,1) = import_price(st:fn,4)'*var_util.import(st:fn,ii) - export_price(st:fn,4)'*(var_rees.rees_dchrg_nem(st:fn,ii) + var_pv.pv_nem(st:fn,ii) + var_lrees.rees_dchrg_nem(st:fn,ii));
        end
        %%%CARE Rates
        energy_costs(:,2) = energy_costs(:,1).*(1-care_energy_rebate);
        
        demand_costs = zeros(size(fixed_costs));
        %%%Apply Commercial Rates
    else

        if dc_exist(ii) == 1
            idx = 2;
        else
            idx = 1;
            shit
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
            energy_costs(jj,1) = import_price(st:fn,idx)'*var_util.import(st:fn,ii) - export_price(st:fn,idx)'*(var_rees.rees_dchrg_nem(st:fn,ii) + var_pv.pv_nem(st:fn,ii) + var_lrees.rees_dchrg_nem(st:fn,ii));
            demand_costs(jj,1) = max(var_util.import(st:fn,ii))*rates_gen.dc(1,idx) + max(onpeak_index(st:fn).*var_util.import(st:fn,ii))*rates_gen.dc(2,idx) + max(midpeak_index(st:fn).*var_util.import(st:fn,ii))*rates_gen.dc(3,idx);
           
            energy_costs(jj,1) = import_price(st:fn,idx)'*elec(st:fn,ii);
            demand_costs(jj,1) = max(elec(st:fn,ii))*rates_gen.dc(1,idx) + max(onpeak_index(st:fn).*elec(st:fn,ii))*rates_gen.dc(2,idx) + max(midpeak_index(st:fn).*elec(st:fn,ii))*rates_gen.dc(3,idx);
           
            
        end
        demand_costs(:,2) = demand_costs(:,1);
        energy_costs(:,2) = energy_costs(:,1);
        
    end
    bldg(ii).costs_elec.ec = energy_costs;
    bldg(ii).costs_elec.fc = fixed_costs;
    bldg(ii).costs_elec.dc = demand_costs;
    
    bldg(ii).costs_elec.total = bldg(ii).costs_elec.ec + bldg(ii).costs_elec.fc + bldg(ii).costs_elec.dc;
    
    
end