
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
    options.MaxNodes = 15000;
    x = [];
%     load starting_point
%     if length(model.f) ~= length(x)
%         x = [];
%     end
    fprintf('%s Starting CPLEX Solver \n', datestr(now,'HH:MM:SS'))
    tic
    %     [x, fval, exitflag, output, lambda] = cplexlp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, lb, ub, [], options);
    [x, fval, exitflag, output] = cplexmilp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, [],[],[],lb,ub,model.ctype,x,options);
    elapsed = toc;
    fprintf('CPLEX took %.2f seconds \n', elapsed)

    %     cplex = Cplex(model); %instantiate object cplex of class Cplex
    %     cplex.solve() %metod solve() to create Solution dynamic property
    %     cplex.Solution.status
    %     cplex.Solution.miprelgap
    
    % Recovering data and assigning to the YALMIP variables
    assign(recover(recoverymodel.used_variables),x)
    
   
   
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