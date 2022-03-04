%%% Only initiate variables if critical loads exist

if ~isempty(crit_load_lvl) && crit_load_lvl >0
    
    xfmr_subset_unique = unique(xfmr_subset);
    
    T_res = [1 endpts(end)];
    elec_res = elec_res(T_res(1):T_res(2),:);
    if sim_lvl == 3
        pf = 0.95.*ones(1,size(elec_res,2));
        elec_res_reactive = elec_res.*repmat(tan(acos(pf)),length(elec_res),1);
    end
    
    
    %%% PV exists
    if ~isempty(pv_v) || ~isempty(pv_legacy)
        var_resiliency.pv_elec = sdpvar(T_res(2),K,'full');
        if sim_lvl == 3
            var_resiliency.pv_real = sdpvar(T_res(2),K,'full');
            var_resiliency.pv_reactive = sdpvar(T_res(2),K,'full');
        else
            var_resiliency.pv_real = 0;
            var_resiliency.pv_reactive = 0;
        end
    else
        var_resiliency.pv_elec = zeros(T_res(2),K);
    end
    
    %%%If Storage Exists
    if lees_on || lrees_on || ~isempty(ees_v)
        var_resiliency.ees_chrg = sdpvar(T_res(2),K,'full');
        var_resiliency.ees_dchrg = sdpvar(T_res(2),K,'full');
        
        
        if sim_lvl == 3
            var_resiliency.ees_dchrg_real = sdpvar(T_res(2),K,'full');
            var_resiliency.ees_dchrg_reactive = sdpvar(T_res(2),K,'full');
        else
            var_resiliency.ees_dchrg_real = 0;
            var_resiliency.ees_dchrg_reactive = 0;
        end
        
        var_resiliency.ees_soc = sdpvar(T_res(2),K,'full');
    else
        var_resiliency.ees_chrg = zeros(T_res(2),K);
        var_resiliency.ees_dchrg = zeros(T_res(2),K);
        var_resiliency.ees_soc = zeros(T_res(2),K);
    end
    
    %%%If energy trading is allowed at the transformer level
    if sim_lvl == 2 || sim_lvl == 3
        var_resiliency.import = sdpvar(T_res(2),K,'full'); %%%
        var_resiliency.export = sdpvar(T_res(2),K,'full');
        if sim_lvl == 3
        var_resiliency.import_reactive = sdpvar(T_res(2),K,'full'); %%%
        var_resiliency.export_reactive = sdpvar(T_res(2),K,'full');
        else
            var_resiliency.import_reactive = 0;
            var_resiliency.export_reactive = 0;
        end
            
    else
        var_resiliency.import = zeros(T_res(2),K);
        var_resiliency.export = zeros(T_res(2),K);
    end
    
    %%%If transformers are connected to each other
    if sim_lvl == 3
        N = length(bb_lbl) - 1;
        B = size(branch_bus,1) - 1;
        var_resiliency.Pinj = sdpvar(N,T_res(2),'full'); %kW
        var_resiliency.Qinj = sdpvar(N,T_res(2),'full'); %kW
        var_resiliency.pflow = sdpvar(B,T_res(2),'full');
        var_resiliency.qflow = sdpvar(B,T_res(2),'full');
        var_resiliency.bus_voltage = sdpvar(N,T_res(2),'full');
    else
        var_resiliency.Pinj = zeros(N,T_res(2));
        var_resiliency.pflow = zeros(N,T_res(2));
        var_resiliency.bus_voltage = zeros(N,T_res(2));
    end
    
    
else
    
    var_resiliency.pv_elec = zeros(endpts(2),K);
    var_resiliency.ees_chrg = zeros(endpts(2),K);
    var_resiliency.ees_dchrg = zeros(endpts(2),K);
    var_resiliency.ees_soc = zeros(endpts(2),K);
    var_resiliency.import = zeros(endpts(2),K);
    var_resiliency.export = zeros(endpts(2),K);
    var_resiliency.Pinj = 0;
     var_resiliency.Qinj = 0;
    var_resiliency.pflow = 0;
        var_resiliency.qflow = 0;
    var_resiliency.bus_voltage = 0;
end
