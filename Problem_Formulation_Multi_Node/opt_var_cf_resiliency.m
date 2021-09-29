%%% Only initiate variables if critical loads exist
if ~isempty(crit_tier)
    
    %%% PV exists
    if ~isempty(pv_v) || ~isempty(pv_legacy)
        var_resiliency.pv_elec = sdpvar(T,K,'full');
    else
        var_resiliency.pv_elec = zeros(T,K);
    end
    
    %%%If Storage Exists
    if lees_on || lrees_on || ~isempty(ees_v)
        var_resiliency.ees_chrg = sdpvar(T,K,'full');
        var_resiliency.ees_dchrg = sdpvar(T,K,'full');
        var_resiliency.ees_soc = sdpvar(T,K,'full');
    else
        var_resiliency.ees_chrg = zeros(T,K);
        var_resiliency.ees_dchrg = zeros(T,K);
        var_resiliency.ees_soc = zeros(T,K);
    end
else
    
    var_resiliency.pv_elec = zeros(T,K);
    var_resiliency.ees_chrg = zeros(T,K);
    var_resiliency.ees_dchrg = zeros(T,K);
    var_resiliency.ees_soc = zeros(T,K);
end