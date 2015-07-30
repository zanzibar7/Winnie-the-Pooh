%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pre-compute honey foraging numbers, if needed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    trialsurf;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Intializations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numyears = 3;
summerdays = 240;
yeardays = 360;
agemax = 60; % max life of a summer bee, +1 because of matlab indexing
agemaxwinter = 150; % max life of winter bee

%Parameters for testing perturbed colony scenarios
P0 = 200; %P0 = 1000; %initial cells of pollen
V0 = 500000 - P0; % intial vacant cells, total number cells is 140000
                  % subtract to leave room for eggs and pollen
H0=0; %initial honey
R0=0; %initial eggs

STAGEMATRIX = zeros(6,agemax);
STAGEMATRIX(1,1:3)=1;
STAGEMATRIX(2,4:11)=1;
STAGEMATRIX(3,12:26)=1;
STAGEMATRIX(4,27:42)=1;
STAGEMATRIX(5,43:48)=1;
STAGEMATRIX(6,49:agemax)=1;

% initial number of eggs/3 days   
% initial number of larva = 1600/8 days
% initial number of pupa = 2400/15 days
% initial number of nurse bees = 3000/16 days
% initial number of house bees= 3000/ 6 days
% initial number of forager bees = 3000 / 12 days
STAGES0 = [0, 200, 160, 187, 500, 250];
N = zeros(agemax,1);
for i=1:6
	N = N + G(i,:)'*STAGES0(1,i);
end

STATE0 = [V0; P0; H0; R0; N]; % This hold the initial state

% these super long vectors hold the daily vacant cells, pollen, honey, and egg
% filled cells for every year in our simulation
Spop=zeros(6,yeardays*numyears);
Vpop=zeros(1,yeardays*numyears);
Ppop=zeros(1,yeardays*numyears);
Hpop=zeros(1,yeardays*numyears);
Rpop=zeros(1,yeardays*numyears);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Simulation algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%each year starts with a field season, goes through one winter, and then
%one more field season
for T = 0:(numyears-1) %T tells us what year we are in 0,1, 2...
	disp(['Year ',num2str(T)]);

	disp('    Summer Season Dynamics');

	[S, V, P, H, R] = \
		hive_summer(T, agemax, summerdays, yeardays, STATE0, STAGEMATRIX);

	Spop(:,(yeardays*T+1):(yeardays*T+summerdays)) = S;
	Vpop(:,(yeardays*T+1):(yeardays*T+summerdays)) = V;
	Ppop(:,(yeardays*T+1):(yeardays*T+summerdays)) = P;
	Hpop(:,(yeardays*T+1):(yeardays*T+summerdays)) = H;
	Rpop(:,(yeardays*T+1):(yeardays*T+summerdays)) = R;

	disp('    Winter Season Dynamics')

	[wintS,wintV,wintP,wintH,wintR] = \
		hive_winter(T,agemax,agemaxwinter,summerdays,yeardays,S,V,P,H,R);

	Spop(:,(yeardays*T+summerdays+1):(yeardays*(T+1))) = wintS;
	Vpop(1,(yeardays*T+summerdays+1):(yeardays*(T+1))) = wintV;
	Ppop(1,(yeardays*T+summerdays+1):(yeardays*(T+1))) = wintP;
	Hpop(1,(yeardays*T+summerdays+1):(yeardays*(T+1))) = wintH;
	Rpop(1,(yeardays*T+summerdays+1):(yeardays*(T+1))) = wintR;

	disp('    Setting up next Summer Season')

	N = zeros(agemax,1);
	N(1:3) = Spop(1,yeardays*(T+1))/3;
	N(4:11) = Spop(2,yeardays*(T+1))/8;
	N(12:26) = Spop(3,yeardays*(T+1))/15;
	N(27:42) = Spop(5,yeardays*(T+1))/34;
	N(43:48) = Spop(5,yeardays*(T+1))/34 ;
	N(49:agemax) = Spop(5,yeardays*(T+1))/34;
	P0 = Ppop(1,yeardays*(T+1));
	V0 = Vpop(1,yeardays*(T+1));
	R0= Rpop(1,yeardays*(T+1));
	H0= Hpop(1,yeardays*(T+1)); 

	STATE0 = [ V0; P0; H0; R0; N];
end %END OF LOOP THROUGH MULTIPLE YEARS

%for each day, this gives the ratio of eggs+larvae/nurse+house bees
% BARatio=(Spop(1,1:360*numyears)+Spop(2,1:360*numyears))./(Spop(4,1:360*numyears)+Spop(5,1:360*numyears)); 
%for each day, this gives the ratio of foragers/nurse+house bees
% FARatio=Spop(6,1:360*numyears)./(Spop(4,1:360*numyears)+Spop(5,1:360*numyears));

YMatrix1=Spop';
A=Ppop; %pollen storage throughout all seaseons
% disp('pollen in kg, no equip')
% disp(A'*.00023)
B=Hpop;  %honey storage throught all seasons
% A=Ppop.*0.23/1000;
% B=Hpop*0.5/1000;
YMatrix2= [A;B]';
Y3=Rpop;
%Y3=Spop(3)*0.1552/1000+Spop(4)*0.2189/1000+Spop(5)*0.2189/1000+A+B;
timplot(YMatrix1, YMatrix2, Y3); 
% figure;

% plot(Y3);
% foundationweight = 50.2 * 453.6 /1000;
% 
% Y1=(Spop(2)+Spop(3))*0.1552/1000+Spop(4)*0.2189/1000+Spop(5)*0.2189/1000+Ppop.*0.23/1000+Hpop*0.5/1000;
% plot(Y1(1:360));
% t=[0:30:360];months=['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec';];
% set(gca,'xtick',t)
% set(gca,'xticklabel',months)wint
% xlabel('Date')
% ylabel('Colony Weight')
% 
% BNy=(BARatio+FARatio)';

format long;
disp(sum(sum(Spop)));
format short;
