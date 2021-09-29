%% Determining Critical Loads for the Oak View Microgrid Project
unit_loads = xlsread('microgrid_loads.xlsx');

%%
elec_crit = [];
crit_tier_com = .25;

if ~isempty(crit_tier)
    for ii = 1:length(bldg)
        if strcmp(bldg(ii).type,'MFm') || strcmp(bldg(ii).type,'Single-Family Detached')  || strcmp(bldg(ii).type,'Residential')
            if  strcmp(bldg(ii).type,'Single-Family Detached')
                bldg(ii).units = 1;
            end
            if strcmp(bldg(ii).type,'MFm') && isempty(bldg(ii).units)
                bldg(ii).units = round(bldg(ii).footprint/1200);
            end
            if crit_tier == 1
                elec_crit(:,ii) = bldg(ii).units.*(sum(unit_loads(:,1:3),2) + unit_loads(:,4).*(sum(bldg(ii).gas_loads.Equip) == 0)) + bldg(ii).elec_loads.IntLight.*0.5 + bldg(ii).elec_loads.DHW;
            elseif  crit_tier == 2
                elec_crit(:,ii) = bldg(ii).elec_loads.IntLight.*0.5 + bldg(ii).elec_loads.DHW + bldg(ii).elec_loads.Plugload*0.5;
            elseif  crit_tier == 3
                elec_crit(:,ii) = bldg(ii).elec_loads.IntLight.*0.5 + bldg(ii).elec_loads.DHW + bldg(ii).elec_loads.Plugload*0.75 + bldg(ii).elec_loads.Cooling + bldg(ii).elec_loads.Heating;
            elseif  crit_tier == 4
                elec_crit(:,ii) = bldg(ii).elec_loads.IntLight.*0.5 + bldg(ii).elec_loads.DHW + bldg(ii).elec_loads.Plugload + bldg(ii).elec_loads.Cooling + bldg(ii).elec_loads.Heating;
            elseif  crit_tier == 5
                elec_crit(:,ii) =  bldg(ii).elec_loads.Total;
            end
            
        elseif strcmp(bldg(ii).type,'EPr') || strcmp(bldg(ii).type,'SUn') || strcmp(bldg(ii).type,'RtS') || strcmp(bldg(ii).type,'MLI') || strcmp(bldg(ii).type,'OfS')
            
            elec_crit(:,ii) = bldg(ii).elec_loads.Total.*crit_tier_com;
            
        else
            bldg(ii).type
            shittt
        end
        
    end
end

%% Formatting/shrinking data
if ~isempty(crit_tier)
    if ~isempty(bldg_ind)
        elec_crit = elec_crit(:,bldg_ind);
    end
    
    elec_crit_update = [];
    if downselection == 1
        for ii = 1:size(elec_crit,2)
            elec_crit_update(:,ii) = interp1(legacy.time,elec_crit(:,ii),time);
        end
    end
end