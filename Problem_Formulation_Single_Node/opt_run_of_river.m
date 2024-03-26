
if exist('river_power_potential')
     Constraints = [Constraints
         (var_run_of_river.electricity <= river_power_potential):'Run of River is limited by available resources'];
end
    