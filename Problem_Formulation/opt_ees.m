%%%EES Constraints
%% Grid tied EES
if isempty(ees_v) == 0 

    if ees_onoff  %BESS ON/OFF (Working)
 
        xc = binvar(T,K,'full');
        xd = binvar(T,K,'full');

        %Non-vectorized (for implies support)    
        for k=1:K
                %%%BESS SOC Equality / Energy Balances
                Constraints = [Constraints
                    xc(:,k) + xd(:,k) <=1
                    ees_soc(2:T,k) == ees_v(10)*ees_soc(1:T-1,k) + ees_v(8)*ees_chrg(2:T,k)  - (1/ees_v(9))*ees_dchrg(2:T,k)  %%%Minus discharging of battery
                    ees_v(4)*ees_adopt(k) <= ees_soc(:,k) <= ees_v(5)*ees_adopt(k) %%%Min/Max SOC               
                    implies(xc(:,k),ees_chrg(:,k) <= ees_v(6)*ees_adopt(k)) %%%Max Charge Rate
                    implies(xc(:,k)+1,ees_chrg(:,k) <= 0)
                    implies(xd(:,k),ees_dchrg(:,k) <= ees_v(7)*ees_adopt(k))%%%Max Discharge Rate   
                    implies(xd(:,k)+1,ees_dchrg(:,k) <= 0)
                    ];                  
        end
        
        %Old, working                
        %         xc_on = binvar(T,K,'full');
        %         xc_off = binvar(T,K,'full');
        %         xd_on = binvar(T,K,'full');
        %         xd_off = binvar(T,K,'full');
        % 
        %         %Non-vectorized (for implies support)    
        %         for k=1:K
        %                 %%%BESS SOC Equality / Energy Balances
        %                 Constraints = [Constraints
        %                     xc_on(:,k) + xc_off(:,k) ==1
        %                     xd_on(:,k) + xd_off(:,k) ==1
        %                     xc_on(:,k) + xd_on(:,k) <=1
        %                     ees_soc(2:T,k) == ees_v(10)*ees_soc(1:T-1,k) + ees_v(8)*ees_chrg(2:T,k)  - (1/ees_v(9))*ees_dchrg(2:T,k)  %%%Minus discharging of battery
        %                     ees_v(4)*ees_adopt(k) <= ees_soc(:,k) <= ees_v(5)*ees_adopt(k) %%%Min/Max SOC               
        %                     implies(xc_on(:,k),ees_chrg(:,k) <= ees_v(6)*ees_adopt(k)) %%%Max Charge Rate
        %                     implies(xc_off(:,k),ees_chrg(:,k) <= 0)
        %                     implies(xd_on(:,k),ees_dchrg(:,k) <= ees_v(7)*ees_adopt(k))%%%Max Discharge Rate   
        %                     implies(xd_off(:,k),ees_dchrg(:,k) <= 0)
        %                     ];                  
        %         end
        
    else 
            
        if toolittle_storage ==1 
          for k=1:K
                Constraints = [Constraints
                    (implies(ees_adopt(k) <= 13.5, ees_adopt(k) == 0)):'tolittle_ees'
                    (implies(rees_adopt(k) <= 13.5, rees_adopt(k) == 0)):'tolittle_rees'
                    ];
          end
        end 
           
        % EES 
        %Vectorized, wihtout ON/OFF behavior
        Constraints = [Constraints 
                  (ees_soc(2:T,:) == ees_v(10).*ees_soc(1:T-1,:) + ees_v(8).*ees_chrg(2:T,:)-(1/ees_v(9)).*ees_dchrg(2:T,:)):'EES Energy SOC'%%%SOC + Charge - Discharge
                  (repmat(ees_v(4).*ees_adopt,T,1) <= ees_soc <= repmat(ees_v(5).*ees_adopt,T,1)):'EES Min/Max SOC' %%%Min/Max SOC 
                  (ees_chrg <= repmat(ees_v(6).*ees_adopt,T,1)):'EES Max Charge' %%Charging ON, charigng power <= max charge Rate
                  (ees_dchrg <= repmat(ees_v(7).*ees_adopt,T,1)):'EES Max Discharge' %%%Discharging ON, discharigng power <= max discharge rate
                  ];
              
        % Renewable tied EES (RESS)
        if isempty(pv_v) == 0 & rees_exist ==1
            %Vectorized, without ON/OFF behavior 
             Constraints = [Constraints 
                      (rees_soc(2:T,:) == ees_v(10,:).*rees_soc(1:T-1,:) + ees_v(8,:).*rees_chrg(2:T,:)-(1./ees_v(9,:)).*(rees_dchrg(2:T,:) + rees_dchrg_nem(2:T,:))):'REES Energy SOC'%%%SOC + Charge - Discharge
                      (repmat(ees_v(4,:).*rees_adopt,T,1) <= rees_soc <= repmat(ees_v(5,:).*rees_adopt,T,1)):'REES Min/Max SOC' %%%Min/Max SOC 
                      (rees_chrg <= repmat(ees_v(6,:).*rees_adopt,T,1)):'REES Max Charge' %%Charging, charigng power <= max charge Rate
                      (rees_dchrg_nem + rees_dchrg <= repmat(ees_v(7,:).*rees_adopt,T,1)):'REES Max Dicharge' %%%Discharging, discharigng power <= max discharge rate
                      ];           

        end
    end

%% EES SOC 
%Final SOC needs to be greater or equal than initial SOC for sustainable operation
% if socc == 1 
%     Constraints = [Constraints 
%               ees_soc(T,:) >= ees_soc(1,:)
%               rees_soc(T,:) >= rees_soc(1,:) ];
% end 

%EES/REES will come with 10% SOC to prevent adopting 100% charged EES to use it as NEM export 
if socc == 1 
    Constraints = [Constraints 
              (ees_soc(1,:) <= 0.5*ees_adopt):'EES SOC(1) <= X% SOC'
              (rees_soc(1,:) <= 0.5*rees_adopt):'EES SOC(1) <= X% SOC'];
end 

end %if isempty(ees_v) == 0 