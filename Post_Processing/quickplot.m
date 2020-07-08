close all 
%% Color Palletes
load('palletes_ldn');
pallete = bright;

    n = size(mpc.bus,1);
    m = size(mpc.branch,1);
    if n <=54
    s = 1; %spacing between xticks
    elseif n >= 105
        s = 4; 
    else n > 54
        s = 3;
    end 

%%  %Voltage Profile for all 864 timesteps
    Position = [467   -53   812   515];
    fig = figure('Position', Position ,'PaperPositionMode','auto');
    fig.Color = 'w';
    ax = axes('Parent',fig,'XTick',1:s:n);
    box(ax,'on'); hold(ax,'on');
    ax.Color = [234 234 242]./255; % set background gray
    grid on; ax.GridColor = [255,255,255]./255; 
    ax.GridAlpha = 0.9; %set grid white with transparency
    ax.TickLength = [0 0];
    
    %ACPF
    h1 = plot(1:n,BusVolAC,'Color',[pallete(2,:) 1],'LineWidth',0.6);hold on;
    
    %Linearized
    if exist('Volts','var') 
        if dlpfc
           h2 = plot(1:n,Volts,'Color',[pallete(1,:) 0.2 ],'LineWidth',0.6);hold on;
        else 
           h2 = plot(1:n,Volts,'Color',pallete(7,:),'LineWidth',0.6);hold on;
        end
    
    %Highlight Linearize d OV and UV with black line
    %h3 = plot(1:n,Volts(:,[timeuvL timeovL]),'Color','k','LineWidth',1.0);hold on;

    %Highlight a specific timestep for comparing Linearized vs. true solution      
    ts = 345;
    h3 = plot(1:n,BusVolAC(:,ts),'k','LineWidth',0.4);hold on;
    h4 = plot(1:n,Volts(:,ts),':k','LineWidth',1.8);hold on;
 

    %Highlight, for thefirst day of each month @ 13 PM and 6 PM (check)
    %  h4 = plot(1:n,Volts(:,endpts-11),'Color','k','LineWidth',0.6);hold on;
    %  h5 = plot(1:n,Volts(:,endpts-5),'Color','k','LineWidth',0.6);hold on;   
    else
        
    %Highlight a timestep for base case
    %Winter day 02/02 13 & 02/02 18
    h5 = plot(1:n,BusVolAC(:,109),'Color','k','LineWidth',1.0);hold on;
    h5 = plot(1:n,BusVolAC(:,115),'Color','k','LineWidth',1.0);hold on;
    %Summer day 07/01 13 & 07/01 18
    h6 = plot(1:n,BusVolAC(:,445),'Color','k','LineStyle',':','LineWidth',1.5);hold on;
    h6 = plot(1:n,BusVolAC(:,451),'Color','k','LineStyle',':','LineWidth',1.5);hold on;

    end
    
    %True OV and UV Labels and orange Marker
    d = 0.01;
    p1 = plot(nodeuv, uv,'o' ,'MarkerSize', 5,'Color','k','MarkerFaceColor',pallete(2,:));
    p2 = plot(nodeov, ov,'o' ,'MarkerSize', 5,'Color','k','MarkerFaceColor',pallete(2,:));
    text(nodeuv-d, uv+d, sprintf('%.3f',uv),'FontSize', 11)
    text(nodeov+d, ov+d, sprintf('%.3f',ov),'FontSize', 11)
%     text(nodeuv-d, uv+d, sprintf('%.3f @ node %.0f',uv,nodeuv),'FontSize', 11)
%     text(nodeov+d, ov+d, sprintf('%.3f @ node %.0f',ov,nodeov),'FontSize', 11)
    
    %Linearized OV and UV Markers
    if lindist 
        p3 = plot(nodeuvL, uvL,'o' ,'MarkerSize', 5,'Color','k','MarkerFaceColor',pallete(7,:));
        p4 = plot(nodeovL, ovL,'o' ,'MarkerSize', 5,'Color','k','MarkerFaceColor',pallete(7,:));
    elseif dlpfc
        p3 = plot(nodeuvL, uvL,'o' ,'MarkerSize', 5,'Color','k','MarkerFaceColor',pallete(1,:));
        p4 = plot(nodeovL, ovL,'o' ,'MarkerSize', 5,'Color','k','MarkerFaceColor',pallete(1,:));
    end 
    
    %Linearized OV and UV labels and black line for time 
    if exist('Volts','var')
    text(nodeuvL-d, uvL+d, sprintf('%.3f ',uvL),'FontSize', 11)
    text(nodeovL+d, ovL+d, sprintf('%.3f ',ovL),'FontSize', 11) 
    %text(nodeuvL-d, uvL+d, sprintf('%.3f @ node %.0f',uvL,nodeuvL),'FontSize', 11)
    %text(nodeovL+d, ovL+d, sprintf('%.3f @ node %.0f',ovL,nodeovL),'FontSize', 11) 
    end
    
    ax.FontSize = 12;
    ax.XTickLabelRotation = 90;
    
    if dlpfc %DLPF legend
        [leg, objects] = legend([h1(1) h2(1)],'True voltage','Linearized (DLPF)','Location','northwest');
%       [leg, objects] = legend([h3(1) h4(1)],'True voltage','Linearized (DLPF)','Location','southwest');
    if VL < 0.95 % DLPF title
        title(sprintf('Voltage Profiles - Linearized (DLPF) vs. True voltage \n Voltage constraint: v <= %.2f', VH));
    else 
        title(sprintf('Voltage Profiles - DLPF vs. ACPF \n Voltage constraint: %.2f <= v <= %.2f', VL, VH));
    end
    
    elseif lindist %LinDist legend
%       [leg, objects ] = legend([h1(1) h2(1) h3(1) h4(1) h5(1)],'True Voltage (ACPF)','LinDist','OV and UV','1:00 PM','6:00 PM','Location','best');
        [leg, objects] = legend([h1(1) h2(1)],'True voltage','Linearized (LinDistFlow)','Location','northwest');
    if VL < 0.95 % Lidist title
        title(sprintf('Voltage Profiles - LinDistFlow vs.  ACPF \n Voltage constraint: v <= %.2f', VH));
    else 
        title(sprintf('Voltage Profiles - LinDistFlow vs. ACPF \n Voltage constraint: %.2f <= v <= %.2f', VL, VH));
    end  
    else %Basecase title
        [leg, objects ] = legend([h1(1) h5(1) h6(1)],'True Voltage (ACPF)','Winter day','Summer day','Location','best');
        title('Voltage Profiles - Base Case ');
    end 
    
    leg.BoxFace.ColorType = 'truecoloralpha';
    leg.BoxFace.ColorData = uint8([234 234 242 242*0.8]');
    xlabel('Node');
    ylabel('Voltage Magnitude (p.u.)');
    ylim([0.85  1.22]) %[0.80 1.085] for all cases but baseline. %Baseline [0.85  1.22]
    tix=get(ax,'ytick')';
    set(ax,'yticklabel',num2str(tix,'%.3f'))
    ax.YMinorTick = 'on';
    xlim([1 N])
