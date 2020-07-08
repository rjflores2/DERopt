%% YALMIP Conversions
import=value(import);
if sum(dc_exist) > 0
    onpeak_dc=value(onpeak_dc);
    midpeak_dc=value(midpeak_dc);
    nontou_dc=value(nontou_dc);
end

if isempty(pv_v) == 0
    pv_adopt=value(pv_adopt);
    pv_elec=value(pv_elec);
    pv_nem = value(pv_nem);
    pv_wholesale = value(pv_wholesale);
end

if isempty(ees_v) == 0
    ees_adopt = value(ees_adopt);
    ees_soc = value(ees_soc);
    ees_dchrg = value(ees_dchrg);
    ees_chrg = value(ees_chrg);
else
    ees_adopt=zeros(1,K);
end

if isempty(ees_v) == 0 & rees_exist == 1
    rees_adopt = value(rees_adopt);
    rees_soc = value(rees_soc);
    rees_dchrg = value(rees_dchrg);
    rees_dchrg_nem = value(rees_dchrg_nem);
    rees_chrg = value(rees_chrg);
else
    rees_adopt=zeros(1,K);
end

Objective = value(Objective);

if island == 0 % If not an island 
    if nopv == 0 % If there's solar 
        pv_nem_revenue=sum(value(pv_nem_revenue));
        pv_w_revenue=sum(value(pv_w_revenue));
        if noees == 0; % And EES/RESS
            rees_revenue=sum(value(rees_revenue));
        else %Or no EES 
            rees_revenue=0;
        end 
    else %If there's no solar 
        if noees == 1 % And no EES/REES
            rees_revenue=0;
        else  % or EES/REES 
            rees_revenue=sum(value(rees_revenue));
        end 
        pv_nem_revenue=0;
        pv_w_revenue=0;
    end 
end 

%Transformer
Pinj = value(Pinj); %Pinj(isnan(Pinj)) = 0; %kW
Qinj = value(Qinj); %Qinj(isnan(Pinj)) = 0; %kW
Sinj = sqrt(Pinj.^2 + Qinj.^2); %kVA %Absolute value
%Sinj = Pinj./cos(atan(Qinj./Pinj)); %kVA %Captures the (+) and (-) flows 

%DLPF
if dlpfc == 1
    Theta = value(Theta);
    Volts = value(Volts);
    Pflow = value(Pflow);
    Qflow = value(Qflow);
    Sflow = sqrt(Pflow.^2 + Qflow.^2); %MVA
    %Sflow = Pflow./cos(atan(Qflow./Pflow)); %MVA %Captures +-sign
end

%LinDist
if lindist  == 1
    Volts_sq = value(Volts);
    Volts = sqrt(Volts_sq); %p.u.
    Pflow = value(Pflow);
    Qflow = value(Qflow);
    Sflow = sqrt(Pflow.^2 + Qflow.^2); %MVA
    %Sflow = Pflow./cos(atan(Qflow./Pflow)); %MVA %Captures +-sign
    Theta = zeros(N,T);
end 

%slack = value(slack);