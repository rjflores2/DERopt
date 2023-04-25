
%% Optimize thru CPLEX
if opt_now==1
    
    %% Export Model YALMIP -> CPLEX
    tic
    [model,recoverymodel,diagnostic,internalmodel] = export(Constraints,Objective,sdpsettings('solver','cplex'));
    elapsed = toc;
    fprintf('Model Export took %.2f seconds \n', elapsed)
    
    %% Other limits and settings
    
    %%%Setting lower/upper bounds for all variables
    lb=zeros(size(model.f));
    ub=inf(size(lb));
    
    %%%Solver settings
    ops = sdpsettings('solver','cplex','verbose',1)
    
    %%% Finding location of carbon constraing in model.bineq
    %%%CO2 limit index
    co2_lim_idx = find(model.bineq == co2_lim);
    
    %% Loop to rerun optimization
    
    for ii = 1:length(co2_red)
        
        %%%Empty out any prior solver results
        clear x fval exitflag output
        
        %%%If this is not the 1st iteration, update the CO2 limit
        if ii > 1
            model.bineq(co2_lim_idx) = co2_base*(1-co2_red(ii));
        end
        
        x = [];
        
        fprintf('%s Starting CPLEX Solver \n', datestr(now,'HH:MM:SS'))
        tic
        
        %  [x, fval, exitflag, output, lambda] = cplexlp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, lb, ub, [], options);
        
        if sum(strfind(model.ctype,'B')>0) + sum(strfind(model.ctype,'I')>0)
            
            opt_cplexmilp = 1
            [x, fval, exitflag, output] = cplexmilp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, [],[],[],lb,ub,model.ctype,x,ops);
        else
            opt_cplexlp = 1
            [x, fval, exitflag, output, lambda] = cplexlp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, lb, ub, [], ops);
        end
        
        elapsed = toc;
        fprintf('CPLEX took %.2f seconds \n', elapsed)
        
        % Recovering data and assigning to the YALMIP variables
        assign(recover(recoverymodel.used_variables),x)
        %     cplex = Cplex(model); %instantiate object cplex of class Cplex
        %     cplex.solve() %metod solve() to create Solution dynamic property
        %     cplex.Solution.status
        %     cplex.Solution.miprelgap
        %% Starting Recorder Structure - Model Outputs
        rec.solver.x(ii,:) = x;
        rec.solver.fval(ii,1) = fval;
        rec.solver.exitflag(ii,1) = exitflag;
        rec.solver.output(ii,1) = output;
        
        %% Optimized Variables -  Utilities
        
        %%% Utility Variables
        rec.utility.import(:,ii) = value(var_util.import);
        rec.utility.nontou_dc(:,ii) = value(var_util.nontou_dc);
        rec.utility.onpeak_dc(:,ii) = value(var_util.onpeak_dc);
        rec.utility.midpeak_dc(:,ii) = value(var_util.midpeak_dc);
        rec.utility.gen_export(:,ii) = value(var_util.gen_export);
        
        %% Optimized Variables - New Technologies
        %%% Solar Variables
        rec.solar.pv_adopt(:,ii) = value(var_pv.pv_adopt);
        rec.solar.pv_elec(:,ii) = value(var_pv.pv_elec);
        rec.solar.pv_nem(:,ii) = value(var_pv.pv_nem);
        
        %%% Electrical Energy Storage
        rec.ees.ees_adopt(:,ii) = value(var_ees.ees_adopt);
        rec.ees.ees_chrg(:,ii) = value(var_ees.ees_chrg);
        rec.ees.ees_dchrg(:,ii) = value(var_ees.ees_dchrg);
        rec.ees.ees_soc(:,ii) = value(var_ees.ees_soc);
        
        %%% Renewable Electrical Energy Storage
        rec.rees.rees_adopt(:,ii) = value(var_rees.rees_adopt);
        rec.rees.rees_chrg(:,ii) = value(var_rees.rees_chrg);
        rec.rees.rees_dchrg(:,ii) = value(var_rees.rees_dchrg);
        rec.rees.rees_soc(:,ii) = value(var_rees.rees_soc);
        rec.rees.rees_dchrg_nem(:,ii) = value(var_rees.rees_dchrg_nem);
        
        %%% H2 Production - Electrolyzer
        rec.el.el_adopt(:,ii) = value(var_el.el_adopt);
        rec.el.el_prod(:,ii) = value(var_el.el_prod);
        
        %%% H2 Production - Renewable Electrolyzer
        rec.rel.rel_adopt(:,ii) = value(var_rel.rel_adopt);
        rec.rel.rel_prod(:,ii) = value(var_rel.rel_prod);
        rec.rel.rel_prod_wheel(:,ii) = value(var_rel.rel_prod_wheel);
        
        %%% H2 Production - Storage
        rec.h2es.h2es_adopt(:,ii) = value(var_h2es.h2es_adopt);
        rec.h2es.h2es_chrg(:,ii) = value(var_h2es.h2es_chrg);
        rec.h2es.h2es_dchrg(:,ii) = value(var_h2es.h2es_dchrg);
        rec.h2es.h2es_soc(:,ii) = value(var_h2es.h2es_soc);
        rec.h2es.h2es_bin(:,ii) = value(var_h2es.h2es_bin);
        %% Optimized Variables -  Legacy technologies %%
        %% DG - Topping Cycle
        rec.ldg.ldg_elec(:,ii) = value(var_ldg.ldg_elec);
        rec.ldg.ldg_fuel(:,ii) = value(var_ldg.ldg_fuel);
        rec.ldg.ldg_rfuel(:,ii) = value(var_ldg.ldg_rfuel);
        rec.ldg.ldg_hfuel(:,ii) = value(var_ldg.ldg_hfuel);
        rec.ldg.ldg_sfuel(:,ii) = value(var_ldg.ldg_sfuel);
        rec.ldg.ldg_dfuel(:,ii) = value(var_ldg.ldg_dfuel);
        rec.ldg.ldg_elec_ramp(:,ii) = value(var_ldg.ldg_elec_ramp);
        % var_ldg.ldg_off(:,ii) = value(var_ldg.ldg_off);
        rec.ldg.ldg_opstate(:,ii) = value(var_ldg.ldg_opstate);
        %% Bottoming Cycle
        rec.lbot.lbot_elec(:,ii) = value(var_lbot.lbot_elec);
        rec.lbot.lbot_on(:,ii) = value(var_lbot.lbot_on);
        
        %% Heat Recovery Systems
        rec.ldg.hr_heat(:,ii) = value(var_ldg.hr_heat);
        rec.ldg.db_fire(:,ii) = value(var_ldg.db_fire);
        rec.ldg.db_rfire(:,ii) = value(var_ldg.db_rfire);
        rec.ldg.db_hfire(:,ii) = value(var_ldg.db_hfire);
        
        %% Boiler
        rec.boil.boil_fuel(:,ii) = value(var_boil.boil_fuel);
        rec.boil.boil_rfuel(:,ii) = value(var_boil.boil_rfuel);
        rec.boil.boil_hfuel(:,ii) = value(var_boil.boil_hfuel);
        
        %% EES
        if ~isempty(ees_legacy)
            rec.lees.ees_chrg(:,ii) = value(var_lees.ees_chrg);
            rec.lees.ees_dchrg(:,ii) = value(var_lees.ees_dchrg);
            rec.lees.ees_soc(:,ii) = value(var_lees.ees_soc);
        end
        
        %% Carbon Emissions
        %%%Carbon emissions from 1) utility electiricity, 2) natural gas,
        %%%3) renewable natural gas
        rec.co2_emissions(1:3,ii) = [sum(rec.utility.import(:,ii).*co2_import)
            co2_ng*(sum(sum(rec.ldg.ldg_fuel(:,ii))) + sum(sum(rec.ldg.db_fire)) + sum(sum(rec.boil.boil_fuel)))
            co2_rng*(sum(sum(rec.ldg.ldg_rfuel)) + sum(sum(rec.ldg.db_rfire)) + sum(sum(rec.boil.boil_rfuel)))]';
       %%%Total carbon emissions
        rec.co2_emissions(4,ii) =   sum(rec.co2_emissions(1:3,ii));
        
        %%% Percent reduciton
        rec.co2_emissions_red(1,ii) = 100.*(rec.co2_emissions(4,1) - rec.co2_emissions(4,ii))./rec.co2_emissions(4,1);
        %% Financials
        %%%($/kWh)
        rec.financials.lcoe(ii,1) = rec.solver.fval(ii,1)./sum(elec)
        
        %%%Bulk cost of carbon ($/tonne)
        rec.financials.cost_of_co2(ii,1) = abs((rec.solver.fval(ii,1) - rec.solver.fval(1,1))/((rec.co2_emissions(4,ii) - rec.co2_emissions(4,1))./1000));
        
        %%%Marginal cost of carbon ($/tonne)
        if ii > 1
        rec.financials.cost_of_co2_marginal(ii,1) = abs((rec.solver.fval(ii,1) - rec.solver.fval(ii-1,1))/((rec.co2_emissions(4,ii) - rec.co2_emissions(4,ii-1))./1000));
        else 
            rec.financials.cost_of_co2_marginal(ii,1) = NaN;
        end
        
        %%%Capital Cost Requirements
        rec.financials.cap_cost(ii,:) = [rec.solar.pv_adopt(:,ii).*pv_cap*pv_cap_mod
            rec.ees.ees_adopt(:,ii).*ees_cap.*ees_cap_mod
            rec.rees.rees_adopt(:,ii).*ees_cap.*rees_cap_mod
            rec.el.el_adopt(:,ii).*el_cap.*el_cap_mod
            rec.rel.rel_adopt(:,ii).*el_cap.*rel_cap_mod
            rec.h2es.h2es_adopt(:,ii).*h2es_cap];
            
        %% Resetting CO2 baseline limit
        %%%If economic operation yields lower emissions than the initial
        %%%estimate
        if ii == 1 && rec.co2_emissions(4,ii) < co2_base
            %%%Then set "co2_base" variable to the economic dispatch level
            co2_base = rec.co2_emissions(4,ii);
        end
    end
    
    return
