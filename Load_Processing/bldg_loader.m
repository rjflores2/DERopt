%% BUILDING LOADER
% loads building demand data and solar production data 

%% AEC 31 Buildings

load bldgdata\mdl_loads 
elec = [comm.all_ecm.ind comm.all_ecm.res comm.all_ecm.com]; 
rate={'CI2' 'CI1' 'CI2' 'CI2' 'CI2' 'CI1' 'CI2' 'CI2' 'CI2' 'CI2' 'CI2' 'CI2' 'CI2' 'CI2' 'CI2' 'CI2' 'CI2' 'CI2' 'CI2' 'CI2' 'CI2' 'R1' 'R1' 'R1' 'R1' 'R1' 'R1' 'R1' 'R1' 'R1' 'R1' };
% DC applicable (1 = yes, 0 = no)
dc_exist=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0];

% Transformer Map - Maps buildings to nodes (transformers)
% This format allows "connecting" multiple buildgins to the same node 
%             k1   k2  k3          K   
%T_map(k)= [  n1 | n1 | n1 | ... |   ]; %(1,K)
% K > N
T_map = [2 2 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 44 36 36 38 38 38 54]; 

K = length(T_map); % Number of buildings 
    
pf=0.9*ones(1,K); % Assuming PF = 0.9 for res+comm+ind buildings 

max_elec=max(elec);
cooling=zeros(size(elec));   
heating=zeros(size(elec));   

%% K-medeoids on elec and solar data

% If first time running, you'll need to run these two files, otherwise, comment two lines below and just load data :) 
%kmedoids_demand
%kmedoids_solar

load elecsample.mat
load days_multi.mat
load timesample.mat 
load solarsample.mat
load elecAECsample.mat

elec = elecsample;
time = timesample;
solar = solarsample;
day_multi = days_multi;
clear days_multi;

% Simulation time step: (60 for hourly, 15 for 15-minutes)
t_step=round((time(2) - time(1))*(60*24));

datetimev=datevec(time);

%%%Determining (sampled) endpoints 
counter=1;
for i=2:length(time)
   if datetimev(i,2)~=datetimev(i-1,2)
       endpts(counter,1)=i-1;
       counter=counter+1;
    end
end

endpts(end+1)=length(time);

%% Number of days in the filtered data
day_count = length(elecsample)/24;

%% Locating Summer Months

%summer_month = [6;7;8;9;10];

summer_month=[];
counter=1;
counter1=1;
% endpts
if length(endpts)>1
    for i=2:endpts(length(endpts))
        if datetimev(i,2)~=datetimev(i-1,2)
            counter=counter+1;
            if datetimev(i,2)>=6&&datetimev(i,2)<10
                summer_month(counter1,1)=counter;
                counter1=counter1+1;
            end
        end
    end
else
    if datetimev(1,2)>=6&&datetimev(1,2)<10
        summer_month=counter;
    end
end
