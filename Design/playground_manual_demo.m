
%% This is the file to run DERopt Manually

clear;
close all;
clc;


%% temporary solution to run in different installs...
opList = {'1 - Robert''s PC', '2 - Roman''s Laptop', '3 - Roman''s Desktop'};

[demo_files_location,~] = listdlg('ListString',opList,'SelectionMode','single', 'InitialValue',1,'PromptString','Select Environment','ListSize',[160 60]);

if isempty(demo_files_location)
    demo_files_location = 1;
end

%% Create all variables and default values (idem manual UI app)

% Baseline CO2 emissions [kg]
playground_run_cfg.co2_baseline_emissions_kg = [];

% Desired reduction
%playground_run_cfg.co2_desired_amount_reduction = [0:0.05:.5];
playground_run_cfg.co2_desired_amount_reduction = [0 0.05];

% Building DataValues to filter data by
playground_run_cfg.month_idx = [1 4 7 10];
playground_run_cfg.year_idx = 2018;


% Demo files location
if demo_files_location == 1       % 1 - Robert's PC

    playground_run_cfg.files_path = 'H:\_Tools_';
    playground_run_cfg.data_path = 'H:\Data\UCI';
    playground_run_cfg.results_path = 'H:\_Tools_\UCI_Results\Sc19';

    playground_run_cfg.yalmip_master_path = 'H:\Matlab_Paths\YALMIP-master';
    playground_run_cfg.matlab_path = 'C:\Program Files\MATLAB\R2014b\YALMIP-master';


elseif demo_files_location == 2   % 2 - Roman's Laptop

    playground_run_cfg.files_path = 'C:\MotusVentures';
    playground_run_cfg.data_path = 'C:\MotusVentures\DERopt\Data';
    playground_run_cfg.results_path = 'C:\MotusVentures\DERopt\SolveResults';

    playground_run_cfg.yalmip_master_path = 'C:\MotusVentures\YALMIP-master';
    playground_run_cfg.matlab_path = 'C:\Program Files\MATLAB\R2023a\YALMIP-master';


else                                % 3 - Roman's Desktop

    playground_run_cfg.files_path = 'E:\MotusVentures';
    playground_run_cfg.data_path = 'E:\MotusVentures\DERopt\Data';
    playground_run_cfg.results_path = 'E:\MotusVentures\DERopt\SolveResults';

    playground_run_cfg.yalmip_master_path = 'C:\MotusVentures\YALMIP-master';
    playground_run_cfg.matlab_path = 'C:\Program Files\MATLAB\R2023a\YALMIP-master';

end

