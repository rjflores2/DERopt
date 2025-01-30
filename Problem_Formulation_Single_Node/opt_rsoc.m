
if rsoc_on

Constraints = [Constraints 
    (var_rsoc.rsoc_fuel_cell <= rsoc_v(1)*var_rsoc.rsoc_capacity):'RSOC Fuel Cell Energy Balance'
    (var_rsoc.rsoc_electrolyzer <= rsoc_v(1)*var_rsoc.rsoc_capacity):'RSOC Electrolyzer Energy Balance'
    (-rsoc_v(6)*rsoc_v(1)*var_rsoc.rsoc_capacity <= var_rsoc.rsoc_fuel_cell(2:8760) - var_rsoc.rsoc_fuel_cell(1:8760-1) <= rsoc_v(6)*rsoc_v(1)*var_rsoc.rsoc_capacity):'RSOC Fuel Cell Ramp Rate'
    (-rsoc_v(6)*rsoc_v(1)*var_rsoc.rsoc_capacity <= var_rsoc.rsoc_electrolyzer(2:8760) - var_rsoc.rsoc_electrolyzer(1:8760-1) <= rsoc_v(6)*rsoc_v(1)*var_rsoc.rsoc_capacity):'RSOC Electrolyzer Ramp Rate'];
end