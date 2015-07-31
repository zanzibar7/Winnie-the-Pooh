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

numyears = 2;
summerdays = 240;
yeardays = 360;

% timeseries vectors hold the daily counts for all time
Spop=zeros(6,yeardays*numyears); % stage counts
Vpop=zeros(1,yeardays*numyears); % vacant
Ppop=zeros(1,yeardays*numyears); % pollen
Hpop=zeros(1,yeardays*numyears); % honey
Rpop=zeros(1,yeardays*numyears); % egg production

% old stages
agemax = 60; % max life of a summer bee, +1 because of matlab indexing
agemaxwinter = 150; % max life of winter bee
STAGEMATRIX = zeros(6,agemax);
STAGEMATRIX(1,1:3)=1;
STAGEMATRIX(2,4:11)=1;
STAGEMATRIX(3,12:26)=1;
STAGEMATRIX(4,27:42)=1;
STAGEMATRIX(5,43:48)=1;
STAGEMATRIX(6,49:agemax)=1;

%%% new stages
% agemax = 50; % max life of a summer bee, +1 because of matlab indexing
% agemaxwinter = 150; % max life of winter bee
% STAGEMATRIX = zeros(6,agemax);
% STAGEMATRIX(1,1:3)=1;
% STAGEMATRIX(2,4:8)=1;
% STAGEMATRIX(3,9:20)=1;
% STAGEMATRIX(4,21:32)=1;
% STAGEMATRIX(5,33:42)=1;
% STAGEMATRIX(6,43:agemax)=1;


% initial number of eggs = 0/3 days   
% initial number of larva = 1600/8 days
% initial number of pupa = 2400/15 days
% initial number of nurse bees = 3000/16 days
% initial number of house bees= 3000/6 days
% initial number of forager bees = 3000/12 days
S0 = [0, 1600, 2400, 3000, 3000, 3000]; % initial state by stages
N0 = ((S0./sum(STAGEMATRIX'))*STAGEMATRIX)';

%Parameters for testing perturbed colony scenarios
P0 = 200; %P0 = 1000; %initial cells of pollen
V0 = 500000 - P0; % intial vacant cells, total number cells is 140000
                  % subtract to leave room for eggs and pollen
H0=0; %initial honey
R0=0; %initial eggs

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

	STATE = [V0; P0; H0; R0; N0]; % This hold the initial state

	disp('    Summer Season Dynamics'); %%%%%%%%%%%%%%%%%%%%
	[S, V, P, H, R] = \
		hive_summer(year, agemax, summerdays, yeardays, STATE, STAGEMATRIX);
	i = yeardays*year+1;
	j = yeardays*year+summerdays;
	Spop(:,i:j) = S;
	Vpop(:,i:j) = V;
	Ppop(:,i:j) = P;
	Hpop(:,i:j) = H;
	Rpop(:,i:j) = R;

	disp('    Winter Season Dynamics'); %%%%%%%%%%%%%%%%%%%%
	[wintS, wintV, wintP, wintH, wintR] = \
		hive_winter(year,agemax,agemaxwinter,summerdays,yeardays, \
			S(:,end), V(:,end), P(:,end), H(:,end), R(:,end));
	i = yeardays*year+summerdays+1;
	j = yeardays*(year+1);
	Spop(:,i:j) = wintS;
	Vpop(1,i:j) = wintV;
	Ppop(1,i:j) = wintP;
	Hpop(1,i:j) = wintH;
	Rpop(1,i:j) = wintR;

	disp('    Setting up next Summer Season'); %%%%%%%%%%%%%%%%%%%
	wn = (wintS([1,2,3,5],end)./sum(([eye(4),[0,0,0,1]'*[1,1]]*STAGEMATRIX)')')';
	wn = wn*[eye(3,6); kron([0,1],[1,1,1])];
	N0 = (wn*STAGEMATRIX)';
	assert( abs(sum(N0) - sum(wintS(:,end))) < 1e-1); % check for conversion bug

	V0 = wintV(1,end);
	P0 = wintP(1,end);
	R0 = wintR(1,end);
	H0 = wintH(1,end); 
end %END OF LOOP THROUGH MULTIPLE YEARS

%for each day, this gives the ratio of eggs+larvae/nurse+house bees
% BARatio=(Spop(1,1:360*numyears)+Spop(2,1:360*numyears))./(Spop(4,1:360*numyears)+Spop(5,1:360*numyears)); 
%for each day, this gives the ratio of foragers/nurse+house bees
% FARatio=Spop(6,1:360*numyears)./(Spop(4,1:360*numyears)+Spop(5,1:360*numyears));

timfigs(Spop', [Ppop;Hpop]', Rpop); 
n = length(Vpop);
timeseries = [1:n; Spop; Vpop; Ppop; Hpop; Rpop]';
headers='Day,Eggs,Larvae,Pupae,Nurse bees,House bees,Foragers,Vacant cells,Pollencells,Honey cells,Eggs lain';
dlmwrite('t.data',headers,'');
dlmwrite('t.data',timeseries,'-append');
save -ascii 'timeseries.data' timeseries;

format long;
disp(sum(sum(Spop)));
testval = 13592076.3176541;
assert( abs( testval - sum(sum(Spop))) < 5e-8 );
format short;
