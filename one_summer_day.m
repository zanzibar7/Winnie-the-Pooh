function nextstate = one_summer_day(state, date, STAGEMATRIX)% bee model in the field season 

global hsurfX hsurfY hsurf; % the interpolated surface of NectarODE and honeycollection 

p_precocious = 0; % probability of nurse bee precociously developing to forager
p_reversion = 0; % reversed probability between foragers and nurse bees;
broodnurseratio = 2.65; % One nurse bee can heat 2.65 brood cells - NOT CRUCIAL.. but probably closer to 5
p_slow = 1e-3; %probability of individual bee retardant developing to next age class

queen_efficiency = 1; % downregulation of queen egg laying, used in perturbed hive scenarios

%Honey consumption rates
% fraction of a cell's honey consumed by a bee in one day, a cellful of honey weighs~~0.5g
% h2: Rotais says .0297 cells/day, HoPoMo has .008 cells/day
% h3: Rotais says 0, HoPoMo has .008 cells/day (even those these get packed
% in prior to capping
% h4: Rotais says 0, which is weird
% h5: Rotais says .038-.14 cells/day doing various tasks
% h6: Rotais says .08-.32 cells/day for nectar forager, and .026 - .039
% cells/day for pollen forager

honeyconsumption = [ 0, 0.0297, 0, 0, 0.05 , 0.05 ];

%Pollen consumption rates
%a cellful of pollen weighs~~0.23g
%These are from Rotais entirely.  HoPoMo has higher consumption of pollen
%by brood, so this is an option with some flexibility.  Remember that
%higher consumption means higher need, and thus more brought in.
pollenconsumption = [0, 0.0047, 0, 0.028, 0, 0 ];

% (Blaschon et al.,1999) The modeled colony regulates the pollen stores around
% a level that represents a reserve for approximately 6 days, based on the
% current level of demand.
storagelead=6;

% 0.48 is the pollen collected each day each forager, based on the amount
% of pollen collected per foraging trip(0.06 cellful pollen,Camazine et
% al., 1990), the average foraging trips performed per forager per day(10 trips per day) and the stochastic factor for each pollen
% forager to make a successful foraging trip(80%)
foragingsuccess = 0.48;

honeyforagingsuccess = 0.2; % cludge factor to prevent glutteny with colonies 
	% do not swarm

relativedate = mod(date,360);  %% BUG!!! hard-coded dependence on year length

%% Queen reproduction potential (McLellan et al., 1978)
maxProduction = (0.0000434)*(relativedate)^4.98293*exp(-0.05287*relativedate);

%% SURVIVORSHIP PARAMETERS
% st1 = 0.913;%0.5; % st1=0.86; % 0.86--survivorship for egg stage 
% st2 = 0.923;%0.5; % st2= 0.85; %---survivorship for larval stage 
% st3 = 0.985;%0.86; % suvivorship for -- survivorship for pupa stage
% st4 = 0.923;%0.85; % 0.99-85%--survivorship for nurse bee stage 
% st5 = 0.913;%0.88; % 0.96-88.6%--survivorship for house bee stage 
% st6 = 0.78; % 78.5%--survivorship for forager bee stage %0.653;%

%%% Following variables are not used below, just for reference currently
% tel = 1; %0.98; %through-stage survival for egg maturing to 1st instar larva
% tlp = 1; %0.85; %through-stage survival for larva maturaing to pupa
% tpn = 1; %0.98; %through-stage survival for pupa maturing to nurse bee
% tnh = 1; %0.98; %through stage survival for nurse bee maturing to house bee
% thf = 1; %0.98; %through-stage survival for house been maturing to forager

% st1 = 0.85; % 0.86--survivorship for egg stage
% st2 = 0.85; %---survivorship for larval stage
% st3 = 0.86;
% st4 = 0.85; % 0.99-85%--survivorship for nurse bee stage
% st5 = 0.85; % 0.96-88.6%--survivorship for house bee stage
% st6 = 0.78; % 78.5%--survivorship for forager bee stage

stageship = [0.85, 0.85, 0.86, 0.85, 0.85, 0.78]; % baseline state survivorships

agemax = max(size(STAGEMATRIX)); % indexing in matlab starts at 1, so add an extra day
n_brood = sum(sum(STAGEMATRIX')(1:3));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Current conditions in bee hive %%%%%%%%
V = state(1); % vacant cells 
P = state(2); % pollen stores
H = state(3); % honey stores at time t. 
N = state(4:end);% bee number at time t 

stage = STAGEMATRIX*N;

%  %%%%%%%%%%% Fungicide treatments
%  %day of the year on which pesticide treatment was applied : 
%  % August 1st 2012 = day 150
%  % June 25th 2013 = day 115
%  startdate = 241; 
%  enddate = 242; %day of the year on which pesticide treatment was no longer
%  %in effect - probably end of field season
%  
%  if  date == startdate %  && date < enddate
%      %Parameters for fungicide treatment effects
%  	stageship = [0.50, 0.85, 0.86, 0.85, 0.85, 0.78];
%      queen_efficiency = 0.5; %0.06;
%  end




% The colony pollen demand includes the need of egg, larval, nurse and house bee stage. 
% We assume the daily demand of pollen of bees is constant stage-specific parameters.
PollenDemand = pollenconsumption*stage;
HoneyDemand = honeyconsumption*stage;

if ( (PollenDemand <= 0) || (HoneyDemand <= 0) )
    disp('PollenDemand or HoneyDemand leq zero, dead hive')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Bee Dynamics : Everyone ages by one day

% Index for the quality of pollen status and nursing quality in the colony
% Negative feedback loops of pollen stores and nursing quality in affecting
% the bee dynamics (Larva, Nurse) in turn affecting food collection and
% storage.

% Fraction of the pollen stores in relation to demand of the colony
IndexPollen = P/(PollenDemand*storagelead + 1);
IndexPollen = max(0,min(1,IndexPollen));
% Nurse bees per total nursing demand of eggs and larva
IndexNursing = stage(4)/((stage(2)+stage(1))*broodnurseratio+1);
IndexNursing = max(0,min(1,IndexNursing));
% Indexhoney = max([0 min([1 H/HoneyDemand])]); %max(0,min(1,H/(HoneyDemand)))


% 1-(1-IndexNursing)^6
% nonlinear feedbacks on survivorships
stageship = stageship.*max([zeros(1,6); min([ones(1,6); [ \
	func_A(IndexNursing,0.05,1e4), \
	func_A(IndexPollen*IndexNursing,0.15,1e2), \
	func_A(IndexNursing,0.05,1e4), \
	func_A(IndexNursing,0.08,1e4), \
	1, 1]])]);
survivorship = (stageship.^(1./sum(STAGEMATRIX')))*STAGEMATRIX;
%
% survivorship(1:3) is the daily survival rate of egg stage at age(i=1-3) 
%
% survivorship(4:11) is the time independent base mortality rate of larval
% stage at any age (4-11 days old- total 8 days) Larvae are frequently
% cannibalized in a honeybee colony.  The rate of cannibalism depends on the
% age of the larvae (Schmickl and Crailsheim, 2001), the pollen status of the
% colony (Schmickl and Crailsheim, 2001)and the nursing quality (Eischen et
% al., 1982).  Therefore, larval mortality includes a time-independent base
% mortality rate and the cannibalism factor. 0.15--the time-independent base
% cannibalism mortality rate for larval stage. 
%
% survivorship(12:26) is pupae stage survival, cummulative over 15 days
% 
% survivorship(27:42) is nurse survivorship NURSE: who don't precociously
% forage and who survive one day of 16 that make up st4 It will be varied by
% the nursing efforts. A higher nursing load will cause a higher mortality of
% the nurse bee stage.
% 
% survivorship(43:48) is survivorship of HOUSE bees
% 
% survivorship(49:agemax) is survivorship of forager bees


% Everything here just relates to matrix multiplication.
A = diag(survivorship);
theta = p_slow*ones(agemax,1); % probabilities of retarded development
theta(1) = 0.; % can not have retardation of first stage
A = (diag(theta)+diag(1-theta(1:end-1),-1))*diag(survivorship);

% Extra transitions
ii = find(STAGEMATRIX(4,:));
jj = find(STAGEMATRIX(6,:));
% the precocious development of nurse bees 
j = jj(1);
for i = ii;
	A(j,i) = A(j,i) + A(i,i)*p_precocious;
	A(i,i) = A(i,i)*(1-p_precocious);
end
% the reversion of development of forager bees 
j = ii(1);
for i = jj;
	A(j,i) = A(j,i) + A(i,i)*p_reversion;
	A(i,i) = A(i,i)*(1-p_reversion);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Food is consumed, new eggs are layed

% The removal of dead brood, hygenic behavior gives total number of scavanged cells
% -- this was the line that was generating an error before- causing V to be a matrix
scavanged = (1-survivorship(1:n_brood))*N(1:n_brood);

% pollen consumption of egg, larval, nurse and house bee stage
polleneaten =  min([P, PollenDemand]); 

% honey consumption of larval, nurse, house and forager bee stage
honeyeaten= min([H, HoneyDemand]); 

% Empty Cells due to the cleaned food cells and adult emergence
vacated = N(n_brood) + polleneaten + honeyeaten; %check this, maybe not N(26)- maybe N1(26)?
V = V + vacated + scavanged ;
%Actual eggs layed by queen this day determined here
if (stage(4)+stage(5)+stage(6))<= 10 % the minimum requirement of number of bees needed to be around a queen bee
    disp('HIVE COLLAPSED, leq 10 adult bees left')
    disp(date);
    R = 0;
else 
    % The actual egg production per day depends on the queen egg laying potential, 
    % the nursing workforce and the available hive space - the function below is
    % the one in the documentation, but this layer of complexsity can be
    % added later!
    %V+vacated+scavanged cells gives how many cells are allocated to 
    %R = min([queen_efficiency*maxProduction,stage(4)*broodnurseratio,V+vacated+scavangedcells]);
    %queen_efficiency is set to 1 currently- simplified, always max production

    R = min([V, queen_efficiency*maxProduction]); 
    %the only cap on the egg laying right now is the 
end 
%UPDATE VACANT CELL COUNT
V = V - R ;
if V == 0
	disp(sprintf('day %d : ran out of space after eggs laid',date));
end

%% POLLEN FORAGING- field season

% Pollen foraging feedback mechanism: pollen foraging is regulated
% according to the current pollen demand, which is the amount of pollen
% need for each stage and reserve for next 6 days (storagelead) need minus
% to current pollen storage.
PollenNeed=max(0,PollenDemand*storagelead-P);

%Number of pollen foragers to recruit
NeedPollenForager=PollenNeed/foragingsuccess; 

% In nature, there is always a certain minimum number of pollen foragers
% within the cohort of foragers (1% forager will have the preference to
% make pollen foraging), even when there is almost no pollen need (personal
% observation). The maximum number of pollen foragers is 33% of the current
% cohort of foragers. 
PollenForager=max(stage(6)*0.01, min(NeedPollenForager,stage(6)*.33)); %%THIS one seems like the right one! with the 33% cap!
%PollenForager = max([stage(6)*0.01 min([NeedPollenForager stage(6)])]);

% pollen storage depends on the available cells in the hive
% and the foraging collection efficiency of the pollen forager---assumption for pollen foraging behavior
storedpollen = max([0, min([PollenForager*0.48, V])]);

V = V - storedpollen;
if V == 0
	disp(sprintf('day %d : ran out of space after pollen stored',date));
end

%% Honey dynamics-field season 
% Reference: Edwards and Myerscough 2011 , nectarODE.m called here
% nectar collection is based on the interaction of current nectar forager and the house bees 
% Nectar being processed into honey is reduced in volume by a factor .4
 
predictedhoney=interp2(hsurfX,hsurfY,hsurf,stage(5),(stage(6)-PollenForager));
if ( 0==exist('predictedhoney','var') || isnan(predictedhoney) \
		|| predictedhoney<0 )
	predictedhoney=1.e-3;
end
storedhoney = min([ predictedhoney*honeyforagingsuccess, V]);
    
V = V - storedhoney;
if V == 0
	disp(sprintf('day %d : ran out of space after honey stored',date));
end
 
%% Pollen, Honey, Cells net input 
P = max(0, P - polleneaten + storedpollen); % Updated pollen stores at end of day
H = H + storedhoney - honeyeaten; % Updated honey stores at end of day, capped by total size of hive
N = A*N; % structured dynamics for bees - output is a vector
N(1) = R; % number of eggs laid today, these are now the age zero eggs

nextstate = [V; P; H; N];

snapframe(date, nextstate, survivorship);

return
