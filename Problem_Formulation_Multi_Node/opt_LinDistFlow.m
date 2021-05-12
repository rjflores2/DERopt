% LinDistFlow
% ldn's implementation into DERopt
% based off of LinDist code from GitHub repository:
% Schweitzer, E. Lossless DistFlow implementation. GitHub (2018). 
% Available at: https://github.com/eranschweitzer/distflow

    %Define MATPOWER constants and base power
    define_constants;

    %Load MATPOWER case study files (migrated to playground)
    %mpc = loadcase('caseAEC');
    %[baseMVA, bus, gen, branch] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.branch);

    %Get bus types
    [ref, pv, pq] = bustypes(mpc.bus, mpc.gen);

    %Housekeeping on MATPOWER case
    mpc.branch(:,BR_STATUS) = 1; %All branches are connected 
    mpc.branch(find(mpc.branch(:,TAP)==0),TAP) = 1; % TAP = 1 for simple coding 
    mpc.gen(:, GEN_STATUS) = 1; %Activates all generators 
    mpc.bus([pv;pq],VA) = 0; %initial angle = 0
    mpc.bus(:,VM) = 1;       %initial bus voltage magnitude =1

    %% LinDistFow

    %Branch Rated kVA (migrated to playground)
    %load Sb_rated_86; Sb_rated = Sb_rated_86; %MVA

    FromNode = mpc.branch(:,F_BUS);
    ToNode = mpc.branch(:,T_BUS);
    Branch = (1:size(mpc.branch,1))';
    N = size(mpc.bus,1); %Number of Nodes
    B = length(FromNode); %Number of Branches 
    slack_bus = find(mpc.bus(:,BUS_TYPE)==3);
    slack_voltage = mpc.bus(slack_bus,VM);
    From=sparse(Branch,FromNode,1,B,N);
    To=sparse(Branch,ToNode,1,B,N);

    r=mpc.branch(:,BR_R); %resistance
    x=mpc.branch(:,BR_X); %reactance
    Rline= sparse(1:B, 1:B,r);
    Xline= sparse(1:B, 1:B,x);

    TFT=To*From'; %ToFromTo
    I=speye(B);
    M0=From-To; % Incidence matrix 
    M=M0(:,2:end); %Incidence matrix ignoring slack bus
    C=(I-TFT)^(-1)-I;
    tau=(Rline*C*Rline+Xline*C*Xline)*(Rline*Rline+Xline*Xline)^(-1);
    D=(I+C)*To;

    %Lossless
    R=2*(M\Rline)*(C+I)*To;
    X=2*(M\Xline)*(C+I)*To;

    Volts = sdpvar(N,T,'full'); Volts(1,:) = ones(1,T); %slack node voltage = 1 p.u. 
    Pflow = sdpvar(B,T,'full');
    Qflow = sdpvar(B,T,'full');

    %LinDistFlow for linearized Volts, Pflow, and Qflow
         Constraints = [Constraints...,
             (Volts == [repmat(slack_voltage^2,1,T) ; slack_voltage^2+R*(Pinj'/1e3/baseMVA)+X*(Qinj'/1e3/baseMVA)]):'LinDist Volts' %p.u.^2
             (Pflow == baseMVA*(C+I)*To*(Pinj'/1e3/baseMVA)):'LinDist Pflow' %MW
             (Qflow == baseMVA*(C+I)*To*(Qinj'/1e3/baseMVA)):'LinDist Qflow' %MVAR
             ]; 
         
        %Setting up Polygon Constraints
        Lb = 22; % number of segments of the polygon
        ib = 0:Lb-1;
        thetab = pi/Lb + ib.*(2*pi)./Lb; %rad
        Cb = [cos(thetab)' sin(thetab)'];
        sb = Sb_rated*cos(thetab(1));
        margin = 1;

        %Polygon constaints for each branch 
        if branch
         for b=1:B % for each branch b
          Constraints = [Constraints, (Cb*[Pflow(b,:);Qflow(b,:)] <= margin*sb(b)):'LinDist Branch Polygon'];
         end
        end 

        %Voltage constraints
        %slack = sdpvar(N,T);
        %Constraints = [Constraints, (0 <= slack <= 0.5):'LinDist Voltage Slack'];
        if voltage 
            %Constraints = [Constraints, (VL^2 - slack <= Volts <= VH^2):'LinDist Voltage'];
            Constraints = [Constraints, (VL^2 <= Volts <= VH^2):'LinDist Voltage'];
        end 


  