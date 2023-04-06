%%%Constraints that consider resiliency requirements and must meet loads
if ~isempty(crit_load_lvl) && crit_load_lvl >0
    %% Electrical Energy Balance
    if sim_lvl == 1 || sim_lvl == 2
        Constraints = [Constraints
            (var_resiliency.pv_elec + var_resiliency.ees_dchrg + var_resiliency.import == var_resiliency.export + var_resiliency.ees_chrg + elec_res):'Critical Electric Energy Balance'];
    elseif sim_lvl == 3
        %%%Polygon constraints
        L = 30;%%%Number of polygons
        i = 0:L-2;
        theta = [0 pi/L + i.*(pi/2)./L]; %Angle of polygon i (rads)
        theta = [0:pi/2/L:pi/2];
        C_gen = [cos(theta)' sin(theta)']; %cos/sin of theta for each polygon

        Constraints = [Constraints
            (var_resiliency.pv_real + var_resiliency.ees_dchrg_real + var_resiliency.import == var_resiliency.export + var_resiliency.ees_chrg + elec_res):'Critical Electric Energy Balance'
            (var_resiliency.pv_reactive + var_resiliency.ees_dchrg_reactive + var_resiliency.import_reactive== var_resiliency.export_reactive + elec_res_reactive):'Critical Reactive Electric Energy Balance'];
    end
    %% PV Production
    if ~isempty(pv_v) || ~isempty(pv_legacy)
        Constraints = [Constraints
            ( var_resiliency.pv_elec  <= (1/e_adjust).*repmat(legacy.solar(T_res(1):T_res(2)),1,K).*(repmat(pv_legacy_cap,size(elec_res,1),1) + repmat(var_pv.pv_adopt,size(elec_res,1),1))):'PV Resiliency Production'];
        if sim_lvl == 3
            for ii = 1:size(elec,2)
                Constraints = [Constraints
                    (C_gen*[var_resiliency.pv_real(:,ii)'; var_resiliency.pv_reactive(:,ii)'] <= repmat(var_resiliency.pv_elec(:,ii)',size(C_gen,1),1)):'PV Resiliency Real and Reactive Power'];
            end
            
        end
    end
    
    %% Storage
    if lees_on || lrees_on || ~isempty(ees_v)
        for k=1:K
            Constraints = [Constraints
                var_resiliency.ees_soc(1,k) <= var_resiliency.ees_soc(end,k)
                var_resiliency.ees_soc(2:end,k) == ees_v(10)*var_resiliency.ees_soc(1:end-1,k) + ees_v(8)*var_resiliency.ees_chrg(2:end,k)  - (1/ees_v(9))*var_resiliency.ees_dchrg(2:end,k)  %%%Minus discharging of
                ees_v(4)*(var_ees.ees_adopt(k) + var_rees.rees_adopt(k) + ees_legacy_cap(k) + rees_legacy_cap(k)) <= var_resiliency.ees_soc(:,k) <= ees_v(5)*(var_ees.ees_adopt(k) + var_rees.rees_adopt(k) + ees_legacy_cap(k) + rees_legacy_cap(k)) %%%Min/Max SOC
                var_resiliency.ees_chrg(:,k) <= ees_v(6)*(var_ees.ees_adopt(k) + var_rees.rees_adopt(k) + ees_legacy_cap(k) + rees_legacy_cap(k)) %%%Max Charge Rate
                var_resiliency.ees_dchrg(:,k) <= ees_v(7)*(var_ees.ees_adopt(k) + var_rees.rees_adopt(k) + ees_legacy_cap(k) + rees_legacy_cap(k))]; %%%Max Discharge Rate
            if sim_lvl == 3
                Constraints = [Constraints
                    (C_gen*[var_resiliency.ees_dchrg_real(:,k)'; var_resiliency.ees_dchrg_reactive(:,k)'] <= repmat(var_resiliency.ees_dchrg(:,k)',size(C_gen,1),1)):'EES Resiliency Real and Reactive Power'];
            end
        end
    end
    %% Connected to other buildings
    if sim_lvl == 2
        for ii = 1:length(xfmr_subset_unique)
            idx = find(strcmp(xfmr_subset_unique(ii),xfmr_subset));
            
            Constraints = [Constraints
                (sum(var_resiliency.import(:,idx),2) == sum(var_resiliency.export(:,idx),2)):'Resiliency imports = exports'];
        end
    end
    %% Connected to other transformers
    if sim_lvl == 3
        %%% Aggregating injeciton at each node
        idx_rec = [];
        %%%Polygon constraints
        L = 20;%%%Number of polygons
        i = 0:L-1;
        theta = pi/L + i.*(2*pi)./L; %Angle of polygon i (rads)
        C = [cos(theta)' sin(theta)']; %cos/sin of theta for each polygon
        %     s = t_rating*cos(theta(1)); %s rating around archimedes circle
        
%         for ii = 1:N
%             ii
%             if isempty(find(strcmp(bb_lbl(ii + 1),xfmr_subset_unique)))
%                 Constraints = [Constraints
%                     (var_resiliency.Pinj(ii,:)' == 0):'Resiliency Power injection at branching bus is zero'                    
%                     (var_resiliency.Qinj(ii,:)' == 0):'Resiliency ReactivePower injection at branching bus is zero'];
%             else
%                 ii
%                 idx = find(strcmp(xfmr_subset_unique(ii),xfmr_subset));
%                 idx_rec = [idx_rec;idx];
%                 Constraints = [Constraints
%                     (var_resiliency.Pinj(ii,:)' == -sum(-var_resiliency.import(:,idx) +var_resiliency.export(:,idx),2)):'Resiliency Real Power Equality'
%                     (var_resiliency.Qinj(ii,:)' == -sum(-var_resiliency.import_reactive(:,idx) +var_resiliency.export_reactive(:,idx),2)):'Resiliency Real Power Equality'];
%             end
%         end
        idx_rec = [];
        cnt = 1;
        
        for ii = 2:length(bb_lbl)
            
%             bb_lbl(ii)
            idx = find(strcmp(bb_lbl(ii),xfmr_subset));
            idx_rec = [idx_rec
                idx];
            if ~isempty(idx)
                Constraints = [Constraints
                    (var_resiliency.Pinj(ii - 1,:)' == -sum(-var_resiliency.import(:,idx) +var_resiliency.export(:,idx),2)):'Resiliency Real Power Equality'
                    (var_resiliency.Qinj(ii - 1,:)' == -sum(-var_resiliency.import_reactive(:,idx) +var_resiliency.export_reactive(:,idx),2)):'Resiliency Real Power Equality'];
            else
                
                 Constraints = [Constraints
                    (var_resiliency.Pinj(ii - 1,:)' == 0):'Resiliency Real Power Equality'
                    (var_resiliency.Qinj(ii - 1,:)' == 0):'Resiliency Real Power Equality'];
            end
            
            
            %%%If its a transformer in the table
            if ~isempty(xfmr_tbl.Rating_kVA_(find(strcmp(bb_lbl(ii),xfmr_tbl.Name))))
                Constraints = [Constraints
                    (C*[var_resiliency.Pinj(ii - 1,:) ; var_resiliency.Qinj(ii - 1,:)] <= 1*xfmr_tbl.Rating_kVA_(find(strcmp(bb_lbl(ii),xfmr_tbl.Name)))):'Resiliency xfmr aparent power limit'];
         
            inhere = ii
            end
            
            
        end
%             ii
%             if isempty(find(strcmp(bb_lbl(ii + 1),xfmr_subset_unique)))
%                 Constraints = [Constraints
%                     (var_resiliency.Pinj(ii,:)' == 0):'Resiliency Power injection at branching bus is zero'                    
%                     (var_resiliency.Qinj(ii,:)' == 0):'Resiliency ReactivePower injection at branching bus is zero'];
%             else
%                 idx = find(strcmp(xfmr_subset_unique(ii),xfmr_subset));
%                 idx_rec = [idx_rec;idx];
%                 Constraints = [Constraints
%                     (var_resiliency.Pinj(ii,:)' == -sum(-var_resiliency.import(:,idx) +var_resiliency.export(:,idx),2)):'Resiliency Real Power Equality'
%                     (var_resiliency.Qinj(ii,:)' == -sum(-var_resiliency.import_reactive(:,idx) +var_resiliency.export_reactive(:,idx),2)):'Resiliency Real Power Equality'];
%             end
%         end
        
%         idx_rec = sort(idx_rec);
        %%%Base voltage
        base_voltage = [12500/sqrt(3)
            zeros(size(branch_bus(:,2:end),1) - 1,1)];
        base_voltage = 12500/sqrt(3);
        %%%LinDistFlow
        Constraints = [Constraints
            (var_resiliency.Pinj == branch_bus(2:end,2:end)'*var_resiliency.pflow):'Resiliency LDF Real Power Flow'
            (var_resiliency.Qinj == branch_bus(2:end,2:end)'*var_resiliency.qflow):'Resiliency LDF Real Power Flow'
            (branch_bus(2:end,2:end)*var_resiliency.bus_voltage == 2.*resistance(2:end,2:end)*var_resiliency.pflow + 2.*reactance(2:end,2:end)*var_resiliency.qflow):'Resiliency - Voltage Constraints'
            (var_resiliency.bus_voltage(1,:) == base_voltage):'Reference Node Voltage'
            (base_voltage(1)*0.97 <= var_resiliency.bus_voltage <= base_voltage(1)*1.05):'Voltage PU Requirements'];
%             (branch_bus(2:end,2:end)*var_resiliency.bus_voltage + repmat(base_voltage,1,length(var_resiliency.bus_voltage )) == 2.*resistance*var_resiliency.pflow + 2.*reactance*var_resiliency.qflow):'Resiliency - Voltage Constraints'];
        
        
        
        %         (var_resiliency.Pinj == branch_bus(:,2:end)'*var_resiliency.pflow):'Resiliency LDF Real Power Flow'
%         (var_resiliency.Qinj == branch_bus(:,2:end)'*var_resiliency.qflow):'Resiliency LDF Real Power Flow'
%     (var_resiliency.pflow(1,:)' == 0):'Resiliency - cut power flow at first branch'
%         (var_resiliency.qflow(1,:)' == 0):'Resiliency - cut reactive power flow at first branch'
% (branch_bus(:,2:end)*var_resiliency.bus_voltage + repmat(base_voltage,1,length(var_resiliency.bus_voltage )) == 2.*resistance*var_resiliency.pflow + 2.*reactance*var_resiliency.qflow)
    end
end