%%% Only initiate variables if critical loads exist
if ~isempty(crit_load_lvl) && crit_load_lvl >0
    
    T_res = [1 endpts(2)];
    
    elec_res = elec_res(T_res(1):T_res(2),:);
    %%% PV exists
    if ~isempty(pv_v) || ~isempty(pv_legacy)
        var_resiliency.pv_elec = sdpvar(T_res(2),K,'full');
    else
        var_resiliency.pv_elec = zeros(T_res(2),K);
    end
    
    %%%If Storage Exists
    if lees_on || lrees_on || ~isempty(ees_v)
        var_resiliency.ees_chrg = sdpvar(T_res(2),K,'full');
        var_resiliency.ees_dchrg = sdpvar(T_res(2),K,'full');
        var_resiliency.ees_soc = sdpvar(T_res(2),K,'full');
    else
        var_resiliency.ees_chrg = zeros(T_res(2),K);
        var_resiliency.ees_dchrg = zeros(T_res(2),K);
        var_resiliency.ees_soc = zeros(T_res(2),K);
    end
else
    
    var_resiliency.pv_elec = zeros(endpts(2),K);
    var_resiliency.ees_chrg = zeros(endpts(2),K);
    var_resiliency.ees_dchrg = zeros(endpts(2),K);
    var_resiliency.ees_soc = zeros(endpts(2),K);
end