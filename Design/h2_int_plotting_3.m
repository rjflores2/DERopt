clc, clear all, close all

files = dir;

% asdas

vals = [11 5 6 7 8 9 10];
fst_run = 1;
idx = 1;
for ii = vals
    ii
    files(ii).name
    dt = load(files(ii).name);
    close all
    %%%Recording first cost
    if fst_run == 1
        fval = dt.fval;
        fst_run = 0;
    end
    
    adopted_tech_0(:,idx) = [dt.var_pv.pv_adopt
        dt.var_ees.ees_adopt + dt.var_rees.rees_adopt
        dt.var_el.el_adopt + dt.var_rel.rel_adopt
        dt.var_h2es.h2es_adopt
        dt.var_utilpv.util_pv_adopt
        dt.var_h2_inject.h2_inject_size];
    
    total_cost_0(idx) = dt.fval;
    
    co2_emissions_0(idx) = dt.co2_emissions_total;
    if ~isempty(dt.co2_lim)
        co2_lim_0(idx) = dt.co2_lim;
    else
        co2_lim_0(idx) = co2_emissions_0(idx);
    end
    dt.fval/sum(dt.elec)
    idx = idx + 1;
    clear dt
end

% vals = [29 23 24 25 26 27 28];
% fst_run = 1;
% idx = 1;
% for ii = vals
%     ii
%     files(ii).name
%     dt = load(files(ii).name);
%     close all
%     %%%Recording first cost
%     if fst_run == 1
%         fval = dt.fval;
%         fst_run = 0;
%     end
%     
%     adopted_tech_1(:,idx) = [dt.var_pv.pv_adopt
%         dt.var_ees.ees_adopt + dt.var_rees.rees_adopt
%         dt.var_el.el_adopt + dt.var_rel.rel_adopt
%         dt.var_h2es.h2es_adopt
%         dt.var_utilpv.util_pv_adopt
%         dt.var_h2_inject.h2_inject_size];
%     
%     total_cost_1(idx) = dt.fval;
%     
%     co2_emissions_1(idx) = dt.co2_emissions_total;
%     if ~isempty(dt.co2_lim)
%         co2_lim_1(idx) = dt.co2_lim;
%     else
%         co2_lim_1(idx) = co2_emissions_1(idx);
%     end
%     
%     dt.fval/sum(dt.elec)
%     idx = idx + 1;
%     clear dt
% end


vals = [11 5 6 32 33 34 35 36];
fst_run = 1;
idx = 1;
for ii = vals
    ii
    files(ii).name
    dt = load(files(ii).name);
    close all
    %%%Recording first cost
    if fst_run == 1
        fval = dt.fval;
        fst_run = 0;
    end
    
    adopted_tech_1(:,idx) = [dt.var_pv.pv_adopt
        dt.var_ees.ees_adopt + dt.var_rees.rees_adopt
        dt.var_el.el_adopt + dt.var_rel.rel_adopt
        dt.var_h2es.h2es_adopt
        dt.var_utilpv.util_pv_adopt
        dt.var_h2_inject.h2_inject_size];
    
    total_cost_1(idx) = dt.fval;
    
    co2_emissions_1(idx) = dt.co2_emissions_total;
    if ~isempty(dt.co2_lim)
        co2_lim_1(idx) = dt.co2_lim;
    else
        co2_lim_1(idx) = co2_emissions_1(idx);
    end
    
    dt.fval/sum(dt.elec)
    idx = idx + 1;
    clear dt
end




vals = [11 19 20 21 22];
fst_run = 1;
idx = 1;
for ii = vals
    ii
    files(ii).name
    dt = load(files(ii).name);
    close all
    %%%Recording first cost
    if fst_run == 1
        fval = dt.fval;
        fst_run = 0;
    end
    
    adopted_tech_2(:,idx) = [dt.var_pv.pv_adopt
        dt.var_ees.ees_adopt + dt.var_rees.rees_adopt
        dt.var_el.el_adopt + dt.var_rel.rel_adopt
        dt.var_h2es.h2es_adopt
        dt.var_utilpv.util_pv_adopt
        dt.var_h2_inject.h2_inject_size];
    
    total_cost_2(idx) = dt.fval;
    
    co2_emissions_2(idx) = dt.co2_emissions_total;
    if ~isempty(dt.co2_lim)
        co2_lim_2(idx) = dt.co2_lim;
    else
        co2_lim_2(idx) = co2_emissions_2(idx);
    end
    
    dt.fval/sum(dt.elec)
    idx = idx + 1;
    clear dt
