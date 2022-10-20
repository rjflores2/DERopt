%% TDV
import_elec_TDV = sum(var_util.import.*tdv_elec) 
import_gas_TDV = sum((var_sofc.sofc_elec./sofc_v(3)).*tdv_gas.*tdv_gas_mod) +...
             sum(var_gwh.gwh_gas.*tdv_gas.*tdv_gas_mod) + ...
             sum(var_gsph.gsph_gas.*tdv_gas.*tdv_gas_mod)

import_TDV = sum(var_util.import.*tdv_elec) + ...
             sum((var_sofc.sofc_elec./sofc_v(3)).*tdv_gas.*tdv_gas_mod) +...
             sum(var_gwh.gwh_gas.*tdv_gas.*tdv_gas_mod) + ...
             sum(var_gsph.gsph_gas.*tdv_gas.*tdv_gas_mod);

export_TDV = sum(var_pv.pv_nem.*tdv_elec) +...
             sum(var_rees.rees_dchrg_nem.*tdv_elec);

%% Energy import and export (kWh)      
imported_gas_kWh= sum((var_sofc.sofc_elec./sofc_v(3)))+...
                  sum(var_gwh.gwh_gas) + sum(var_gsph.gsph_gas);
imported_elec_kWh = sum(var_util.import);
exported_REES_kWh = sum(var_rees.rees_dchrg_nem)
exported_PV_kWh = sum(var_pv.pv_nem)

%% Cost of energy import and onsite technologies (capital and O&M) 
imported_gas_dollar =sum(ng_cost * var_gwh.gwh_gas)+...
                    sum(ng_cost * var_gsph.gsph_gas)+...
                    sum(ng_cost * var_sofc.sofc_elec./sofc_v(3))
                
imported_elec_dollar = sum(var_util.import.*day_multi.*import_price(:,index))

