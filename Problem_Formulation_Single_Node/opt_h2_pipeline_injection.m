%%%H2 Pipeline Injection
if h2_inject_on
    Constraints = [Constraints
        (var_h2_inject.h2_inject + var_h2_inject.h2_store <= 1e6*var_h2_inject.h2_inject_adopt):'H2 Injection is Adopted'
        (var_h2_inject.h2_inject + var_h2_inject.h2_store <= var_h2_inject.h2_inject_size.*(1/e_adjust)):'H2 Injection Capacity'
        (sum(var_ldg.ldg_sfuel) <= sum(var_h2_inject.h2_store)):'Fuel pulled from storage is less than equal what has been stored'];
end