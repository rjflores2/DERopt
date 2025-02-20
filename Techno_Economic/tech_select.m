%% Technology Selection
%% Utility
utility_exists=1;

%% Solar PV
%%% Cap cost ($/kW)
%%% Efficiency / Conversion Percent at 1 kW/m^2
%%% O&M ($/kWh generated)
if pv_on
    %pv_v=[3500; 0.2 ; 0.001];
    pv_v=[3190*0.849496321; 0.2 ; 0.001]; %pv_v=[2650; 0.2 ; 0.001];
    pv_v=[3190; 0.2 ; 0.001]; %pv_v=[2650; 0.2 ; 0.001];
     
    pv_cap=pv_v(1,:);
    
    %%%How pv capital cost is modified for different types of buildings
    pv_cap_mod = [2/3.19 %%%Commercial/industrial
        3.19/3.19]; %%%Residential
    
    %%%Financial Aspects - Solar PV 
    pv_fin = [-0.4648; ... %%%Scaling linear factor - Based on Lazards cost of electricity
        5; ... %%%MACRS Schedule Modified Accelerated Cost Recovery System (tax)
        0; ... %%%ITC Solar Investment Tax Credit (ITC)
        0.3]; %IRA Tax Credits
        
    
    %%%Solar on multifamily affordable homes (SOMAH)
    somah = [2600];
    somah = [3250];
else
    pv_v = [];
    
end
%% Electrical Energy Storage
if ees_on
    %%% (1) Capital Cost ($/kWh installed)
    %%% (2) Charge O&M ($/kWh charged)
    %%% (3) Discharge O&M ($/kWh discharged)
    %%% (4) Minimum state of charge
    %%% (5) Maximum state of charge
    %%% (6) Maximum charge rate (% Capacity/hr)
    %%% (7) Maximum discharge rate (% Capacity/hr)
    %%% (8) Charging efficiency
    %%% (9) Discharging efficiency
    %%% (10) State of charge holdover
    
    %ees_v=[200; 0.001; 0.001; 0.3; 0.95; 0.25; 0.25; .95; .95; .995];
    %ees_v=[195; 0.001; 0.001; 0.25; 0.99; 0.3; 0.3; .9; .85; .999];
    %ees_v=[200; 0.001; 0.001; 0.1; 0.95; 1; 1; 1; 1; 1];
    %ees_v=[200; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .95; .95; .995];
    %ees_v=[300; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .95; .95; .995];
    %ees_v=[500; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .95; .95; .995];
    %ees_v=[830; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .90; .90; .995];
    %%%%%%%%%%%%%%%           ees_v=[830; 0.001; 0.001; 0.1; 0.95; 0.5; 0.5; .90; .90; .9999];
    %ees_v=[600; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; 1; 1; .995]; %Testing with 100% RTE
    
 
%         Original one
        ees_v=[830; 0.001; 0.001; 0.1; 0.95; 0.5; 0.5; .90; .90; .9999];
        ees_v=[1218; 0.00; 0.00; 0.1; 0.95; 0.5; 0.5; .90; .90; .9999];
        ees_v=[1200; 0.00; 0.00; 0.1; 0.95; 0.5; 0.5; .90; .90; .9999];
% ees_v=[162; 0.001; 0.001; 0.05; 0.98; 0.9; 0.2; .95; .99; .9999];
    ees_cap=ees_v(1);
    
    %%%How pv capital cost is modified for different types of buildings
    ees_cap_mod = [400/1218 %%%Commercial/industrial
        1218/1218]; %%%Residential
    
    %%%Financial Aspects - EES
    ees_fin = [-0.4648;... %%%Scaling linear factor - Based on Lazards cost of electricity
        7; ... %%%MACRS Schedule:Modified Accelerated Cost Recovery(tax depreciation system to calculate asset depreciation) 
        1; ... %%%ITC Benefit:Investment Tax Credit(federal tax incentive for business investment) 
        0.3]; 
        
    %%%Financial Aspects - EES
    rees_fin = [-0.4648;... %%%Scaling linear factor - Based on Lazards cost of electricity
        5; ... %%%MACRS Schedule
        1]; ... %%%ITC Benefit
        
    ees_fin = [-0.1306;... %%%Scaling linear factor - Based on Lazards cost of electricity
        7; ... %%%MACRS Schedule
        0; ... %%%ITC Benefit
        0.3]; %%%IRA
        
    %%%Financial Aspects - EES
    rees_fin = [-0.1306;... %%%Scaling linear factor - Based on Lazards cost of electricity
        5; ... %%%MACRS Schedule
        0; ... %%%ITC Benefit
        0.3]; %%%IRA
else
ees_v = [];
rees_v = [];
end

