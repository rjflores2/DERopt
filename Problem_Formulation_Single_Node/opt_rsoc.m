%% RSOC Constraints

% RSOC Max Capacity Adopted
if ~isempty(rsoc_v)
    Constraints = [Constraints
        (sum(rsoc_v(5).*var_rsoc.rsoc_elec,2) + sum(var_rsoc.rsoc_prod,2) ...
        <= sum(var_rsoc.rsoc_adopt,2).*(1/e_adjust)):'rSOC Max Capacity'
        (-var_rsoc.rsoc_adopt.*rsoc_v(6) <= var_rsoc.rsoc_elec(2:size(var_rsoc.rsoc_elec,1)) - ...
            var_rsoc.rsoc_elec(1:size(var_rsoc.rsoc_elec,1) - 1) <= var_rsoc.rsoc_adopt):...
            'rSOC electricity Production'
        (-var_rsoc.rsoc_adopt.*rsoc_v(6) <= var_rsoc.rsoc_prod(2:size(var_rsoc.rsoc_prod,1)) - ...
            var_rsoc.rsoc_prod(1:size(var_rsoc.rsoc_prod,1) - 1) <= var_rsoc.rsoc_adopt):...
            'rSOC hydrogen Production'
        (var_rsoc.rsoc_elec(:,ii) <= var_rsoc.rsoc_bin(:,ii)*10000):'RSOC Elec Op State'
        (var_rsoc.rsoc_prod(:,ii) <= (1 - var_rsoc.rsoc_bin(:,ii))*10000):'H2ES Op State'];
%         (1000 <= var_rsoc.rsoc_adopt):'Forced rSOC Adoption'
%         (var_rsoc.rsoc_adopt.*(1/e_adjust)*0.1*length(time) <= sum(var_rsoc.rsoc_elec)): ' Forced rSOC H2 production'
%         (var_rsoc.rsoc_elec(:,ii) <= var_rsoc.rsoc_op(:,ii)*20000):'rSOC Op State'
%         (var_rsoc.rsoc_prod(:,ii) <= (1-var_rsoc.rsoc_op(:,ii))*20000):'rSOC Op State'  
%         (var_rsoc.rsoc_adopt.*(1/e_adjust)*0.1*length(time) <= sum(var_rsoc.rsoc_prod)): ' Forced rSOC H2 production' 
    
end


%         (4000*0.5*length(time) <= sum(var_rsoc.rsoc_prod)):'rSOC H2 Production'
% 