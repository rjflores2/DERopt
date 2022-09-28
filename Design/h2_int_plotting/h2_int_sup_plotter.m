
%%

nonsolar = find(solar_util == 0);

idx = [0];
cnt = 1;
for ii = 2:length(nonsolar)
    if nonsolar(ii) ~= (nonsolar(ii-1) + 1)
        idx(cnt) = ii;
        cnt = cnt + 1;
    end
end
%%
clc
for ii = 1:length(idx)
    if ii == 1
        st = 1;
        fn = idx(ii) - 1;
    else
        st = idx(ii-1);
        fn = idx(ii) - 1;
    end
    
    [nonsolar(st) nonsolar(fn)]
    
    h2_used = sum(var_ldg.ldg_hfuel(nonsolar(st):nonsolar(fn)));
    
    for jj = nonsolar(st):nonsolar(fn)
        var_ldg.ldg_fuel(jj) = var_ldg.ldg_fuel(jj) + var_ldg.ldg_hfuel(jj);
        var_ldg.ldg_hfuel(jj) = 0;
        if h2_used > 0
            var_ldg.ldg_hfuel(jj) = var_ldg.ldg_fuel(jj)*h2_fuel_limit;
            
            h2_used = h2_used - var_ldg.ldg_hfuel(jj);
            
            if h2_used < 0
                var_ldg.ldg_hfuel(jj) = var_ldg.ldg_hfuel(jj) + h2_used;
                h2_used = 0;
            end
            
            
            
            var_ldg.ldg_fuel(jj) = var_ldg.ldg_fuel(jj) - var_ldg.ldg_hfuel(jj);
        end
    end
   
    h2_fuel_limit
%     st = day_stpts(ii);
%     fn = day_endpts(ii);

% h2_fuel = sum(


end


%% Biogas use / fuel uses
if ~isempty(biogas_limit)
    biogas_utilization = sum(var_ldg.ldg_rfuel  + var_boil.boil_rfuel + var_ldg.db_rfire)/(biogas_limit*(length(endpts)/12))
end
gt_fuel_source = sum([var_ldg.ldg_fuel ...
    var_ldg.ldg_rfuel ...
    var_ldg.ldg_hfuel])./sum(sum([var_ldg.ldg_fuel ...
    var_ldg.ldg_rfuel ...
    var_ldg.ldg_hfuel]))

%% Gas Splits - Conventional vs Renewable vs Hydrogen
if  ~exist('ldg_on','var')
    ldg_on = 0;    
end
if ldg_on
biogas_frac = sum(var_ldg.ldg_rfuel)./sum(var_ldg.ldg_fuel + var_ldg.ldg_rfuel)
if isnan(biogas_frac)
    biogas_frac = 0;
end
con_frac = sum(var_ldg.ldg_fuel)./sum(var_ldg.ldg_fuel + var_ldg.ldg_rfuel)
if isnan(con_frac)
    con_frac = 0;
end
h2_frac = var_ldg.ldg_hfuel./(var_ldg.ldg_fuel + var_ldg.ldg_rfuel + var_ldg.ldg_hfuel);
h2_frac(isnan(h2_frac)) = 0;
non_h2_frac = 1 - h2_frac;
% non_h2_frac(isnan(non_h2_frac)) = 0;
end
%% Plotting Generation
close all
mth_idx = 125
% mth_idx = 1
x_lim_range = [time(day_stpts(mth_idx))+0 time(day_endpts(mth_idx+7))-1 ];



f3 = figure;
hold on
if exist('var_pp')
    if  ~isfield(var_pp,'pp_elec_wheel')
        var_pp.pp_elec_wheel = zeros(size(elec));
    end
    if  ~isfield(var_pp,'pp_elec_wheel_lts')
        var_pp.pp_elec_wheel_lts = zeros(size(elec));
    end
end
plot_data = [];
if ldg_on
    plot_data = e_adjust.*[var_ldg.ldg_elec.*non_h2_frac.*con_frac + var_ldg.ldg_elec.*non_h2_frac.*biogas_frac ...
        var_ldg.ldg_elec.*h2_frac ...
        var_lbot.lbot_elec ...
        var_pv.pv_elec ...
        var_util.import ...
        var_pp.pp_elec_wheel ...
        var_rees.rees_dchrg + var_ees.ees_dchrg + var_lees.ees_dchrg]./1000;
else
    plot_data = e_adjust.*[zeros(length( var_pv.pv_elec),4) ...
        var_rees.rees_dchrg + var_ees.ees_dchrg + var_lees.ees_dchrg...
    var_pv.pv_elec ...
    var_util.import]./1000;
end

p3 = area(time,plot_data);
plot(time,e_adjust.*elec./1000,'LineWidth',2,'Color',[0 0 0])
a3 = gca;
 a3.FontSize = 16;
 a3.YLabel.String = 'Electricity (MW)';
 a3.YLabel.FontSize = 20;
a3.XTick = [round(time(1)) + 0.5 :1: round(time(end))-0.5];
% a3.XTick = [0 1]
datetick('x','ddd','KeepTicks')
% xlim([x_lim_range])
box on
grid on
legend('GT - NG','GT - H_2','ST','PV to Load','General Utility Import','Utility Solar','Battery Discharge','Orientation','Vertical','Location','EastOutside')
% a1.xtick = 1
set(gcf, 'Position',  [-1500, -150, 900, 400])
xlim([x_lim_range])
% ylim([0 22])
hold off