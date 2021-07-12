%% RSOC Constraints
if ~isempty(rsoc_v)
    Constraints = [Constraints
        sum(rsoc_v(5).*var_rsoc.rsoc_elec,2) + sum(var_rsoc.rsoc_prod,2) ...
        <= sum(var_rsoc.rsoc_adopt,2)];
end
