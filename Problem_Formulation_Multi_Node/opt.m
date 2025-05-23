
%% Optimize thru CPLEX
if opt_now==1
    
    % Export Model YALMIP -> CPLEX
    tic
%     [model,recoverymodel,diagnostic,internalmodel] = export(Constraints,Objective,sdpsettings('solver','cplex'));
     [model,recoverymodel,diagnostic,internalmodel] = export(Constraints,Objective,sdpsettings('solver','gurobi'));
   [model,recoverymodel,diagnostic,internalmodel] = export(Constraints,Objective);
   model.lb(:) = 0;
clear params
params.NodeLimit = 100;
params.OutputFlag = 1;
% params.Method = -1;
params.PreSparsify = 2;
if sim_idx == 7 && opt_resiliency_model == 3
    params.Threads = 2;
else
    params.Threads = 36;
end
solution = gurobi(model,params)
    %%%Setting lower/upper bounds for all variables
    %     lb=zeros(size(model.f));
    % lb=[];
    % ub=inf(size(lb));
    % ub=[];
    % elapsed = toc;
    % fprintf('Model Export took %.2f seconds \n', elapsed)
    %      opt = cplexoptimset('cplex');
    % options = cplexoptimset('Display', 'on', 'MaxNodes', 10);
    %     options.Display='on';
    %         options.MaxTime = 2*3600;
    %     options.MaxNodes = 100;
    % ops = sdpsettings('solver','cplex','verbose',1,'showprogress',1);
    %     ops.cplex.MaxNodes = 100;
    %     ops.mip.strategy.file =  2
    %     ops.display = 'on';
    %     ops.Diagnostics = 'on';
    
    
%     options.Display='on';
%     options.Diagnostics='on';
% 
%     fprintf('%s Starting CPLEX Solver \n', datestr(now,'HH:MM:SS'))
%     tic
%     %         [x, fval, exitflag, output, lambda] = cplexlp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, lb, ub, [], ops);
%     if isempty(strfind(model.ctype,'I')) && isempty(strfind(model.ctype,'B'))
%         'LP Model'
%         [x, fval, exitflag, output, lambda] = cplexlp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, lb, ub, [], options);
%     else
%         'MILP Model'
% %         options = cplexoptimset('mip.strategy.file', 2,...
% %             'mip.limits.nodes', 100);
%         [x, fval, exitflag, output] = cplexmilp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, [],[],[],lb,ub,model.ctype,[],options);
%     end
%     %     [x, fval, exitflag, output] = cplexmilp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, [],[],[],lb,ub,model.ctype,[],options);
%     elapsed = toc;
    fprintf('CPLEX took %.2f seconds \n', elapsed)
    
    % output
    % exitflag
    % fval
    
    
    
    %     cplex = Cplex(model); %instantiate object cplex of class Cplex
    %     cplex.solve() %metod solve() to create Solution dynamic property
    %     cplex.Solution.status
    %     cplex.Solution.miprelgap
    
    % Recovering data and assigning to the YALMIP variables
    % assign(recover(recoverymodel.used_variables),x)

    if ~strcmp(solution.status,'INF_OR_UNBD')
            assign(recover(recoverymodel.used_variables),solution.x)
    end



    
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