%% SOFC
if  sofc_on

    sofc_v = [4588.5   %%% 1: Capital cost ($/kWel)
          1454.3  %%% 2: O&M ($/kWh generated) 6 Yearly % of TIC(Total Installed Cost) % of the purchasing cost (4–10%) 
          0.6        %%% 3: SOFC electrical efficiency at nominal condition (fraction)     
          0.28]      %%% 4: SOFC thermal efficiency at nominal condition (fraction)
                  
    % Find these numbers !   
    %%%Financial Aspects - SOFC 
    sofc_fin = [-0.4648; ... %%%Scaling linear factor - Based on Lazards cost of electricity
        5; ... %%%MACRS Schedule Modified Accelerated Cost Recovery System (tax)
        1]; ... %%% SOFC Investment Tax Credit (ITC)   
        
    
end    

%% Binary/Continuous DG
if dgb_on
    dgb_v = [4588.5   %%% 1: Capital cost ($/kWel)
          1454.3  %%% 2: O&M ($/kWh generated) 6 Yearly % of TIC(Total Installed Cost) % of the purchasing cost (4–10%) 
          0.5       %%% 3: SOFC electrical efficiency at nominal condition (fraction) 
          0.8];     %%% 4: Minimum output
      
      dgb_fin = [-40.6
          5; ... %%%MACRS Schedule Modified Accelerated Cost Recovery System (tax)
          1]; ... %%% SOFC Investment Tax Credit (ITC)
else
dgb_v = [];
end
%% 
if dgl_on
    dgl_v = [2000 %Capital Cost $/kW
        .5]; %Efficiency

    dgl_pipeline_fuel = [6.*(3.6/120)]; %%%pipeline cost ($/kWh)
end
%% H2 Storage
if h2_storage_on
    %%%Hydrogen energy storage
    %%% (1) Capital Cost ($/kWh installed)
    %%% (2) Charge O&M ($/kWh charged)
    %%% (3) Discharge O&M ($/kWh discharged)
    %%% (4) Minimum state of charge
    %%% (5) Maximum state of charge
    %%% (6) Maximum charge rate (% Capacity/hr)
    %%% (7) Maximum discharge rate (% Capacity/hr)
    %%% (8) Charging efficiency
    %%% (9) Discharging efficiency
    %%% (10) State of charge holdover
    %%% (11) when H2 is delivered (hour into resiliency event)
    h2es_v = [60;0.001;0.001;0.01;1;1;1;0.95;1;1];
    h2_storage_v =  [22;0.001;0.001;0.01;1;1;1;1;1;0.9995; 12];

    h2_delivery_fuel = [6.*(3.6/120)]; %%% cost of delivered fuel ($/kWh)

end
%% Continuous DG
if dgc_on
    dgc_v = [5500   %%% 1: Capital cost ($/kWel)
        0.01  %%% 2: O&M ($/kWh generated) 6 Yearly % of TIC(Total Installed Cost) % of the purchasing cost (4–10%)
          0.6       %%% 3: SOFC electrical efficiency at nominal condition (fraction) 
          0.8];     %%% 4: Minimum output
      
      dgc_fin = [0
          5; ... %%%MACRS Schedule Modified Accelerated Cost Recovery System (tax)
          1]; ... %%% SOFC Investment Tax Credit (ITC)
else 
dgc_v = [];
end

%% SGIP incentives
if sgip_on
    %%%Self generation incentive program (SGIP) values
    sgip = [5 %%% 1:CO2 reduction required per kWh for large scale systems
        250 %%% 2: Large storage incentive($/kWh)
        150 %%% 3: Residential storage incentive ($/kWh)
        850 %%% 4: Equity rate ($/kWh)
        2000]; %%% 5: kWh incriment at which SGIP decreases
    sgip_o = sgip;
    %%%Non_residential rates that receive sgip(2) incentive
    non_res_rates = [1 2];
else
    sgip = [];
end
%% Building space
%%%[space available for PV (m^2)
%%%Cooling loop input (C)
%%%Cooling loop output (C)
%%%Building cooling side (C)
bldg_v= [10000000000; 10; 18; 15];

%% Inverter
%%% Cap cost ($/kW)
inv_v = [49];

%% Transformer
%%% Cap cost ($/kVA)
xfmr_v = [1090];

%% Tech select

if ~pv_on
    pv_v=[];
end

if ~ees_on
    ees_v =[];
end

%% Placeholders

%%%Technologies avaialable at a single node
el_v = [];
rel_v = [];
h2es_v = [];
utilpv_v = [];
util_ees_v = [];
hrs_on = [];

%%%Legacy technologies available at a single node
pv_legacy = []; 
dg_legacy = [];
hr_legacy = [];