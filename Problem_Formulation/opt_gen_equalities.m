%% General equalities
K = size(elec,2);  %k-th building from 1...K
%% Building Electrical Energy Balances
 %%For each building k, all timesteps t 
 %Vectorized
    Constraints = [Constraints 
        (import + pv_elec + ees_dchrg + rees_dchrg == elec + ees_chrg):'BLDG Energy Balance'];


%%
%OLD, Non-vectorized
% for k=1:K
%      Constraints = [Constraints 
%         import(:,k) + pv_elec(:,k,:) + ees_dchrg(:,k) + rees_dchrg(:,k) == elec(:,k) + ees_chrg(:,k)];
% end