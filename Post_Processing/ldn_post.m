%% Calculating/ Printing Results
% DER Adoption
totalPV_kW = sum(pv_adopt);
totalEES_kW = max(max(sum(ees_chrg,2)),max(sum(ees_dchrg,2)));
totalEES_kWh = sum(ees_adopt);
totalREES_kW = max(max(sum(rees_chrg,2)),max(sum(rees_dchrg,2)));
totalREES_kWh = sum(rees_adopt);
%Import/Export
%"multi" subscript refers to scaling up the totals to account for all days, not only representative days.
total_import = sum(sum(import));
total_import_multi = sum(sum(repmat(day_multi,1,K).*import));

total_export_PV_NEM = sum(sum(pv_nem));
total_export_PV_NEM_multi = sum(sum(repmat(day_multi,1,K).*pv_nem));

total_export_PV_wholesale = sum(sum(pv_wholesale));
total_export_PV_wholesale_multi = sum(sum(repmat(day_multi,1,K).*pv_wholesale)); 

total_export_PV = total_export_PV_NEM + total_export_PV_wholesale;
total_export_PV_multi = total_export_PV_NEM_multi + total_export_PV_wholesale_multi;

total_export_RESS_NEM = sum(sum(rees_dchrg_nem));
total_export_REES_NEM_multi = sum(sum(repmat(day_multi,1,K).*rees_dchrg_nem));

total_export = total_export_PV_NEM + total_export_PV_wholesale + total_export_RESS_NEM;
total_export_multi  = total_export_PV_NEM_multi + total_export_PV_wholesale_multi + total_export_REES_NEM_multi;

peakload = max(sum(elec,2));
totalAECkWh = sum(sum(elec));
totalAECkWh_multi = sum(sum(repmat(day_multi,1,K).*elec));

NetEnergy = total_import - total_export;

totalEES_chrg_kWh = sum(sum(ees_chrg));
totalEES_dchrg_kWh = sum(sum(ees_dchrg));
 
if nopv == 0
pv_curtail = ( repmat(solar,1,K).*repmat(pv_adopt,T,1) ) - ( pv_wholesale + pv_elec + pv_nem + rees_chrg ); 
PVCurtail = sum(sum(pv_curtail));
PVCurtail_multi = sum(sum(repmat(day_multi,1,K).*pv_curtail));
else 
    PVCurtail = 0;PVCurtail_multi =0;
end 

format shortG
SystemTotals = table(totalPV_kW,totalEES_kW,totalEES_kWh,totalREES_kW,totalREES_kWh,'VariableNames' , {'Total_PV_kW','Total_EES_kW','Total_EES_kWh','Total_REES_kW','Total_REES_kWh'})

Import_Export = table(total_import, total_export, NetEnergy, PVCurtail, total_export_PV_NEM, total_export_PV_wholesale, total_export_PV, total_export_RESS_NEM, 'VariableNames', {'Total_Import_kWh','Total_Export_kWh','Net_Energy_kWh','PV_Curtail_kW','Total_Grid_Export_PV_NEM_kWh', 'Total_Grid_Export_PV_Wholesale_kWh','Total_Grid_Export_PV_kWh','Total_Grid_Export_RESS_NEM_kWh'})   

BatteryTotals = table(totalEES_chrg_kWh,totalEES_dchrg_kWh, 'VariableNames' , {'Total_EES_Charge_kWh','Total_EES_Discharge_kWh' })
%AECtotals = table(peakload,totalAECkWh,NetEnergy, 'VariableNames', {'Peak_Load_kW','AEC_Energy_Consumption_kWh','AEC_Net_Energy_kWh'})


%% Bulding ZNE (to calculate bar graph)
ZNE_blgd = sum(import) - sum(pv_nem) - sum(pv_wholesale) - sum(rees_dchrg_nem);

%% PCC Net import/export, i.e, hourly flow @ the PCC
PCCnet = sum(import,2) - sum(pv_nem,2) - sum(pv_wholesale,2) - sum(rees_dchrg_nem,2); 
PCCImport = sum(PCCnet(PCCnet>0));
PCCExport = abs(sum(PCCnet(PCCnet<0)));

exportflag=find(PCCnet<0); %finds hours where there was export
importflag=find(PCCnet>0);
PCCnetimportonly = PCCnet; PCCnetimportonly(exportflag)= 0; %hours that had exports are now zero
PCCnetexportonly = -1*PCCnet; PCCnetexportonly(importflag)= 0; %hours that had import are now zero

PCCnet_multi = day_multi.*PCCnet;%takes into account daymulti
PCCImport_multi = sum(PCCnet_multi(PCCnet_multi>0)); 
PCCExport_multi = sum(PCCnet_multi(PCCnet_multi<0));
%% Transformer constraint test 

TloadkVA = zeros(T,N); T_PV = zeros(N,1); T_EES = zeros(N,1); T_REES = zeros(N,1);

