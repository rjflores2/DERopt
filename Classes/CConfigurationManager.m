classdef CConfigurationManager < handle
    
    properties (SetAccess = public)

        demo_files_path
        demo_data_path
        yalmip_master_path
        matlab_path
        results_path

        co2_base                    % Baseline CO2 emissions [Kg]
        co2_red                     % CO2 Desired reduction [%]

        year_idx
        month_idx
        saveResultsToFile



        
    end

    properties (SetAccess = private)

    end


    methods

        %--------------------------------------------------------------------------
        function obj = CConfigurationManager()

            obj.ResetToDefault();

        end
        
        %--------------------------------------------------------------------------
        function ResetToDefault(obj)

            obj.SetRunningEnvironment(1);       % 1 - Robert's PC

            obj.co2_base = [];
            obj.co2_red = 0;                    % [0 0.05];
            obj.year_idx = 2018;
            obj.month_idx = [1 4 7 10];
            obj.saveResultsToFile = false;
            
        end

        
        %--------------------------------------------------------------------------
        function SetRunningEnvironment(obj, mode)

            if mode == 1                    % 1 - Robert's PC
            
                obj.demo_files_path = 'H:\_Tools_\DERopt';
                obj.demo_data_path = 'H:\_Tools_\DERopt\Data';
                obj.results_path = 'H:\_Tools_\UCI_Results\Sc19';
            
                obj.yalmip_master_path = 'H:\Matlab_Paths\YALMIP-master';
                obj.matlab_path = 'C:\Program Files\MATLAB\R2014b\YALMIP-master';
            
            
            elseif mode == 2                    % 2 - Roman's Laptop
            
                obj.demo_files_path = 'C:\MotusVentures\DERopt';
                obj.demo_data_path = 'C:\MotusVentures\DERopt\Data';
                obj.results_path = 'C:\MotusVentures\DERopt\SolveResults';
            
                obj.yalmip_master_path = 'C:\MotusVentures\YALMIP-master';
                obj.matlab_path = 'C:\Program Files\MATLAB\R2023a\YALMIP-master';

            else                                % 3 - Roman's Desktop
            
                obj.demo_files_path = 'E:\MotusVentures\DERopt';
                obj.demo_data_path = 'E:\MotusVentures\DERopt\Data';
                obj.results_path = 'E:\MotusVentures\DERopt\SolveResults';
            
                obj.yalmip_master_path = 'C:\MotusVentures\YALMIP-master';
                obj.matlab_path = 'C:\Program Files\MATLAB\R2023a\YALMIP-master';
            
            end

        end


        %--------------------------------------------------------------------------
        function [co2Limit] = SetUpFirstCO2Limit(obj)

            co2Limit = obj.co2_base * (1 - obj.co2_red(1));

        end


    end
end

