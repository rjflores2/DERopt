%%%Calculating how capital costs are handled at each building/site
cap_mod = [];
cap_scalar = [];
for i = 1:size(elec,2)    
    %%%Is building general or residential based on applicalble utility rate
    if find(non_res_rates == find(ismember(rate_labels,rate(i)))) %%%IS nonresidential
        %%%Scaling capital cost based on property end use
        cap_mod.pv(1,i) = pv_cap_mod(1);
        cap_mod.ees(1,i) = ees_cap_mod(1);
        cap_mod.rees(1,i) = ees_cap_mod(1);
        
        %%%Adder to be included for each property
        cap_scalar.pv(1,i) = 0;
        cap_scalar.ees(1,i) = 0;
        cap_scalar.rees(1,i) = 0;
    else %%%IS Residential
        cap_mod.pv(1,i) = pv_cap_mod(2);
        cap_mod.ees(1,i) = ees_cap_mod(2);
        cap_mod.rees(1,i) = ees_cap_mod(2);
        
        %%%Adder to be included for each property
        cap_scalar.pv(1,i) = 0;
        cap_scalar.ees(1,i) = 0;
        cap_scalar.rees(1,i) = 0;
        
        
        if low_income(i)
            cap_mod.pv(1,i) = 1-somah/pv_cap;
            
            cap_scalar.ees(1,i) = 0;
            cap_scalar.rees(1,i) = 0;
        end
    end
end