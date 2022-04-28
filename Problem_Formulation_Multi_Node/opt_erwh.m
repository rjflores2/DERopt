%opt_erwh
% AHRI Directory
%% ERWH Constraints
if ~isempty(erwh_v) 
    for i=1:K
    Constraints = [Constraints,
              ((var_erwh.erwh_heat(:,i))/erwh_v(2) == var_erwh.erwh_elec(:,i)):'ERWH electricity consumption' %%% Electricity demand of ERWH  
            ( var_erwh.erwh_elec(:,i) <= var_erwh.erwh_adopt):'Max elec limited by ERWH capacity'];
            
    end    
end 
     