%%%cyc PC Paths
% addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Design'))
% addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Input_Data'))
% addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Load_Processing'))
% addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Post_Processing'))
% addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Problem_Formulation_Single_Node'))
% addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Techno_Economic'))
% addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Utilities'))
%
% %%%cyc Office Paths
% addpath(genpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Design'))
% addpath(genpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Input_Data'))
% addpath(genpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Load_Processing'))
% addpath(genpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Post_Processing'))
% addpath(genpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Problem_Formulation_Single_Node'))
% addpath(genpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Techno_Economic'))
% addpath(genpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Utilities'))

%%%Specific project path
% addpath('H:\_Research_\CEC_OVMG\DERopt')

%%%SGIP CO2 Signal
% addpath('H:\Data\CPUC_SGIP_Signal')
% addpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Data')
% addpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Data')

%%%CO2 Signal Path
% addpath('H:\Data\Emission_Factors')
% addpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Data\Emission_Factors')
% addpath('C:\Users\cyc\OneDrive - UC Irvine\DERopt (Office New)\Data\Emission_Factors')



%%-------------------------------------------------------------------------
%--------------------------------------------------------------------------
%        
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------


%% Run DERopt optimization

optRec = playground_demo_function(playground_run_cfg);



%%-------------------------------------------------------------------------
%--------------------------------------------------------------------------
%        
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------







%%-------------------------------------------------------------------------
%--------------------------------------------------------------------------
%        SHOW RESULTS (Plot data)
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%%% Plot 'LCOE ($/kWh)'
figure
hold on
plot(optRec.co2_emissions_red,optRec.financials.lcoe,'LineWidth',2)
box on
grid on
ylabel('LCOE ($/kWh)','FontSize',18)
xlabel('CO_2 Reduction (%)','FontSize',18)
set(gcf,'Position',[100 100 500 275])
xlim([0 50])
hold off
    
        
%%% Plot 'Cost of Carbon'
close all
figure
hold on
plot(optRec.co2_emissions_red,optRec.financials.cost_of_co2,'LineWidth',2)
plot(optRec.co2_emissions_red,optRec.financials.cost_of_co2_marginal,'LineWidth',2)
box on
grid on
ylabel('Cost of CO_2 ($/tonne)','FontSize',18)
xlabel('CO_2 Reduction (%)','FontSize',18)
set(gcf,'Position',[100 100 500 275])
xlim([5 50])
legend('Average Cost','Marginal Cost','Location','NorthWest')
hold off


%%% Plot 'Capital Requirements'
close all
figure
hold on
plot(optRec.co2_emissions_red,sum(optRec.financials.cap_cost,2)./1000000,'LineWidth',2)
% plot(optRec.co2_emissions_red,optRec.financials.cost_of_co2_marginal,'LineWidth',2)
box on
grid on
ylabel('Capital Cost ($MM)','FontSize',18)
xlabel('CO_2 Reduction (%)','FontSize',18)
set(gcf,'Position',[100 100 500 275])
xlim([5 50])
% legend('Average Cost','Marginal Cost','Location','NorthWest')
hold off


%%% Dispatch Plots
close all
idx = 1;
    
dt1 = [sum(optRec.ldg.ldg_elec(:,idx),2)...
        sum(optRec.utility.import(:,idx),2)...
        sum(optRec.solar.pv_elec(:,idx),2) + sum(optRec.rees.rees_chrg(:,idx),2)...
        sum(optRec.ees.ees_dchrg(:,idx),2) + sum(optRec.rees.rees_dchrg(:,idx),2) + sum(optRec.lees.ees_dchrg(:,idx),2)];
         
dt2 = [optRec.elec ...
        sum(optRec.ees.ees_chrg(:,idx),2) + sum(optRec.lees.ees_chrg(:,idx),2) + sum(optRec.rees.rees_chrg(:,idx),2)...
        sum(optRec.el_eff.*optRec.el.el_prod(:,idx),2) + sum(optRec.h2_chrg_eff.*optRec.h2es.h2es_chrg(:,idx),2) + sum(optRec.rel_eff.*optRec.rel.rel_prod(:,idx),2) ...
        optRec.solar.pv_nem(:,idx)];



graphIndex = find(playground_run_cfg.month_idx == 7);
            
if isempty(graphIndex)
    graphIndex = 1;
end


%%% Plot 'Electric Sources (MW)'
figure
hold on
area(optRec.time,dt1.*4./1000)
set(gca,'XTick', round(optRec.time(1),0)+.5:round(optRec.time(end),0)+.5,'FontSize',14)
box on
grid on
datetick('x','ddd','keepticks')
xlim([optRec.time(optRec.stpts(graphIndex)) optRec.time(optRec.stpts(graphIndex)+96*7)])
ylabel('Electric Sources (MW)','FontSize',18)
legend('Gas Turbine','Utility Import','Solar','Battery Discharge','Location','Best')
set(gcf,'Position',[100 450 500 275])
hold off

%%% Plot 'Electric Loads (MW)'
figure
hold on
area(optRec.time,dt2.*4./1000)
set(gca,'XTick', round(optRec.time(1),0)+.5:round(optRec.time(end),0)+.5, 'FontSize',14)
box on
grid on
datetick('x','ddd','keepticks')
xlim([optRec.time(optRec.stpts(graphIndex)) optRec.time(optRec.stpts(graphIndex)+96*7)])
ylabel('Electric Loads (MW)','FontSize',18)
legend('Campus','Battery Charging','H_2 Production','Export','Location','Best')
set(gcf,'Position',[100 100 500 275])
hold off
