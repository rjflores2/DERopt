%% General equalities
%% Building Electrical Energy Balances
%%For  all timesteps t
%Vectorized
% Constraints = [Constraints
%     (sum(var_util.import,2) + sum(var_pv.pv_elec,2) + sum(var_ees.ees_dchrg,2) + sum(var_rees.rees_dchrg,2) + sum(var_ldg.ldg_elec,2) + sum(var_lbot.lbot_elec,2) == elec + sum(var_ees.ees_chrg,2) + var_vc.generic_cool./4  + sum(var_lvc.lvc_cool.*vc_cop,2)):'BLDG Electricity Balance'];

% Constraints = [Constraints
%     (sum(var_util.import,2) + sum(var_pv.pv_elec,2) + sum(var_ees.ees_dchrg,2) + sum(var_rees.rees_dchrg,2) + sum(var_ldg.ldg_elec,2) + sum(var_lbot.lbot_elec,2) == elec + sum(var_ees.ees_chrg,2) + var_vc.generic_cool./4  + sum(var_lvc.lvc_op.*vc_cop.*vc_size,2)):'BLDG Electricity Balance'];


lgth = round(length(time)/vc_hour_num);
for j = 1:vc_hour_num
    if j == 1
        st = 1;
        fn = j*lgth;
    elseif j == vc_hour_num
        st = (j-1)*lgth + 1;
        fn = length(elec);
    else
        st = (j-1)*lgth + 1;
        fn = j*lgth;
    end
    Constraints = [Constraints
        (sum(var_util.import(st:fn,:),2) ...
        + sum(var_pv.pv_elec(st:fn,:),2) ...
        + sum(var_ees.ees_dchrg(st:fn,:),2) ...
        + sum(var_rees.rees_dchrg(st:fn,:),2) ...
        + sum(var_ldg.ldg_elec(st:fn,:),2) ...
        + sum(var_lbot.lbot_elec(st:fn,:),2)...
        == elec(st:fn,:) ...
        + sum(var_ees.ees_chrg(st:fn,:),2) ...
        + var_vc.generic_cool(st:fn,:)./4  ...
        + sum(var_lvc.lvc_op(j).*vc_cop.*vc_size,2)) 
        var_vc.generic_cool(st:fn,:) + sum(var_ltes.ltes_dchrg(st:fn,:),2) + sum(vc_size.*var_lvc.lvc_op(j),2) == cool(st:fn,:) + sum(var_ltes.ltes_chrg(st:fn,:),2)];
    
    
    if rem(j,100) == 0
        j
    end
end
%% Heat Balance
if ~isempty(heat) && sum(heat>0)>0
    Constraints = [Constraints
        (var_boil.boil_rfuel + var_boil.boil_fuel).*boil_legacy(2) + var_ldg.hr_heat == heat];
end

%% Cooling Balance
% if ~isempty(cool) && sum(cool)>0
% %     Constraints = [Constraints
% %         var_vc.generic_cool + sum(var_ltes.ltes_dchrg,2) + sum(var_lvc.lvc_cool,2) == cool + sum(var_ltes.ltes_chrg,2)];
%     
%     Constraints = [Constraints
%         var_vc.generic_cool + sum(var_ltes.ltes_dchrg,2) + sum(vc_size.*var_lvc.lvc_op,2) == cool + sum(var_ltes.ltes_chrg,2)];
% end