for n=1:N
        cluster = find(T_map == n); % returns vector of building # (k) connected to node n
        if isempty(cluster) == 0
            TloadkVA(:,n) = sum(elec(:,cluster)./repmat(pf(cluster),T,1),2); %KVA
            TloadkVAR(:,n) = sum(elec(:,cluster).*repmat(tan(acos(pf(cluster))),T,1),2); %KVAR
           
            Telec(:,n) = sum(elec(:,cluster),2); %KW
            Tees_chrg(:,n) = sum(ees_chrg(:,cluster),2); %KW
            Tees_dchrg(:,n)= sum(ees_dchrg(:,cluster),2); %KW
            Trees_chrg(:,n)= sum(rees_chrg(:,cluster),2); %KW
            Trees_dchrg(:,n)= sum(rees_dchrg(:,cluster),2); %KW
            Trees_dchrg_nem(:,n)= sum(rees_dchrg_nem(:,cluster),2); %KW
            Tpv_nem(:,n)= sum(pv_nem(:,cluster),2); %KW
            Tpv_wholesale(:,n)= sum(pv_wholesale(:,cluster),2); %KW
            Timport(:,n) = sum(import(:,cluster),2); %KW
            
            T_PV(n,1) = sum(sum(pv_adopt(:,cluster)));
            T_EES(n,1) = sum(sum(ees_adopt(:,cluster)));
            T_REES(n,1) = sum(sum(rees_adopt(:,cluster)));
        end
end

