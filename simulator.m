%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pre-compute honey foraging numbers, if needed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

global hsurfX hsurfY hsurf;

if ( 0 ~= exist('hsurf.data','file') )
	disp('Loading nector surface');
	load('hsurfX.data');
	load('hsurfY.data');
	load('hsurf.data');
else
	disp('no hsurf files')
end

if ( 0 == exist('hsurf','var') || isempty(hsurf) )
	disp('Precomputing nector surface');
	disp('WARNING:  This could take days...');
    trialsurf;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Intializations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numyears = 3;
summerdays = 240;
yeardays = 360;

% timeseries vectors hold the daily counts for all time
Spop=zeros(6,yeardays*numyears); % stage counts
Vpop=zeros(1,yeardays*numyears); % vacant
Ppop=zeros(1,yeardays*numyears); % pollen
Hpop=zeros(1,yeardays*numyears); % honey
Rpop=zeros(1,yeardays*numyears); % egg production

% new stages
agemaxsummer = 50; % max life of a summer bee, +1 because of matlab indexing
SUMMERSTAGES = zeros(6,agemaxsummer);
SUMMERSTAGES(1,1:3)=1;
SUMMERSTAGES(2,4:8)=1;
SUMMERSTAGES(3,9:20)=1;
SUMMERSTAGES(4,21:32)=1;
SUMMERSTAGES(5,33:42)=1;
SUMMERSTAGES(6,43:end)=1;

%used for compression age structure from daily to by-class in winter
agemaxwinter = 60; % max life of winter bee
WINTERSTAGES = zeros(4,agemaxwinter);
WINTERSTAGES(1,1:3)=1;
WINTERSTAGES(2,4:11)=1;
WINTERSTAGES(3,12:26)=1;
WINTERSTAGES(4,27:end)=1;

% transfer matrices between winter and summer stages (DUMB IDEA, but
% the simplest choice in the current design)
TFWS = [eye(4),[0,0,0,1]'*[1,1]]*SUMMERSTAGES; % winter to summer
TFSW = [eye(4),[0,0,0,1]'*[1,1]]'*WINTERSTAGES; % summer to winter

%Parameters for testing perturbed colony scenarios
P0 = 200; %P0 = 1000; %initial cells of pollen
V0 = 500000 - P0; % intial vacant cells, total number cells is 140000
                  % subtract to leave room for eggs and pollen
H0=0; %initial honey
R0=0; %initial eggs

% initial number of eggs = 0/3 days   
% initial number of larva = 1600/8 days
% initial number of pupa = 2400/15 days
% initial number of nurse bees = 3000/16 days
% initial number of house bees= 3000/6 days
% initial number of forager bees = 3000/12 days
S0 = [0, 1600, 2400, 3000, 3000, 3000]; % initial state by stages
N0 = ((S0./sum(SUMMERSTAGES'))*SUMMERSTAGES)';
N0(1) = R0;

STATE = [V0; P0; H0; N0]; % This hold the initial state

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Simulation algorithm
%
% Each year starts with a field season, goes 
% through one winter, and then sets up the next
% field season.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for year = 0:(numyears-1) 
	disp(['Year ',num2str(year)]);

	disp('    Summer Season Dynamics'); %%%%%%%%%%%%%%%%%%%%
	[V, P, H, R, S] = \
		hive_summer(year,summerdays, yeardays, STATE, SUMMERSTAGES);
	i = yeardays*year+1;
	j = yeardays*year+summerdays;
	Spop(:,i:j) = S;
	Vpop(i:j) = V;
	Ppop(i:j) = P;
	Hpop(i:j) = H;
	Rpop(i:j) = R;
	if (sum(S(:,end)) < 10)
		break
	end

	disp('    Winter Season Dynamics'); %%%%%%%%%%%%%%%%%%%%
	N = ((S(:,end)'./sum(TFSW'))*TFSW)';
	assert( abs(sum(N) - sum(S(:,end))) < 1e-1); % check for conversion bug
	STATE = [V(:,end); P(:,end); H(:,end); N];

	[V, P, H, R, S] = \
		hive_winter(year,summerdays,yeardays, STATE, WINTERSTAGES);
	i = yeardays*year+summerdays+1;
	j = yeardays*(year+1);
	Spop([1,2,3,5],i:j) = S; % stages 4 and 6 are empty in the winter
							 % but we want to keep a consistent shape for Spop
	Vpop(i:j) = V;
	Ppop(i:j) = P;
	Hpop(i:j) = H;
	Rpop(i:j) = R;
	if (sum(S(:,end)) < 10)
		break
	end

	disp('    Setting up next Summer Season'); %%%%%%%%%%%%%%%%%%%
	N = ((S(:,end)'./sum(TFWS'))*TFWS)';
	assert( abs(sum(N) - sum(S(:,end))) < 1e-1); % check for conversion bug
	STATE = [V(:,end); P(:,end); H(:,end); N];
end %END OF LOOP THROUGH MULTIPLE YEARS

timfigs(Spop', [Ppop;Hpop]', Rpop); 
n = length(Vpop);
timeseries = [1:n; Spop; Vpop; Ppop; Hpop; Rpop]';
headers='Day,Eggs,Larvae,Pupae,Nurse bees,House bees,Foragers,Vacant cells,Pollencells,Honey cells,Eggs lain';
dlmwrite('data/timeseries.data',headers,'');
dlmwrite('data/timeseries.data',timeseries,'-append');

format long;
disp(sum(sum(Spop)));
testval = 13592076.3176541;
%assert( abs( testval - sum(sum(Spop))) < 5e-8 );
format short;
