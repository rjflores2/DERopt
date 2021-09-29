%%%Transformer Cosntraints
if xfmr_on
    %%%Polygon constraints
    L = 20;%%%Number of polygons
    i = 0:L-1;
    theta = pi/L + i.*(2*pi)./L; %Angle of polygon i (rads)
    C = [cos(theta)' sin(theta)']; %cos/sin of theta for each polygon
    %     s = t_rating*cos(theta(1)); %s rating around archimedes circle
    
    for ii = 1:length(t_rating)
        %%%Buildings connected to the current transformer
        idx = find(t_map == ii);
        %%%Setting reactive power demand

        var_xfmr.Qinj(:,ii) = sum(elec(:,idx).*repmat(tan(acos(pf(idx))),length(elec),1),2);
        Constraints = [Constraints
            (var_xfmr.Pinj(:,ii) == sum(var_util.import(:,idx),2) - sum(var_pv.pv_nem(:,idx),2) - sum(var_rees.rees_dchrg_nem(:,idx),2)):'Real Power Equality'
            (C*[var_xfmr.Pinj(:,ii)'; var_xfmr.Qinj(:,ii)'] <= t_alpha.*t_rating(ii)):'Polygon Xfmr Constraints'];
    end
    
end