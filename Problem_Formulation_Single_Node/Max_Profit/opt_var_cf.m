%% Declaring decision variables and setting up cost function
yalmip('clear')
clear var*
Constraints=[];

T = length(time);     %t-th time interval from 1...T
M = length(endpts);   %# of months in the simulation

% Objective = [];

%% General import & export

%%% Wholesale export on the day ahead market
var_sales.wholesale_export = sdpvar(T,1,'full');

%%% Wholesale import on the day ahead market
if wholesale_import
    var_sales.wholesale_import = sdpvar(T,1,'full');
else
    var_sales.wholesale_import = zeros(T,1);
end

Objective = -whl_sale_da'*var_sales.wholesale_export ... %%%Wholesale exports
    + whl_sale_da'*var_sales.wholesale_import; %%%Wholesale Imports


%% Legacy generator
if ~isempty(dg_legacy)
    %%%DG Electrical Output
    var_ldg.ldg_elec = sdpvar(T,size(dg_legacy,2),'full');
    %%%DG Fuel Input
    var_ldg.ldg_fuel = sdpvar(T,size(dg_legacy,2),'full');
    %%%Generator On/Off State
    var_ldg.ldg_onoff = binvar(T,size(dg_legacy,2),'full');
    
    %%%DG Renewable Fuel Input
    if ~isempty(biogas_limit)
        var_ldg.ldg_rfuel = sdpvar(T,size(dg_legacy,2),'full');
    else
        var_ldg.ldg_rfuel = zeros(T,size(dg_legacy,2));
    end
    
    %     %%%If hydrogen production is an option
    %     if ~isempty(el_v) || ~isempty(rel_v)
    %         var_ldg.ldg_hfuel = sdpvar(T,size(dg_legacy,2),'full');
    %     else
    %         var_ldg.ldg_hfuel = zeros(T,1);
    %     end
    
    %%%DG Fuel that has been stored in the pipeline
    if h2_inject_on
        var_ldg.ldg_sfuel = sdpvar(T,size(dg_legacy,2),'full');
    else
        var_ldg.ldg_sfuel = zeros(T,size(dg_legacy,2));
    end
    %%%DG On/Off State - Number of variables is equal to:
    %%% (Time Instances) / On/Off length
    %     (dg_legacy(end,i)/t_step)
    %     ldg_off=binvar(ceil(length(time)/(dg_legacy(end,i)/t_step)),K,'full');
    %     var_ldg.ldg_off = [];
    
    
    
    for ii = 1:size(dg_legacy,2)
        Objective=Objective ...
            + sum(var_ldg.ldg_elec(:,ii))*dg_legacy(1,ii) ...
            + sum(var_ldg.ldg_fuel(:,ii))*ng_cost ...
            + sum(var_ldg.ldg_rfuel(:,ii))*rng_cost;
    end
    
    %%%If including cycling costs
    if ~isempty(dg_legacy_cyc)
       
        %%%Startup Costs
        if ~isempty(dg_legacy_cyc) && sum(dg_legacy_cyc(1,:)) > 0 %%%Only include if cycling costs is nonzero
            var_ldg.ldg_start = sdpvar(T - 1,size(dg_legacy,2),'full');
            
            for ii = 1:size(dg_legacy_cyc,2)
                Objective=Objective ...
                    + sum(sum(var_ldg.ldg_start(:,2)).*dg_legacy_cyc(2,ii).*(dg_legacy(2,ii) + sum(bot_legacy(2,:))/size(dg_legacy,2)));
            end
        else
            var_ldg.ldg_start = [];
        end
        
        %%%Ramping costs
        if ~isempty(dg_legacy_cyc) && sum(dg_legacy_cyc(2,:)) > 0 %%%Only include if cycling costs is nonzero
            var_ldg.ldg_elec_ramp = sdpvar(T - 1,size(dg_legacy,2),'full');
            
            Objective=Objective ...
                + sum(sum(var_ldg.ldg_elec_ramp).*dg_legacy_cyc(2,:));
        else
            var_ldg.ldg_elec_ramp = [];
        end
    else
        var_ldg.ldg_elec_ramp = [];
    end
    
    
    %%%If abandon GT is possible
    if ldg_off
        var_ldg.ldg_off = binvar(1,size(dg_legacy,2),'full');
    else
        var_ldg.ldg_off = zeros(1,size(dg_legacy,2));
    end
    
else
    var_ldg.ldg_elec = zeros(T,1);
    var_ldg.ldg_rfuel = zeros(T,1);
    var_ldg.ldg_hfuel = zeros(T,1);
    var_ldg.ldg_sfuel = zeros(T,1);
    var_ldg.ldg_fuel = [];
    var_ldg.ldg_off = [];
    var_ldg.ldg_off = 1;
    var_ldg.ldg_elec_ramp = [];
end

%% Legacy bottoming systems
%%%Bottoming generator is any electricity producing device that operates
%%%based on heat recovered from another generator

if ~isempty(bot_legacy)
    %%%Bottom electrical output
    var_lbot.lbot_elec = sdpvar(T,size(bot_legacy,2),'full');
    %%%Bottom operational state
    var_lbot.lbot_on = binvar(T,size(bot_legacy,2),'full');
    
    %%%Bottoming cycle
    for i=1:size(bot_legacy,2)
        Objective=Objective+var_lbot.lbot_elec(:,1)'*(bot_legacy(1,i)*ones(length(time),1));%%%Bottoming cycle O&M
    end
else
    var_lbot.lbot_elec = zeros(T,1);
    var_lbot.lbot_on = zeros(T,1);
end
%% Duct Burner
%%%If duct burner or HR heating source is available
if ~isempty(db_legacy)
    %%%Duct burner - Conventional
    var_ldg.db_fire=sdpvar(T,size(db_legacy,2),'full');
    %%%Duct burner - Renewable
    var_ldg.db_rfire=sdpvar(T,size(db_legacy,2),'full');
    
    %%%If hydrogen production is an option
%     if ~isempty(el_v) || ~isempty(rel_v)
%         var_ldg.db_hfire = sdpvar(T,size(dg_legacy,2),'full');
%     else
        var_ldg.db_hfire = zeros(T,1);
%     end
    
    for ii = 1:size(db_legacy,2)
        %%%Duct burner and renewable duct burner
        Objective=Objective ...
            + var_ldg.db_fire'*((db(1,ii)+ng_cost)*ones(length(time),1)) ...
            + var_ldg.db_rfire'*((db(1,ii)+rng_cost)*ones(length(time),1)) ...
            + var_ldg.db_hfire'*((db(1,ii)+rng_cost)*ones(length(time),1));
    end
else
    var_ldg.db_fire = zeros(T,1);
    var_ldg.db_rfire = zeros(T,1);
    var_ldg.db_hfire = zeros(T,1);
end
%% Dump Variables
%%%These variables should always be zero and are nonzero when you ahve a
%%%poorly conceived problem
if ~isempty(elec_dump)
    var_dump.elec_dump = sdpvar(T,1,'full');
else
    var_dump.elec_dump = zeros(T,1);
end
