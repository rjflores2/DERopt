imported_gas_kWh= sum(var_gwh.gwh_gas) + sum(var_gsph.gsph_gas);
              
imported_gas_dollar =sum(ng_cost * var_gwh.gwh_gas)+...
                    sum(ng_cost * var_gsph.gsph_gas)
                
imported_elec_kWh = sum(var_util.import);
imported_elec_dollar = sum(var_util.import.*day_multi.*import_price(:,index))

exported_REES_kWh = sum(var_rees.rees_dchrg_nem)
exported_PV_kWh = sum(var_pv.pv_nem)
import_elec_TDV = sum(var_util.import.*tdv_elec) 
import_gas_TDV = sum(var_gwh.gwh_gas.*tdv_gas.*tdv_gas_mod) + ...
              sum(var_gsph.gsph_gas.*tdv_gas.*tdv_gas_mod)

import_TDV = sum(var_util.import.*tdv_elec) + ...
             sum(var_gwh.gwh_gas.*tdv_gas.*tdv_gas_mod) + ...
             sum(var_gsph.gsph_gas.*tdv_gas.*tdv_gas_mod);

export_TDV = sum(var_pv.pv_nem.*tdv_elec) +...
             sum(var_rees.rees_dchrg_nem.*tdv_elec);
%% Capital and O&M Costs
%PV
PV_Cost= sum(M*pv_mthly_debt.*pv_cap_mod'.*var_pv.pv_adopt)...
        + pv_v(3)*(sum(sum(repmat(day_multi,1,K).*(var_pv.pv_elec + var_pv.pv_nem))))
    
REES_Cost= sum(rees_mthly_debt*M.*rees_cap_mod'.*var_rees.rees_adopt) ...
            + ees_v(2)*sum(sum(repmat(day_multi,1,K).*var_rees.rees_chrg))... 
            + ees_v(3)*(sum(sum(repmat(day_multi,1,K).*(var_rees.rees_dchrg))))
        
EES_Cost= sum(ees_mthly_debt*M.*ees_cap_mod'.* var_ees.ees_adopt) ...
        + ees_v(2)*sum(sum(repmat(day_multi,1,K).* var_ees.ees_chrg)) ...
        + ees_v(3)*sum(sum(repmat(day_multi,1,K).* var_ees.ees_dchrg))

Export_Income =- (export_price(:,index)'*(var_rees.rees_dchrg_nem(:,k)) + (export_price(:,index)'* var_pv.pv_nem(:,k))); 
%% Avoided costs
pv_acc_dollar =sum(-day_multi.*export_price(:,index).*var_pv.pv_nem)

rees_acc_dollar = sum(day_multi.*(ees_v(3) - export_price(:,index)).*var_rees.rees_dchrg_nem)

%%check
export=(day_multi.*export_price(:,index).*var_pv.pv_nem)- ((day_multi.*(ees_v(3) - export_price(:,index)).*var_rees.rees_dchrg_nem));
total_load= elec + var_ees.ees_chrg + var_lees.ees_chrg + var_erwh.erwh_elec + var_ersph.ersph_elec;
%% plotting codes
days_to_look_at = 200;
xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
figure  
hold on
plot_dt = [var_util.import ...
    var_pv.pv_elec ...
    var_ees.ees_dchrg...
    var_rees.rees_dchrg ...
    var_sofc.sofc_elec ];
area(time,plot_dt)
plot(time,elec,'LineWidth',2,'Color','k')
plot(time,total_load,'LineWidth',2,'Color','r')
legend({'Grid','PV','EES','REES','SOFC'},'Location','northwest','Orientation','horizontal')
xlim(xlim_range)
datetick('x','ddd','KeepTicks')
box on
grid on
set(gca,'FontSize',14,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
hold off
