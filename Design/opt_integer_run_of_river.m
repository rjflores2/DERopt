
if ror_integer_on

    Constraints = [Constraints
        (0 <= var_ror_integer.elec <= river_power_potential.*ror_integer_v(3,:).*repmat(var_ror_integer.units,T,1)):'Integer RoR Electricity Limits'
        (0 <= var_ror_integer.units <= ror_integer_v(4,:)):'Integer RoR Installed Units Limits'];
end

