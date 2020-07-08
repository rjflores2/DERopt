close all 
%% Color Palletes
load('palletes_ldn');
pallete = bright;
%% Select plots 
plot1 = 1; % AEC Dynamics for the entire year
plot2 = 0; % AEC Dynamics for a given interval "dlength"
plot1_1 = 0; %Building dynamics for the entire year
plot2_1 = 0; %Building dynamics for dlength
plot4 = 0; % AEC Dynamics subplots 
plot5 = 0; % Transformer kVA limits subplot
plot6 = 0; % Individual XFMR loading
vpq = 1; % Voltage, Active and Reactive power comparison with ACPF MATPOWER
barinjections = 0;
powererror =0;
X_R = 0;
sflowbranch = 0; % Sflow for individual branches
sflowall = 0; % Sflow for all branches colored by ampacity
plot10 = 0;% k-medeoids 
plot11 = 0;%testing
plot12 = 0;%Building Dynamics subplots
%% Plot constants 
xp = 1:1:T;  
dstart = 10;
dlength = dstart+2;
range = dstart*24:6:dstart*24+(dlength-dstart)*24;
scrsz = get(groot,'ScreenSize'); 
Position = [scrsz(3)/8 scrsz(4)/8 1200 450]; %Location and size of drawable area [left bottom width height]

pv_elec_t = sum(pv_elec,2);
pv_t = solar.*sum(pv_adopt);
pv_nem_t = sum(pv_nem,2);
pv_wholesale_t = sum(pv_wholesale,2);
elec_t = sum(elec,2);
import_t = sum(import,2);
ees_chrg_t = sum(ees_chrg,2);
ees_dchrg_t = sum(ees_dchrg,2);
rees_chrg_t = sum(rees_chrg,2);
rees_dchrg_t = sum(rees_dchrg,2);
rees_dchrg_nem_t = sum(rees_dchrg_nem,2);
pv_curtail_t = sum(pv_curtail,2);

%% AEC Dynamics for the entire year
if plot1 == 1
    fig = figure('Units','inches','Position',[3.9063      -1.6667       8.4167       7.5521]);
    plot(xp,-solar.*sum(pv_adopt),'Color',rgb('OrangeRed'),'LineStyle',':','LineWidth',1.0)
    hold on
    plot(xp,sum(pv_elec,2),'Color',rgb('Orange'))
    hold on
    plot(xp,-sum(pv_nem,2),'Color','r')
    hold on
    plot(xp,-sum(pv_wholesale,2),'Color',rgb('Purple'))
    hold on
    plot(xp,sum(import,2),'Color','m','LineWidth',1.5)
    hold on 
    plot(xp,sum(elec,2),'Color','b','LineStyle',':')
    hold on
    plot(xp,-sum(ees_chrg,2),'Color',rgb('DodgerBlue'),'LineWidth',1.5)
    hold on
    plot(xp,sum(ees_dchrg,2),'Color',rgb('DodgerBlue'),'LineWidth',1.5)
    hold on
    plot(xp,-sum(rees_chrg,2),'Color',rgb('LimeGreen'),'LineWidth',1.5)
    hold on
    plot(xp,sum(rees_dchrg,2),'Color',rgb('LimeGreen'),'LineWidth',1.5)
    hold on
    plot(xp,-sum(rees_dchrg_nem,2),'Color',rgb('GreenYellow'))
    hold on
    plot(xp,-sum(pv_curtail,2),'Color',rgb('RosyBrown'))
    hold on
    plot(xp,PCCnet,'Color','k','LineWidth',1.5,'LineStyle','-')
    
    str = sprintf( 'AEC Power Dynamics(kW) \n PV: %.0f kW | EES: %.0f/%.0f (kW/kWh) | REES: %.0f/%.0f (kW/kWh)' , abs(totalPV_kW), abs(totalEES_kW), abs(totalEES_kWh) , abs(totalREES_kW), abs(totalREES_kWh));
    title(str);
    ylabel('Power (kW)')
    axis tight;
    legend('(-)PV Potential','(+)PV_{elec}','(-)PV NEM','(-)PV Wholesale','(+)Import','(+)AEC Load', '(-)EES Charge','(+)EES Discharge','(-)REES Charge','(+)RESS Discharge','(+)RESS Discharge NEM','(-)PV Curtail','AEC Net') 
end

%% AEC Dynamics for a given interval "dlength" 
if plot2 == 1 

    interval = dstart*24:dlength*24;

    fig = figure('Units','inches','Position',[6.8542         0.25       5.0313       4.3125]);
    plot(xp(interval),-pv_t(interval),'Color',rgb('OrangeRed'),'LineStyle',':','LineWidth',1.0)
    hold on
    plot(xp(interval),pv_elec_t(interval),'Color',rgb('Orange'))
    hold on
    plot(xp(interval),-pv_nem_t(interval),'Color','r')
    hold on
    plot(xp(interval),-pv_wholesale_t(interval),'Color',rgb('Purple'))
    hold on
    plot(xp(interval),import_t(interval),'Color','m','LineWidth',1.5)
    hold on 
    plot(xp(interval),elec_t(interval),'Color','b','LineStyle',':')
    hold on
    plot(xp(interval),-ees_chrg_t(interval),'Color',rgb('DodgerBlue'),'LineWidth',1.5)
    hold on
    plot(xp(interval),ees_dchrg_t(interval),'Color',rgb('DodgerBlue'),'LineWidth',1.5)
    hold on
    plot(xp(interval),-rees_chrg_t(interval),'Color',rgb('LimeGreen'),'LineWidth',1.5)
    hold on
    plot(xp(interval),rees_dchrg_t(interval),'Color',rgb('LimeGreen'),'LineWidth',1.5)
    hold on
    plot(xp(interval),-rees_dchrg_nem_t(interval),'Color',rgb('GreenYellow'),'LineWidth',1.5)
    hold on
    plot(xp(interval),-pv_curtail_t(interval),'Color',rgb('RosyBrown'))
    hold on
    plot(xp(interval),PCCnet(interval),'Color','k','LineWidth',1.5,'LineStyle','--')
    
    str = sprintf( 'AEC Power Dynamics(kW) \n PV: %.0f kW | EES: %.0f/%.0f (kW/kWh) | REES: %.0f/%.0f (kW/kWh)' , abs(totalPV_kW), abs(totalEES_kW), abs(totalEES_kWh) , abs(totalREES_kW), abs(totalREES_kWh));
    title(str);
    xlabel('Hour')
    ylabel('Power (kW)')
    axis tight;
    legend('(-)PV Potential','(+)PV_{elec}','(-)PV NEM','(-)PV Wholesale','(+)Import','(+)AEC Load', '(-)EES Charge','(+)EES Discharge','(-)REES Charge','(+)RESS Discharge','(+)RESS Discharge NEM','(-)PV Curtail','AEC Net','Location','eastoutside') 
    ax = fig.CurrentAxes;
    
    %XTick and XLabel
    h = 6; %Hour interval
    hour = h:h:24;
    xtick = floor(length(interval)/length(hour)/h);
    xtickfull = repmat(hour,1,xtick);     
    lbl = cell(length(xtickfull),1);
    for i=1:length(xtickfull)
    lbl{i} = sprintf( '%02.f' , xtickfull(i));
    end 

    ax.XTick = h:h:T;
    ax.XTickLabel = lbl;
    
    %ax.XTick = range;
    %ax.XTickLabel = {'0','6','12','18','0','6','12','18','0','6','12','18','0'};
