%%%Legacy generator constraints
if exist('ldiesel_binary_on') && ldiesel_binary_on
    
    Constraints = [Constraints
        (ldiesel_binary_v(1).*ldiesel_binary_v(4).*var_legacy_diesel_binary.operational_state <= var_legacy_diesel_binary.electricity <= ldiesel_binary_v(1).*var_legacy_diesel_binary.operational_state):'Legacy Diesel Generator Maximum Output'];
    
end