end


%% Optimize thru YALMIP
if opt_now_yalmip==1  
%% Lower Bound Constraints
%Variables that need to be positive 
  
  Constraints=[Constraints
            0 <= nontou_dc
            0 <= onpeak_dc
            0 <= midpeak_dc
            0 <= import
            ];
        
  if isempty(pv_v) ==0
  Constraints=[Constraints
            0 <= pv_elec
            0 <= pv_nem
            0 <= pv_wholesale
            0 <= pv_adopt <= 99999 %Big M limits
 %           3 <= pv_adopt <= 99999 % Limits for semivar
            ];
  end
  
  if isempty(ees_v) ==0
  Constraints=[Constraints
            0 <= rees_adopt <= 99999 %Big M limits
%            13.5 <= rees_adopt <= 99999 %Limits for semivar
            0 <= rees_chrg
            0 <= rees_dchrg
            0 <= rees_dchrg_nem
            0 <= rees_soc 
            0 <= ees_adopt <= 99999 %Big M limits
%            13.5 <= ees_adopt <= 99999 %Limits for semivar
            0 <= ees_chrg
            0 <= ees_dchrg
            0 <= ees_soc
            ];
  end 
        
  if opt_t == 1
       Constraints=[Constraints
          0 <= T_rated <= 20000];
  end 
  
    ops = sdpsettings('solver','cplex','debug',1,'verbose',2,'warning',1,'savesolveroutput',1);
    ops.showprogress=1;
    ops.cplex.options.Display='on';
    ops.cplex.options.Diagnostics='on';
    ops.cplex.mip.tolerances.mipgap = 0.004;
    max_nodes = 60000;
    ops.cplex.MaxNodes=max_nodes;
    ops.cplex.mip.limits.nodes=max_nodes;
    
    %Optimize!
    sol = optimize(Constraints,Objective,ops)
    %optimize(Constraints,[],ops) %remove objective function to debug unfeasible problems 
end