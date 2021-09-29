
N = length(bus);  %n-th node from 1...N
T = length(time); %t-th time interval from 1...T

%% Transformer-Aggregated Nodal Injection
%               n1       n2       
% Pinj(n)= [    :    |   :     };  %[T,N] %kW

%% AEC 31 BLDGS 
% There are more nodes (N=54) than buildings (K=31)
% One node n can take more than one k buildings
% A node n might not have a transformer (connection node)

%% Transformer Map 
% Maps buildings to nodes (transformers)
% This format allows "connecting" multiple buildings to the same node 

%             k1   k2  k3          K   
%T_map(k)= [  n1 | n1 | n1 | ... |   ]; %(1,K)

%T_map = [28 40	28	33	44	37	41	38	35	30	4	2	6	54	18	18	8	31	16	29	34	12	43	11	27	26	39	14	22	42	36];%Feb.25.19 
%T_map = [37 40	28	44	39	41	42	28	43	2	54	4	6	30	18	22	8	31	16	29	34	27	35	14	38	10	33	12	36	26	11];%Mar.18.19 %54-node %elec = base 
%T_map = [65 76	84	82	78	74	72	84	70	4	12	7	15	10	39	44	19	47	34	67	59	53	61	30	80	22	57	27	63	51	24];%Apr.10.19 %84-node
% ^ Migrated to playground 
%% Transformer Ratings
%Optimize Transformer ratings
if opt_t
    %T_rated as deision variable -> remeber to include it in objective function 
    T_rated = sdpvar(1,54,'full'); %Later will need to automate this t o make N = length of number of buses of MATPOWER case or something....
    Objective = Objective + xfmr_v(1)*sum(T_rated);

    %T_rated can only assume a list of possible values
    possiblevalues = [0,10,15,25,37.5,50,75,100,167,200,225,300,500,750,1000,1500,2000,3000,4000,5000,6000,7000,10000,20000];

    %Using ismember (it is slower than methods below)
    %Constraints = [Constraints, ismember(T_rated,possiblevalues)];

    %Using binvar 
    %  pick = binvar(54,length(possiblevalues),'full');
    %  Constraints = [Constraints 
    %      (T_rated' == (pick*possiblevalues')):'PickPossiblevalues' 
    %      (sum(pick,2)==1):'SumPick=1' 
    %      (T_rated >=0):'T_rated>0' ]

    %Using sdpvar and binary()
    pick = sdpvar(54,length(possiblevalues),'full');
    Constraints = [Constraints
        (T_rated' == (pick*possiblevalues')):'pick*possiblevalues'
        (binary(pick)):'binary(pick)'
        sum(pick,2)==1 ];
%        T_rated >= 5
%        T_rated <= 1500 ];
%% Known transformer ratings   
else %Known tranformer ratings
    
    %T_rated = [0	100	0	75	0	100	0	75	0	0	75	500	0	25	0	50	0	50	0	0	0	37.5	0	0	0	15	37.5	100	25	200	15	0	25	15	15	15	1250	15	100	800	200	75	15	15	0	0	0	0	0	0	0	0	0	50]; %Mar.01.19
    %T_rated = [0	150	0	75	0	150	0	75	0	0	75	1000	0	25	0	75	0	50	0	0	0	37.5	0	0	0	25	37.5	150	25	300	25	0	25	25	25	25	1500	25	100	1000	200	100	25	25	0	0	0	0	0	0	0	0	0	75]; %Feb.25.19
    %T_rated = [0	100	0	150	0	75	0	150	0	50	25	150	0	37.5	0	100	0	25	0	0	0	200	0	0	0	25	25	150	37.5	200	25	0	100	37.5	75	1000	1250	100	250	37.5	1500	25	37.5	25	0	0	0	0	0	0	0	0	0	500]; %Mar.18.19 %elec = base
    %ratings = [1250	37.5	150	25	250	1500	25	150	37.5	100	500	150	75	200	25	200	150	25	100	37.5	37.5	25	75	37.5	100	50	100	150	1000	25	25]; %Apr.10.19 84-node
    ratings = [1250	37.5	150	25	250	1500	25	37.5	37.5	100	500	150	75	200	25	200	150	25	100	37.5	37.5	25	75	37.5	100	50	100	150	1000	25	25]; %Jun.17.19 115-node
    
    T_rated = zeros(1,N);
    for k=1:K
        T_rated(T_map(k)) = ratings(k);
    end  
end 

%% Pinj, Qinj, and Polygon Constraints 
Pinj = sdpvar(T,N,'full'); %kW
Qinj = sdpvar(T,N,'full'); %kVAR 

%Set up Polygon Constraints
L = 20; % number of line segments of the polygon
i = 0:L-1;
theta = pi/L + i.*(2*pi)./L; %rad
C = [cos(theta)' sin(theta)'];
s = T_rated*cos(theta(1));

for n=1:N % For each node n
    cluster = find(T_map == n); % returns vector of building # (k) connected to node n
    if isempty(cluster) == 0 % if there is a building connected to that node, calculate injections and add a constraint     
      %Qinj
      Qinj(:,n) = sum(elec(:,cluster).*repmat(tan(acos(pf(cluster))),T,1),2); % Qinj = Pelec*tan(phi)  Glover,(2.3.8) %kVAR
      % Pinj
      Constraints = [Constraints, Pinj(:,n) == sum([import(:,cluster), - pv_nem(:,cluster), - pv_wholesale(:,cluster), - rees_dchrg_nem(:,cluster)],2)]; %kW       
      
        if tc ==1 
            %Polygon Constraints
            Constraints = [Constraints, C*[Pinj(:,n)';Qinj(:,n)'] <= alpha*s(n)];
            %Individual import/ export Constraints
            Constraints = [Constraints,  sum(import(:,cluster),2) <= alpha*T_rated(n)];
            Constraints = [Constraints,  sum(pv_nem(:,cluster),2) + sum(pv_wholesale(:,cluster),2) + sum(rees_dchrg_nem(:,cluster),2)  <= alpha*T_rated(n)];
        end 
      
    else % if it i s a connection node, Pinj, Qinj = 0 so it does not show as NaN  
        Pinj(:,n) = zeros(T,1);
        Qinj(:,n) = zeros(T,1);
    end
end