%% Converting volume fractions to energy fractions
if ~isempty(h2_lim)
    h2_lim_e_frac = h2_lim*2*141.88/(h2_lim*2*141.88 + (1-h2_lim)*16*55.5);
end
%% Natural Gas Cost
%%%CO2 Cost
co2_cost = 27.96; %$/tonne 2030: $27.96/tonne __2040: $50/tonne__2050: $71.5/tonne
ng_td = 0.8; %$/therm
ng_procure = 0.6; %$/therm
ng_carbon =  (co2_cost/1000)*(105.5/55.5/16*44);% $/therm (1 therm * 105.5MJ/therm * 1kmolCH4/16kg CH4 * 1kmolCO2/1kmolCH4 * 44kg/1kmolCO2)

ng_cost = (ng_td + ng_procure + ng_carbon)/29.3; %ng cost $/kWh (1therm = 29.3kWh)

%% H2 Gas Cost
h2_procure = h2_cost_kg./141.88*3.6; %$/kWh ($/kgH2 * 1kg/141.99MJ * 3.6MJ/kWh)
h2_td = ng_td*1.2./29.3; % $/kWh (1therm = 29.3kWh)

h2_cost = h2_procure + h2_td;

%% H2 injected into the gas grid at a specified fraction
if ~isempty(h2_mix)
    h2_mix_e_frac = h2_mix*2*141.88/(h2_mix*2*141.88 + (1-h2_mix)*16*55.5);
    
    %%%Cost of blended fuel
    ng_cost = ng_cost*(1 - h2_mix_e_frac) + h2_cost*h2_mix_e_frac; %$/kWh
    
    tdv_gas_mod = (1 - h2_mix_e_frac); %%%Value to multiply TDV values by
end
   