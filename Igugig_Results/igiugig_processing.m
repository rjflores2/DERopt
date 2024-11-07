load diesel_8000.mat
%%
results_output.lcoe = solution.objval/sum(elec)

results_output.energy_source = [sum(var_legacy_diesel_binary.electricity)
    sum(var_ror_integer.elec)'
    sum(var_pv.pv_elec)'];

results_output.loads = [sum(elec)
    sum(var_ees.ees_chrg)+sum(var_lees.ees_chrg)
    sum(var_el_binary.el_prod.*el_binary_eff)];

results_output.storage_cycles = [sum(var_ees.ees_dchrg +var_lees.ees_dchrg)./(var_ees.ees_adopt + ees_legacy(1))
    sum(var_pem.elec)/var_h2es.h2es_adopt];

results_output.energy_source_percentage_of_generation = results_output.energy_source./sum(results_output.energy_source).*100;
results_output.energy_source_percentage_of_load = results_output.energy_source./sum(elec).*100;

results_output.co2_emisisons = sum(var_legacy_diesel_binary.electricity).*(1./ldiesel_binary_v(2,:)) ...
        .*(3.6) ... %%% Convert from kWh to MJ
        .*(1/135.6) ... %%% Convert from MJ to Gallons diesel fuel
        .*(10.19); %%%Convert from gallons to kg CO2

results_output.co2_intensity = results_output.co2_emisisons/sum(elec);

results_output.adopted_tech = [var_ror_integer.units'
    var_pv.pv_adopt'
    var_ees.ees_adopt
    var_el_binary.el_adopt
    var_h2es.h2es_adopt
    var_pem.cap]

var_ror_integer.old_elec = var_ror_integer.elec;
var_pv.old_pv_elec = var_pv.pv_elec;
%%
% for ii = 1:length(time)
%     if var_ror_integer.elec(ii,1) < 9 %&& var_pv.pv_elec(ii) > 0
% var_ror_integer.elec(ii,1) = var_ror_integer.elec(ii-1);
% var_pv.pv_elec(ii) = var_pv.pv_elec(ii) - var_ror_integer.elec(ii,1);
%     end
% end
107
x_days = [300];


%%% Plotting generation
close all
figure
tiledlayout(2,1)
nexttile
hold on
plot_data = [sum(var_ror_integer.elec,2) ...
    sum(var_pv.pv_elec,2)...
    var_legacy_diesel_binary.electricity...
    var_pem.elec ...
    sum(var_ees.ees_dchrg +var_lees.ees_dchrg,2)
    ];

a1 = area(time,plot_data)
plot(time,elec,'LineWidth',2,'Color',[0 0 0])

box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(time(1))+.5:1:floor(time(end))+.5])
xlim([time((x_days-1)*24+1)  time((x_days+6)*24)])
if ldiesel_binary_on
legend(a1([1:3 5]),'Hydrokinetic','Solar PV','Diesel','Battery Discharge','Orientation','horizontal','Location','south')
else
legend(a1([1:2 4:5]),'Hydrokinetic','Solar PV','PEMFC','Battery Discharge','Orientation','horizontal','Location','south')
end
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)

hold off

% set(gcf,'Position',[10 10 900 300])

% clc, close all
nexttile
hold on

plot_data = [elec ...
    sum(var_ees.ees_chrg +var_lees.ees_chrg,2) ...
    var_el.el_prod.*el_binary_eff ];

a2 = area(time,plot_data)
box on
grid on
set(gca,'FontSize',14,...
'XTick',[floor(time(1))+.5:1:floor(time(end))+.5])
xlim([time((x_days-1)*24+1)  time((x_days+6)*24)])
datetick('x','ddd','keeplimits','keepticks')
ylabel('Generation (kW)','FontSize',16)
legend(a2,'Load','Battery Charge','Electrolyzer','Orientation','horizontal','Location','south')
hold off

set(gcf,'Position',[10 10 900 700])
%%
plot_data = [];
total_data = [sum(var_ror_integer.elec,2) ...
    sum(var_pv.pv_elec,2)...
    var_legacy_diesel_binary.electricity...
    var_pem.elec ...
    sum(var_ees.ees_dchrg +var_lees.ees_dchrg,2)
    ]./1000;
for ii = 1:length(endpts)
    plot_data(ii,:) = [sum(elec(stpts(ii):endpts(ii))) sum(total_data(stpts(ii):endpts(ii),:))];
end
plot_data


figure
hold on

b1 = bar([1:12],plot_data(:,2:4),'stacked')

set(gca,'FontSize',14,...
    'XTick',[1:12])
ylabel('Generation (MWh)','FontSize',16)
legend('Hydrokinetic','Solar PV','Diesel','Orientation','horizontal','Location','south')
box on
grid on


set(gcf,'Position',[10 10 900 300])
% bar([1:12] + .33 ,plot_data(:,1),'stacked')