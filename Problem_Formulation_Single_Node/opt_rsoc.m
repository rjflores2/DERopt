%% RSOC Constraints

% RSOC Max Capacity Adopted
if ~isempty(rsoc_v)
    Constraints = [Constraints
        (sum(rsoc_v(5).*var_rsoc.rsoc_elec,2) + sum(var_rsoc.rsoc_prod,2) ...
        <= sum(var_rsoc.rsoc_adopt,2)*(1/e_adjust)):'rSOC Max Capacity'
        (-var_rsoc.rsoc_adopt*(rsoc_v(7)/e_adjust/rsoc_v(5)) <= var_rsoc.rsoc_elec(2:size(var_rsoc.rsoc_elec,1)) - ...
            var_rsoc.rsoc_elec(1:size(var_rsoc.rsoc_elec,1) - 1) <= var_rsoc.rsoc_adopt*(rsoc_v(7)/e_adjust/rsoc_v(5))):...
            'rSOC electricity Production'
        (-var_rsoc.rsoc_adopt*(rsoc_v(7)/e_adjust/rsoc_v(5)) <= var_rsoc.rsoc_prod(2:size(var_rsoc.rsoc_prod,1)) - ...
            var_rsoc.rsoc_prod(1:size(var_rsoc.rsoc_prod,1) - 1) <= var_rsoc.rsoc_adopt*(rsoc_v(7)/e_adjust/rsoc_v(5))):...
            'rSOC hydrogen Production'];
% Temp opt out.
%          (var_rsoc.rsoc_elec(:,ii) <= var_rsoc.rsoc_bin(:,ii)*10000):'RSOC Elec Op State'
%          (var_rsoc.rsoc_prod(:,ii) <= (1 - var_rsoc.rsoc_bin(:,ii))*10000):'RSOC H2 Op State'];
%     
    %%% START RJF deactivated constraints
    
         %%%%Try running w/out these constraints. If operational state
         %%%%requirements are violated, introduce 'RSOC Elec Op State' & 'H2ES Op State' Only
       
%     
%         (-(1-var_rsoc.rsoc_bin)*1000 + var_rsoc.rsoc_adopt*rsoc_v(6) <= var_rsoc.rsoc_elec):'rSOC min load elec'
%         (-var_rsoc.rsoc_bin*1000 + var_rsoc.rsoc_adopt*rsoc_v(6) <= var_rsoc.rsoc_prod):'rSOC min load prod'
    
    
    %%%% END RJF deactivated constraints
%         (1000 <= var_rsoc.rsoc_adopt):'Forced rSOC Adoption'
%         (var_rsoc.rsoc_adopt.*(1/e_adjust)*0.1*length(time) <= sum(var_rsoc.rsoc_elec)): ' Forced rSOC H2 production'
%         (var_rsoc.rsoc_elec(:,ii) <= var_rsoc.rsoc_op(:,ii)*20000):'rSOC Op State'
%         (var_rsoc.rsoc_prod(:,ii) <= (1-var_rsoc.rsoc_op(:,ii))*20000):'rSOC Op State'  
%         (var_rsoc.rsoc_adopt.*(1/e_adjust)*0.1*length(time) <= sum(var_rsoc.rsoc_prod)): ' Forced rSOC H2 production' 
    
end


%         (4000*0.5*length(time) <= sum(var_rsoc.rsoc_prod)):'rSOC H2 Production'
% 