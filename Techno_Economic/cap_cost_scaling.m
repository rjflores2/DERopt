function [cost_scale] = cap_cost_scaling(tr,tech_v,fin_v,scale_factor,debt,discount_rate,rebate)
%% IRA
if length(fin_v) >=4
    ira = (tech_v(1) + scale_factor)*fin_v(4);
else 
    ira = 0;
end
%% MARCS Schedules
%%%5 year schedule
macrs5 = [0.2   %yr1
    0.32        %yr2
    0.192       %yr3
    0.1152      %yr4
    0.1152      %yr5
    0.0576      %yr6
    0           %yr7
    0           %yr8
    0           %yr9
    0];         %yr10

%%%7 year schedule
macrs7 = [0.1429%yr1
    0.2449      %yr2
    0.1749      %yr3
    0.1249      %yr4
    0.0893      %yr5
    0.0892      %yr6
    0.0893      %yr7
    0.0446      %yr8
    0           %yr9
    0];         %yr10

%% MACRS
%%% IF IRA is active, MACRS is slightly reduced
if length(fin_v) >= 4
    macrs_mod = 1;
else
    macrs_mod = 1;
end

%%% MACRS does not apply to resdiential systems
if tr == 0.2
    macrs_mod = 0;
end

if fin_v(2) == 5
    macrs = macrs5.*(tech_v(1) + scale_factor - ira*0.5)*tr.*macrs_mod;
elseif fin_v(2) == 7
    macrs = macrs7.*(tech_v(1) + scale_factor - ira*0.5)*tr.*macrs_mod;
else
    macrs = zeros(size(macrs5));
end

%% ITC
itc = (tech_v(1) + scale_factor)*tr*fin_v(3);



%% Cashflows
cashflow = debt - macrs;
cashflow(1) = cashflow(1) - itc - ira;

%%%Adjsuted Cost
npv_cost = pvvar(cashflow,discount_rate);

%% Cost Scaling
cost_scale = npv_cost/tech_v(1);

if cost_scale < 0
    cost_scale = 0;
end
% cashflow
% cost_scale