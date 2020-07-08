%%%Already existing technolgoy at the building/microgrid
%% Vapor Compression Chiller Vector
vc_cop=3.4;%VC COP
vc_om=0.0139734;%O&M of VC chiller ($/kWh)
% vc_om=ac_v(2)
vc_v=[vc_om; vc_cop];

%% Boiler Vector
eff_b=0.9;%Efficiency of boiler
c_omb=0.001; %O&M Cost of Boiler

boil_v=[c_omb; eff_b];
%% Transformer ratings (if doing community study)
%              (T1)   (T2)      
% T_rated = [   25  |  50  ]; (kVA) %[1,N] 
% T_rated=[2500 3000]; %kVa
% T_rated = [900 1500 350 175 200 570 200];

% 6 transformers
% T_rated = [900 1500 350 175 200 570];

%AEC  
%T = zeros(1,52);
%paste from excel
%save T.mat
%load T
%T_rated = T;
%gen_T_rated 
%loaded from AEC_grid

