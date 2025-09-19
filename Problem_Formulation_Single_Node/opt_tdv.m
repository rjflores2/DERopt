if tdv_on
    Constraints = [Constraints
        ((var_util.import - var_util.export)'*tdv_elec + (var_sofc.electricity'./sofc_v(2))*tdv_gas <= 0):'TDV limit'];

end