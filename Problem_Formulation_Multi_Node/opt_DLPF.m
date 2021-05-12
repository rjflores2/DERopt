%% DLPF 
% ldn implementation based off of:
% "A State-Independent Linear Power Flow Model with Accurate Estimation of Voltage Magnitude
% Jingwei Yang, Student Member, IEEE, Ning Zhang, Member, IEEE, Chongqing Kang, Fellow, IEEE and Qing Xia, Senior Member, IEEE

    %Define MATPOWER constants and base power
    define_constants;

    %Load MATPOWER case study files
    %Comment if loading in playground.m  
    %mpc = loadcase('caseAEC');
    %[baseMVA, bus, gen, branch] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.branch);

    %Get bus types
    [ref, pv, pq] = bustypes(mpc.bus, mpc.gen);

    %Admittance matrix YBUS %(p.u.)
    [YBUS, YF, YT] = makeYbus(mpc); %(p.u.)

    %Susceptance (B) and Conductance (G) Matrices, and also Bprime (BP) 
    B = imag(YBUS);     %(p.u.)
    G = real(YBUS);     %(p.u.)
    BD = diag(sum(B));  %shunt elements %(p.u.)
    BP = -B + BD;       %B_prime = B matrix with no shunt elements %(p.u.)

    H = BP([pv;pq],[pv;pq]); 
    NN = G([pv;pq],pq);
    M = -G(pq,[pv;pq]);
    L = -B(pq,pq);

    BSRp = BP(pv,ref);
    GSR = G(pv,ref);
    GSS = G(pv,pv);
    BLRp = BP(pq,ref);
    GLR = G(pq,ref);
    BLR = B(pq,ref);
    BLS = B(pq,pv);
    GLS = G(pq,pv);

    ThetaR = 0;
    VR = gen(1,6);
    VS = gen(2:size(gen,1),6);

    t1 = NN/L;
    t2 = M/H;
    Hbar = H - t1*M;
    Lbar = L - t2*NN;

    %Iniial Voltage Angle
    Theta_init = ones(length(pq),T)*mpc.bus(ref,VA);

    %Defining branch constants 
    branch(:,BR_STATUS) = 1; %All branches are connected 
    branch(find(branch(:,TAP)==0),TAP) = 1; % TAP = 1 for simple DLPF coding 
    tap = repmat(branch(:,TAP),1,T); %dim = (B,T)
    gij = repmat(branch(:,BR_R)./(branch(:,BR_X).^2+branch(:,BR_R).^2),1,T); %dim = (B,T)
    bij = repmat(-branch(:,BR_X)./(branch(:,BR_X).^2+branch(:,BR_R).^2),1,T); %dim = (B,T)

    %Housekeeping on MATPOWER case
    mpc.bus([pv;pq],VA) = 0; %initial angle = 0
    mpc.bus(:,VM) = 1;       %initial bus voltage magnitude =1
%% DLPF
    
    B = size(branch,1); %number of branches
    
    %Branch Rated kVA (migrasted to playground)
     %load Sb_rated_86;
     %load Sb_rated_86_new; %For seondary of the transformer 120/240V
     %Sb_rated = Sb_rated_86; %MVA
    
    Theta = sdpvar(N,T,'full'); Theta(1,:) = zeros(1,T);  %slack node angle = 0 deg
    Volts = sdpvar(N,T,'full'); Volts(1,:) = ones(1,T);   %slack node voltage = 1 p.u. 
    Pflow = sdpvar(B,T,'full');
    Qflow = sdpvar(B,T,'full');
     
    %DLPF for linearized Volts, Pflow, and Qflow
    start = tic; 
    Constraints = [Constraints
        (Theta([pv;pq],:) == Theta_init + (Hbar\(((-Pinj(:,[pv,pq])'./1e3./baseMVA) + repmat([BSRp -GSR -GSS ; BLRp -GLR -GLS ]*[ThetaR ; VR ; VS],1,T)) - t1*((-Qinj(:,pq)'./1e3./baseMVA) + repmat([GLR BLR BLS]*[ThetaR ; VR ; VS],1,T)))./(pi*180))):'DLPF Theta'
        (Volts(pq,:) == (Lbar\(((-Qinj(:,pq)'./1e3./baseMVA) + repmat([GLR BLR BLS]*[ThetaR ; VR ; VS],1,T)) - t2*((-Pinj(:,[pv,pq])'./1e3./baseMVA) + repmat([BSRp -GSR -GSS ; BLRp -GLR -GLS ]*[ThetaR ; VR ; VS],1,T))))):'DLPF Volts'
        (Pflow == (((Volts(branch(:,F_BUS),:))./tap - (Volts(branch(:,T_BUS),:))).*gij./tap + ((Theta(branch(:,F_BUS),:)) - (Theta(branch(:,T_BUS),:))).*-bij/180*pi./tap)*baseMVA):'DLPF Pflow'
        (Qflow == (((Volts(branch(:,F_BUS),:))./tap - (Volts(branch(:,T_BUS),:))).*-bij./tap + ((Theta(branch(:,F_BUS),:)) - (Theta(branch(:,T_BUS),:))).*-gij/180*pi./tap)*baseMVA):'DLPF Qflow'
        ];  
    tdlpf = toc(start);

    %Setting up Polygon Constraints
    Lb = 22; % number of segments of the polygon
    ib = 0:Lb-1;
    thetab = pi/Lb + ib.*(2*pi)./Lb; %rad
    %Cb = [sin(thetab)' cos(thetab)'];
    Cb = [cos(thetab)' sin(thetab)'];
    sb = Sb_rated*cos(thetab(1));
    margin = 1;
    
    %Polygon constaints for each branch 
    if branch
        for b=1:B % for each branch b
         Constraints = [Constraints, (Cb*[Pflow(b,:);Qflow(b,:)] <= margin*sb(b)):'DLPF Branch Polygon'];
        end
    end 

    %Voltage constraints
    if voltage 
        Constraints = [Constraints, (VL <= Volts <= VH):'DLPF Voltage'];
    end 