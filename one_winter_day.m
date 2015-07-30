function nextstate = one_winter_day(state,date,WINTERSTAGEMATRIX) % For winter bee dynamics 

agemaxwinter=max(size(WINTERSTAGEMATRIX)); % indexing in matlab starts at 1, so add an extra day
n_brood = sum(sum(WINTERSTAGEMATRIX')(1:3));

%%%%%%%%%%%%%%%%%%%%%%%% Parameter Set %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% pollen consumption rate for each stage of bees during the winter 
% a2 = .005; % fraction of a cell's pollen consumed by a larva in one day
% a4 = 0; %.028; % fraction of a cell's pollen consumed by a nurse in one day
pollenconsumption = [0, 0.005, 0, 0];
a2 = pollenconsumption(2);

%% honey consumption rate for each stage of bees during the winter
% h4 = 0.022; % fraction of a cell's honey consumed by a nurse bee in one day
honeyconsumption = [0, 0.0297, 0, 0.022];
h4 = honeyconsumption(4);

%%%%%%%%%%%%%%%%%%%%%%%% Hive Dynamics %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Empty Cell+Pollen Cells + Honey Cells+Brood Cells =Hive Space
%%%% Current conditions in bee hive
V = state(1); % vacant cells
P = state(2); % ollen cells
H = state(3); % honey cells
R = state(4); % egg cells
N = state(5:end);% bee number at time t
stage = WINTERSTAGEMATRIX*N; % 4 stages

if stage(4)<=100  % The minimum number of hive bees in a winter colony (2000-3000), derived from the brood temperature model from M.A.Becher 2010.
	survivorship = zeros(agemaxwinter,1);
    disp('dead hive')
else
	P_base = 0.999; %baseline survivorship
    P_base = P_base*max(0, 1 - max(0,1-H/(h4*stage(4)+1e-100))); % 1e-100 term prevents division-by-zero issues
    k = max(0, (1 - max(0,1-P/(a2*stage(2)+1e-100))));
    survivorship = (P_base*[ 1, k, 1, 1]*WINTERSTAGEMATRIX)';
end 
theta = .01*ones(agemaxwinter-1,1); % theta = probabilities of development retardation
A = (diag(1-theta,-1)+diag([0;theta]))*diag(survivorship);

%% Food, Empty Cell dynamics
honeyeaten = min([H, honeyconsumption*stage]);
polleneaten = min([P, pollenconsumption*stage]);
vacated = N(n_brood) + polleneaten + honeyeaten;
scavangedcells = N(1:n_brood)'*(1-survivorship(1:n_brood));

%there should be NO egg laying in winter. The last eggs layed in summer are
%super long-lived. this just sits in the survivorship function.
R=0; 

%%%%%%%%% Colony, Pollen, Honey, Cells output %%%%%%%%%%%%%%%%%%%%
P = P - polleneaten;  % The net pollen storage at the end of the day
H = H - honeyeaten; % The net honey storage at the end of the day.
V = V + vacated - R + scavangedcells; % The net vacant cells
N = A*N;
N(1) = 1; %R; 
nextstate = [ V; P; H; R; N ];

return
