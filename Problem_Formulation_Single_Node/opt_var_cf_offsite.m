%% Energy products exported from a power plant
if util_solar_on || util_ees_on
    
    if util_pp_export
        var_pp.pp_elec_export = sdpvar(T,1,'full'); %%%Export from the power plant
    else
        var_pp.pp_elec_export = zeros(T,1);
    end
    
    %%%Can the power plant import power at the local node??
    if util_pp_import
        var_pp.pp_elec_import = sdpvar(T,1,'full'); %%%Import at the power plant
        var_pp.import_state = binvar(T,1,'full'); %%%Import State
    else
        var_pp.pp_elec_import =   zeros(T,1);
        var_pp.import_state = zeros(T,1);
    end
    
    %%%General wheeling potential
    if util_pv_wheel
        var_pp.pp_elec_wheel = sdpvar(T,1,'full');
    else
        var_pp.pp_elec_wheel = zeros(T,1);
    end
    
    %%%Wheeling for long term storage
    if util_pv_wheel_lts
        var_pp.pp_elec_wheel_lts = sdpvar(T,1,'full');
    else
        var_pp.pp_elec_wheel_lts = zeros(T,1);
    end
    
    
    Objective = Objective ...
        + sum((-lmp_util).*var_pp.pp_elec_export) ...
        + sum((lmp_util + 0.015).*var_pp.pp_elec_import) ...
        + sum(t_and_d.*(var_pp.pp_elec_wheel + var_pp.pp_elec_wheel_lts));
else
    var_pp.pp_elec_export = zeros(T,1);
    var_pp.pp_elec_import = zeros(T,1);
    var_pp.pp_elec_wheel = zeros(T,1);
    var_pp.pp_elec_wheel_lts = zeros(T,1);
    var_pp.import_state = zeros(T,1);
end%test
%% Community Scale Solar
if ~isempty(utilpv_v)
    %%% Adopted Utility Scale PV
    var_utilpv.util_pv_adopt = sdpvar(1,size(utilpv_v,2),'full');
    %%% Electricity generated and sent to the grid
    var_utilpv.util_pv_elec = sdpvar(T,size(utilpv_v,2),'full');
    for ii = 1:size(utilpv_v,2)
        Objective = Objective ...
            + sum(M.*utilpv_cap_mod(ii).*utilpv_mthly_debt(ii).*var_utilpv.util_pv_adopt(ii)) ...
            + sum((utilpv_v(3,ii)).*var_utilpv.util_pv_elec);
    end
else
    var_utilpv.util_pv_adopt = 0;
    var_utilpv.util_pv_elec = zeros(T,1);
end
%% Community Scale Wind
if ~isempty(util_wind_v)
    %%% Adopted Utility Scale PV
    var_util_wind.util_wind_adopt = sdpvar(1,size(util_wind_v,2),'full');
    %%% Electricity generated and sent to the grid
    var_util_wind.util_wind_elec = sdpvar(T,size(util_wind_v,2),'full');
    for ii = 1:size(util_wind_v,2)
        Objective = Objective ...
            + sum(M.*util_wind_cap_mod(ii).*util_wind_mthly_debt(ii).*var_util_wind.util_wind_adopt(ii)) ...
            + sum((util_wind_v(2,ii)).*var_util_wind.util_wind_elec);
    end
else
    var_util_wind.util_wind_adopt = 0;
    var_util_wind.util_wind_elec = zeros(T,1);
end

%% Community Scale Storage
if ~isempty(util_ees_v)
    %%%Adopted utility scale EES
    var_util_ees.ees_adopt = sdpvar(1,size(util_ees_v,2),'full');
    %%% Adopted EES SOC
    var_util_ees.ees_soc = sdpvar(T,size(util_ees_v,2),'full');
    %%% Adopted EES Charging
    var_util_ees.ees_chrg = sdpvar(T,size(util_ees_v,2),'full');
    %%% Adopted EES Discharging
    var_util_ees.ees_dchrg = sdpvar(T,size(util_ees_v,2),'full');
    
    for ii = 1:size(util_ees_v,2)
        Objective = Objective ...
            + sum(M*util_ees_cap_mod(ii)*util_ees_mthly_debt(ii)*var_util_ees.ees_adopt(ii)) ...
            + sum( var_util_ees.ees_chrg(:,ii))*util_ees_v(2,ii) ...
            + sum( var_util_ees.ees_dchrg(:,ii))*util_ees_v(3,ii);
    end
    
else
    var_util_ees.ees_adopt = 0;
    var_util_ees.ees_soc = 0;
    var_util_ees.ees_chrg = zeros(T,1);
    var_util_ees.ees_dchrg = zeros(T,1);
end

%% Remote Electrolyzer
if ~isempty(util_el_v)

    %%%Electrolyzer efficiency
    util_el_eff = ones(T,size(el_v,2));
    for ii = 1:size(el_v,2)
        util_el_eff(:,ii) = (1/util_el_v(3,ii)).*util_el_eff(:,ii);
    end
    
       %%%Adoption technologies
    var_util_el.el_adopt = sdpvar(1,size(util_el_v,2),'full');
    %%%Electrolyzer production
    var_util_el.el_prod = sdpvar(T,size(util_el_v,2),'full');
    
    
    for ii = 1:size(util_el_v,2)
        %%%Electrolyzer Cost Functions
        Objective = Objective...
            + sum(M.*util_el_mthly_debt.*var_util_el.el_adopt) ... %%%Capital Cost
            + sum(sum(var_util_el.el_prod).*util_el_v(2,:)); %%%VO&M
    end
    
else
    var_util_el.el_prod = zeros(size(elec(:,1)));
end

%% H2 Pipeline Injection
if util_h2_inject_on
    %%%Adopt HRS Equipment
    var_util_h2_inject.h2_inject_adopt = binvar(1,1,'full');
    %%%Size of adopted HRS Equipment
    var_util_h2_inject.h2_inject_size = sdpvar(1,1,'full');
    
    %%%Injected Hydrogen
    if util_h2_sale
        var_util_h2_inject.h2_inject = sdpvar(T,1,'full');
    else
        var_util_h2_inject.h2_inject = zeros(T,1);
    end
    %%%Stored Hydrogen
    if util_h2_pipe_store
        var_util_h2_inject.h2_store = sdpvar(T,1,'full');
    else
        var_util_h2_inject.h2_store = zeros(T,1);
    end
    
    
    Objective = Objective ...
        + M*util_h2_inject_mthly_debt(1)*var_util_h2_inject.h2_inject_adopt ...
        + M*util_h2_inject_mthly_debt(2)*var_util_h2_inject.h2_inject_size ...
        - ng_inject.*sum(var_util_h2_inject.h2_inject) ...
        + rng_storage_cost.*sum(var_util_h2_inject.h2_store);
else
    var_util_h2_inject.h2_inject = zeros(T,1);
    var_util_h2_inject.h2_inject_size = 0;
    var_util_h2_inject.h2_inject_adopt = 0;
    var_util_h2_inject.h2_store = zeros(T,1);
end