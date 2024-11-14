%%%% Titus de Jong

%% Paths

%%%YALMIP Master Path
addpath(genpath('D:\LAB DOCS\YALMIP\yalmip\YALMIP-master')) %rjf path

%%%DERopt paths
addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Design'))
addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Input_Data'))
addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Load_Processing'))
addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Post_Processing'))
addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Problem_Formulation_Single_Node'))
addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Techno_Economic'))
addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Utilities'))
addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\Igiugig'))

%% Efficiencies
e_curve = @(x) .5*(1+exp(-x)).^(-1);

max_output = 5;  % Max power output in kW

prop_capacity = .5;   % proportion of output power produced

%% Costs

start_cost = 100; % Cost to start up

end_cost = 100; % Cost to stop usage

fuel_cost = .5; % Cost/L of fuel

OM_cost = .02;

capital_cost = 100000; 

interest=0.08; %%%Interest rates on any loans
interest=nthroot(interest+1,12)-1; %Converting from annual to monthly rate for compounding interest
period=10;%%%Length of any loans (years)
equity=0.2; %%%Percent of investment made by investors
required_return=.12; %%%Required return on equity investment
required_return=nthroot(required_return+1,12)-1; % Converting from annual to monthly rate for compounding required return
equity_return=10;% Length at which equity + required return will be paid off (Years)
discount_rate = 0.08;

monthly_debt = capital_cost_to_monthly_cost(capital_cost,equity,interest,period,required_return);

%% tech-vector
% 1- peak_capacity kW
% 2- efficiency e \in [0, 1]
% 3- switch_cost $
% 4- Operations and Management $/kWh

generator_v = [max_output, e_curve(prop_capacity), start_cost+end_cost, OM_cost]';

%%

%{ 

Add --  vars to "CModelVariables"

    var_gen.gen_elec
    var_gen.gen_adopt

Make var_gen be a decision variable

    var_gen.gen_elec = sdpvar(T, size(generator_v, 2), 'full')
    var_gen.gen_adopt = sdpvar(1, size(generator_v, 2), 'full')

Cost = M*monthly_debt.*mod.*var_gen.gen_adopt %% what is mod?

OaM = sum((generator_v(3,:).*day_multi).*(var_gen.gen_elec)) %% what is day_multi?

% Extra = start/end costs, when turned off/on (How would I implement this?)

Objective = Objective + sum(Cost) + sum(OaM) % + Extra


Constraints = [ Constraints
                    (var_gen.gen_elec + var_rees.rees_chrg + rel_eff.*var_rel.rel_prod <= repmat(var_gen.gen_adopt./e_curve,T,1)) :'gen Energy Balance'];



%}