end


vals = [11 94 95 96 97 98 99];
fst_run = 1;
idx = 1;
adopted_tech_3 = [];
co2_emissions_3 = [];
co2_lim_3 = [];
for ii = vals
    ii
    files(ii).name
    dt = load(files(ii).name);
    close all
    %%%Recording first cost
    if fst_run == 1
        fval = dt.fval;
        fst_run = 0;
    end
    
    adopted_tech_3(:,idx) = [dt.var_pv.pv_adopt
        dt.var_ees.ees_adopt + dt.var_rees.rees_adopt
        dt.var_el.el_adopt + dt.var_rel.rel_adopt
        dt.var_h2es.h2es_adopt
        dt.var_utilpv.util_pv_adopt
        dt.var_h2_inject.h2_inject_size];
    
    total_cost_3(idx) = dt.fval;
    
    co2_emissions_3(idx) = dt.co2_emissions_total;
    if ~isempty(dt.co2_lim)
        co2_lim_3(idx) = dt.co2_lim;
    else
        co2_lim_3(idx) = co2_emissions_3(idx);
    end
    
    dt.fval/sum(dt.elec)
    idx = idx + 1;
    clear dt
end


vals = [11 12 13 14 15 16 17 18];
fst_run = 1;
idx = 1;
adopted_tech_4 = [];
co2_emissions_4 = [];
co2_lim_4 = [];
for ii = vals
    ii
    files(ii).name
    dt = load(files(ii).name);
    close all
    %%%Recording first cost
    if fst_run == 1
        fval = dt.fval;
        fst_run = 0;
    end
    
    adopted_tech_4(:,idx) = [dt.var_pv.pv_adopt
        dt.var_ees.ees_adopt + dt.var_rees.rees_adopt
        dt.var_el.el_adopt + dt.var_rel.rel_adopt
        dt.var_h2es.h2es_adopt
        dt.var_utilpv.util_pv_adopt
        dt.var_h2_inject.h2_inject_size];
    
    total_cost_4(idx) = dt.fval;
    
    co2_emissions_4(idx) = dt.co2_emissions_total;
    if ~isempty(dt.co2_lim)
        co2_lim_4(idx) = dt.co2_lim;
    else
        co2_lim_4(idx) = co2_emissions_4(idx);
    end
    
    dt.fval/sum(dt.elec)
    idx = idx + 1;
    clear dt
end

%% 
close all

f1 = figure;
adopted_tech_3(5,1) = 0;
adopted_tech_4(5,1) = 0;
hold on
yyaxis left
plot((co2_lim_0(1) - co2_lim_0)./co2_lim_0(1).*100,adopted_tech_0(1,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0 .5 0])
plot((co2_lim_1(1) - co2_lim_1)./co2_lim_1(1).*100,adopted_tech_1(1,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 .45 0.75],'Color',[0 .45 .75]) 
plot((co2_lim_2(1) - co2_lim_2)./co2_lim_2(1).*100,adopted_tech_2(1,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.85 .33 .1],'Color',[0.85 .33 .1])
plot((co2_lim_3(1) - co2_lim_3)./co2_lim_3(1).*100,adopted_tech_3(1,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0.93 .69 .13])
plot((co2_lim_4(1) - co2_lim_4)./co2_lim_4(1).*100,adopted_tech_4(1,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.49 .18 .56],'Color',[0.49 .18 .56])
box on
grid on
set(gca,'FontSize',16)
ylabel('On-Site Solar (MW)','FontSize',20)

