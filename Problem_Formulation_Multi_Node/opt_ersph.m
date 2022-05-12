%% ERSPH Constraints
if ~isempty(ersph_v)  
    for i=1:K
    Constraints = [Constraints,
              ((var_ersph.ersph_heat(:,i))/ersph_v(2) == var_ersph.ersph_elec(:,i)):'ERSPH electricity consumption' %%% Electricity demand of electric space heater 
            (var_ersph.ersph_elec(:,i) <= var_ersph.ersph_adopt):'Max electricity limited by ERSPH capacity'];
            
    end    
end 