ElecLoad = table(sum(sum(elec)), 'VariableNames', {'AEC_load_kWh'})
%ElecLoad = table(max(elec)',min(elec)', max(Tload)', 'VariableNames', {'Max_elec', 'Min_elec'})

TranformerResults = table(max(TloadkVA)',max(TloadkVAR)', T_PV , T_EES, T_REES, T_rated', max(Sinj)',min(Sinj)','VariableNames', {'T_load_max_kVA', 'T_load_max_kVAR' ,'T_PV_kW', 'T_EES_kWh', 'T_RESS_kWh', 'T_rated_kVA','Sinj_max_kVA', 'Sinj_min_kVA'})

%Adoptions, Elecload, Tchec
BLDGResultskW = table(pv_adopt',ees_adopt',rees_adopt', max(elec)',min(elec)', 'VariableNames' , {'pv_adopt_kW','ees_adopt_kWh','rees_adopt_kWh' 'Max_elec_load_kW', 'Min_elec_load_kW'})

Objective

%% MATPOWER Post-Process AC Power Flow 
define_constants;
B = size(branch,1); %number of branches
mpopt = mpoption('model','AC','verbose',0,'out.all',0); %verbose =0 and out.all = 0 not to print anything

BusVolAC=zeros(N,T); BusAglAC=zeros(N,T); BranchPFlowAC=zeros(B,T); BranchQFlowAC=zeros(B,T);

for t=1:T
    %Force DEROPT Pinj and Qinj injections into MATPOWER case (mpc) bus matrix (Pd and Qd)
    mpc.bus(:,PD) = (Pinj(t,:)')./1000;  %kW to MW %Updates MATPOWER case
    mpc.bus(:,QD) = (Qinj(t,:)')./1000;  %kW to MW %Updates MATPOWER case
    
    resultAC = runpf(mpc,mpopt);
    BusVolAC(:,t) = resultAC.bus(:,VM); %p.u.
    BusAglAC(:,t) = resultAC.bus(:,VA); %degrees
    BranchPFlowAC(:,t) = (resultAC.branch(:,PF)-resultAC.branch(:,PT))/2; %MW
    BranchQFlowAC(:,t) = (resultAC.branch(:,QF)-resultAC.branch(:,QT))/2; %MVAR
end 

BranchSFlowAC= sqrt(BranchPFlowAC.^2 + BranchQFlowAC.^2); % MVA

%% Find (simultaneous) import/export > T_rated (bug!) 

[row, col] = find(import > 0 & (pv_nem + pv_wholesale + rees_dchrg) > 0 );
import_bug = [row col];
s = T_rated*cos(theta(1));

%Run these for XFMR constrained scenarios
if opt_t == 0
    
    [row,col] = find(pv_wholesale > repmat(s(T_map),T,1));
    pv_w_bug = [row col];

    [row,col] = find(import > repmat(s(T_map),T,1));
    import_bug = [row col];
end

%% PV penetration
if nopv ==0
PV_2_BLDG = sum(sum(pv_elec)) + sum(sum(rees_dchrg)); %this is still missing the contribution from ees ... which is hard  to calculate
PV_2_AEC = sum(sum((repmat(solar,1,K).*repmat(pv_adopt,T,1)) - pv_wholesale - pv_nem - rees_dchrg_nem - pv_curtail));
%% RTE
RTE1 = sum(sum(elec))/(sum(sum(pv_elec)) + sum(sum(pv_nem)) + sum(sum(pv_wholesale)) + sum(sum(rees_dchrg_nem)));
total_PV = sum(sum(repmat(solar,1,K).*repmat(pv_adopt,T,1))); 
%RTE2=(sum(sum(elec)) + total_export)/(total_import + total_PV - abs(PVCurtail));
RTE2=(sum(sum(elec)) + total_export + abs(PVCurtail))/(total_import + total_PV); 
RTE3 = ((sum(sum(elec)) + total_export_RESS_NEM))/(total_import + sum(sum(rees_chrg))+sum(sum(pv_elec)));
else 
    PV_2_BLDG =0;
    PV_2_AEC=0;
    RTE3 = 0;
end 
%% Results vector

adopt = [pv_adopt' , ees_adopt', rees_adopt'];

if noees ==0
total_rev = rees_revenue +  pv_w_revenue + pv_nem_revenue;
else 
    total_rev=0;
end

total_export_multi = total_export_PV_NEM_multi +  total_export_REES_NEM_multi + total_export_PV_wholesale_multi;


res = [...
    totalAECkWh_multi;...
    total_import_multi;...
    total_export_multi;...
    PCCImport_multi;...
    PCCExport_multi;...
    total_export_PV_NEM_multi;...
    total_export_PV_wholesale_multi;...
    total_export_REES_NEM_multi;...
    total_export_multi;...
    rees_revenue;...
    pv_nem_revenue;...
    pv_w_revenue;...
    total_rev;...
    total_rev/total_export_multi;
    total_rev/PCCExport_multi;
    PVCurtail_multi;...
    PV_2_BLDG;...
    PV_2_AEC;...
    RTE3;...
    Objective;...
    ];

resc = cell([length(res),2]);
for i=1:length(res)
resc{i,2} = res(i);
end

varnames = {...
    'AEC load_multi';...
    'BLDG Import_multi';...
    'BLDG Export_multi';...
    'PCCImport_multi';...
    'PCCExport_multi';...
    'PV_NEM_multi';...
    'PV_wholesale_multi';...
    'REES_NEM_multi';...
    'Export_multi';... 
    'rees_revenue';...
    'pv_nem_revenue';...
    'pv_w_revenue';...
    'total_revenue';...
    '$/kWh bldg export';...
    '$/kWh PCC export';...
    'PVCurtail_multi';...
    'PV_2_BLDG';...
    'PV_2_AEC';...
    'RTE3';...
    'Objective';...
    };

for i=1:length(res)
resc{i,1} = varnames{i};
end

resc

%% Errors 
% % Values < 1e-5 MW (1 W) are substituted by 1e-5 (1 W) to avoid high % errors 
% smalls = find(abs(BranchPFlowAC)<=1E-5); BranchPFlowAC(smalls) = 1E-5;
% smalls = find(abs(Pflow)<=1E-5); Pflow(smalls) = 1E-5;
% 
% %Absolute errors 
% Verror = (Volts-BusVolAC); %p.u.
% Perror = Pflow-BranchPFlowAC; %MW
% Aerror = Theta - BusAglAC; %degrees
% 
% % Percent Errors OBS: percent error can be misleading for low V values 
% Verror_percent = 100.*(Volts-BusVolAC)./BusVolAC;  %percent
% Perror_percent = 100.*(BranchPFlowAC-Pflow)./BranchPFlowAC; Perror_percent(isnan(Perror)) = 0; Perror_percent(isnan(Perror)) = 0; %percent 
% Aerror_percent = 100.*(Theta - BusAglAC)./BusAglAC; Aerror_percent(isnan(Aerror)) = 0;
% 
% %% R/X ratios
% RX = branch(:,BR_R)./branch(:,BR_X);

%% Display Voltage ranges
fprintf('ACPF True voltage range: %.3f - %.3f',  min(min(BusVolAC)), max(max(BusVolAC)))
if exist('Volts','var')
    fprintf('Linearized voltage range: %.3f - %.3f',  min(min(Volts)), max(max(Volts)))
end
%% ACPF V max min 
[uvnodes, uvtimes] = min(BusVolAC,[],2);
[uv, nodeuv] = min(uvnodes)
timeuv = uvtimes(nodeuv)
datetimev(timeuv,:)

[ovnodes, ovtimes] = max(BusVolAC,[],2);
[ov, nodeov] = max(ovnodes)
timeov = ovtimes(nodeov)
datetimev(timeov,:)

%% Linearized V max min 
if exist('Volts','var')
[uvnodesL, uvtimesL] = min(Volts,[],2);
[uvL, nodeuvL] = min(uvnodesL)
timeuvL = uvtimesL(nodeuvL)
datetimev(timeuvL,:)

[ovnodesL, ovtimesL] = max(Volts,[],2);
[ovL, nodeovL] = max(ovnodesL)
timeovL = ovtimesL(nodeovL)
datetimev(timeov,:)
end

%% Overcurrent 
[ocnodes, octimes] = max(BranchSFlowAC,[],2);
[oc, nodeoc] = max(ocnodes)
timeoc = octimes(nodeoc)
datetimev(timeoc,:)

[ocnodesL, octimesL] = max(Sflow,[],2);
[ocL, nodeocL] = max(ocnodesL)
timeocL = octimesL(nodeocL)
datetimev(timeocL,:)