yyaxis right
plot((co2_lim_2(1) - co2_lim_2)./co2_lim_2(1).*100,adopted_tech_2(5,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.85 .33 .1],'Color',[0.85 .33 .1])
plot((co2_lim_3(1) - co2_lim_3)./co2_lim_3(1).*100,adopted_tech_3(5,:)./1000,'--o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0.93 .69 .13])
plot((co2_lim_4(1) - co2_lim_4)./co2_lim_4(1).*100,adopted_tech_4(5,:)./1000,'--o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.49 .18 .56],'Color',[0.49 .18 .56])

legend('Baseline','Current Engine','High H_2 Engine','High H_2 Engine + Wheeling','High H_2 Engine, Wheeling, & H_2 Injection','Location','NorthWest')
legend('Sc1 Onsite Solar','Sc2 Onsite Solar','Sc3 Onsite Solar','Sc4 Onsite Solar','Sc3 Offsite Solar','Sc4 Offsite Solar','Location','NorthWest')


ylabel('Off-Site Utility Solar (MW)','FontSize',20)
% xlabel('CO_2_e Reduction (%)','FontSize',20)

hold off
f1.Position = [100 100 800 400];
%%
f2 = figure;
hold on
plot((co2_lim_0(1) - co2_lim_0)./co2_lim_0(1).*100,adopted_tech_0(2,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 .45 0.75],'Color',[0 .45 .75]) 
plot((co2_lim_1(1) - co2_lim_1)./co2_lim_1(1).*100,adopted_tech_1(2,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 .45 0.75],'Color',[0 .45 .75]) 
% plot((co2_lim_2(1) - co2_lim_2)./co2_lim_2(1).*100,adopted_tech_2(2,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.85 .33 .1],'Color',[0.85 .33 .1])
% plot((co2_lim_3(1) - co2_lim_3)./co2_lim_3(1).*100,adopted_tech_3(2,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0.93 .69 .13])
% plot((co2_lim_4(1) - co2_lim_4)./co2_lim_4(1).*100,adopted_tech_4(2,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.49 .18 .56],'Color',[0.49 .18 .56])
box on
grid on
set(gca,'FontSize',16)
ylabel('Electric Energy Storage (MWh)','FontSize',20)
hold off
f2.Position = [100 100 400 400];




f3 = figure;
hold on
plot((co2_lim_1(1) - co2_lim_1)./co2_lim_1(1).*100,adopted_tech_1(3,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 .45 0.75],'Color',[0 .45 .75]) 
% plot((co2_lim_2(1) - co2_lim_2)./co2_lim_2(1).*100,adopted_tech_2(3,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.85 .33 .1],'Color',[0.85 .33 .1])
% plot((co2_lim_3(1) - co2_lim_3)./co2_lim_3(1).*100,adopted_tech_3(3,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0.93 .69 .13])
% plot((co2_lim_4(1) - co2_lim_4)./co2_lim_4(1).*100,adopted_tech_4(3,:)./1000,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.49 .18 .56],'Color',[0.49 .18 .56])
box on
grid on
set(gca,'FontSize',16)
ylabel('Electrolyzer Capacity (MW)','FontSize',20)
% xlabel('CO_2_e Reduction (%)','FontSize',20)
hold off
f3.Position = [100 100 400 400];



f4 = figure;
hold on
plot((co2_lim_0(1) - co2_lim_0)./co2_lim_0(1).*100,(total_cost_0 - total_cost_0(1))./total_cost_0(1).*100,'--o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0 0 0])
plot((co2_lim_1(1) - co2_lim_1)./co2_lim_1(1).*100,(total_cost_1 - total_cost_1(1))./total_cost_1(1).*100,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 .45 0.75],'Color',[0 .45 .75]) 
plot((co2_lim_2(1) - co2_lim_2)./co2_lim_2(1).*100,(total_cost_2 - total_cost_2(1))./total_cost_2(1).*100,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.85 .33 .1],'Color',[0.85 .33 .1])
plot((co2_lim_3(1) - co2_lim_3)./co2_lim_3(1).*100,(total_cost_3 - total_cost_3(1))./total_cost_3(1).*100,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.93 .69 .13],'Color',[0.93 .69 .13])
plot((co2_lim_4(1) - co2_lim_4)./co2_lim_4(1).*100,(total_cost_4 - total_cost_4(1))./total_cost_4(1).*100,'-o','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.49 .18 .56],'Color',[0.49 .18 .56])
box on
grid on
set(gca,'FontSize',16)
ylabel('Change in Cost of Energy (%)','FontSize',20)
xlabel('CO_2_e Reduction (%)','FontSize',20)
ylim([0 750])
legend('Baseline','Current Engine','High H_2 Engine','High H_2 Engine + Wheeling','High H_2 Engine, Wheeling, & H_2 Injection','Location','NorthWest')
hold off
f4.Position = [100 100 800 400];