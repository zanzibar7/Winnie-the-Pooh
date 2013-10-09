function nextstate = winterbeesR(state,date) % For winter bee dynamics 

agemaxwinter=150; % indexing in matlab starts at 1, so add an extra day

%%%%%%%%%%%%%%%%%%%%%%%% Parameter Set %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% pollen consumption rate for each stage of bees during the winter 
a2 = .005; % fraction of a cell's pollen consumed by a larva in one day
a4 = 0; %.028; % fraction of a cell's pollen consumed by a nurse in one day

%% honey consumption rate for each stage of bees during the winter
h4 = 0.022; % fraction of a cell's honey consumed by a nurse bee in one day

%% Stage Structure for field season bees-normal cycle 
s = zeros(4,agemaxwinter);
s(1,1:3) = 1; %egg
s(2,4:11) = 1; %larva
s(3,12:26) = 1; %pupa
s(4,27:agemaxwinter) = 1; %  test to combine the all the adult bees into one stage 


%% Abnormal developmental.(precocious+delayed development in bees)
u = 0;%precocious prob
v = 0;% reversed prob. between foragers and house bees;
theta = .01*ones(agemaxwinter-1,1); % theta = probabilities of development retardation

%% Hive Dynamics%
%%%% Empty Cell+Pollen Cells + Honey Cells+Brood Cells =Hive Space

%%%% Current conditions in bee hive 
Vt = state(1); % vacant cells 
Pt = state(2); % Pt for pollen cells at time t.  Formlerly F_t for food at time t.
Ht = state(3); % Ht for honey cells at time t. 
R  = state(4); % Egg cells 
Nt = state(5:end);% bee number at time t 

%% Dynamics in the bee hive 
stage = s*Nt; % 4 stages 

overall_P = 0.999; %overall survivorship

survivorship = zeros(agemaxwinter,1);
if stage(4)<=100  % The minimum number of hive bees in a winter colony (2000-3000), derived from the brood temperature model from M.A.Becher 2010. 
    survivorship(1:agemaxwinter)=0;
    disp('dead hive')
else  
    % I DO NOT UNDERSTAND THE BIOLOGY OF THIS PART
    survivorship (1:3) = max( 0, overall_P* ( 1 - max(0,1-Ht/(h4*stage(4)))));
    survivorship(4:11) = max(0, overall_P*( 1 - max(0,1- Pt/(a2*stage(2))))*(1-max(0,1-Ht/(a4*stage(4))))); % Larval survival depends on the intrinsic mortality and pollen availibility 
    survivorship (12:26) = max( 0, overall_P* ( 1 - max(0,1-Ht/(h4*stage(4)))));
    survivorship(27:agemaxwinter)= max( 0, overall_P* ( 1 - max(0,1-Ht/(h4*stage(4))))); % the survival of the adult bees in the hive depends on the intrisic mortality and the food availibility 

% survivorship (1:agemaxwinter) = overall_P;

end 

A = (diag(1-theta,-1)+diag([0;theta]))*diag(survivorship);
transit=A;
Nt1= transit*Nt;

%% Food, Empty Cell dynamics 

honeyeaten = min([Ht , stage(4)*h4]);

polleneaten = min([Pt , a2*stage(2)+ a4*stage(4)]);  

vacated = Nt(26) + polleneaten + honeyeaten;

scavangedcells = Nt(1:26)'*(1-survivorship(1:26));

%there should be NO egg laying in winter. The last eggs layed in summer are
%super long-lived. this just sits in the survivorship function.
R=0; 


%%%%%%%%%Pollen, Honey, Cells net input%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Pt1 = Pt - polleneaten;  % The net pollen storage at the end of the day 
Ht1 = Ht - honeyeaten; % The net honey storage at the end of the day. 
Vt1 = Vt + vacated - R + scavangedcells; % The net vacant cells 
Nt1(1) = 1; %R; 
nextstate = [ Vt1; Pt1; Ht1; R; Nt1 ];

return
