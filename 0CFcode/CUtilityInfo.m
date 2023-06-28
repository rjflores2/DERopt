classdef CUtilityInfo

    properties (SetAccess = public)
        energy_charge
        dc_nontou
        dc_on
        dc_mid
        import_price
        export_price
        onpeak_count
        midpeak_count
        onpeak_index
        midpeak_index        
    end
    
    methods

        function obj = CUtilityInfo(rateType, exportOn, genExportOn, lmpData, electricityVectorSize)
            
            %% Current utility rates
            %%% Rates
            %%% 1: current rate, which does not value export
            %%% 2: current import rate + LMP export rate
            %%% 3: LMP Rate + 0.2 and LMP Export
             
            if rateType == 1

                obj.energy_charge = 0.21;   %$/kWh
                obj.dc_nontou = 9.16;           %$/kW - facility related demand charge
                obj.dc_on = 0;
                obj.dc_mid = 0;
                obj.import_price = obj.energy_charge.*ones(electricityVectorSize,1);

                if exportOn
                    obj.export_price = obj.import_price - 0.02;
                else
                    obj.export_price = zeros(length(elec),1);
                end
                
            elseif rateType == 2

                obj.energy_charge = 0.11; %$/kWh
                obj.dc_nontou = 9.16; %$/kW - facility related demand charge
                obj.dc_on = 0;
                obj.dc_mid = 0;
                obj.import_price = obj.energy_charge.*ones(electricityVectorSize,1);

                if exportOn || genExportOn
                    obj.export_price = lmpData;
                else
                    obj.export_price = zeros(length(elec),1);
                end
 
            elseif rateType == 3

                obj.energy_charge = 0;
                obj.dc_nontou = 9.16; %$/kW - facility related demand charge
                obj.dc_on = 0;
                obj.dc_mid = 0;
                obj.import_price = lmpData;
                
                if exportOn || genExportOn
                    obj.export_price = lmpData;
                else
                    obj.export_price = zeros(electricityVectorSize,1);
                end
            end

            obj.onpeak_count = 0;
            obj.midpeak_count = 0;
            obj.onpeak_index = zeros(electricityVectorSize,1);
            obj.midpeak_index = zeros(electricityVectorSize,1);

        end
        
    end
end

