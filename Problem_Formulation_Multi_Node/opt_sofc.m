%% SOFC Constraints
if ~isempty(sofc_v) 
    for i=1:K
    Constraints = [Constraints,
              ((sofc_v(4)*var_sofc.sofc_elec(:,i))/sofc_v(3) == var_sofc.sofc_heat(:,i)):'SOFC Heat Generation' %%% Cogenerated heat by SOFC 
            ( var_sofc.sofc_elec(:,i) <= var_sofc.sofc_adopt):'Max/Min elec limited by SOFC capacity'];
            
    end    
end 
% ((sofc_v(3)*var_sofc.sofc_elec(:,i)) == var_sofc.sofc_fuel(:,i)):'SOFC Fuel Consmuption' %%% SOFC fuel consumption to produce electricity + heat
          