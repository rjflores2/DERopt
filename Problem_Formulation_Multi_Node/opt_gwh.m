%% GWH Constraints
if ~isempty(gwh_v)  
    for i=1:K
    Constraints = [Constraints,
              ((var_gwh.gwh_heat(:,i))/gwh_v(2) == var_gwh.gwh_gas(:,i)):'GWH gas consumption' %%% Gas demand of GWH  
            (var_gwh.gwh_gas(:,i) <= var_gwh.gwh_adopt):'Max gas limited by GWH capacity'];
            
    end    
end 