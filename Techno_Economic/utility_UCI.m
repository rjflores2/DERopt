%% Loading Utility Info
%% Current utility rates
%%% Rates
%%% 1: current rate, which does not value export
%%% 2: current import rate + LMP export rate
%%% 3: LMP Rate + 0.2 and LMP Export
if uci_rate == 1
    uci_energy_charge = 0.11; %$/kWh
    uci_energy_charge = 0.21; %$/kWh
    dc_nontou = 9.16; %$/kW - facility related demand charge
    dc_on = 0;
    dc_mid = 0;
    
    import_price = uci_energy_charge.*ones(length(elec),1);
    if export_on
        export_price = import_price - 0.02;
    else
        export_price = zeros(length(elec),1);
    end
    
elseif uci_rate == 2
    uci_energy_charge = 0.11; %$/kWh
    dc_nontou = 9.16; %$/kW - facility related demand charge
    dc_on = 0;
    dc_mid = 0;
    
    import_price = uci_energy_charge.*ones(length(elec),1);
    if export_on || gen_export_on
        export_price = lmp_uci;
    else
        export_price = zeros(length(elec),1);
    end
    
    
    
elseif uci_rate == 3
    dc_nontou = 9.16; %$/kW - facility related demand charge
    dc_on = 0;
    dc_mid = 0;
    import_price = lmp_uci;
    
    if export_on || gen_export_on
        export_price = lmp_uci;
    else
        export_price = zeros(length(elec),1);
    end
end


onpeak_count = 0;
midpeak_count = 0;
onpeak_index = zeros(length(elec),1);
midpeak_index = zeros(length(elec),1);
%% Rate Labels 
rate_labels = {'TOU8'};