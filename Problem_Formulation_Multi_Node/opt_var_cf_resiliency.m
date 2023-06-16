%%% Only initiate variables if critical loads exist

if ~isempty(crit_load_lvl) && crit_load_lvl >0
    
    xfmr_subset_unique = unique(xfmr_subset);
    
    %     T_res = [1 endpts(end)];
    if downselection == 2
        T_res = [1 24*14];
    end
    elec_res = elec_res(T_res(1):T_res(2),:);
    if sim_lvl == 3
        pf = 0.95.*ones(1,size(elec_res,2));
        elec_res_reactive = elec_res.*repmat(tan(acos(pf)),size(elec_res,1),1);
    end
    
    
    
    %%% PV exists
    if ~isempty(pv_v) || ~isempty(pv_legacy)
        var_resiliency.pv_elec = sdpvar(size(elec_res,1),K,'full');
        if sim_lvl == 3
            var_resiliency.pv_real = sdpvar(size(elec_res,1),K,'full');
            var_resiliency.pv_reactive = sdpvar(size(elec_res,1),K,'full');
        else
            var_resiliency.pv_real = 0;
            var_resiliency.pv_reactive = 0;
        end
    else
        var_resiliency.pv_elec = zeros(size(elec_res,1),K);
    end

%%% DGB exists
    if ~isempty(dgb_v) 
        var_resiliency.dgb_elec = sdpvar(size(elec_res,1),K,'full');
        if sim_lvl == 3
            var_resiliency.dgb_real = sdpvar(size(elec_res,1),K,'full');
            var_resiliency.dgb_reactive = sdpvar(size(elec_res,1),K,'full');
        else
            var_resiliency.dgb_real = 0;
            var_resiliency.dgb_reactive = 0;
        end
    else
        var_resiliency.dgb_elec = zeros(size(elec_res,1),K);
        var_resiliency.dgb_real = 0;
            var_resiliency.dgb_reactive = 0;
    end
    
    %%% DGC exists
    if ~isempty(dgc_v) 
        var_resiliency.dgc_elec = sdpvar(size(elec_res,1),K,'full');
        if sim_lvl == 3
            var_resiliency.dgc_real = sdpvar(size(elec_res,1),K,'full');
            var_resiliency.dgc_reactive = sdpvar(size(elec_res,1),K,'full');
        else
            var_resiliency.dgc_real = 0;
            var_resiliency.dgc_reactive = 0;
        end
    else
        var_resiliency.dgc_elec = zeros(size(elec_res,1),K);
        var_resiliency.dgc_real = 0;
            var_resiliency.dgc_reactive = 0;
    end
    
    %%%If Storage Exists
    if lees_on || lrees_on || ~isempty(ees_v)
        var_resiliency.ees_chrg = sdpvar(size(elec_res,1),K,'full');
        var_resiliency.ees_dchrg = sdpvar(size(elec_res,1),K,'full');
        
        
        if sim_lvl == 3
            var_resiliency.ees_dchrg_real = sdpvar(size(elec_res,1),K,'full');
            var_resiliency.ees_dchrg_reactive = sdpvar(size(elec_res,1),K,'full');
        else
            var_resiliency.ees_dchrg_real = 0;
            var_resiliency.ees_dchrg_reactive = 0;
        end
        
        var_resiliency.ees_soc = sdpvar(size(elec_res,1),K,'full');
    else
        var_resiliency.ees_chrg = zeros(size(elec_res,1),K);
        var_resiliency.ees_dchrg = zeros(size(elec_res,1),K);
        var_resiliency.ees_soc = zeros(size(elec_res,1),K);
    end
    
    %%%If energy trading is allowed at the transformer level
    if sim_lvl == 2 || sim_lvl == 3
        var_resiliency.import = sdpvar(size(elec_res,1),K,'full'); %%%
        var_resiliency.export = sdpvar(size(elec_res,1),K,'full');
        if sim_lvl == 3
        var_resiliency.import_reactive = sdpvar(size(elec_res,1),K,'full'); %%%
        var_resiliency.export_reactive = sdpvar(size(elec_res,1),K,'full');
        else
            var_resiliency.import_reactive = 0;
            var_resiliency.export_reactive = 0;
        end
            
    else
        var_resiliency.import = zeros(size(elec_res,1),K);
        var_resiliency.export = zeros(size(elec_res,1),K);
    end
    
    %%%If transformers are connected to each other
    if sim_lvl == 3
        N = length(bb_lbl) - 1;
        B = size(branch_bus,1) - 1;
        var_resiliency.Pinj = sdpvar(N,size(elec_res,1),'full'); %kW
        var_resiliency.Qinj = sdpvar(N,size(elec_res,1),'full'); %kW
        var_resiliency.pflow = sdpvar(B,size(elec_res,1),'full');
        var_resiliency.qflow = sdpvar(B,size(elec_res,1),'full');
        var_resiliency.bus_voltage = sdpvar(N,size(elec_res,1),'full');
    else
        var_resiliency.Pinj = zeros(1,size(elec_res,1));
         var_resiliency.Qinj = zeros(1,size(elec_res,1))
        var_resiliency.pflow = zeros(1,size(elec_res,1));
        var_resiliency.qflow = zeros(1,size(elec_res,1));
        var_resiliency.bus_voltage = zeros(1,size(elec_res,1));
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