PV_Cost= sum(M*pv_mthly_debt.*pv_cap_mod'.*var_pv.pv_adopt)...
        + pv_v(3)*(sum(sum(repmat(day_multi,1,K).*(var_pv.pv_elec + var_pv.pv_nem))))
    
REES_Cost= sum(rees_mthly_debt*M.*rees_cap_mod'.*var_rees.rees_adopt) ...
            + ees_v(2)*sum(sum(repmat(day_multi,1,K).*var_rees.rees_chrg))... 
            + ees_v(3)*(sum(sum(repmat(day_multi,1,K).*(var_rees.rees_dchrg))))
        
EES_Cost= sum(ees_mthly_debt*M.*ees_cap_mod'.* var_ees.ees_adopt) ...
        + ees_v(2)*sum(sum(repmat(day_multi,1,K).* var_ees.ees_chrg)) ...
        + ees_v(3)*sum(sum(repmat(day_multi,1,K).* var_ees.ees_dchrg))
    
SOFC_Cost= sum(M*sofc_mthly_debt.*var_sofc.sofc_adopt)...  %%%Annual investment/Capital Cost ($/kW)*(kW)
        + sum((sofc_v(2).* var_sofc.sofc_adopt))... %%% O&M ($/kW/yr)*(kW)
        + sum(ng_cost * var_sofc.sofc_elec./sofc_v(3))

SOFC_Cost_NoGas= sum(M*sofc_mthly_debt.*var_sofc.sofc_adopt)...  %%%Annual investment/Capital Cost ($/kW)*(kW)
        + sum((sofc_v(2).* var_sofc.sofc_adopt))... %%% O&M ($/kW/yr)*(kW)
        
%% SOFC Capacity Factor
SOFC_Capacity_Factor =sum(var_sofc.sofc_elec)/(length(elec)*sofc_v(5))

%% LCOE
SOFC_LCOE = SOFC_Cost/sum(var_sofc.sofc_elec)
PV_LCOE = PV_Cost/sum(var_pv.pv_elec + var_pv.pv_nem + var_rees.rees_chrg + var_lrees.rees_chrg )

%% Avoided costs
pv_acc_dollar =sum(-day_multi.*export_price(:,index).*var_pv.pv_nem)
rees_acc_dollar = sum(day_multi.*(ees_v(3) - export_price(:,index)).*var_rees.rees_dchrg_nem)
Export_Income =- (export_price(:,index)'*(var_rees.rees_dchrg_nem(:,k)) + (export_price(:,index)'* var_pv.pv_nem(:,k))); 
% EXPORT
REES_Export = sum(var_rees.rees_dchrg_nem)
PV_Export = sum(var_pv.pv_nem) 

%% Annual Energy Components 
REES_C = ees_v(8)*(sum(var_rees.rees_chrg))
REES_D = (1/ees_v(9))*(sum(var_rees.rees_dchrg))
REES_EXP =sum(var_rees.rees_dchrg_nem)
PV_Gen = sum(var_pv.pv_elec)+ sum(var_pv.pv_nem) + sum(var_rees.rees_chrg) + sum(var_lrees.rees_chrg)
PV_REES = sum(var_rees.rees_chrg)
%Domestic Hot Water balance
GWH_used_DHW =sum(var_gwh.gwh_gas)
TES_D = sum(var_tes.tes_dchrg)
GWH_DHW =sum(var_gwh.gwh_gas.*gwh_eff)
ERWH_DHW = sum(var_erwh.erwh_elec.*erwh_eff)
SOFC_DHW = sum(var_sofc.sofc_wh)
DHW_Demand = sum(dhw)
ERWH_DHW_elec_used = sum(var_erwh.erwh_elec)
% IMPORT
Grid_Total = sum(var_util.import)
EES_C = sum(var_ees.ees_chrg)
% LOAD balance
SOFC_Load = sum(var_sofc.sofc_elec)
PV_Load=sum(var_pv.pv_elec)
Grid_Load = sum(var_util.import) - EES_C
EES_Load = sum(var_ees.ees_dchrg)
REES_Load = sum(var_rees.rees_dchrg)
Total_Load= sum(elec) + sum(var_erwh.erwh_elec) + sum(var_ersph.ersph_elec)
Just_Building=sum(elec) %Includes the electricity demand for water heater and space heater (excludes the electricity charged in EES)
% Balance check
REES_Balance = (1/ees_v(9))*(sum(var_rees.rees_dchrg) + sum(var_rees.rees_dchrg_nem)) - ees_v(8)*(sum(var_rees.rees_chrg))
EES_Balance = (1/ees_v(9))*sum(var_ees.ees_dchrg) - ees_v(8)*(sum(var_ees.ees_chrg))

%% PV_Generation

export=(day_multi.*export_price(:,index).*var_pv.pv_nem)- ((day_multi.*(ees_v(3) - export_price(:,index)).*var_rees.rees_dchrg_nem));
total_load_building= elec + var_erwh.erwh_elec + var_ersph.ersph_elec;
PV_Total = ((var_pv.pv_elec)+ (var_pv.pv_nem) + (var_rees.rees_chrg) + (var_lrees.rees_chrg));
Grid = var_util.import;
plot(total_load_building)
hold on 
plot(total_load_building+var_ees.ees_chrg,'Color','b')
plot(Grid,'Color','r')
plot(var_rees.rees_dchrg,'LineWidth',2,'Color','c')
plot(var_ees.ees_dchrg,'LineWidth',1,'Color','m')
plot(var_ees.ees_chrg,'LineWidth',1,'Color','k')
plot(var_pv.pv_elec,'LineWidth',1)
plot(var_sofc.sofc_elec,'LineWidth',2,'Color','g')

legend({'building','building + EES-C','Grid','REES-D','EES-D','EES-C','PV','SOFC'},'Location','northwest','Orientation','horizontal')
%%%%
%  figure 
%  Grid = var_util.import;
%  PVEX = var_pv.pv_nem;
%  plot(var_util.import,'LineWidth',2,'Color','[0.4940 0.1840 0.5560]')
%  hold on 
%  plot(var_pv.pv_nem,'LineWidth',2,'Color','[0.4660 0.6740 0.1880]')
%var_util.import + var_pv.pv_elec 
%+ var_ees.ees_dchrg

% plot(time,PV_Total)
% HoursOfYear = ones(size(PV_Total));
% j = 1;
% HoursOfYear(j)=1
% for h= 0:1:8760
%     HoursOfYear(j) = h +1;
% end
% HoursOfYear
% plot(PV_Total(1:24))
% xticks([1 12 24])
% xlim([1 4])
% xticklabels({'1','2','3','4'})
% %% plotting codes
% days_to_look_at = 200;
% xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
% figure  
% hold on
% plot_dt = [var_sofc.sofc_elec...
%     var_util.import ...
%     var_pv.pv_nem+var_rees.rees_chrg ...
%     var_ees.ees_dchrg...
%     var_rees.rees_dchrg ...
%     ]; 
% area(time,plot_dt)
% hold on
% plot(time,elec,'LineWidth',2,'Color','k')
% plot(time,total_load_building,'LineWidth',2,'Color','r')
% plot(time,var_rees.rees_chrg,'LineWidth',2,'Color','g')
% plot(time,var_ees.ees_chrg,'LineWidth',2,'Color','m')
% plot(time,var_rees.rees_dchrg_nem,'LineWidth',2,'Color','c')
% legend({'SOFC','Grid','PV','EES','REES','building','total load','REES-C','EES-C','REES-exp'},'Location','northwest','Orientation','horizontal')
% xlim = (xlim_range)
% datetick('x','ddd','KeepTicks')
% box on
% grid on
% set(gca,'FontSize',14,...
%     'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
% hold off
% % %%
% %%
% days_to_look_at = 200;
% xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
% figure  
% hold on
% % plot_dt = [var_util.import ...
% %     var_pv.pv_elec ...
% %     var_ees.ees_dchrg...
% %     var_rees.rees_dchrg ...
% %     ]; 
% area(time,plot_dt)
% plot(time,elec,'LineWidth',2,'Color','k')
% plot(time,elec + var_erwh.erwh_elec + var_ersph.ersph_elec,'LineWidth',2,'Color','r')
% plot(time,total_load_building + var_ees.ees_chrg + var_rees.rees_chrg ,'LineWidth',2,'Color','m')
% plot(time,var_rees.rees_chrg,'LineWidth',2,'Color','g')
% plot(time,var_ees.ees_chrg,'LineWidth',2,'Color','c')
% legend({'elec','total(elec+HVAC+DHW)','total+batteries','REES-C','EES-C'},'Location','northwest','Orientation','horizontal')
% xlim(xlim_range)
% datetick('x','ddd','KeepTicks')
% box on
% grid on
% set(gca,'FontSize',14,...
%     'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
% hold off
% 
% 
% %%
% days_to_look_at = 200;
% xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
% figure  
% hold on
% plot_dt = [var_util.import ...
%       var_rees.rees_chrg...
%       var_ees.ees_dchrg ...
%     ]; 
% area(time,plot_dt)
% plot(time,total_load_building + var_ees.ees_chrg + var_rees.rees_chrg ,'LineWidth',2,'Color','m')
% legend({'import','PV-REES-C','EES-D','total+batteries'},'Location','northwest','Orientation','horizontal')
% xlim(xlim_range)
% datetick('x','ddd','KeepTicks')
% box on
% grid on
% set(gca,'FontSize',14,...
%     'XTick',[round(min(time)) :1: round(max(time)) + 0.5])
% hold off
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %% RJF plotting codes
% figure 
% 
% hold on
% plot(x,elec,'LineWidth',2,'Color','k')
% plot(x,var_pv.pv_nem,'LineWidth',2,'Color','c')
% xlim= [1 24]
% legend({'elec','PV-Gen'},'Location','northwest','Orientation','horizontal')
% box on
% grid on
% hold off
% % 
% % %% plotting codes - Load
% % days_to_look_at = 20;
% % xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
% % figure  
% % hold on
% % plot_dt = [var_ees.ees_dchrg...
% %            var_ees.ees_chrg...
% %                  ];
% % area(time,plot_dt)
% % plot(time,elec,'LineWidth',2,'Color','k')
% % plot(time,var_util.import,'LineWidth',2,'Color','b')
% % plot(time,var_ees.ees_soc,'LineWidth',2,'Color','m')
% % legend({'EES-DC','EES-C'},'Location','northwest','Orientation','horizontal')
% % xlim(xlim_range)
% % datetick('x','ddd','KeepTicks')
% % box on
% % grid on
% % set(gca,'FontSize',14,...
% %     'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
% % hold off
% % 
% % %%
% % days_to_look_at = 20;
% % xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
% % figure 
% % hold on
% % plot_dt = [var_ees.ees_dchrg...
% %        var_rees.rees_dchrg...
% %        var_util.import...   
% %        var_rees.rees_dchrg_nem ...
% %     ]
% % area(time,plot_dt)
% % plot(time,var_pv.pv_elec+var_pv.pv_nem+var_rees.rees_chrg,'LineWidth',4,'Color','g')
% % % plot(time,var_util.import,'LineWidth',2,'Color','c')
% % plot(time,var_rees.rees_chrg,'LineWidth',2,'Color','m')
% % plot(time,elec,'LineWidth',2,'Color','k')
% % plot(time,var_rees.rees_dchrg,'LineWidth',4,'Color','c')
% % legend({'EES-DC','REES-DC','Grid','REES-NEM','PV','REES-C','load'},'Location','northwest','Orientation','horizontal')
% % xlim(xlim_range)
% % datetick('x','ddd','KeepTicks')
% % box on
% % grid on
% % set(gca,'FontSize',12,...
% %     'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
% % hold off
% 
% 
% days_to_look_at = 200;
% xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
% figure  
% hold on
% plot_dt = [var_util.import ...
%     var_pv.pv_elec ...
%     var_ees.ees_dchrg...
%     var_rees.rees_dchrg ...
%     var_rees.rees_dchrg_nem ...
%     var_pv.pv_nem ...
%     var_sofc.sofc_elec ];
% area(time,plot_dt)
% plot(time,elec,'LineWidth',2,'Color','k')
% legend({'Grid','PV','EES','REES','REES EXP','PV EXP','SOFC'},'Location','northwest','Orientation','horizontal')
% xlim(xlim_range)
% datetick('x','ddd','KeepTicks')
% box on
% grid on
% set(gca,'FontSize',12,...
%     'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
% hold off