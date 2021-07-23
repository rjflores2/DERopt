%% Legacy TES
if ~isempty(cool) && sum(cool) >0 && ~isempty(tes_legacy)
    for i = 1:size(tes_legacy,2)
        
        Constraints=[Constraints
            (var_ltes.ltes_soc(2:length(elec),i) == tes_legacy(10,i).*var_ltes.ltes_soc(1:length(elec)-1,i)+var_ltes.ltes_chrg(2:length(elec),i).*(tes_legacy(8,i))-var_ltes.ltes_dchrg(2:length(elec),i).*(1/tes_legacy(9,i))):'TES Balance' %%%State of charge
            ((tes_legacy(1,i)*tes_legacy(4,i)) <= var_ltes.ltes_soc(:,i) <= (tes_legacy(1,i)*tes_legacy(5,i))):'TES Min/Max SOC'%%%Min/max SOC
            (var_ltes.ltes_chrg <= (tes_legacy(1,i)*tes_legacy(6,i))):'TES Mac Chrg'%%%Min/Max charge rate
            (var_ltes.ltes_dchrg <= (tes_legacy(1,i)*tes_legacy(7,i))):'TES Mac Dchrg'];%%%Min/Max
        
    end
end