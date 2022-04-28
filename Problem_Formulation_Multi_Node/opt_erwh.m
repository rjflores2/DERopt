%opt_erwh
% AHRI Directory
%% ERWH Constraints
if ~isempty(ewrh_v) 
    for i=1:K
    Constraints = [Constraints,
              ((var_erwh.erwh_heat(:,i))/ewrh_v(2) == var_erwh.erwh_elec(:,i)):'ERWH electricity consumption' %%% Electricity demand of ERWH  
            ( var_erwh.erwh_elec(:,i) <= var_erwh.erwh_adopt):'Max elec limited by ERWH capacity'];
            
    end    
end 
     