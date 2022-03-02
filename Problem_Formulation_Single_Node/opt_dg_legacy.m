%%%Legacy generator constraints
if ~isempty(dg_legacy)
    for i = 1:size(dg_legacy,2)
        Constraints = [Constraints
            (-dg_legacy(2,i)*dg_legacy(5,i) <= var_ldg.ldg_elec(2:size(var_ldg.ldg_elec,1),i) - var_ldg.ldg_elec(1:size(var_ldg.ldg_elec,1)-1,i) <= dg_legacy(2,i)*dg_legacy(4,i)):'LDG Ramp Constraints' %Ramp Rates Constraints
            ((dg_legacy(3,i)*(1/e_adjust)).*var_ldg.ldg_opstate(:,ii) <= var_ldg.ldg_elec(:,i) <= (dg_legacy(2,i)*(1/e_adjust).*var_ldg.ldg_opstate(:,ii))):'Min/Max Power' %%%Min/Max Power output for generator & on/off behavior
            (dg_legacy(7,i)*var_ldg.ldg_elec(:,i) + dg_legacy(8,i).*var_ldg.ldg_opstate(:,ii) == (var_ldg.ldg_fuel(:,i) + var_ldg.ldg_rfuel(:,i) + var_ldg.ldg_hfuel(:,i) + var_ldg.ldg_sfuel(:,i) + var_ldg.ldg_dfuel(:,i))):'LDG Fuel Input']; %%%Fuel Consumption to produce electricity
               
        %% If Cycling Costs are included
        if  ~isempty(dg_legacy_cyc)
            %%%Ramping Constraints
            Constraints = [Constraints
                ((var_ldg.ldg_elec(2:end,i) - var_ldg.ldg_elec(1:end-1,i)) <= var_ldg.ldg_elec_ramp(:,i)):'Cycling Cost Constraints'
                ((var_ldg.ldg_elec(1:end-1,i) - var_ldg.ldg_elec(2:end,i)) <= var_ldg.ldg_elec_ramp(:,i)):'Cycling Cost Constraints'];
            
            
        end
        %             dg_legacy(7,i)*var_ldg.ldg_elec(:,i) + dg_legacy(8,i) == (var_ldg.ldg_fuel(:,i) + var_ldg.ldg_rfuel(:,i))]; %%%Fuel Consumption to produce electricity
%             dg_legacy(7,i)*var_ldg.ldg_elec(:,i) + dg_legacy(8,i) == (var_ldg.ldg_fuel(:,i) + var_ldg.ldg_rfuel(:,i) + sum(var_el.el_prod,2) + sum(var_h2es.h2es_dchrg,2))]; %%%Fuel Consumption to produce electricity
        
        %         onoff = (dg_legacy(end,i)/t_step);
        %         for j = 1:ceil(length(time)/(dg_legacy(end,i)/t_step))
        %             if j == 1
        %                 st = 1;
        %                 fn = j*onoff;
        %             elseif j == ceil(length(time)/(dg_legacy(end,i)/t_step))
        %                 st = (j-1)*onoff + 1;
        %                 fn = length(elec);
        %             else
        %                 st = (j-1)*onoff + 1;
        %                 fn = j*onoff;
        %             end
        %
        %             Constraints = [Constraints
        %                 ldg_elec(st:fn,i) <= (dg_legacy(2,i)/4)*(1 - ldg_off(j,i)) %%%Min/Max Power output for generator & on/off behavior
        %                 dg_legacy(7,i)*ldg_elec(st:fn,i) + dg_legacy(8,i)*ones(fn-st+1,1) - dg_legacy(8,i)*ldg_off(j,i) == ldg_fuel(st:fn,i) ]; %%%Fuel consumption is linked to electrical production
        %
        %
        %         end
    end
end


