
if rsoc_on

Constraints = [Constraints 
    (var_rsoc.rsoc_fuel_cell <= rsoc_v(1).*rsoc_v(2)*var_rsoc.rsoc_capacity):'RSOC Energy Balance'];
end