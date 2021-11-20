%% General equalities
%% Building Electrical Energy Balances
%%For  all timesteps t
%Vectorized
Constraints = [Constraints
    (var_sales.wholesale_import + sum(var_ldg.ldg_elec,2) + sum(var_lbot.lbot_elec,2) ... %%%Generation & Imports
    == ...
    var_sales.wholesale_export):'Electricity Balance'];%%%Exports 