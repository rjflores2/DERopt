%% GSPH Constraints
if ~isempty(gsph_v)  
%     for i=1:K
    Constraints = [Constraints,
            (var_gsph.gsph_gas + var_gsph.gsph_h2 <= repmat(var_gsph.gsph_adopt,size(var_gsph.gsph_gas,1),1)):'Max gas limited by GSPH capacity'];
            
%     end    
end 
