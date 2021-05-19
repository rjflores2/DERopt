yalmip('clear')
clear var*
Objective = 0;
ii = 1;
jj = 11
idx = endpts(ii):endpts(ii+jj);
cool = cool_o(idx);
elec = cool;
time = cool;
%% Legacy Chillers
if ~isempty(cool) && sum(cool) >0 && ~isempty(vc_legacy)
    
    vc_hour_num = ceil(length(time)/4);
    
    
    %%%VC Cooling output
    var_lvc.lvc_cool = sdpvar(length(elec),size(vc_legacy,2),'full');
    %%%VC Operational State
    var_lvc.lvc_op = binvar(vc_hour_num,size(vc_legacy,2),'full');
    
    %%%Electric Vapor Compression
    for i=1:size(vc_legacy,2)
        Objective = Objective ...
            + var_lvc.lvc_cool(:,i)'*(vc_legacy(1,i)*ones(length(time),1));
    end
    
    
    
    % vc_cop = vc_legacy(2,:);
    % vc_size = vc_legacy(3,:)./e_adjust;
    vc_size = zeros(length(elec),size(vc_legacy,2));
    vc_cop=ones(length(elec),size(vc_legacy,2));
    for i=1:length(elec)
        vc_cop(i,:)=vc_cop(i,:).*(1./vc_legacy(2,:));
        vc_size(i,:) = vc_legacy(3,:);
    end
    
else
    
end
var_vc.generic_cool = zeros(length(elec),1);

%% Extra Cooling Potential

extra_cooling =  sdpvar(length(elec),1,'full');

Objective = Objective + sum(1e6*extra_cooling);
%% Legacy Cold TES
if ~isempty(cool) && sum(cool) >0 && ~isempty(tes_legacy)
    %%%TES Energy Storage Vector
    %%%TES State of Charge
    var_ltes.ltes_soc = sdpvar(length(elec),size(tes_legacy,2),'full');
    %%%TES charging/discharging
    var_ltes.ltes_chrg = sdpvar(length(elec),size(tes_legacy,2),'full');
    var_ltes.ltes_dchrg = sdpvar(length(elec),size(tes_legacy,2),'full');
    
    %%%TES
    for i=1:size(tes_legacy,2)
        Objective=Objective + var_ltes.ltes_chrg(:,i)'*(tes_legacy(2,i)*ones(length(time),1))...
            + var_ltes.ltes_dchrg(:,i)'*(tes_legacy(3,i)*ones(length(time),1));
    end
    
else
    var_ltes.ltes_soc = zeros(T,1);
    var_ltes.ltes_chrg = zeros(T,1);
    var_ltes.ltes_dchrg = zeros(T,1);
end

%% Equality constraints

if ~isempty(cool) && sum(cool)>0
    Constraints = [extra_cooling + var_vc.generic_cool + sum(var_ltes.ltes_dchrg,2) + sum(var_lvc.lvc_cool,2) == cool + sum(var_ltes.ltes_chrg,2)];
    
%     Constraints = [Constraints
%         var_vc.generic_cool + sum(var_ltes.ltes_dchrg,2) + sum(vc_size.*var_lvc.lvc_op,2) == cool + sum(var_ltes.ltes_chrg,2)];
end

%% Legacy VC Constraints
fprintf('%s: Legacy VC Constraints.', datestr(now,'HH:MM:SS'))
tic
opt_vc_legacy
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)
%% Legacy TES Constraints
fprintf('%s: Legacy TES Constraints.', datestr(now,'HH:MM:SS'))
tic
opt_tes_legacy
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)

%% Optimize
fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))

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
    
    close all
    figure
    subplot(3,1,1)
    plot(cool)
    
    subplot(3,1,2)
    plot(sum(value(var_lvc.lvc_cool),2) - value( var_ltes.ltes_chrg) + value( var_ltes.ltes_dchrg))
    
    subplot(3,1,3)
    plot(round(sum(value(var_lvc.lvc_cool),2) - value( var_ltes.ltes_chrg) + value( var_ltes.ltes_dchrg) - cool))
    
    figure
    plot(value(extra_cooling))
%     plot(value(