%% GSPH Constraints
if ~isempty(gsph_v)  
    for i=1:K
    Constraints = [Constraints,
              ((var_gsph.gsph_heat(:,i))/gsph_v(2) == var_gsph.gsph_gas(:,i)):'GSPH gas consumption' %%% Gas demand of gas space heater 
            (var_gsph.gsph_gas(:,i) <= var_gsph.gsph_adopt):'Max gas limited by GSPH capacity'];
            
    end    
end 
