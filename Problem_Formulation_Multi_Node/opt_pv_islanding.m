%% PV Constraints
%% PV Energy balance when curtailment is allowed
Constraints = [Constraints, (var_pv.pv_elec + var_lrees.rees_chrg <= (1/e_adjust).*repmat(solar,1,K).*(repmat(pv_legacy_cap,T,1))):'PV Energy Balance - <='];
%         Constraints = [Constraints, (pv_wholesale + pv_elec + pv_nem + rees_chrg <= repmat(solar,1,K).*repmat(pv_adopt,T,1)):'PV Energy Balance'];
