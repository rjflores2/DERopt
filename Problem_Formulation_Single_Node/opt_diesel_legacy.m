%%%Legacy generator constraints
if exist('ldiesel_on') && ldiesel_on
    
    Constraints = [Constraints
        (zeros(T,size(ldiesel_v,2)) <= var_legacy_diesel.electricity <= repmat(ldiesel_v(1,:),T,1)):'Legacy Diesel Generator Maximum Output'];
    
end


