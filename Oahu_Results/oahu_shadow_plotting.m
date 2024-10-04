clc, clear all, close all

dt = readtable("shadow_results.xlsx");

wave_potential = readtable("H:\_Tools_\DERopt\Data\Oahu\Wave_Potential.xlsx");

%%


wave_power = table2array(dt(1,2:end));

wave_value = table2array(dt(16,2:end));

wave_value = -pvfix(0.06,10,wave_value);

energy = table2array(dt(8:10,2:end));
energy_fraction = table2array(dt(12:14,2:end));

%% Calculating utilizaiton
wave_energy_potential = wave_power.*sum(wave_potential.Normalized_Power);

wave_utilization = energy(1,:)./wave_energy_potential.*100;
wave_utilization(1) = 100;


wave_marginal_utilization = []
wave_marginal_utilization = (energy(1,2:end) - energy(1,1:end-1))./wave_energy_potential(2).*100;
wave_marginal_utilization = [100 wave_marginal_utilization];


solar_tracking = readtable('H:\_Tools_\DERopt\Data\Oahu\solar_tracking_Oahu.csv');
solar = [solar_tracking.ACSystemOutput_W_];

 dt = readtable('H:\_Tools_\DERopt\Data\Oahu\Oahu_Loads_8760.xlsx');

    time = datenum(dt.Date);
    elec = dt.ElectricDemand_kW_;
%%
close all
figure
tiledlayout(2,1)
nexttile
hold on


yyaxis left
plot(wave_power./1000,wave_value./1000,'LineWidth',2)
box on
grid on
set(gca,'FontSize',14,...
    'YTick',[0:6],...
    'YColor',[0 0 0])
xlabel('Wave Power Capacity','FontSize',16)
ylabel({'Marginal Value of','Wave Power ($1000/kW)'},'FontSize',16)

yyaxis right
plot(wave_power./1000,wave_utilization,'LineWidth',2)
plot(wave_power./1000,wave_marginal_utilization,'LineWidth',2)
ylabel({'Wave Potential','Utilization (%))'},'FontSize',16)
ylim([0 100])
set(gca,'FontSize',14,...
    'YTick',[0:25:100],...
    'YColor',[0 0 0])
legend('Marginal Value','Average Utilization','Marginal Utilization','Location','SouthWest')
hold off



nexttile
hold on
area(wave_power./1000,energy_fraction'.*100)
set(gca,'FontSize',14)
xlabel('Wave Power Capacity','FontSize',16)
ylabel({'Primary Energy','Source (%)'},'FontSize',16)
ylim([0 100])
grid on
box on
legend('Wave','Solar','Fossil','Orientation','horizontal','Location','south')
set(gcf,'Position',[10 10 800 550])

%% Wave Power
clc
tm = 0:1/24:365-1/24;

rng = [100/8760:100/8760:100];

tm_ticks = 15:30:350;

close all
figure
tiledlayout(2,2)
nexttile
hold on
plot(tm,wave_potential.Normalized_Power.*100,'LineWidth',2)
set(gca,'FontSize',14,...
    'XTick',tm_ticks)
box on
grid on
xlim([0 365-1/24])
ylim([0 100])
datetick('x','mmm','keeplimits','keepticks')
ylabel('Wave Power Potential (%)','FontSize',16)
hold off

nexttile
hold on
plot(rng,sort(wave_potential.Normalized_Power.*100,'descend'),'LineWidth',2)
set(gca,'FontSize',14)
box on
grid on
xlim([0 100])
ylim([0 100])
xlabel('Time (%)','FontSize',16)
ylabel('Wave Power Potential (%)','FontSize',16)
hold off


nexttile
hold on
plot(tm,solar.*100,'LineWidth',2)
set(gca,'FontSize',14,...
    'XTick',tm_ticks)
box on
grid on
xlim([0 365-1/24])
ylim([0 100])
datetick('x','mmm','keeplimits','keepticks')
ylabel('Solar Potential (%)','FontSize',16)
hold off

nexttile
hold on
plot(rng,sort(solar.*100,'descend'),'LineWidth',2)
set(gca,'FontSize',14)
box on
grid on
xlim([0 100])
ylim([0 100])
xlabel('Time (%)','FontSize',16)
ylabel('Solar Potential (%)','FontSize',16)
hold off

set(gcf,'Position',[10 10 1650 600])

%%
close all
figure
hold on
plot(time(1:24),elec(1:24)./1000,'LineWidth',2)

plot(time(1:24),mean(elec(1:24))./1000.*ones(24,1),'LineWidth',2)

xlim([time(1) time(24)])
set(gca,'FontSize',14,...
    'XTick',time([1:6:24 24]))
box on
grid on
ylabel('Oahu Load (MW)')
datetick('x','HH PM','keeplimits','keepticks')
set(gcf,'Position',[10 10 450 200])
legend('Load','Avg. Load','Location','NorthWest')