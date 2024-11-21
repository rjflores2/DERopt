
if titus_on

Constraints = [Constraints 
    (var_titus.titus_elec <= titus_v(1).*titus_v(2)*var_titus.titus_adopt):'Titus Energy Balance'];
end