end    

%filename = 'Baseline';
%print(filename,'-dpng','-r300');

%% BUILDING Dynamics for the entire year

if plot1_1 == 1  
    
    k = 14; %Building number

    if ees_adopt(k)> 10 & rees_adopt(k)> 10 
        ax1p = [0.1 0.48 0.8 0.435]; %[left bottom width height].
        ax2p = [0.1 0.3 0.8 0.1];
        ax3p = [0.1 0.1 0.8 0.1];
    elseif ees_adopt(k)> 10
        ax1p = [0.1 0.40 0.8 0.5];
        ax2p = [0.1 0.1 0.8 0.2];
        ax3p = [1 1 1 1];
    elseif ees_adopt(k)> 10    
        ax1p = [0.1 0.40 0.8 0.5];
        ax2p = [1 1 1 1];
        ax3p = [0.1 0.1 0.8 0.2];
    else 
        ax1p = [0.1 0.1 0.8 0.8];
        ax2p = [1 1 1 1];
        ax3p = [1 1 1 1];
    end 
           
    fig = figure('Units','inches','Position',[5.0521       1.1458          8.5            8]);
    %subplot(3,1,1);
    ax1 = subplot('Position', ax1p); %[left bottom width height].
    plot(xp,-solar.*pv_adopt(k),'Color',rgb('OrangeRed'),'LineStyle',':','LineWidth',1.0)
    hold on
    plot(xp,pv_elec(:,k),'Color',rgb('Orange'))
    hold on
    plot(xp,-pv_nem(:,k),'Color','r')
    hold on
    plot(xp,-pv_wholesale(:,k),'Color','k')
    hold on
    plot(xp,import(:,k),'Color','m','LineWidth',1.5)
    hold on 
    plot(xp,elec(:,k),'Color','b','LineStyle',':')
    hold on
    plot(xp,-ees_chrg(:,k),'Color',rgb('DodgerBlue'),'LineWidth',1.5) %'DarkBlue'
    hold on
    plot(xp,ees_dchrg(:,k),'Color',rgb('DodgerBlue'),'LineWidth',1.5)
    hold on
    plot(xp,-rees_chrg(:,k),'Color',rgb('LimeGreen'),'LineWidth',1.5) %'DarkGreen'
    hold on
    plot(xp,rees_dchrg(:,k),'Color',rgb('LimeGreen'),'LineWidth',1.5)
    hold on
    plot(xp,-rees_dchrg_nem(:,k),'Color',rgb('GreenYellow'),'LineWidth',1.5)
    hold on
    plot(xp,-pv_curtail(:,k),'Color',rgb('RosyBrown'),'LineWidth',1.5)
    hold on 
    plot(xp,Pinj(:,T_map(k)),'Color',rgb('Purple'),'LineWidth',1.2, 'LineStyle', '--')
    hold on
    plot(xp,T_rated(T_map(k)).*ones(1,T),'Color',rgb('Black'),'LineWidth',1.0)
    hold on
    plot(xp,-T_rated(T_map(k)).*ones(1,T),'Color',rgb('Black'),'LineWidth',1.0)
    
    str = sprintf( 'Building %.0f  \n PV: %.0f kW | ESS: %.0f/%.0f (kW/kWh) | RESS: %.0f/%.0f (kW/kWh)\n xfmr = %.0f kVA'...
        ,k, abs(pv_adopt(k)), abs(max(max(ees_chrg(:,k)),max(ees_dchrg(:,k)))), abs(ees_adopt(k)),abs(max(max(rees_chrg(:,k)),max(rees_dchrg(:,k)))),...
        abs(rees_adopt(k)),T_rated(T_map(k)) );    
    title(str);
    ylabel('Power (kW)')
    axis tight;
    %ax1.XLim = [0 200];
    legend('(-)PV Potential','(+)PV_{elec}','(-)PV NEM','(-)PV Wholesale','(+)Import','(+)AEC Load', '(-)EES Charge','(+)EES Discharge','(-)REES Charge','(+)RESS Discharge','(-)RESS Discharge NEM','(-)PV Curtail','Pinj') 
    
    %subplot(3,1,2);
    ax2 = subplot('Position', ax2p); %[left bottom width height].
    plot(xp,100*ees_soc(:,k)./ees_adopt(k), 'k');
    title('EES SOC')
    ylabel('%')
   
    %subplot(3,1,3);
    ax3 = subplot('Position', ax3p); %[left bottom width height].
    plot(xp,100*rees_soc(:,k)./rees_adopt(k), 'k');
    title('REES SOC')
    ylabel('%')
    
    linkaxes([ax1,ax2,ax3],'x')

end

