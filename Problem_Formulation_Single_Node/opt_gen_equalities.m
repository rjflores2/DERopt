%% General equalities
%% Building Electrical Energy Balances
%%For  all timesteps t
%Vectorized
Constraints = [Constraints
    (sum(var_util.import,2) + sum(var_legacy_diesel.electricity,2) + sum(var_pv.pv_elec,2) + sum(var_ees.ees_dchrg,2) + sum(var_lees.ees_dchrg,2) + sum(var_rees.rees_dchrg,2) + sum(var_ldg.ldg_elec,2) + sum(var_legacy_diesel_binary.electricity,2) + sum(var_lbot.lbot_elec,2) + sum(var_run_of_river.electricity,2) + sum(var_pem.elec,2)  + sum(var_ror_integer.elec,2) + sum(var_wave.electricity,2)+sum(var_rsoc.rsoc_elec, 2)... %%%Production
    ==...
    elec + sum(var_ees.ees_chrg,2) + sum(var_lees.ees_chrg,2) + var_vc.generic_cool./4  + sum(var_lvc.lvc_cool.*vc_cop,2) + sum(el_binary_eff.*var_el_binary.el_prod,2) + sum(el_eff.*var_el.el_prod,2) + sum(h2_chrg_eff.*var_h2es.h2es_chrg,2) + var_util.gen_export + var_hrs.hrs_supply.*hrs_chrg_eff + var_dump.elec_dump):'Electricity Balance']; %%%Demand

%% Heat Balance
if ~isempty(heat) && sum(heat>0)>0
    Constraints = [Constraints
        ((var_boil.boil_fuel + var_boil.boil_rfuel + var_boil.boil_hfuel).*boil_legacy(2) + var_ldg.hr_heat == heat):'Thermal Balance'];
end

%% Cooling Balance
if ~isempty(cool) && sum(cool)>0
    Constraints = [Constraints
        (var_vc.generic_cool + sum(var_ltes.ltes_dchrg,2) + sum(var_lvc.lvc_cool,2) == cool + sum(var_ltes.ltes_chrg,2)):'Cooling Balance'];
    
%     Constraints = [Constraints
%         var_vc.generic_cool + sum(var_ltes.ltes_dchrg,2) + sum(vc_size.*var_lvc.lvc_op,2) == cool + sum(var_ltes.ltes_chrg,2)];
end

%% Chemical ennergy conversion balance - Hydrogen
if ~isempty(el_v) || ~isempty(rel_v) || ~isempty(el_binary_v) || ~isempty(rsoc_v)
    Constraints = [Constraints
       (sum(var_rel.rel_prod,2) + sum(var_el.el_prod,2) + sum(var_el_binary.el_prod,2) + sum(var_rel.rel_prod_wheel,2) + sum(var_el.el_prod_wheel,2) + sum(var_h2es.h2es_dchrg,2) == sum(var_pem.elec./0.5,2) + sum(var_ldg.ldg_hfuel,2) + sum(var_ldg.db_hfire,2) + sum(var_boil.boil_hfuel,2) + sum(var_h2es.h2es_chrg,2) + var_hrs.hrs_supply + var_h2_inject.h2_inject + var_h2_inject.h2_store):'Hydrogen Balance'];

end

%% H2 Transportation
if exist('hrs_on') && hrs_on
    Constraints = [Constraints
    (var_hrs.hrs_supply + var_hrs.hrs_tube == hrs_demand):'HRS Balance'
    var_hrs.hrs_supply <=1.5*max(hrs_demand)*var_hrs.hrs_supply_adopt];
end

%% POWERPLANTS
if (exist('util_solar_on') || exist('util_ees_on')) && (util_solar_on || util_ees_on)
    Constraints = [Constraints
        (sum(var_pp.pp_elec_import,2) + sum(var_util_ees.ees_dchrg,2) + sum(var_utilpv.util_pv_elec,2) + sum(var_util_wind.util_wind_elec,2) == sum(var_pp.pp_elec_wheel,2) + sum(var_pp.pp_elec_wheel_lts,2) + sum(var_pp.pp_elec_export,2) + sum(var_util_ees.ees_chrg,2) + sum(util_el_eff.*var_util_el.el_prod,2)):'PP Electricity Balance'];
    
    if util_pv_wheel_lts
        Constraints = [Constraints
            (sum(el_eff.*var_el.el_prod_wheel,2) + sum(el_eff.*var_rel.rel_prod_wheel,2) == sum(var_pp.pp_elec_wheel_lts,2)):'PP to LTS Wheeling Electricity Balance'];
    end
end

%% SHITTT

% Constraints = [Constraints
%     sum(var_ldg.ldg_hfuel(idx,:),2) + sum(var_ldg.db_hfire(idx,:),2) + sum(var_boil.boil_hfuel(idx,:),2) <= .001
%     sum(var_rel.rel_adopt) + sum(var_el.el_adopt) == 5000*0.6];

% Constraints = [Constraints
% sum(var_rees.rees_adopt) + sum(var_ees.ees_adopt) == 1.1896e+04];