%opt_erwh
% AHRI Directory
%% ERWH Constraints
if ~isempty(erwh_v) 
%     for i=1:K
        Constraints = [Constraints
            (var_erwh.erwh_elec <= repmat(var_erwh.erwh_adopt,size(var_erwh.erwh_elec,1),1)):'Max elec limited by ERWH capacity'];        
%     end
end
