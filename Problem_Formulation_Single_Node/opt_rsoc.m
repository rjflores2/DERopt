
if rsoc_on

Constraints = [Constraints 
    (var_rsoc.rsoc_elec <= rsoc_v(1).*rsoc_v(2)*var_rsoc.rsoc_adopt):'rsoc Energy Balance'];
end