function [cost_scale] = cap_cost_scaling(tr,tech_v,fin_v,scale_factor,debt,discount_rate,rebate)

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
if fin_v(2) == 5
    macrs = macrs5.*(tech_v(1) + scale_factor)*tr;
elseif fin_v(2) == 7
    macrs = macrs7.*(tech_v(1) + scale_factor)*tr;
else
    macrs = zeros(size(macrs5));
end

%% ITC
itc = (tech_v(1) + scale_factor)*tr*fin_v(3);

%% Cashflows
cashflow = debt - macrs;
cashflow(1) = cashflow(1) - itc;

%%%Adjsuted Cost
npv_cost = pvvar(cashflow,discount_rate);

%% Cost Scaling
cost_scale = npv_cost/tech_v(1);

if cost_scale < 0
    cost_scale = 0;
end
% cashflow
% cost_scale