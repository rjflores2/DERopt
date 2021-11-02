%% Loading Utility Info
addpath('H:\_Research_\CEC_OVMG\Rates\SCE') %%%Same path used for UO Analysis
%% Constants
%%% Wholesale export rate, Net Surplus Compensation Rate ($/kWh)
ex_wholesale = 0.03;

%% Loading Electric Rates

%%%Residential TOU Rates
rates_res.tou_fix = xlsread('Res_TOU.xlsx','Fixed');
rates_res.tou_1 = xlsread('Res_TOU.xlsx','4-9PM');
rates_res.tou_2 = xlsread('Res_TOU.xlsx','5-8PM');
rates_res.tou_3 = xlsread('Res_TOU.xlsx','PRIME');

%%%General TOU Rates
rates_gen.fix = xlsread('Gen_TOU.xlsx','Fixed');
rates_gen.dc = xlsread('Gen_TOU.xlsx','DC');
rates_gen.tou_1 = xlsread('Gen_TOU.xlsx','GS1');
rates_gen.tou_8= xlsread('Gen_TOU.xlsx','TOU-8');

%% Demand Charges
%%%Demand Charges
dc_nontou = rates_gen.dc(1,:);
dc_on = rates_gen.dc(2,:);
dc_mid = rates_gen.dc(3,:);

%% On/Midpeak index recorders
onpeak_index=zeros(length(elec),1);
midpeak_index=zeros(size(onpeak_index));

%% Generating TOU Rate Vectors
%%% Generating TOU Rate vectors
cnt = 1;
peak_times = zeros(length(datetimev),1);
for ii = 1:size(datetimev,1)
    if datetimev(ii,2) >= 6 && datetimev(ii,2) <= 9 %%%Summer
        if weekday(datenum(datetimev(ii,:))) ~= 1 && weekday(datenum(datetimev(ii,:))) ~= 7
            res_tou(ii,1) = rates_res.tou_1(datetimev(ii,4)+1,4);
            res_tou(ii,2) = rates_res.tou_2(datetimev(ii,4)+1,4);
            res_tou(ii,3) = rates_res.tou_3(datetimev(ii,4)+1,4);
            
            gen_tou(ii,1) = rates_gen.tou_1(datetimev(ii,4)+1,4);
            gen_tou(ii,2) = rates_gen.tou_8(datetimev(ii,4)+1,4);
            
            res_tou_ex(ii,:) = res_tou(ii,:) - rates_res.tou_fix(3,:);
            gen_tou_ex(ii,:) = gen_tou(ii,:) - rates_gen.fix(3,:);
        else
            res_tou(ii,1) = rates_res.tou_1(datetimev(ii,4)+1,5);
            res_tou(ii,2) = rates_res.tou_2(datetimev(ii,4)+1,5);
            res_tou(ii,3) = rates_res.tou_3(datetimev(ii,4)+1,5);
            
            gen_tou(ii,1) = rates_gen.tou_1(datetimev(ii,4)+1,5);
            gen_tou(ii,2) = rates_gen.tou_8(datetimev(ii,4)+1,5);
            
            res_tou_ex(ii,:) = res_tou(ii,:) - rates_res.tou_fix(3,:);
            gen_tou_ex(ii,:) = gen_tou(ii,:) - rates_gen.fix(3,:);
        end
    else %%%Winter
        if weekday(datenum(datetimev(ii,:))) ~= 1 && weekday(datenum(datetimev(ii,:))) ~= 7
            res_tou(ii,1) = rates_res.tou_1(datetimev(ii,4)+1,2);
            res_tou(ii,2) = rates_res.tou_2(datetimev(ii,4)+1,2);
            res_tou(ii,3) = rates_res.tou_3(datetimev(ii,4)+1,2);
            
            gen_tou(ii,1) = rates_gen.tou_1(datetimev(ii,4)+1,2);
            gen_tou(ii,2) = rates_gen.tou_8(datetimev(ii,4)+1,2);
            
            res_tou_ex(ii,:) = res_tou(ii,:) - rates_res.tou_fix(3,:);
            gen_tou_ex(ii,:) = gen_tou(ii,:) - rates_gen.fix(3,:);
        else
            res_tou(ii,1) = rates_res.tou_1(datetimev(ii,4)+1,3);
            res_tou(ii,2) = rates_res.tou_2(datetimev(ii,4)+1,3);
            res_tou(ii,3) = rates_res.tou_3(datetimev(ii,4)+1,3);
            
            gen_tou(ii,1) = rates_gen.tou_1(datetimev(ii,4)+1,3);
            gen_tou(ii,2) = rates_gen.tou_8(datetimev(ii,4)+1,3);
            
            res_tou_ex(ii,:) = res_tou(ii,:) - rates_res.tou_fix(3,:);
            gen_tou_ex(ii,:) = gen_tou(ii,:) - rates_gen.fix(3,:);
        end
    end
    
    %%%Determining peak times
    if weekday(datenum(datetimev(ii,:))) ~= 1 && weekday(datenum(datetimev(ii,:))) ~= 7 ... %%%Is a work day
            && datetimev(ii,4) >=16 && datetimev(ii,4) <21 %%%Is between 4pm and 9pm
        peak_times(ii) = 1;%%%Peak time occurs
        
        %%% Summer peak times
        if datetimev(ii,2) >= 6 && datetimev(ii,2) <= 9 %%%Summer
            onpeak_index(ii) = 1;
        else %%%Winter peak times
            midpeak_index(ii) = 1;
        end
            
    end
end

%% Counting Months where on-peak and mid-peak occur
onpeak_count = 0;
midpeak_count = 0;
for i = 1:length(endpts)
    if i == 1
        start = 1;
        finish=endpts(1);
    else
         start = endpts(i-1) + 1;
        finish = endpts(i);
    end
    if sum(onpeak_index(start:finish)) > 0
        onpeak_count = onpeak_count + 1;
    end
    if sum(midpeak_index(start:finish)) > 0
         midpeak_count = midpeak_count + 1;
    end
end
%% Combining Prices
import_price = [gen_tou res_tou];

export_price = [gen_tou_ex res_tou_ex];

%% Rate Labels 
rate_labels = {'GS1','TOU8','R1','R2','R3'};


%% ESA/CARE Info
care_energy_rebate = 0.3; %%%Rebate assocaited with CARE rates
% care_nbc_rebate = 0.3;
