if exist('sofc_on') && sofc_on

    Constraints = [Constraints
        (0 <= var_sofc.capacity):'SOFC Capacit>0'
        (0 <= var_sofc.electricity):'SOFC Output>0'];

    if sofc_v(7) > 0 %Forced Adoption
        1
        Constraints = [Constraints
            (var_sofc.capacity == sofc_v(7)):'Forced SOFC Adoption']
    end

    if sofc_v(5) > 0 %Minimum Load
        2
        Constraints = [Constraints
            (var_sofc.capacity.*sofc_v(5) <= var_sofc.electricity <= var_sofc.capacity):'SOFC Operational Limits'];
    else
        Constraints = [Constraints
            (var_sofc.electricity == var_sofc.capacity):'SOFC Operational Limits'];
    end
    if sofc_v(6) > 0 %Limited SOFC Capacity
        3
        Constraints = [Constraints
            (var_sofc.capacity <= sofc_v(6)):'Limit on SOFC Adoption'];
    end


    % Constraints = [Constraints
    %     0 <= var_sofc.adopted_sofc
    %     0 <= var_sofc.sofc_operational_state
    %     0 <= var_sofc.sofc_electricity
    %     var_sofc.sofc_operational_state <=  var_sofc.adopted_sofc
    %     var_sofc.sofc_electricity <= var_sofc.operational_state*fuel_cell_capacity];


    %%%%Plug into opt_gen_eqalities
% Constraints = [Constraints
%     generation + var_sofc.sofc_electricity == loads]

end