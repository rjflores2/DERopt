%%%Transformer Cosntraints
% if xfmr_on
if (xfmr_on && acpf_sim) || (acpf_sim >= 1)
    %%%Unique transformers
    xfmr_subset_unique = unique(xfmr_subset);
    
    %%%Polygon constraints
    L = 20;%%%Number of polygons
    i = 0:L-1;
    theta = pi/L + i.*(2*pi)./L; %Angle of polygon i (rads)
    C = [cos(theta)' sin(theta)']; %cos/sin of theta for each polygon
    %     s = t_rating*cos(theta(1)); %s rating around archimedes circle
    pf = 0.95.*ones(1,size(elec,2));
    
    if xfmr_on && acpf_sim == 0
        for ii = 1:length(t_rating)
            %%%Buildings connected to the current transformer
            idx = find(t_map == ii);
            %%%Setting reactive power demand
            
            var_xfmr.Qinj(:,ii) = sum(elec(:,idx).*repmat(tan(acos(pf(idx))),length(elec),1),2);
            Constraints = [Constraints
                (var_xfmr.Pinj(ii,:)' == sum(var_util.import(:,idx),2) - sum(var_pv.pv_nem(:,idx),2) - sum(var_rees.rees_dchrg_nem(:,idx),2)):'Real Power Equality'
                (C*[var_xfmr.Pinj(ii,:); var_xfmr.Qinj(ii,:)] <= t_alpha.*t_rating(ii)):'Polygon Xfmr Constraints'];
        end
    elseif xfmr_on && acpf_sim >= 1
        for ii = 1:length(xfmr_subset_unique)%N
            %%%Empty bus not connected to any load
            if isempty(find(strcmp(bb_lbl(ii + 1),xfmr_subset_unique)))
                Constraints = [Constraints
                    (var_xfmr.Pinj(ii,:)' == 0):'Power injection at branching bus is zero'];
            else %%%Load
                
                idx = find(strcmp(xfmr_subset_unique(ii),xfmr_subset));
                var_xfmr.Qinj(ii,:) = sum(elec(:,idx).*repmat(tan(acos(pf(idx))),length(elec),1),2);
                Constraints = [Constraints
                    (var_xfmr.Pinj(ii,:)' == -(sum(var_util.import(:,idx),2) - sum(var_pv.pv_nem(:,idx),2) - sum(var_rees.rees_dchrg_nem(:,idx),2))):'Real Power Equality'];
                
                if acpf_xfmr_on
                     Constraints = [Constraints
                    (C*[var_xfmr.Pinj(ii,:); var_xfmr.Qinj(ii,:)] <= t_alpha.*t_rating(ii)):'Polygon Xfmr Constraints'];
                end
            end
        end
        
    end
    
end