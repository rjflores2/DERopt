
if rsoc_on
max_switch = 36;
if (var_rsoc.rsoc_fuel_cell(end) - var_rsoc.rsoc_fuel_cell(end-1)) && (var_rsoc.rsoc_electrolyzer(end - 1) == 0)
    var_rsoc.rsoc_switch = var_rsoc.rsoc_switch + 1;
end

Constraints = [Constraints 
    (var_rsoc.rsoc_fuel_cell/rsoc_v(8) + var_rsoc.rsoc_electrolyzer/rsoc_v(9) <= rsov_v(7)): 'RSOC current density balance'
    % (var_rsoc.rsoc_fuel_cell <= rsoc_v(1)*var_rsoc.rsoc_capacity):'RSOC Fuel Cell Energy Balance'
    % (var_rsoc.rsoc_electrolyzer <= rsoc_v(1)*var_rsoc.rsoc_capacity):'RSOC Electrolyzer Energy Balance'
    (-rsoc_v(6)*rsoc_v(1)*var_rsoc.rsoc_capacity <= var_rsoc.rsoc_fuel_cell(2:end) - var_rsoc.rsoc_fuel_cell(1:end-1) <= rsoc_v(6)*rsoc_v(1)*var_rsoc.rsoc_capacity):'RSOC Fuel Cell Ramp Rate'
    (-rsoc_v(6)*rsoc_v(1)*var_rsoc.rsoc_capacity <= var_rsoc.rsoc_electrolyzer(2:end) - var_rsoc.rsoc_electrolyzer(1:end-1) <= rsoc_v(6)*rsoc_v(1)*var_rsoc.rsoc_capacity):'RSOC Electrolyzer Ramp Rate'
    (var_rsoc.rsoc_switch <= max_switch)];

end 