%% BUILDING Dynamics for a given interval dlength
 
 if plot2_1 == 1
   
    k = 8; %Building number

    if ees_adopt(k)> 10 & rees_adopt(k)> 10 
        ax1p = [0.13 0.48 0.79 0.40]; %[left bottom width height].
        ax2p = [0.13 0.29 0.79 0.1];
        ax3p = [0.13 0.1 0.79 0.1];
    elseif ees_adopt(k)> 10
        ax1p = [0.13 0.40 0.79 0.49];
        ax2p = [0.13 0.1 0.79 0.2];
        ax3p = [1 1.2 1 1];
    elseif rees_adopt(k)> 10    
        ax1p = [0.13 0.40 0.79 0.49];
        ax2p = [1 1.2 1 1];
        ax3p = [0.13 0.1 0.79 0.2];
    else 
        ax1p = [0.13 0.1 0.79 0.76];
        ax2p = [1 1.2 1 1];
        ax3p = [1 1.2 1 1];
    end 
           
    fig = figure('Units','inches','Position',[4.2083       2.2083       4.9167       4.4375]);
    %subplot(3,1,1);
    ax1 = subplot('Position', ax1p); %[left bottom width height].
    plot(xp,-solar.*pv_adopt(k),'Color',rgb('OrangeRed'),'LineStyle',':','LineWidth',1.0)
    hold on
    plot(xp,pv_elec(:,k),'Color',rgb('Orange'))
    hold on
    plot(xp,-pv_nem(:,k),'Color','r')
    hold on
    plot(xp,-pv_wholesale(:,k),'Color',rgb('Purple'))
    hold on
    plot(xp,import(:,k),'Color','m','LineWidth',1.5)
    hold on
    plot(xp,elec(:,k),'Color','b','LineStyle',':')
    hold on
    plot(xp,-ees_chrg(:,k),'Color',rgb('DodgerBlue'),'LineWidth',1.5) %'DarkBlue'
    hold on
    plot(xp,ees_dchrg(:,k),'Color',rgb('DodgerBlue'),'LineWidth',1.5)
    hold on
    plot(xp,-rees_chrg(:,k),'Color',rgb('LimeGreen'),'LineWidth',1.5) %'DarkGreen'
    hold on
    plot(xp,rees_dchrg(:,k),'Color',rgb('LimeGreen'),'LineWidth',1.5)
    hold on
    plot(xp,-rees_dchrg_nem(:,k),'Color',rgb('GreenYellow'),'LineWidth',1.5)
    hold on
    plot(xp,-pv_curtail(:,k),'Color',rgb('RosyBrown'),'LineWidth',1.5)
    hold on 
    plot(xp,Pinj(:,T_map(k)),'Color','k','LineWidth',1.5,'LineStyle','--')
    hold on
    plot(xp,T_rated(T_map(k)).*ones(1,T),'Color',rgb('Black'),'LineWidth',1.0)
    hold on
    plot(xp,-T_rated(T_map(k)).*ones(1,T),'Color',rgb('Black'),'LineWidth',1.0)
    
    str = sprintf( 'Building %.0f  \n PV: %.0f kW | EES: %.0f/%.0f (kW/kWh) | REES: %.0f/%.0f (kW/kWh)\n Transformer = %.0f kVA'...
        ,k, abs(pv_adopt(k)), abs(max(max(ees_chrg(:,k)),max(ees_dchrg(:,k)))), abs(ees_adopt(k)),abs(max(max(rees_chrg(:,k)),max(rees_dchrg(:,k)))),...
        abs(rees_adopt(k)),T_rated(T_map(k)) );    
    title(str);
    %xlabel('Hour')
    ylabel('Power (kW)')
    %axis tight;
    ax1.XLim = [1 48];
    %lgd = columnlegend(3,{'(-)PV Potential','(+)PV_{elec}','(-)PV NEM','(-)PV Wholesale','(+)Import','(+)AEC Load', '(-)EES Charge','(+)EES Discharge','(-)REES Charge','(+)REES Discharge','(-)REES Discharge NEM','(-)PV Curtail','Pinj'},'location','south','padding',-0.1,'fontsize', 8) 
    lgd = legend('(-)PV Potential','(+)PV_{elec}','(-)PV NEM','(-)PV Wholesale','(+)Import','(+)AEC Load', '(-)EES Charge','(+)EES Discharge','(-)REES Charge','(+)RESS Discharge','(-)RESS Discharge NEM','(-)PV Curtail','Pinj','Location','south') 
    
    %subplot(3,1,2);
    ax2 = subplot('Position', ax2p); %[left bottom width height].
    plot(xp,100*ees_soc(:,k)./ees_adopt(k), 'k');
    title('EES SOC')
    ylabel('%')
   
    %subplot(3,1,3);
    ax3 = subplot('Position', ax3p); %[left bottom width height].
    plot(xp,100*rees_soc(:,k)./rees_adopt(k), 'k');
    title('REES SOC')
    ylabel('%')
    xlabel('Hour')
    
    %XTick and XLabel
    h = 6; %Hour interval
    hour = h:h:24;
    xtick = floor(T/length(hour)/h);
    xtickfull = repmat(hour,1,xtick);     
    lbl = cell(length(xtickfull),1);
    for i=1:length(xtickfull)
    lbl{i} = sprintf( '%02.f' , xtickfull(i));
    end 
    
    ax1.XTick = h:h:T;
    ax1.XTickLabel = lbl;
    ax2.XTick = h:h:T;
    ax2.XTickLabel = lbl;
    ax3.XTick = h:h:T;
    ax3.XTickLabel = lbl;
    linkaxes([ax1,ax2,ax3],'x')
 end


%% AEC Dynamics subplots
%Plot dynamics for a selected interval
if plot4 == 1
    
    interval = dstart*24:dlength*24;
    figure('Units','inches','Position',[3.5 -1.5 8.5 8])

    s1 = subplot(5,1,1);
    plot(xp(interval),elec_t(interval),'Color','b','Linewidth',1.5)
    hold on
    plot(xp(interval),pv_elec_t(interval),'Color',rgb('Orange'),'Linewidth',1.5)
    hold on
    plot(xp(interval),import_t(interval),'Color','m','Linewidth',1.5)
    legend('AEC Load','PV_{elec}','Import')
    s1.XTick = range;
    s1.XTickLabel = {'0','6','12','18','0','6','12','18','0','6','12','18','0'};
    %s1.XTickLabel = '';
    %set(s1,'XTickLabel','');
    axis tight;

    s2 = subplot(5,1,2);
    plot(xp(interval),pv_t(interval),'Color',rgb('OrangeRed'),'Linewidth',1.5)
    legend('PV Potential')
    s2.XTick = range;
    s2.XTickLabel = {'0','6','12','18','0','6','12','18','0','6','12','18','0'};
    %s2.XTickLabel = '';
    axis tight;

    s3 = subplot(5,1,3);
    plot(xp(interval),pv_nem_t(interval),'Color','r','Linewidth',1.5)
    hold on
    plot(xp(interval),pv_wholesale_t(interval),'Color','k','Linewidth',1.5)
    legend('PV NEM','PV Wholesale')
    s3.XTick = range;
    s3.XTickLabel = {'0','6','12','18','0','6','12','18','0','6','12','18','0'};
    %s3.XTickLabel = '';
    axis tight;

    s4 = subplot(5,1,4);
    plot(xp(interval),ees_chrg_t(interval),'Color',rgb('DarkBlue'),'Linewidth',1.5)
    hold on
    plot(xp(interval),ees_dchrg_t(interval),'Color',rgb('DodgerBlue'),'Linewidth',1.5)
    legend('EES Charge','EES Discharge')
    s4.XTick = range;
    s4.XTickLabel = {'0','6','12','18','0','6','12','18','0','6','12','18','0'};
    %s4.XTickLabel = '';
    axis tight;

    s5 = subplot(5,1,5);
    plot(xp(interval),rees_chrg_t(interval),'Color',rgb('DarkGreen'),'Linewidth',1.5)
    hold on
    plot(xp(interval),rees_dchrg_t(interval),'Color',rgb('LimeGreen'),'Linewidth',1.5) 
    s5.XTick = range;
    s5.XTickLabel = {'0','6','12','18','0','6','12','18','0','6','12','18','0'};
    xlabel('Hours')
    legend('REES Charge','REES Discharge') 
    axis tight;

    %suplabel('Hours','x')
    %suplabel('Power(kW)','y')
    %axis tight;

    filename = 'Baseline_SUB';
    %print(filename,'-dpng','-r300');
