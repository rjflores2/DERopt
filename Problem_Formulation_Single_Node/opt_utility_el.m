if ~isempty(util_el_v)
    for i = 1:size(util_el_v,2)
        Constraints = [Constraints
            (0 <= var_util_el.el_prod(:,i) <= var_util_el.el_adopt(i).*(1/e_adjust)):'Electrolyzer Min/Max Output' %%%Production is limited by adopted capacity
            (var_util_h2_inject.h2_store(:,i) + var_util_h2_inject.h2_inject(:,i) == var_util_el.el_prod(:,i)):'Electrolyzer output direciton'];
    end
    
    %%%H2 Pipeline Injection
    if util_h2_inject_on
        Constraints = [Constraints
            (var_util_h2_inject.h2_inject + var_util_h2_inject.h2_store <= 1e6*var_util_h2_inject.h2_inject_adopt):'H2 Injection is Adopted'
            (var_util_h2_inject.h2_inject + var_util_h2_inject.h2_store <= var_util_h2_inject.h2_inject_size.*(1/e_adjust)):'H2 Injection Capacity'
            (sum(var_ldg.ldg_dfuel) <= sum(var_util_h2_inject.h2_store)):'Fuel pulled from storage is less than equal what has been stored'];
    end
    
end