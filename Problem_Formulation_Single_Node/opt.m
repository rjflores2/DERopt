
%% Optimize thru CPLEX
if opt_now==1
    
    % Export Model YALMIP -> CPLEX
    tic
    [model,recoverymodel,diagnostic,internalmodel] = export(Constraints,Objective,sdpsettings('solver','cplex'));
        
    %%%Setting lower/upper bounds for all variables
    lb=zeros(size(model.f));
    ub=inf(size(lb));
    elapsed = toc;
    fprintf('Model Export took %.2f seconds \n', elapsed)
  
    options = cplexoptimset;
    options.Display='on';
%     options.MaxTime = 2*3600;
options.MaxNodes = 100;

    
    fprintf('%s Starting CPLEX Solver \n', datestr(now,'HH:MM:SS'))
    tic
%     [x, fval, exitflag, output, lambda] = cplexlp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, lb, ub, [], options);
    [x, fval, exitflag, output] = cplexmilp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, [],[],[],lb,ub,model.ctype,[],options);
    elapsed = toc;
    fprintf('CPLEX took %.2f seconds \n', elapsed)
    
    output
    exitflag
    fval
    
    
    
%     cplex = Cplex(model); %instantiate object cplex of class Cplex 
%     cplex.solve() %metod solve() to create Solution dynamic property
%     cplex.Solution.status
%     cplex.Solution.miprelgap
    
    % Recovering data and assigning to the YALMIP variables
    assign(recover(recoverymodel.used_variables),x)
    
    
    (sum(value(var_pv.pv_adopt))+sum(pv_legacy(2,:))).*sum(solar)*(1/e_adjust)
    sum(value(var_pv.pv_elec) + value(var_pv.pv_nem))
    
    figure
    hold on
    plot(value(var_ldg.ldg_elec))
    plot(value(var_util.import) + value(var_ldg.ldg_elec))
    plot(value(var_util.import) + value(var_pv.pv_elec) + value(var_ldg.ldg_elec))
    
    return
    
    %%% evaluating performance of the model
    %%%Utility values
    import = value(import);
%     nontou_dc = value(nontou_dc);
%     onpeak_dc = value(onpeak_dc);
%     midpeak_dc = value(midpeak_dc);
    
    %%%Solar PV values
    pv_elec = value(pv_elec);
    pv_adopt = value(pv_adopt)
    pv_nem = value(pv_nem);
%     pv_wholesale = value(pv_wholesale);
    
    %%%EES Values
    ees_adopt = value(ees_adopt);
    ees_soc = value(ees_soc);
    ees_chrg = value(ees_chrg);
    ees_dchrg = value(ees_dchrg);
    
    %%%REES Values
    rees_adopt = value(rees_adopt);
    rees_soc = value(rees_soc);
    rees_chrg = value(rees_chrg);
    rees_dchrg = value(rees_dchrg);
    rees_dchrg_nem = value(rees_dchrg_nem);
    
    %%%SGIP values
    if exist('sgip_ees_pbi') || isempty(sgip_ees_pbi)
        sgip_ees_pbi = value(sgip_ees_pbi);
    else
        sgip_ees_pbi = [0;0;0];
    end
    
    if exist('sgip_ees_npbi') && ~isempty(sgip_ees_npbi)
        sgip_ees_npbi = value(sgip_ees_npbi);
    else
        sgip_ees_npbi = 0;
    end
    
    if exist('sgip_ees_npbi_equity') && ~isempty(sgip_ees_npbi_equity)
        sgip_ees_npbi_equity = value(sgip_ees_npbi_equity);
    else
        sgip_ees_npbi_equity=0;
    end
    
%     dc_count = 1;
%     
%     energy_cost = [];
%     for i = 1:size(import,2)
%          %%%Find the applicable utility rate
%         index=find(ismember(rate_labels,rate(i)));
%         
%         energy_cost(i,1) = import(:,i)'*import_price(:,index);
%         
%         %%% if demand charges exist
%         if dc_exist(i) == 1
%             for ii = 1:length(endpts)
%                 if ii == 1
%                     start = 1;
%                     finish = endpts(ii);
%                 else
%                     start = endpts(ii-1) + 1;
%                     finish = endpts(ii);
%                 end
%                 
%                 check_nontou_dc(ii,dc_count) = max(import(start:finish,i));
%                 check_onpeak_dc(ii,dc_count) = max(import(start:finish,i).*onpeak_index(start:finish));
%                 check_midpeak_dc(ii,dc_count) = max(import(start:finish,i).*midpeak_index(start:finish));
%                 
% %                 if sum(import(start:finish,i).*onpeak_index(start:finish)) > 0
% %                     figure
% %                     plot(import(start:finish,i).*onpeak_index(start:finish))
% %                 end
%                 
%                 
%             end
%             dc_count = dc_count + 1;
%         end
%     end
end
% check_nontou_dc - nontou_dc;
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