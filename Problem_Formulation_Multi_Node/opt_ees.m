%%%EES Constraints
%% Grid tied EES
if isempty(ees_v) == 0
    if sum(res_idx) >  0
        Constraints = [Constraints
            (0 <= var_ees.ees_adopt):'EES Adoptiong >= 0'
            (0 <= var_ees.ees_chrg):'EES Charging >= 0'
            (0 <= var_ees.ees_dchrg):'EES Discharging >= 0'
            (0 <= var_ees.ees_soc):'EES SOC >= 0'
            ((var_ees.ees_adopt(res_idx) + var_rees.rees_adopt(res_idx)) <= res_units(res_idx)'.*30):'EES Installed Residential Capacity Limit'
            (var_ees.ees_soc(2:end,:) == ees_v(10)*var_ees.ees_soc(1:end-1,:) + ees_v(8)*var_ees.ees_chrg(2:end,:)  - (1/ees_v(9))*var_ees.ees_dchrg(2:end,:)):'EES Energy Balance'  %%%Minus discharging of battery
            (ees_v(4).*repmat(var_ees.ees_adopt,T,1) <= var_ees.ees_soc <= ees_v(5).*repmat(var_ees.ees_adopt,T,1)):'Min/Max EES SOC' %%%Min/Max SOC
            (var_ees.ees_chrg <= ees_v(6).*repmat(var_ees.ees_adopt,T,1)):'Max EES Charge Rate' %%%Max Charge Rate
            (var_ees.ees_dchrg <= ees_v(7).*repmat(var_ees.ees_adopt,T,1)):'Max REES Discharge Rate']; %%%Max Discharge Rate
    else %%%Commercial/nonresidential

        Constraints = [Constraints
            (0 <= var_ees.ees_adopt):'EES Adoptiong >= 0'
            (0 <= var_ees.ees_chrg):'EES Charging >= 0'
            (0 <= var_ees.ees_dchrg):'EES Discharging >= 0'
            (0 <= var_ees.ees_soc):'EES SOC >= 0'
            (var_ees.ees_soc(2:end,:) == ees_v(10)*var_ees.ees_soc(1:end-1,:) + ees_v(8)*var_ees.ees_chrg(2:end,:)  - (1/ees_v(9))*var_ees.ees_dchrg(2:end,:)):'EES Energy Balance'  %%%Minus discharging of battery
            (ees_v(4).*repmat(var_ees.ees_adopt,T,1) <= var_ees.ees_soc <= ees_v(5).*repmat(var_ees.ees_adopt,T,1)):'Min/Max EES SOC' %%%Min/Max SOC
            (var_ees.ees_chrg <= ees_v(6).*repmat(var_ees.ees_adopt,T,1)):'Max EES Charge Rate' %%%Max Charge Rate
            (var_ees.ees_dchrg <= ees_v(7).*repmat(var_ees.ees_adopt,T,1)):'Max REES Discharge Rate']; %%%Max Discharge Rate
    end
end
if  rees_on
    Constraints = [Constraints
        (0 <= var_rees.rees_adopt):'REES Adoptiong >= 0'
        (0 <= var_rees.rees_chrg):'REES Charging >= 0'
        (0 <= var_rees.rees_dchrg):'REES Discharging >= 0'
        (0 <= var_rees.rees_soc):'REES SOC >= 0'
        (var_rees.rees_dchrg(1,:) == 0):'Initial SOC'
        (var_rees.rees_soc(2:end,:) == ees_v(10)*var_rees.rees_soc(1:end-1,:) + ees_v(8)*var_rees.rees_chrg(2:end,:)  - (1/ees_v(9))*var_rees.rees_dchrg(2:end,:)):'EES Energy Balance'  %%%Minus discharging of battery
        (ees_v(4).*repmat(var_rees.rees_adopt,T,1) <= var_rees.rees_soc <= ees_v(5).*repmat(var_rees.rees_adopt,T,1)):'Min/Max EES SOC' %%%Min/Max SOC
        (var_rees.rees_chrg <= ees_v(6).*repmat(var_rees.rees_adopt,T,1)):'Max EES Charge Rate' %%%Max Charge Rate
        (var_rees.rees_dchrg <= ees_v(7).*repmat(var_rees.rees_adopt,T,1)):'Max REES Discharge Rate']; %%%Max Discharge Rate


    %         (var_rees.rees_soc(2:T,k) == ees_v(10)*var_rees.rees_soc(1:T-1,k) + ees_v(8)*var_rees.rees_chrg(2:T,k)  - (1/ees_v(9))*(var_rees.rees_dchrg(2:T,k))):'REES Energy Balance'  %%%Minus discharging of battery
    %         (ees_v(4)*var_rees.rees_adopt(k) <= var_rees.rees_soc(:,k) <= ees_v(5)*var_rees.rees_adopt(k)):'Min/Max REES SOC' %%%Min/Max SOC
    %         (var_rees.rees_chrg(:,k) <= ees_v(6)*var_rees.rees_adopt(k)):'Max REES Charge Rate' %%%Max Charge Rate
    %         (var_rees.rees_dchrg(:,k) <= ees_v(7)*var_rees.rees_adopt(k)):'Max REES Discharge Rate']; %%%Max Discharge Rate];

    if ees_bin_on
        Constraints = [Constraints
            (var_rees.rees_dchrg <= 50.*var_rees.bin)
            (var_rees.rees_chrg <= 50.*(1-var_rees.bin))];
    end
    for k=1:K
        %%%Adding sgip constraints
        if sgip_on && ~isempty(find(non_res_rates == find(ismember(rate_labels,rate(k))))) %%%IS nonresidential
            Constraints = [Constraints;
                (-var_rees.rees_chrg(:,k)'*sgip_signal(:,2) +  var_rees.rees_dchrg(:,k)'*sgip_signal(:,2) >= var_rees.rees_adopt(k)*sgip(1)):'SGIP CO2 Reduciton'];
        end
    end
