%% SOFCWH Constraints
if ~isempty(sofcwh_v) 
    for i=1:K
    Constraints = [Constraints,
               (var_sofcwh.sofcwh_wasteheat(:,i) == var_sofc.sofc_heat(:,i)-var_sofcwh.sofcwh_heat(:,i)):'Unused heat from SOFC' 
               (var_sofcwh.sofcwh_heat(:,i) <= var_sofc.sofc_heat(:,i)):'Max heat limited by SOFC capacity']; %the heat used for water heating cannot be more than available heat from SOFC at that moment
    end    
end