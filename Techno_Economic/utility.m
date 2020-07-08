%% Loading Utility Information

%% Electricity rates
%%%Load SCE Energy Costs

%%%Comercial/Industrial Rates
[erates_ci,labels] = xlsread('SCE_CI.xlsx','Model Input');
for i=1:size(erates_ci,2)
    erate_ci(:,i) = erates_ci(2:6,i) + erates_ci(1,i); % Adding T&D to all rates 
end

%%%Rate Labeling
rate_labels=labels(2,2:size(labels,2));

%%%Demand Charges
dc_nontou = erates_ci(7,:);
dc_on = erates_ci(8,:);
dc_mid = erates_ci(9,:);

%%%NBC for C/I
nbc_ci = erates_ci(end,:);

%%%TOU for C/I Rates (hours at which rates switch)
tou_winter=[8;13;3];
tou_winter=[8  21];
tou_summer=[8;4;6;5;1];
tou_summer=[8 12 18 23];

%%%Residential Rates
[erates_d,labels] = xlsread('SCE_D_TOU.xlsx','Model Inputs');
rate_labels=[rate_labels labels(2,2:size(labels,2))];

%%%Typical TOU Rates (A & B)
erates_d_tou = erates_d(:,1:2);
nbc_d_tou = erates_d(end,1:2);

d_tou_week = [8 14 20 22];
d_tou_weekend = [8 22];

%%%Nontypical TOU Rates (PM rates)
erates_d_tou_pm = erates_d(:,3:4);
nbc_d_tou_pm = erates_d(end,3:4);
d_pm_tou = [16 21;
    17 20];

% %%%Residectial TOU AB
% [erates_d_tou,labels] = xlsread('SCE_R_TOU.xlsx','AB');
% d_tou_week = [8 14 20 22]
% d_tou_weekend = [8 22];

% [erates_d_tou_pm,labels] = xlsread('SCE_R_TOU.xlsx','PM');
% rate_labels=[rate_labels labels(2,2:size(labels,2))]
% d_pm_tou = [16 21;
%     17 20];

%%%Normal Residential Rates
erates_d = xlsread('SCE_D.xlsx');
% erates_d = [erates_d(1:3,:) + erates_d(4:6,:)
%     erates_d(1:3,:) + erates_d(7:9,:)]

% ratedata = xlsread('SCE_Rate_Matrix.xlsx','GS8');

%%% Wholesale export rate, Net Surplus Compensation Rate ($/kWh)
ex_wholesale = 0.03;

%%%Loading CO2 emission rates associated with the grid
load('co2_rates_example.mat');
co2_rates=co2_rates.*(0.650/mean(co2_rates));
grid_emissions(:,1)=co2_rates;


%% Natural Gas Prices
%%%therm to kWh conversion (therm/kWh)
% c1=1/29.31;
% t1=0.8875;
% t2=0.63164;
% t3=0.46009;
% tierv=[t1 t2 t3];
% 
% %%% Max gas use possible
% if isempty(dghr_v) == 0
%     max_gas=c1*(sum(elec(:,1))/min(dghr_v(4,:))+sum(heating)/boil_v(2));
% elseif isempty(dghr_v) == 1 && isempty(boil_v) == 0
%     max_gas=c1*(sum(heating)/boil_v(2));
% end
% 
% ng_v=tierv;
% if max_gas > 4167
%     ng_use_v=[0;250;4167;max_gas];
% else
%     ng_use_v=[0;250;4167;5000];
% end
%     
% ng_cost_v=0;
% for i=1:length(tierv)
%     ng_cost_v(i+1)=ng_cost_v(i)+(ng_use_v(i+1)-ng_use_v(i))*ng_v(i);
% end
% 
% %%%RNG vector
% %%%%%%%[Renewable Natural Gas Prices
% %%%Carbon emissions per them of RNG (lbs/therm)]
% rng_v=[1 2]; %%% $ per therm

%% Optimization/Analysis Constants

% %%%Grid Electricity Cost ($/kWh)
% e_rate=[ratedata(3:7,2)+ratedata(8:12,2)+(ratedata(1,2)+ratedata(2,2))*ones(5,1)];
% %%%Demand Charge Vector
% dc_nontou=ratedata(13,2); % Non Time of Use Demand Charge
% dc_on=ratedata(14,2);%On Peak TOU DC
% dc_mid=ratedata(15,2);%Mid Peak TOU DC
% del1=dc_on+dc_mid-dc_nontou;%Demand Shifting
% dc_v=[dc_nontou dc_on dc_mid del1];
% 
% tou_winter=[8;13;3];
% tou_winter=[8  21];
% tou_summer=[8;4;6;5;1];
% tou_summer=[8 12 18 23];