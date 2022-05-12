%% ERSPH Constraints
if ~isempty(ersph_v)  
%     for i=1:K
    Constraints = [Constraints
            (var_ersph.ersph_elec <= repmat(var_ersph.ersph_adopt,size(var_ersph.ersph_elec,1),1)):'Max electricity limited by ERSPH capacity'];
            
%     end    
end 

