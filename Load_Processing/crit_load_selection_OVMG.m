%%% Determining what part of the year to examine for critical load
%%% development
if ~isempty(crit_load_lvl) && crit_load_lvl > 0
    %%%Length of resiliency model
    days_include = 7;
    res_loads = [];
    for ii = 1:floor(8760/(24*days_include))
        strt_id = (ii-1)*24*days_include+1;
        end_id = (ii)*24*days_include;
        
        if end_id >8760
            end_id = 8760;
        end
        res_loads(ii,:) = [sum(sum(elec_res(strt_id:end_id,:))) sum(legacy.solar(strt_id:end_id))];
    end
    
    %%% Solar Required to meet energy demand
    res_loads(:,3) = res_loads(:,1)./res_loads(:,2);
    
    [~,res_time_idx] = max(res_loads(:,3));
    
    T_res = [(res_time_idx-1)*24*days_include+1  (res_time_idx)*24*days_include];
end