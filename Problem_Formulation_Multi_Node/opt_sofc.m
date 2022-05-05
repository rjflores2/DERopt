%% SOFC Constraints
if ~isempty(sofc_v) 
    for i=1:K
    Constraints = [Constraints,
              ((sofc_v(4)*var_sofc.sofc_elec(:,i))/sofc_v(3) == var_sofc.sofc_heat(:,i)):'SOFC Heat Generation' %Cogenerated heat by SOFC 
              (var_sofc.sofc_elec(:,i) <= var_sofc.sofc_adopt):'Max elec limited by SOFC capacity'    % capacity limit
              (var_sofc.sofc_wh(:,i) <= var_sofc.sofc_heat(:,i)):'Max heat limited by SOFC capacity'];  %the heat used for water heating cannot be more than available heat from CHP_SOFC
              %(var_sofc.sofc_adopt == sofc_v(5)* var_sofc.sofc_number):'SOFC units multiples of 0.5 kw']; %500 watt increments
    end    
end 
% ((sofc_v(3)*var_sofc.sofc_elec(:,i)) == var_sofc.sofc_fuel(:,i)):'SOFC Fuel Consmuption' %%% SOFC fuel consumption to produce electricity + heat
          