%%%Legacy generator constraints
if ~isempty(dg_legacy)
    
    var_ldg.ldg_hfuel = zeros(size(var_ldg.ldg_elec));
    var_ldg.ldg_sfuel = zeros(size(var_ldg.ldg_elec));
    
    for i = 1:size(dg_legacy,2)
        Constraints = [Constraints
            (-dg_legacy(2,i)*dg_legacy(5,i) <= var_ldg.ldg_elec(2:size(var_ldg.ldg_elec,1),i) - var_ldg.ldg_elec(1:size(var_ldg.ldg_elec,1)-1,i) <= dg_legacy(2,i)*dg_legacy(4,i)):'LDG Ramp Constraints' %Ramp Rates Constraints
            ((dg_legacy(3,i)*(1/e_adjust))*(var_ldg.ldg_onoff(:,i)) <= var_ldg.ldg_elec(:,i) <= (dg_legacy(2,i)*(1/e_adjust)*(var_ldg.ldg_onoff(:,i)))):'Min/Max Power' %%%Min/Max Power output for generator & on/off behavior
            (dg_legacy(7,i)*var_ldg.ldg_elec(:,i) + dg_legacy(8,i).*var_ldg.ldg_onoff(:,i) == (var_ldg.ldg_fuel(:,i) + var_ldg.ldg_rfuel(:,i) + var_ldg.ldg_hfuel(:,i) + var_ldg.ldg_sfuel(:,i))):'LDG Fuel Input']; %%%Fuel Consumption to produce electricity
        
        %% If Cycling Costs are included - Ramping
        if  ~isempty(dg_legacy_cyc) && sum(dg_legacy_cyc(1,:)) > 0
            %%%Ramping Constraints
            Constraints = [Constraints
                ((var_ldg.ldg_elec(2:end,i) - var_ldg.ldg_elec(1:end-1,i)) <= var_ldg.ldg_elec_ramp(:,i)):'Cycling Cost Constraints'
                ((var_ldg.ldg_elec(1:end-1,i) - var_ldg.ldg_elec(2:end,i)) <= var_ldg.ldg_elec_ramp(:,i)):'Cycling Cost Constraints'];
        end
        %% If cycling costs are included - Startup
        if  ~isempty(dg_legacy_cyc) && sum(dg_legacy_cyc(1,:)) > 0
            %%%Startup Constraints
            Constraints = [Constraints
                (var_ldg.ldg_onoff(2:end,ii) - var_ldg.ldg_onoff(1:end-1,ii) <= var_ldg.ldg_start(:,ii)):'Start up consts constraints'];
            
        end
    end
end


