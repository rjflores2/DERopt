%%%Leftovers

%% Quick Constraints

tc = 0;          %On/Off tranformer constraints 
nem_c = 1;       %On/Off NEM constraints 
dlpfc = 1;       %On/Off Decoupled Linearized Power Flow (DLPF) constraints 
lindist = 0;     %On/Off LinDistFlow constraints 
voltage = 1;     %Use upped and lower limit for voltage 
branch = 1;      %On/Off Banch kVA constraints 
VH = 1.05;       %Low Voltage Limit (p.u.)
VL = 0.95;        %High Voltage Limit(p.u.)
Rmulti = 1;      %Multiplier for resistance in impedance matrix