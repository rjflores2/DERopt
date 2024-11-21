if exist('pemfc_on') && pemfc_on

    Constraints = [Constraints
        (0 <= var_pem.cap):'PEMFC Capacity must be positive'
        (0 <=var_pem.elec <= var_pem.cap):'PEMFC Output is limited by the Installed Capacity']; %%%

 % Constraints = [Constraints
 %        (var_pem.elec(1650:end,:) <= .01):'PEMFC Output is limited by the Installed Capacity']; %%%
    if pem_v(4) > 0 %%if minimum power setting exists
        Constraints = [Constraints
            (var_pem.cap.*pem_v(4) - 100.*(1-var_pem.onoff) <= var_pem.elec):'PEMFC Lower Production Limit'
            (var_pem.elec <= 100.*(var_pem.onoff)):'PEM Must be turned on to operate'];
    end
    % (var_el_binary.el_adopt(i)*el_binary_v(4,i) - 100*(1-var_el_binary.el_onoff(:,i)) <= var_el_binary.el_prod(:,i)):'Lower Production Limit'
    %             (var_el_binary.el_prod(:,i) <= 100*(var_el_binary.el_onoff(:,i))):'Electrolyzer must be turned on'];

end