end
%% Transformer kVA limits subplot
if plot5 ==1 
    lengthplot = 3;
    for p=1:round(K/lengthplot);
        figure('Units','inches','Position',[3.5 -1.5 8.5 8])
        xfmr = find(T_rated);
        st = 1 + (p-1)*lengthplot;
        ed = lengthplot + st -1 ;
        while ed > length(xfmr)
            ed = ed-1;
        end 
        xfmr=xfmr(st:ed);
        a = st:ed;
        while length(a) < lengthplot
            lengthplot = lengthplot -1;
        end 
        for i=1:lengthplot
            n = xfmr(i); % only nodes that have transformers 
            subax = subplot(lengthplot,1,i);
            c = get (gca,'colororder');
            plot(xp,Sinj(:,n)); %Sinj (kVA)
            hold on
            plot(xp,Pinj(:,n),'Color', c(3,:)); %Pinj (kW)
            hold on 
            plot(xp,Qinj(:,n),'Color', c(4,:)); %Pinj (kW)
            %Rating Limits 
            hold on
            plot(xp,ones(length(xp))*T_rated(n),'--r'); %kVA
            hold on 
            plot(xp,ones(length(xp))*-T_rated(n),'--r'); %kVA
            %Zero crossing
            hold on 
            plot(xp,zeros(length(xp)),'k');
            str = sprintf('T%d (%.1f kVA) - PV: %.0f kW |BESS: %.0f kWh| RESS: %.0f kWh ', n, T_rated(n),T_PV(n), T_EES(n),T_REES(n))
            title(str);
            ylabel('kVA');
            xlim(subax,[0 length(xp)]);
            %ylim(subax,[(-1*T_rated(n)-15),(T_rated(n)+15)]); %This was causing an error and also 'hiding' some ovelroading
            subax.XTickLabel = '';
            subax.XTick = [];
            subax.YTick = linspace( -T_rated(n),T_rated(n),5);
            if i==1 
                legend('Sinj=sqrt(Pinj^2+Qinj^2)','Pinj','Qinj','Location','southoutside','Orientation','Horizontal')
            end 
            if i == lengthplot
                xlabel('Optimization Timeframe');
            end 
        end
        filename = 'T-1';
        %print(filename,'-dpng','-r300');
    end
end
%% Individual XFMR loading
if plot6 == 1
    n = [28,34,37]; % Choosing transformers to plot
    for i=1:length(n)
        figure('Units','inches','Position',[3.5 -1.5 8.5 8])
        ax = plot(xp,Sinj(:,n(i)),'Linewidth',1.5); %Sinj (kVA) 
        c = get (gca,'colororder');
        hold on 
        %plot(xp,Sinj_lin(:,n(i)),'Linewidth',2.5); %Sinj linearized (kVA) 
        %hold on
        plot(xp,Pinj(:,n(i)),'Color', c(3,:),'Linewidth',1.5); %Pinj (kW) 
        hold on 
        plot(xp,Qinj(:,n(i)),'Color', c(4,:),'Linewidth',1.5); %Qinj (kVAR)
        hold on
        plot(xp,TloadkVA(:,n(i)),'Color', c(5,:)); %Electic Load Apparent Power (kVA)  
        hold on 
        plot(xp,Telec(:,n(i)),'Color', c(6,:)); %Electic Load Active Power (kW) 
        hold on 
        plot(xp,TloadkVAR(:,n(i)),'Color', c(7,:)); %Electic Load Reactive Power (kVAR) 
        hold on 
        %Rating Limits
        plot(xp,ones(length(xp))*T_rated(n(i)),'--r');
        hold on 
        plot(xp,ones(length(xp))*-T_rated(n(i)),'--r');
        %Zero crossing
        hold on 
        plot(xp,zeros(length(xp)),'k');
        %title(['T' num2str(n(i)) ' | ' num2str(T_rated(n(i))) 'kVA']);
        str = sprintf('T%d (%.1f kVA) - PV: %.0f kW |BESS: %.0f kWh| RESS: %.0f kWh ', n(i), T_rated(n(i)),T_PV(n(i)), T_EES(n(i)),T_REES(n(i)))
        title(str);
        ylabel('kVA'); 
        xlabel('Optimization Timeframe');
        legend('Sinj','Pinj','Qinj,','Sload','Pload','Qload','Location','southoutside','Orientation','Horizontal') 
        %legend('Sinj=sqrt(Pinj^2+Qinj^2)','Sinjlin=sqrt(psq+Qinj^2)','Pinj','Qinj,','Sload = Pload/PF','Pload','Qload = Pload*tan(PF)','sqrt(psq)') 
        %xlim(ax,[0 length(xp)]);
        %ax.XTickLabel = '';
        %ax.XTick = [];
        %dim = [.2 .5 .3 0.4];
        %dim = [.15 .1 .1 .1]; % [x y w h] %The lower left corner of the figure maps to (0,0) and the upper right corner maps to (1,1)
        %str = sprintf('PV: %.0f kW \nBESS: %.0f kWh \nRESS: %.0f kWh', T_PV(n(i)),T_EES(n(i)),T_REES(n(i)));
        %a = annotation('textbox',dim,'String',str,'FitBoxToText','on');
    end
end

%% Voltage Profile, Voltage Phase Angle, Active Power Flow, Reactive Power Flow

if vpq ==1   
    n = size(mpc.bus,1);
    m = size(mpc.branch,1);
    if n <=54
    s = 1; %spacing between xticks
    elseif n >= 105
        s = 5; 
    else n > 54
        s = 3;
    end 
    
    ts = 250;
