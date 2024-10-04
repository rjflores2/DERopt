%% Diesel Only Toggles
utility_exists=[]; %% Utility access
pv_on = 0;        %Turn on PV
ees_on = 0;       %Turn on EES/REES
rees_on = 0;  %Turn on REES
ror_on = 0; % Turn On Run of river generator
ror_integer_on = 0;
ror_integer_cost = 8000;
pemfc_on = 0;
%%%Hydrogen technologies
el_on = 0; %Turn on generic electrolyer
el_binary_on = 0;
rel_on = 0; %Turn on renewable tied electrolyzer
h2es_on = 0; %Hydrogen energy storage
strict_h2es = 0; %Is H2 Energy Storage strict discharge or charge?
%%% Legacy System Toggles
lpv_on = 0; %Turn on legacy PV 
lees_on = 1; %Legacy EES
ltes_on = 0; %Legacy TES

lror_on = 0; %Turn on legacy run of river

ldiesel_on = 0; %Turn on legacy diesel generators
ldiesel_binary_on = 1; %Binary legacy diesel generators
%% Turn on RoR, solar, + storage
utility_exists=[]; %% Utility access
pv_on = 1;        %Turn on PV
ees_on = 1;       %Turn on EES/REES
rees_on = 0;  %Turn on REES
ror_on = 0; % Turn On Run of river generator
ror_integer_on = 1;
ror_integer_cost = 8000;
pemfc_on = 1;
%%%Hydrogen technologies
el_on = 0; %Turn on generic electrolyer
el_binary_on = 1;
rel_on = 0; %Turn on renewable tied electrolyzer
h2es_on = 1; %Hydrogen energy storage
strict_h2es = 0; %Is H2 Energy Storage strict discharge or charge?
%%% Legacy System Toggles
lpv_on = 0; %Turn on legacy PV 
lees_on = 1; %Legacy EES
ltes_on = 0; %Legacy TES

lror_on = 0; %Turn on legacy run of river

ldiesel_on = 0; %Turn on legacy diesel generators
ldiesel_binary_on = 1; %Binary legacy diesel generators