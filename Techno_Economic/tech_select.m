%% Technology Selection
%% Utility
utility_exists=1;

%% Solar PV
%%% Cap cost ($/kW)
%%% Efficiency / Conversion Percent at 1 kW/m^2
%%% O&M ($/kWh generated)
if pv_on
    %pv_v=[3500; 0.2 ; 0.001];  2025:2484 $/kW__2035:1944 $/kW__2045:1317.5 $/kW
    pv_v=[1317.5; 0.2 ; 0.001];  %https://atb.nrel.gov/electricity/2021/residential_pv
     
    pv_cap=pv_v(1,:);%NREL:PV capital cost: 2000 in 2035, 1300 in 2045 w/ conservative scenario
    
    %%%How pv capital cost is modified for different types of buildings
    pv_cap_mod = [2/2.65 %%%Commercial/industrial
        2.65/2.65]; %%%Residential
    
    %%%Financial Aspects - Solar PV 
    pv_fin = [-0.4648; ... %%%Scaling linear factor - Based on Lazards cost of electricity
        0; ... %%%MACRS Schedule Modified Accelerated Cost Recovery System (tax) 2025:5__2030:0__2045:0
        0]; ... %%%ITC Solar Investment Tax Credit (ITC)2025:1__2030:0__2045:0   
        
    
    %%%Solar on multifamily affordable homes (SOMAH)
    somah = [2600];
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
    
    %2025:911.5 $/kWh__2035:755 $/kWh__2045:654 $/kWh
    ees_v=[654; 0.001; 0.001; 0.1; 0.95; 0.5; 0.5; .90; .90; .9999];
    ees_cap=ees_v(1);
    
    %%%How EES capital cost is modified for different types of buildings
    ees_cap_mod = [575/830 %%%Commercial/industrial
        830/830]; %%%Residential
    
    %%%Financial Aspects - EES
    ees_fin = [-0.4648;... %%%Scaling linear factor - Based on Lazards cost of electricity ($/kW installed)
        0; ... %%%MACRS Schedule:Modified Accelerated Cost Recovery(tax depreciation system to calculate asset depreciation)-PPA(Power Purchase Agreement) 2025:7__2030:0__2045:0   
        0]; ... %%%ITC Benefit:Investment Tax Credit(federal tax incentive for business investment) 2025:0__2030:0__2045:0  
        
    %%%Financial Aspects - EES
    rees_fin = [-0.4648;... %%%Scaling linear factor - Based on Lazards cost of electricity
        0; ... %%%MACRS Schedule 2025:5__2030:0__2045:0   
        0]; ... %%%ITC Benefit 2025:1__2030:0__2045:0 
        
%     ees_fin = [-0.1306;... %%%Scaling linear factor - Based on Lazards cost of electricity
%         0; ... %%%MACRS Schedule
%         0]; ... %%%ITC Benefit
%         
%     %%%Financial Aspects - EES
%     rees_fin = [-0.1306;... %%%Scaling linear factor - Based on Lazards cost of electricity
%         0; ... %%%MACRS Schedule
%         0]; ... %%%ITC Benefit
else
ees_v = [];
rees_v = [];
end

%% SOFC
if  sofc_on
    %2025:5706 $/kW__2035:5529.5 $/kW__2045:5420.5 $/kW
    sofc_v = [0.7*5420.5    %%% 1: Capital cost ($/kWel) C_fc Assume 30% tax credit
        0.06*5420.5     %%% 2: O&M ($/kW/yr generated) 6 Yearly % of TIC(Total Installed Cost) % of the purchasing cost (4–10%)
        0.6        %%% 3: SOFC electrical efficiency at nominal condition (fraction)
        0.3        %%% 4: SOFC thermal efficiency at nominal condition (fraction)
        0.5        %%% %0.5 5: Minimum SOFC capacity is 500 Watt- 0.5 kW increments
        0.0005     %%% 6: kw/s Ramp rate is 6% of nominal capacity per minute [T. D. Hutty, S. Dong, R. Lee, and S. Brown] 500 watt nominal=> 0.5*6/100/6 = 0.0005kw/s
        0.5];      %%% 7: Minimum load setting (% of rated capacity)
    %%ramp rate conversion - Converting the ramp kW/s to the % load
    %%change within the simulation time step
    sofc_v(6) = t_step/((sofc_v(5)/sofc_v(6))/60);
    if sofc_v(6) > 1
        sofc_v(6) = 1;
      end

      % Find these numbers !   
    %%%Financial Aspects - SOFC 
%     sofc_fin = [-0.4648; ...  $/kW %%%Scaling linear factor - Based on Lazards cost of electricity
%         5; ... year %%%MACRS Schedule Modified Accelerated Cost Recovery System (tax)
%         0.26]; ... %%% SOFC Investment Tax Credit (ITC)/ from www.irs.gov       
end
%% ERWH     instead of O&M cost the electricity consumption is multiplied by its cost  
if erwh_on
    erwh_v = [0    %%% 1000  1: Capital cost ($/kWel) https://www.homedepot.com/
               2.62];   %CZ16:WHP COP:2.62 CZ16:ERWH:0.95 PremiumERWH:1 WHP:1.65  %%% 0.9 for ERWH 0.99 for premium on-demand, 2.46 for COP_HPWH 2: ERWH energy factor- COPHPWH = 3 from AHRI Directory  From RFJ model for premium heat pump COP is 2.46   
else 
    erwh_v = [];
end      
%% GWH     instead of O&M cost the gas consumption is multiplied by its cost  
if gwh_on
    gwh_v = [0    %%%2000 1: Capital cost ($/kWth) 
              0.96];  %%% 2: GWH energy factor (EF) Baseline:0.6, Premium_Gas:0.96    
else 
    gwh_v = [];
end
%% GSPH     instead of O&M cost the gas consumption is multiplied by its cost  
if gsph_on
    gsph_v = [0    %%%3000 1: Capital cost ($/kWth)- 75,000–100,000 BTU: $2,500–$5,900: An 80,000 BTU furnace will keep a 1,600- to 2,000-square-foot home warm
              0.96];  %%% BEopt: Baseline: 0.8 - Premium Gas: 0.96  
else 
    gsph_v = [];
end 
%% ERSPH     instead of O&M cost the electricity consumption is multiplied by its cost  
if ersph_on
    ersph_v = [0    %%%1200 1: Capital cost ($/kWel)-  
              1];  %%%1 for ERSPH, 2 for COP_HPSPH = 2    2: 100%  energy efficient-https://www.energy.gov/energysaver/electric-resistance-heating 
else 
    ersph_v = [];
end 
%% SGIP incentives
if sgip_on
    %%%Self generation incentive program (SGIP) values
    sgip = [5 %%% 1:CO2 reduction required per kWh for large scale systems
        350 %%% 2: Large storage incentive($/kWh)
        200 %%% 3: Residential storage incentive ($/kWh)
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
%%% PV
if ~pv_on
    pv_v=[];
end
%%% EES
if ~ees_on
    ees_v =[];
end
%%% SOFC
if ~sofc_on
    sofc_v =[];
end
%%% ERWH
if ~erwh_on
    erwh_v =[];
end
%%% GWH
if ~gwh_on
    gwh_v =[];
end

%%% ERWH  
if ~ersph_on
    ersph_v =[];
end
%%% GSPH
if ~gsph_on
    gsph_v =[];
end

%%% SOFCWH
if ~sofcwh_on
    sofcwh_v =[];
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