%%  %Voltage Profile for all 864 timesteps
    Position = [369   263   495   252];
    fig = figure('Position', Position ,'PaperPositionMode','auto');
    fig.Color = 'w';
    ax = axes('Parent',fig,'XTick',1:s:n);
    box(ax,'on'); hold(ax,'on');
    ax.Color = [234 234 242]./255; % set background gray
    grid on; ax.GridColor = [255,255,255]./255; 
    ax.GridAlpha = 0.9; %set grid white with transparency
    ax.TickLength = [0 0];
    h1 = plot(1:n,BusVolAC,'Color',pallete(2,:),'LineWidth',0.6);hold on;
    if exist('Volts','var')
        if dlpfc
           h2 = plot(1:n,Volts,'Color',pallete(1,:),'LineWidth',0.6);hold on;
         else 
           h2 = plot(1:n,Volts,'Color',pallete(7,:),'LineWidth',0.6);hold on;
        end
    
    h3 = plot(1:n,Volts(:,ovtime),'Color','r','LineWidth',0.6);hold on;
    h3 = plot(1:n,Volts(:,uvtime),'Color','r','LineWidth',0.6);hold on;
    h4 = plot(1:n,Volts(:,endpts-11),'Color','k','LineWidth',0.6);hold on;
    h5 = plot(1:n,Volts(:,endpts-5),'Color','k','LineWidth',0.6);hold on;
    
    end
    %ax.TickLength = [0.005 0.00125];
    ax.FontSize = 9;
    ax.LabelFontSizeMultiplier = 1.2;
    ax.TitleFontSizeMultiplier = 1.2;
    ax.XTickLabelRotation = 90;
    %axis tight;
    if dlpfc
        [leg, objects] = legend([h1(1) h2(1) h3(1) h4(1) h5(1)],'True Voltage (ACPF)','DLPF','OV and UV','1:00 PM','6:00 PM','Location','best');
        title('Voltage Magnitude Comparison DLPF vs. ACPF');
    elseif lindist 
        [leg, objects ] = legend([h1(1) h2(1) h3(1) h4(1) h5(1)],'True Voltage (ACPF)','LinDist','OV and UV','1:00 PM','6:00 PM','Location','best');
        title('Voltage Magnitude Comparison LinDist vs. ACPF');
    else
        [leg, objects ] = legend('ACPF','Location','best');
        title('Voltage Magnitude - Base Case ');
    end 
    leg.BoxFace.ColorType = 'truecoloralpha';
    leg.BoxFace.ColorData = uint8([234 234 242 242*0.8]');
    xlabel('Node');
    ylabel('Voltage Magnitude (p.u.)');
    ylim([0.85  1.15])
    tix=get(ax,'ytick')';
    set(ax,'yticklabel',num2str(tix,'%.3f'))
    xlim([1 N])

%%
    %Voltage Profile @ a given timestep (ts)
    fig = figure('Position', Position ,'PaperPositionMode','auto');
    ax = axes('Parent',fig,'XTick',1:s:n);
    box(ax,'on'); hold(ax,'on');
    h1 = plot(1:n,BusVolAC(:,ts),'r-','LineWidth',0.6);hold on;
    h2 = plot(1:n,Volts(:,ts),'b-','LineWidth',0.6);hold on;
    axis tight;
    if dlpfc
    legend([h1(1) h2(1)],'ACPF','DLPF');
    elseif lindist 
        legend([h1(1) h2(1)],'ACPF','LinDist');
    end 
    tix=get(ax,'ytick')';
    set(ax,'yticklabel',num2str(tix,'%.5f'))
    xlabel('Node');
    ylabel('Voltage Magnitude (p.u.)');
    str = sprintf('Voltage Magnitude Comparison at timestep: %.0f',ts);
    title(str);
   
% Active Power Flows
%     fig = figure('Position',Position,'PaperPositionMode','auto');
%     ax = axes('Parent',fig,'XTick',1:s:m);
%     box(ax,'on'); hold(ax,'on');
%     h1 = plot(1:m,BranchPFlowAC,'r-','LineWidth',0.6);hold on;
%     h2 = plot(1:m,Pflow,'b-','LineWidth',0.6);hold on;
%     axis tight;
%     legend([h1(1) h2(1)],'ACPF','DLPF');
%     xlabel('Branch');
%     ylabel('Branch Active Power Flow - Losless (MW)');
%     title('Active Power Flow Comparison');

    %Active Power Flows @ given timestep
%     fig = figure('Position',Position,'PaperPositionMode','auto');
%     ax = axes('Parent',fig,'XTick',1:s:m);
%     box(ax,'on'); hold(ax,'on');
%     h1 = plot(1:m,BranchPFlowAC(:,ts),'r-','LineWidth',0.6);hold on;
%     h2 = plot(1:m,Pflow(:,ts),'b-','LineWidth',0.6);hold on;
%     axis tight;
%     legend([h1(1) h2(1)],'ACPF','DLPF');
%     xlabel('Branch');
%     ylabel('Branch Active Power Flow - Losless (MW)');
%     str = sprintf('Active Power Flow Comparison at timestep: %.0f',ts);
%     title(str);
    
    %Reactive Power Flow  
%     fig = figure('Position',Position, 'PaperPositionMode','auto');
%     ax = axes('Parent',fig,'XTick',1:s:m);
%     box(ax,'on'); hold(ax,'on');
%     h1 = plot(1:m,BranchQFlowAC,'r-','LineWidth',0.6);hold on;
%     h2 = plot(1:m,Qflow,'b-','LineWidth',0.6);hold on;
%     axis tight;
%     legend([h1(1) h2(1)],'ACPF','DLPF');
%     xlabel('Branch');
%     ylabel('Branch Reactive Power Flow - Lossless (MVAR)');
%     title('Reactive Power Flow Comparison');
    
    %Reactive Power Flow @ given timestep 
%     fig = figure('Position',Position, 'PaperPositionMode','auto');
%     ax = axes('Parent',fig,'XTick',1:s:m);
%     box(ax,'on'); hold(ax,'on');
%     h1 = plot(1:m,BranchQFlowAC(:,ts),'r-','LineWidth',0.6);hold on;
%     h2 = plot(1:m,Qflow(:,ts),'b-','LineWidth',0.6);hold on;
%     axis tight;
%     legend([h1(1) h2(1)],'ACPF','DLPF');
%     xlabel('Branch');
%     ylabel('Branch Reactive Power Flow - Lossless (MVAR)');
%     str = sprintf('Reactive Power Flow Comparison at timestep: %.0f',ts);
%     title(str);
    
    %Apparent Power Flow 
    fig = figure('Position',Position, 'PaperPositionMode','auto');
    ax = axes('Parent',fig,'XTick',1:s:m);
    box(ax,'on'); hold(ax,'on');
    h1 = plot(1:m,BranchSFlowAC,'r-','LineWidth',0.6);hold on;
    h2 = plot(1:m,Sflow,'b-','LineWidth',0.6);hold on;
    axis tight;
        if dlpfc
    legend([h1(1) h2(1)],'ACPF','DLPF');
    elseif lindist 
        legend([h1(1) h2(1)],'ACPF','LinDist');
    end 
    xlabel('Branch');
    ylabel('Branch Apparent Power Flow - Lossless (MVA)');
    str = sprintf('Apparent Power Flow Comparison');
    title(str);
     
    %Apparent Power Flow @ given timestep 
    fig = figure('Position',Position, 'PaperPositionMode','auto');
    ax = axes('Parent',fig,'XTick',1:s:m);
    box(ax,'on'); hold(ax,'on');
    h1 = plot(1:m,BranchSFlowAC(:,ts),'r-','LineWidth',0.6);hold on;
    h2 = plot(1:m,Sflow(:,ts),'b-','LineWidth',0.6);hold on;
    axis tight;
        if dlpfc
    legend([h1(1) h2(1)],'ACPF','DLPF');
    elseif lindist 
        legend([h1(1) h2(1)],'ACPF','LinDist');
    end 
    xlabel('Branch');
    ylabel('Branch Apparent Power Flow - Lossless (MVA)');
    str = sprintf('Apparent Power Flow Comparison at timestep: %.0f',ts);
    title(str);
    
      %Voltage Phase Angle
%     figure4 = figure('Position',Position, 'PaperPositionMode','auto');
%     axes4 = axes('Parent',figure4,'XTick',1:s:n);
%     box(axes4,'on'); hold(axes4,'on');
%     plot(1:n,BusAglAC,'r-','LineWidth',0.6);hold on;
%     plot(1:n,Theta,'b--o','LineWidth',0.6);hold on;
%     axis tight;
%     legend('ACPF','DLPF');
%     xlabel('Node');
%     ylabel('Voltage Angle (degrees)');
%     title('Voltage Angle Comparison');
end 

if barinjections ==1 
    %Bar Bus (Net) Nodal injections (Demand >0)
    % figure5 = figure('Position',Position,'PaperPositionMode','auto');
    % axes5 = axes('Parent',figure5,'XTick',1:s:n);
    % box(axes5,'on'); hold(axes5,'on');
    % %bar(1:n-1,baseMVA*-1000*[Pinj(t,:)',Qinj(t,:)'],1); %kW and KVAR
    % bar(1:n,[Pinj(1:tstep,:)', Qinj(1:tstep,:)'],1); %kW and KVAR
    % title('(Net) Nodal Injections (+) Demand (-) Generation (kW and kVAR)');
    % %axis tight;
    % xlim([1 n])
    % legend('P','Q');
    % axes5.XMinorTick = 'on';
    % %axes5.XTickLabel = strsplit(num2str(1:2:n,'%02d'));
    % axes5.TickLength = [0.005 0.00125];
    % axes5.FontSize = 8;
    % axes5.LabelFontSizeMultiplier = 1.2;
    % axes5.TitleFontSizeMultiplier = 1.5;
    % xlabel('Node');
    % ylabel('Active and Reactive Injection (kW and kVAR)');

    %Bar P Bus (Itemized) Instantaenous Nodal injections (Demand >0)
    tstep=36;
    fig = figure('Position',Position,'PaperPositionMode','auto');
    ax = axes('Parent',fig,'XTick',1:s:n);
    box(ax,'on'); hold(ax,'on');
    bar(1:n,[Pinj(tstep,:)',Timport(tstep,:)', Telec(tstep,:)', Tees_chrg(tstep,:)',-Tees_dchrg(tstep,:)', Trees_chrg(tstep,:)', -Trees_dchrg(tstep,:)', -Trees_dchrg_nem(tstep,:)', -Tpv_nem(tstep,:)', -Tpv_wholesale(tstep,:)' ],1); %kW and KVAR
    title(['P Nodal Injections (+) Demand (-) Generation (kW and kVAR) on timestep:' , num2str(tstep)]);
    %axis tight;
    xlim([1 n])
    legend('Pinj (Net)', 'import','elec' , 'ees_{chrg}' , 'ees_{dchrg}' , 'ress_{chrg}' , 'ress_{dchrg}' , 'ress_{dchrg}_{nem}', 'pv_{nem}' , 'pv_{wholesale}');
    ax.XMinorTick = 'on';
    %axes5.XTickLabel = strsplit(num2str(1:2:n,'%02d'));
    ax.TickLength = [0.005 0.00125];
    ax.FontSize = 8;
    ax.LabelFontSizeMultiplier = 1.2;
    ax.TitleFontSizeMultiplier = 1.5;
    xlabel('Node');
    ylabel('Active Injections (kW)');

    %Bar Q Bus (Itemized) Nodal injections (Demand >0)
    fig = figure('Position',Position,'PaperPositionMode','auto');
    ax = axes('Parent',fig,'XTick',1:s:n);
    box(ax,'on'); hold(ax,'on');
    bar(1:n,Qinj(1:tstep,:)',1); % KVAR
    title('Q Nodal Injections (+) Demand (-) Generation (kW and kVAR)');
    %axis tight;
    xlim([1 n])
    legend('Qinj (Net)');
    ax.XMinorTick = 'on';
    %axes5.XTickLabel = strsplit(num2str(1:2:n,'%02d'));
    ax.TickLength = [0.005 0.00125];
    ax.FontSize = 8;
    ax.LabelFontSizeMultiplier = 1.2;
    ax.TitleFontSizeMultiplier = 1.5;
    xlabel('Node');
    ylabel('Reactive Injections (kVAR)');

    %Bar Branch Power Flows
    fig = figure('Position',Position,'PaperPositionMode','auto');
    ax = axes('Parent',fig,'XTick',1:s:m);
    box(ax,'on'); hold(ax,'on');
    bar(1:m,abs([Pflow,Qflow]),1);
    axis tight;
    legend('P','Q');
    ax.XMinorTick = 'on';
    ax.TickLength = [0.005 0.00125];
    ax.FontSize = 8;
    ax.LabelFontSizeMultiplier = 1.2;
    ax.TitleFontSizeMultiplier = 1.5;
    xlabel('Branch');
    ylabel('Active and Reactive Power Flows (MW and MVAR)');
    title('Branch Power Flows (MW and MVAR)');
end 

if powererror == 1 
    %Power Error Plot (Combined)
    fig = figure('Position',Position,'PaperPositionMode','auto');
    [AX,H1,H2] = plotyy(1:m,Perror_percent, 1:m, Perror, 'bar', 'line');
    %Removes left axis Ticks on right side, but also removes the top of the box 
    set(AX(1),'Box','off')
    %Creates a Top X axis 
    top = refline(AX(1),0,AX(1).YLim(2)); top.Color = 'k'; % fills the top part of box with a black line
    set(AX(1),'XTick',1:s:m);
    set(AX(1),'XLim',[1 m]);
    set(AX(2),'XLim',[1 m]);
    %Aligning the yy axis at zero
    maxval = cellfun(@(x) max(abs(x)), get([H1 H2], 'YData'));
    ylim = [-maxval, maxval] * 1.2;  % Mult by 1.1 to pad out a bit
    set(AX(1), 'YLim', ylim(1,:) );
    set(AX(2), 'YLim', ylim(2,:) );
    xlabel(AX(1),'Branch');
    ylabel(AX(1),'Error (%)');
    ylabel(AX(2),'Error Absolute (MW)');
    H2.LineStyle = ':'; H2.Marker = 'o'; H2.Color = 'r'; set(AX(2),'ycolor','r');
    %text(1:m,Perror_percent,num2str(RX,'RX: %0.2f'),'HorizontalAlignment','center','VerticalAlignment','top');
    title('Power Flow Error');
    grid on

    %Voltage Error Plot (Combined)
    fig = figure('Position',Position,'PaperPositionMode','auto');
    [AX,H1,H2] = plotyy(1:n,Verror_percent, 1:n, Verror, 'bar', 'line');
    set(AX(1),'XTick',1:s:n);
    set(AX(1),'XLim',[1 n]);
    set(AX(2),'XLim',[1 n]);
    xlabel(AX(1),'Node');
    ylabel(AX(1),'Error (%)');
    ylabel(AX(2),'Error Absolute (p.u.)');
    H2.LineStyle = ':'; H2.Marker = 'o'; H2.Color = 'r'; set(AX(2),'ycolor','r');
    %text(1:n,Verror_percent,num2str(Verror_percent,'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom');
    title('Voltage Error');
    grid on
end

if X_R ==1 
    %XR Ratio
    fig = figure('Position',Position,'PaperPositionMode','auto');
    ax = axes('Parent',fig,'XTick',1:s:m);
    box(ax,'on'); hold(ax,'on');
    bar(1:m,RX); 
    %text(1:m,RX,num2str(RX,'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom');
    axis tight;
    xlabel('Branch');
    ylabel('R/X ratio(p.u.)');
    title('R/X ratio');
    grid on
end 
    % FolderName = 'U:\MATLAB (S)\Runs\121918_18';   % Your destination folder
    % FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    % for iFig = 1:length(FigList)
    %   FigHandle = FigList(iFig);
    %   FigName   = num2str(get(FigHandle, 'Number'));
    %   set(0, 'CurrentFigure', FigHandle);
    %   savefig(fullfile(FolderName, [FigName '.fig']));
    % end
%% Sflow for specific branches
if sflowbranch == 1
    b = [2,4,18,20]; % Choosing branches to plot
    for i=1:length(b)
        fig = figure('Position',Position,'PaperPositionMode','auto');
        ax = axes('Parent',fig);
        box(ax,'on'); hold(ax,'on');
        plot(xp,BranchSFlowAC(b(i),:),'r-','LineWidth',1.0);
        %Rating Limits
%       plot(xp,ones(length(xp))*P_rated(b(i)),'--r');hold on; 
%       plot(xp,ones(length(xp))*-P_rated(b(i)),'--r');hold on 
        %Zero crossing
%       plot(xp,zeros(length(xp)),'k');        
        ax.XLim = [1 T] ;
        xlabel('Optimization Timeframe');
        ylabel('Branch Power Flow (MVA)');
        title(['Apparent Power Flow for Branch ', num2str(b(i))]);
    end
end

%% Sflow for all Branches 
if sflowall==1
    pidgeon = find(Sb_rated == 6.8);
    quail = find(Sb_rated == 5.96);
    raven = find(Sb_rated == 5.23);
    swan = find(Sb_rated == 3.02);
    fig = figure('Position',Position,'PaperPositionMode','auto');
    ax = axes('Parent',fig);
    box(ax,'on'); hold(ax,'on');
    c = get (ax,'colororder');
    h1=plot(xp,BranchSFlowAC(pidgeon,:),'Color', c(1,:),'LineWidth',0.6);hold on;
    h2=plot(xp,BranchSFlowAC(quail,:),'Color', c(2,:),'LineWidth',0.6);hold on;
    h3=plot(xp,BranchSFlowAC(raven,:),'Color', c(4,:),'LineWidth',0.6);hold on;
    h4=plot(xp,BranchSFlowAC(swan,:),'Color', c(3,:),'LineWidth',0.6);hold on;
    ax.XLim = [1 T] ;
    legend([h1(1) h2(1) h3(1) h4(1)], 'Pidgeon (6.8 MVA)','Quail (5.96 MVA)','Raven (5.23 MVA)','Swan (3.02 MVA)');
    xlabel('Optimization Timeframe');
    ylabel('Branch Power Flow (MVA)');
    title('|Sflow| for all Branches');

% Sflow 3D 
% [bi,ti] = meshgrid(1:1:B, 1:1:T);
% fig = figure;
% ax = axes('Parent',fig);
% %box(ax,'on'); hold(ax,'on');
% c = get (ax,'colororder');
% h1 = plot3(bi(:,pidgeon),ti(:,pidgeon),BranchSFlowAC(pidgeon,:)','Color', c(1,:),'LineWidth',0.6);hold on;
% h2 = plot3(bi(:,quail),ti(:,quail),BranchSFlowAC(quail,:)','Color', c(2,:),'LineWidth',0.6);hold on;
% h3 = plot3(bi(:,raven),ti(:,raven),BranchSFlowAC(raven,:)','Color', c(4,:),'LineWidth',0.6);hold on;
% h4 = plot3(bi(:,swan),ti(:,swan),BranchSFlowAC(swan,:)','Color', c(3,:),'LineWidth',0.6);hold on;
% %plot3(bi,ti,BranchSFlowAC') %plots with no color differentiation
% xlabel('Branch'); ylabel('Time') ; zlabel('Sflow')
% legend([h1(1) h2(1) h3(1) h4(1)], 'Pidgeon (6.8 MVA)','Quail (5.96 MVA)','Raven (5.23 MVA)','Swan (3.02 MVA)', 'Location', 'best');
% grid on

end

%% k-medoids
if plot10 ==1 
    figure;
    plot(solar)
    axis tight
    title('Sampled Solar. Time-series')

    if exist('elecAECsample','var') 
        %Total AEC Samppled Demand Timeseries
        figure;
        plot(elecAECsample)
        axis tight
        title('Total AEC Sampled Demand Time-series')
        ylabel('Total elec (kW)')
        xlabel('Optimization Timeframe')
    else
        figure;
        plot(sum(elec,2))
        axis tight
        title('Total AEC Sampled Demand Time-series')
        ylabel('Total elec (kW)')
        xlabel('Optimization Timeframe')
    end
end
 
%% Individual XFMR Q loading
if plot11 == 1
    n = [2,4,18,22]; % Choosing transformers to plot
    for i=1:length(n)
        figure('Units','inches','Position',[3.5 -1.5 8.5 8])
        ax = plot(xp,Sinj(:,n(i)),'Linewidth',2.5); %Sinj (kVA) 
        c = get (gca,'colororder');
        plot(xp,Qinj(:,n(i)),'Linestyle','-','Linewidth',1.5); %Qinj (kVAR)
        hold on
        plot(xp,qimport(:,find(T_map==n(i))),'b','Linestyle','-.','Linewidth',2)
        hold on
        plot(xp,-q_elec(:,find(T_map==n(i))),'y','Linestyle','-','Linewidth',2)
        hold on
        plot(xp,-q_cap(:,find(T_map==n(i))),'g','Linestyle','--','Linewidth',3)
        hold on
        plot(xp,q_ind(:,find(T_map==n(i))),'m','Linestyle',':','Linewidth',1)
        hold on
        %plot(xp,Pinv(:,find(T_map==n(i))),'Linestyle','-','Linewidth',1.5)
        %hold on
        plot(xp,Qinv(:,find(T_map==n(i))),'Linestyle','-','Linewidth',1.5)
        hold on
        plot(xp,Sinv(:,find(T_map==n(i))),'Linestyle','-','Linewidth',2)
        %Rating Limits
        plot(xp,ones(length(xp))*T_rated(n(i)),'--r');
        hold on 
        plot(xp,ones(length(xp))*-T_rated(n(i)),'--r');
        %Zero crossing
        hold on 
        plot(xp,zeros(length(xp)),'--k');
        title(['T' num2str(n(i))]);
        ylabel('kVA'); 
        xlabel('Optimization Timeframe');
        %legend('Sinj=sqrt(Pinj^2+Qinj^2)','Pinj','Qinj,','Pload','Qload','qimport','qcap','qind','Sinv' ) 
        legend('Qinj','qimport','qelec','qcap','qind','Qinv','Sinv') 
    end
end
%% Building Dynamics for interval (w/ transparent legends!)
%Plot building dynamics for a selected interval

if plot12 == 1
   
    interval= dstart*24:dlength*24;
    k = [ 1, 3, 5 ,7]; %Buildings to plot  
    %k = find(ees_adopt>100);
    %k = find(rees_adopt>5)
    
    for i=1:length(k)
    
        figure('Units','inches','Position',[3.5 -1.5 8.5 8])

        s1 = subplot(5,1,1);
        plot(xp(interval),elec(interval,k(i)),'Color','b','Linewidth',1.5)
        %stairs(xp(interval),elec(interval,k(i)),'Color','b','Linewidth',1.5)
        hold on
        plot(xp(interval),pv_elec(interval,k(i)),'Color',rgb('Orange'),'Linewidth',1.5)
        %stairs(xp(interval),pv_elec(interval,k(i)),'Color',rgb('Orange'),'Linewidth',1.5)
        hold on
        plot(xp(interval),import(interval,k(i)),'Color','m','Linewidth',1.5)
        %stairs(xp(interval),import(interval,k(i)),'Color','m','Linewidth',1.5)
        ylabel('kW');
        lgd = legend('Building Load','PV_{elec}','Import','Location','northeast','Orientation','Horizontal');
        lgd.FontSize = 10;
        lgd.Color = [1 1 1 .6];
        lgd.BoxFace.ColorType ='truecoloralpha';
        lgd.BoxFace.ColorData = uint8(255*[1;1;1;.6]);
        s1.XTick = range;
        s1.XTickLabel = {'0','6','12','18','0','6','12','18','0','6','12','18','0'};
        s1.XLim = [interval(1) interval(length(interval))];
        s1.YLim = [0 1.5*max(max(elec(interval,k(i))),max(import(interval,k(i))))];
        str = sprintf('Power Dynamics of Building: %d - PV: %.0f kW |BESS: %.0f kWh| RESS: %.0f kWh ', k(i), pv_adopt(k(i)), ees_adopt(k(i)),rees_adopt(k(i)));
        title(str);

        s2 = subplot(5,1,2);
        plot(xp(interval),pv_adopt(k(i)).*solar(interval),'Color',rgb('OrangeRed'),'Linewidth',1.5);
        ylabel('kW');
        lgd = legend('PV','Location','northeast','Orientation','Horizontal');
        lgd.FontSize = 10;
        lgd.Color = [1 1 1 .6];
        lgd.BoxFace.ColorType ='truecoloralpha';
        lgd.BoxFace.ColorData = uint8(255*[1;1;1;.6]);
        s2.XTick = range;
        s2.XTickLabel = {'0','6','12','18','0','6','12','18','0','6','12','18','0'};
        s2.XLim = [interval(1) interval(length(interval))];
        if pv_adopt(k(i))
            s2.YLim = [0 1.5*max(pv_adopt(k(i)).*solar(interval))];
        end
        
        s3 = subplot(5,1,3);
        plot(xp(interval),pv_nem(interval,k(i)),'Color','r','Linewidth',1.5);
        hold on
        plot(xp(interval),pv_wholesale(interval,k(i)),'Color','k','Linewidth',1.5);
        ylabel('kW');
        lgd = legend('PV NEM','PV Wholesale','Location','northeast','Orientation','Horizontal');
        lgd.FontSize = 10;
        lgd.Color = [1 1 1 .6];
        lgd.BoxFace.ColorType ='truecoloralpha';
        lgd.BoxFace.ColorData = uint8(255*[1;1;1;.6]);
        s3.XTick = range;
        s3.XTickLabel = {'0','6','12','18','0','6','12','18','0','6','12','18','0'};
        s3.XLim = [interval(1) interval(length(interval))];
        if sum(pv_nem(k(i))) | sum(pv_wholesale(k(i)))
            s3.YLim = [0 1.5*max(max(pv_nem(interval,k(i)),max(pv_wholesale(interval,k(i)))))];
        end 
        
        s4 = subplot(5,1,4);
        %plot(xp(interval),ees_chrg(interval,k(i)),'Color',rgb('DarkBlue'),'Linewidth',1.5);
        stairs(xp(interval),ees_chrg(interval,k(i)),'Color',rgb('DarkBlue'),'Linewidth',1.5); 
        hold on
        %plot(xp(interval),ees_dchrg(interval,k(i)),'Color',rgb('DodgerBlue'),'Linewidth',1.5);
        stairs(xp(interval),ees_dchrg(interval,k(i)),'Color',rgb('DodgerBlue'),'Linewidth',1.5);
        ylabel('kWh');
        lgd = legend('EES Charge','EES Discharge','Location','northeast','Orientation','Horizontal');
        lgd.FontSize = 10;
        lgd.Color = [1 1 1 .6];
        lgd.BoxFace.ColorType ='truecoloralpha';
        lgd.BoxFace.ColorData = uint8(255*[1;1;1;.6]);
        s4.XTick = range;
        s4.XTickLabel = {'0','6','12','18','0','6','12','18','0','6','12','18','0'};
        s4.XLim = [interval(1) interval(length(interval))];
        if ees_adopt(k(i))
            s4.YLim = [0 1.5*max(max(ees_chrg(interval,k(i)),max(ees_dchrg(interval,k(i)))))];
        end 
        
        s5 = subplot(5,1,5);
        stairs(xp(interval),rees_chrg(interval,k(i)),'Color',rgb('DarkGreen'),'Linewidth',1.5);
        hold on
        stairs(xp(interval),rees_dchrg(interval,k(i)),'Color',rgb('LimeGreen'),'Linewidth',1.5); 
        s5.XTick = range;
        s5.XTickLabel = {'0','6','12','18','0','6','12','18','0','6','12','18','0'};
        xlabel('Hours');
        ylabel('kWh');
        lgd = legend('REES Charge','REES Discharge','Location','northeast','Orientation','Horizontal'); 
        lgd.FontSize = 10;
        lgd.Color = [1 1 1 .6];
        lgd.BoxFace.ColorType ='truecoloralpha';
        lgd.BoxFace.ColorData = uint8(255*[1;1;1;.6]);
        s5.XLim = [interval(1) interval(length(interval))];        
        if rees_adopt(k(i))
            s5.YLim = [0 1.5*max(max(rees_chrg(interval,k(i)),max(rees_dchrg(interval,k(i)))))];
        end 
             
    end 
end

%% SOC 

  %SOC for all 864 timesteps
    fig = figure('Position', Position ,'PaperPositionMode','auto');
    ax = axes('Parent',fig);
    box(ax,'on'); hold(ax,'on');
    h1 = plot(1:T,ees_soc,'r-','LineWidth',0.6);hold on;
    h2 = plot(1:T,rees_soc,'b-','LineWidth',0.6);hold on;
    axis tight;
    legend([h1(1) h2(1)],'EES','REES');
    xlabel('Optimization Timeframe');
    ylabel('Energy (kWh)');
    title('EES / REES Energy(kWh)');
  
    fig = figure('Position', Position ,'PaperPositionMode','auto');
    ax = axes('Parent',fig);
    box(ax,'on'); hold(ax,'on');
    ees_adopt_soc = ees_adopt; rees_adopt_soc = rees_adopt;
    ees_adopt_soc(find(ees_adopt == 0))= 1; rees_adopt_soc(find(rees_adopt == 0))= 1;
    h1 = plot(1:T,100*(ees_soc./ees_adopt_soc),'r-','LineWidth',0.6);hold on;
    h2 = plot(1:T,100*(rees_soc./rees_adopt_soc),'b-','LineWidth',0.6);hold on;
    axis tight;
    legend([h1(1) h2(1)],'EES','REES');
    xlabel('Optimization Timeframe');
    ylabel('SOC (%)');
    title('EES / REES SOC (%)');

    %%
    %SOC @ a given building b
    b = 16;
    fig = figure('Position', Position ,'PaperPositionMode','auto');
    ax = axes('Parent',fig);
    box(ax,'on'); hold(ax,'on');
    h1 = plot(1:T,ees_soc(:,b),'r-','LineWidth',0.6);hold on;
    h2 = plot(1:T,rees_soc(:,b),'b-','LineWidth',0.6);hold on;
    axis tight;
    legend([h1(1) h2(1)],'EES','REES');
    tix=get(ax,'ytick')';
    set(ax,'yticklabel',num2str(tix,'%.0f'))
    xlabel('Optimization Timeframe');
    ylabel('Energy (kWh)');
    str = sprintf('EES / REES Energy(kWh) at building: %.0f',b);
    title(str);