end


    
%     for k=1:K
%         %%%SOC Equality / Energy Balance
% %         Constraints = [Constraints
% %             (var_ees.ees_soc(2:T,k) == ees_v(10)*var_ees.ees_soc(1:T-1,k) + ees_v(8)*var_ees.ees_chrg(2:T,k)  - (1/ees_v(9))*var_ees.ees_dchrg(2:T,k)):'EES Energy Balance'  %%%Minus discharging of battery
% %             (ees_v(4)*var_ees.ees_adopt(k) <= var_ees.ees_soc(:,k) <= ees_v(5)*var_ees.ees_adopt(k)):'Min/Max EES SOC' %%%Min/Max SOC
% %             (var_ees.ees_chrg(:,k) <= ees_v(6)*var_ees.ees_adopt(k)):'Max EES Charge Rate' %%%Max Charge Rate
% %             (var_ees.ees_dchrg(:,k) <= ees_v(7)*var_ees.ees_adopt(k)):'Max REES Discharge Rate']; %%%Max Discharge Rate
%         
%         %% Renewable Tied EES
%         if isempty(pv_v) == 0 && rees_on
%             %%%SOC Equality / Energy Balance
%             Constraints = [Constraints
%                 (0 <= var_rees.rees_adopt):'REES Adoptiong >= 0'
%                 (0 <= var_rees.rees_chrg):'REES Charging >= 0'
%                 (0 <= var_rees.rees_dchrg):'REES Discharging >= 0'
%                 (0 <= var_rees.rees_soc):'REES SOC >= 0'
%                 (var_rees.rees_dchrg(1,k) == 0):'Initial SOC'
%                 (var_rees.rees_soc(2:T,k) == ees_v(10)*var_rees.rees_soc(1:T-1,k) + ees_v(8)*var_rees.rees_chrg(2:T,k)  - (1/ees_v(9))*(var_rees.rees_dchrg(2:T,k))):'REES Energy Balance'  %%%Minus discharging of battery
%                 (ees_v(4)*var_rees.rees_adopt(k) <= var_rees.rees_soc(:,k) <= ees_v(5)*var_rees.rees_adopt(k)):'Min/Max REES SOC' %%%Min/Max SOC
%                 (var_rees.rees_chrg(:,k) <= ees_v(6)*var_rees.rees_adopt(k)):'Max REES Charge Rate' %%%Max Charge Rate
%                 (var_rees.rees_dchrg(:,k) <= ees_v(7)*var_rees.rees_adopt(k)):'Max REES Discharge Rate']; %%%Max Discharge Rate];
% 
%             if ees_bin_on
%                 Constraints = [Constraints  
%                 (var_rees.rees_dchrg <= 50.*var_rees.bin)
%                 (var_rees.rees_chrg <= 50.*(1-var_rees.bin))];
%             end
%             
%             %%%Adding sgip constraints
%             if sgip_on && ~isempty(find(non_res_rates == find(ismember(rate_labels,rate(k))))) %%%IS nonresidential
%                 Constraints = [Constraints;
%                     (-var_rees.rees_chrg(:,k)'*sgip_signal(:,2) +  var_rees.rees_dchrg(:,k)'*sgip_signal(:,2) >= var_rees.rees_adopt(k)*sgip(1)):'SGIP CO2 Reduciton'];
%             end
%             
%             
%         end
%     end
% end






%% From when we used a seperate variable for discharge for export
% (var_rees.rees_soc(2:T,k) == ees_v(10)*var_rees.rees_soc(1:T-1,k) + ees_v(8)*var_rees.rees_chrg(2:T,k)  - (1/ees_v(9))*(var_rees.rees_dchrg(2:T,k) + var_rees.rees_dchrg_nem(2:T,k))):'REES Energy Balance'  %%%Minus discharging of battery
% (var_rees.rees_dchrg(:,k) + var_rees.rees_dchrg_nem(:,k) <= ees_v(7)*var_rees.rees_adopt(k)):'Max REES Discharge Rate'

%%
%                 (var_rees.rees_dchrg <= 50.*var_rees.bin)
%                 (var_rees.rees_chrg <= 50.*(1-var_rees.bin))
%%%Was originally in line 20
% (var_rees.rees_dchrg_nem(1,k) == 0):'Initial SOC'
