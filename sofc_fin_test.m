fcel = zeros(8760)

   sofc_v = [2500   %%% 1: Capital cost ($/kWel) C_fc
          0.06*2500  %%% 2: O&M ($/kWh generated) 6 Yearly % of TIC(Total Installed Cost) % of the purchasing cost (4–10%) 
          0.6        %%% 3: SOFC electrical efficiency at nominal condition (fraction)     
          0.28       %%% 4: SOFC thermal efficiency at nominal condition (fraction)
          25         %%% 5: sofc lifespan n
          0.1        %%% 6: Annual interest rate i_r
          0.023];    %%% 7: Gas_price MUST BE FROM UTILITY DATA price of natural gas ($/kWh)       

fcel = ones(8760,1)
Num = sofc_v(6)*((1+sofc_v(6))^sofc_v(5)) 
Den = (1+sofc_v(6))^sofc_v(5)-1
Cfc = sofc_v(1)
Cc = Cfc * Num/Den %%% ($/kW)
cc2 = sofc_v(1) * (sofc_v(6)*((1+sofc_v(6))^sofc_v(5)))/((1+sofc_v(6))^sofc_v(5)-1)                
Num
Den