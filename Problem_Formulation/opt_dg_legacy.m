%%%Legacy generator constraints
if ~isempty(dg_legacy)
    for i = 1:size(dg_legacy,2)
        Constraints = [Constraints
        -dg_legacy(2,i)*dg_legacy(5,i)<=ldg_elec(2:size(ldg_elec,1),i)-ldg_elec(1:size(ldg_elec,1)-1,i)<=dg_legacy(2,i)*dg_legacy(4,i) %];
        (dg_legacy(3,i)*(1/e_adjust)) <= ldg_elec(:,i) <= (dg_legacy(2,i)*(1/e_adjust))]; %%%Min/Max Power output for generator & on/off behavior
        
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


