% pre-compute honey foraging numbers, if needed
global hsurfX hsurfY hsurf;

A = exist('hsurfX.data','file');
disp('A=');
disp(A);
if ( 0 ~= A )
	disp('Loading nector surface');
	load('hsurfX.data');
	load('hsurfY.data');
	load('hsurf.data');
else disp('no hsurf file')
end

E = exist('hsurfX','var');
disp('E=');
disp(E);
if ( 0 == E || isempty(hsurf) ) 
	disp('Precomputing nector surface');
    trialsurf;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Intializations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First Season Summer Dynamics 

agemax = 50; % +1 because of matlab indexing
numyears = 1;
summerdays = 240;
yeardays = 360;
agemaxwinter = 150; %max life of winter bee

%Parameters for testing perturbed colony scenarios
P0 = 200; %P0 = 1000; %initial cells of pollen

V0 = 500000 - P0; %intial vacant cells, total number cells is 140000
%subtract to leave room for eggs and pollen

H0=0; %initial honey

R0=0; %initial eggs

N = zeros(agemax,1);

N(1:3)=100; % initial number of eggs/3 days   %SHOULD BE ZERO, BUT THIS CAUSES CODE TO CRASH WITH ERROR "DEAD HIVE

N(4:8)=200; % initial number of larva = 1600/8 days

N(9:20)=160; % initial number of pupa = 2400/15 days

N(21:32)=187; % initial number of nurse bees = 3000/16 days

N(33:42)=500; % initial number of house bees= 3000/ 6 days

N(43:agemax)=250; % initial number of forager bees = 3000 / 12 days

X = [ V0; P0; H0;R0; N ]; % This hold the initial bee populion that goes into bees.m

res=zeros(6,summerdays); % res will hold bee population by stage for each day of summer

V=zeros(1,summerdays); %vector will hold # vacant cells for each day of summer

P=zeros(1,summerdays);

H=zeros(1,summerdays);

R=zeros(1,summerdays);

%these super long vectors hold the vacant cells, pollen, honey, and egg
%filled cells for every day of the years in our time series
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
          
    [summres, summV,summP, summH, summR] = hive_summer(T,agemax,summerdays,yeardays,res,V,P,H,R,X);
     
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
    
    
    % First Season Winter Dynamics 

    [wintres,wintV,wintP,wintH,wintR] = hive_winter(T,agemax,agemaxwinter,summerdays,yeardays,res,V,P,H,R);
    
	pop(:, (yeardays*T+summerdays+1):(yeardays*(T+1))) = wintres;% catpop;
    Vpop(1,(yeardays*T+summerdays+1):(yeardays*(T+1))) = wintV;
    Ppop(1,(yeardays*T+summerdays+1):(yeardays*(T+1))) = wintP;
    Hpop (1,(yeardays*T+summerdays+1):(yeardays*(T+1))) = wintH;
    Rpop (1,(yeardays*T+summerdays+1):(yeardays*(T+1))) = wintR;
    
        
	%Second Season Summer Dynamics 

	N = zeros(agemax,1);

	N(1:3)=pop(1,yeardays*(T+1))/3;

	N(4:8)=pop(2,yeardays*(T+1))/5;

	N(9:20)=pop(3,yeardays*(T+1))/12;

	N(21:32)= pop(5,yeardays*(T+1))/30;

	N(33:42)= pop(5,yeardays*(T+1))/30 ;

	N(43:agemax)=pop(5,yeardays*(T+1))/30;

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


YMatrix1=pop';
A=Ppop; %pollen storage throughout all seaseons
B=Hpop;  %honey storage throught all seasons
YMatrix2= [A;B]';
 Y3=Rpop;
timplot(YMatrix1, YMatrix2, Y3); 


