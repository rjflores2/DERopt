
%%                 ZERO CARBON FUTURE
%
%%              DER Optimizer Demonstration Script
%
%   Created: May 3rd 2023               Version 2.0
%
%   Last Modified: June 14th 2023

clear;
close all;
clc;

%% Create DEC Optimizer

derOpt = CDEROptimizer();


%% Setup and configuration (other than default)

derOpt.SetMonthsSelection(7);                       % default: [1 4 7 10]

derOpt.CalculateInitialPathCO2Reduction(0, 50, 25);


%% Optimize and show results

mainFigure = uifigure();

PlotElectricSources = [];
PlotElectricLoads = [];

derOpt.Optimize(mainFigure, PlotElectricSources, PlotElectricLoads);

PlotLCOE = [];
PlotCostOfCO2 = [];
PlotCapitalCost = [];

derOpt.PlotOtherResults(PlotLCOE, PlotCostOfCO2, PlotCapitalCost);

close(mainFigure);

