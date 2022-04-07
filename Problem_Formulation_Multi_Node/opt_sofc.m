%% SOFC Constraints
if ~isempty(sofc_v) 
    for i=1:K
    Constraints = [Constraints,
            ((sofc_v(3)*var_sofc.sofc_elec(:,i)) == var_sofc.sofc_fuel(:,i)):'SOFC Fuel Consmuption' %%% SOFC fuel consumption to produce electricity + heat
            ((sofc_v(4)*var_sofc.sofc_elec(:,i)) == var_sofc.sofc_heat(:,i)):'SOFC Heat Generation' %%% Cogenerated heat by SOFC 
            (0< var_sofc.sofc_elec(:,i) <= var_sofc.sofc_adopt):'Max/Min elec limited by SOFC capacity'];
            
    end    
end 
