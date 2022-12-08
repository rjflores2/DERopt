%% Gas Water Heater Constraints
if ~isempty(gwh_v)
    %     for i=1:K
    Constraints = [Constraints
        (var_gwh.gwh_gas + var_gwh.gwh_h2 <= repmat(var_gwh.gwh_adopt,size(var_gwh.gwh_gas,1),1)):'Max gas limited by GWH capacity'];
    
    %     end
end