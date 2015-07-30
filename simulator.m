%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pre-compute honey foraging numbers, if needed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global hsurfX hsurfY hsurf;

A = exist('hsurfX.data','file');
if ( 0 ~= A )
	disp('Loading nector surface');
	load('hsurfX.data');
	load('hsurfY.data');
	load('hsurf.data');
else disp('no hsurf file')
end

E = exist('hsurfX','var');
if ( 0 == E || isempty(hsurf) ) 
	disp('Precomputing nector surface');
    trialsurf;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Intializations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

agemax = 60; % +1 because of matlab indexing
numyears = 1;
summerdays = 240;
yeardays = 360;
agemaxwinter = 150; %max life of winter bee

%Parameters for testing perturbed colony scenarios
P0 = 200; %P0 = 1000; %initial cells of pollen
V0 = 500000 - P0; % intial vacant cells, total number cells is 140000
                  % subtract to leave room for eggs and pollen
H0=0; %initial honey
R0=0; %initial eggs

N = zeros(agemax,1);

N(1:3)=100; % initial number of eggs/3 days   %SHOULD BE ZERO, BUT THIS CAUSES CODE TO CRASH WITH ERROR "DEAD HIVE
N(4:11)=200; % initial number of larva = 1600/8 days
N(12:26)=160; % initial number of pupa = 2400/15 days
N(27:42)=187; % initial number of nurse bees = 3000/16 days
N(43:48)=500; % initial number of house bees= 3000/ 6 days
N(49:agemax)=250; % initial number of forager bees = 3000 / 12 days

X = [V0; P0; H0; R0; N]; % This hold the initial state

res=zeros(6,summerdays); % bee population by stage for each day of summer 
V=zeros(1,summerdays); % # vacant cells for each day of summer 
P=zeros(1,summerdays); % # pollen cells for each day of summer
H=zeros(1,summerdays); % # honey cells for each day of summer
R=zeros(1,summerdays); % # eggs for each day of summer

% these super long vectors hold the daily vacant cells, pollen, honey, and egg
% filled cells for every year in our simulation
pop=zeros(6,yeardays*numyears);
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

	disp('    Summer Season Dynamics');

	[summres, summV,summP, summH, summR] = \
		hive_summer(T,agemax,summerdays,yeardays,res,V,P,H,R,X);

	res = summres;
	V = summV;
	P = summP;
	H = summH;
	R = summR;

	pop(:,(yeardays*T+1):(yeardays*T+summerdays)) = res;
	Vpop(:,(yeardays*T+1):(yeardays*T+summerdays)) = V;
	Ppop(:,(yeardays*T+1):(yeardays*T+summerdays)) = P;
	Hpop(:,(yeardays*T+1):(yeardays*T+summerdays)) = H;
	Rpop(:,(yeardays*T+1):(yeardays*T+summerdays)) = R;

	disp('    Winter Season Dynamics')

	[wintres,wintV,wintP,wintH,wintR] = \
		hive_winter(T,agemax,agemaxwinter,summerdays,yeardays,res,V,P,H,R);

	pop(:, (yeardays*T+summerdays+1):(yeardays*(T+1))) = wintres;
	Vpop(1,(yeardays*T+summerdays+1):(yeardays*(T+1))) = wintV;
	Ppop(1,(yeardays*T+summerdays+1):(yeardays*(T+1))) = wintP;
	Hpop (1,(yeardays*T+summerdays+1):(yeardays*(T+1))) = wintH;
	Rpop (1,(yeardays*T+summerdays+1):(yeardays*(T+1))) = wintR;

	disp('    Setting up next Summer Season')

	N = zeros(agemax,1);
	N(1:3)=pop(1,yeardays*(T+1))/3;
	N(4:11)=pop(2,yeardays*(T+1))/8;
	N(12:26)=pop(3,yeardays*(T+1))/15;
	N(27:42)= pop(5,yeardays*(T+1))/34;
	N(43:48)= pop(5,yeardays*(T+1))/34 ;
	N(49:agemax)=pop(5,yeardays*(T+1))/34;
	P0 = Ppop(1,yeardays*(T+1));
	V0 = Vpop(1,yeardays*(T+1));
	R0= Rpop(1,yeardays*(T+1));
	H0= Hpop(1,yeardays*(T+1)); 

	X = [ V0; P0; H0; R0; N];
	res=zeros(6,summerdays);
	R=zeros(1,summerdays);
	V=zeros(1,summerdays);
	P=zeros(1,summerdays);
	H= zeros(1,summerdays); 

end %END OF LOOP THROUGH MULTIPLE YEARS

%for each day, this gives the ratio of eggs+larvae/nurse+house bees
% BARatio=(pop(1,1:360*numyears)+pop(2,1:360*numyears))./(pop(4,1:360*numyears)+pop(5,1:360*numyears)); 
%for each day, this gives the ratio of foragers/nurse+house bees
% FARatio=pop(6,1:360*numyears)./(pop(4,1:360*numyears)+pop(5,1:360*numyears));

YMatrix1=pop';
A=Ppop; %pollen storage throughout all seaseons
% disp('pollen in kg, no equip')
% disp(A'*.00023)
B=Hpop;  %honey storage throught all seasons
% A=Ppop.*0.23/1000;
% B=Hpop*0.5/1000;
YMatrix2= [A;B]';
Y3=Rpop;
%Y3=pop(3)*0.1552/1000+pop(4)*0.2189/1000+pop(5)*0.2189/1000+A+B;
timplot(YMatrix1, YMatrix2, Y3); 
% figure;

% plot(Y3);
% foundationweight = 50.2 * 453.6 /1000;
% 
% Y1=(pop(2)+pop(3))*0.1552/1000+pop(4)*0.2189/1000+pop(5)*0.2189/1000+Ppop.*0.23/1000+Hpop*0.5/1000;
% plot(Y1(1:360));
% t=[0:30:360];months=['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec';];
% set(gca,'xtick',t)
% set(gca,'xticklabel',months)wint
% xlabel('Date')
% ylabel('Colony Weight')
% 
% BNy=(BARatio+FARatio)';
