close all 
%% Color Palletes
load('palletes_ldn');
pallete = bright;

    n = size(mpc.bus,1);
    m = size(mpc.branch,1);
    if m <=54
    s = 1; %spacing between xticks
    elseif m >= 105
        s = 4; 
    else m > 54
        s = 3;
    end 

%%  Apparent power Flows 864 timesteps
    Position = [467   -53   812   515];
    fig = figure('Position', Position ,'PaperPositionMode','auto');
    fig.Color = 'w';
    ax = axes('Parent',fig,'XTick',1:s:m);
    box(ax,'on'); hold(ax,'on');
    ax.Color = [234 234 242]./255; % set background gray
    grid on; ax.GridColor = [255,255,255]./255; 
    ax.GridAlpha = 0.9; %set grid white with transparency
    ax.TickLength = [0 0];
    
    %ACPF
    h1 = plot(1:m,BranchSFlowAC,'Color',[pallete(2,:) 1],'LineWidth',0.6);hold on;
    
    %Linearized
    if exist('Volts','var') 
        if dlpfc
           h2 = plot(1:m,Sflow,'Color',[pallete(1,:) 0.2 ],'LineWidth',0.6);hold on;
        else 
           h2 = plot(1:m,Sflow,'Color',pallete(7,:),'LineWidth',0.6);hold on;
        end
    
    %Highlight Linearized OV and UV with black line
    %h3 = plot(1:n,Volts(:,[timeuvL timeovL]),'Color','k','LineWidth',1.0);hold on;

    %Highlight a specific timestep for comparing Linearized vs. true solution      
    ts = 345;
    h3 = plot(1:m,BranchSFlowAC(:,ts),'k','LineWidth',0.4);hold on;
    h4 = plot(1:m,Sflow(:,ts),':k','LineWidth',1.8);hold on;

    %Highlight, for thefirst day of each month @ 13 PM and 6 PM (check)
    %  h4 = plot(1:n,Volts(:,endpts-11),'Color','k','LineWidth',0.6);hold on;
    %  h5 = plot(1:n,Volts(:,endpts-5),'Color','k','LineWidth',0.6);hold on;   
    else       
    %Highlight True OV and UV with black line
    %h3 = plot(1:n,BusVolAC(:,[timeuv timeov]),'Color','k','LineWidth',1.0);hold on;
    end
    
    %True OV and UV Labels and orange Marker
    d = 0.5;
    p1 = plot(nodeoc, oc,'o' ,'MarkerSize', 5,'Color','k','MarkerFaceColor',pallete(2,:));
    text(nodeoc-d, oc+d, sprintf('%.2f',oc),'FontSize', 11)
     
    %Linearized OV and UV Markers
    if lindist 
        p3 = plot(nodeocL, ocL,'o' ,'MarkerSize', 5,'Color','k','MarkerFaceColor',pallete(7,:));
    elseif dlpfc
        p3 = plot(nodeocL, ocL,'o' ,'MarkerSize', 5,'Color','k','MarkerFaceColor',pallete(1,:));
    end 
    
    %Linearized OV and UV labels and black line for time 
    if exist('Sflow','var')
    text(nodeocL-d, ocL+d, sprintf('%.2f ',ocL),'FontSize', 11)
    end
    
    ax.FontSize = 12;
    ax.XTickLabelRotation = 90;
    
    if dlpfc %DLPF legend
        [leg, objects] = legend([h1(1) h2(1)],'True power','Linearized (DLPF)','Location','northeast');
%       [leg, objects] = legend([h3(1) h4(1)],'True voltage','Linearized (DLPF)','Location','southwest');
   
        title('Branch apparent power - Linearized (DLPF) vs. True power');

    elseif lindist %LinDist legend
       [leg, objects ] = legend([h1(1) h2(1)],'True power)','Linearized (LinDistFlow)','Location','best');
 %     [leg, objects] = legend([h3(1) h4(1)],'True power','Linearized (LinDistFlow)','Location','northeast');

        title('Branch apparent power - Linearized (LinDistFlow) vs. True power');

    else %Base case title
        [leg, objects ] = legend('True Voltage (ACPF)','Location','best');
        title('Branch apparent power - Base Case ');
    end 
    
    leg.BoxFace.ColorType = 'truecoloralpha';
    leg.BoxFace.ColorData = uint8([234 234 242 242*0.8]');
    xlabel('Branch');
    ylabel('Branch apparent power kVA');
%   ylim([0.85  1.22]) %[0.80 1.085] for all cases but baseline. %Baseline [0.85  1.22]
    tix=get(ax,'ytick')';
    set(ax,'yticklabel',num2str(tix,'%.0f'))
    ax.YMinorTick = 'on';
    xlim([1 m])
