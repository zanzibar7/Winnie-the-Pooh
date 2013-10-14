function nextstate = one_field_day(state,date)% bee model in the field season 


agemax=60; % indexing in matlab starts at 1, so add an extra day

global hsurfX hsurfY hsurf; % the interpolated surface of NectarODE and honeycollection 

u = 0; % probability of individual nurse bee precociously developing to forager
v = 0; % reversed prob. between foragers and house bees;
FactorBroodNurse = 4 ; % One nurse bee can heat 2.65 brood cells - NOT CRUCIAL.. but probably closer to 5
rt = 0; %probability of individual bee retardant developing to next age class
qh = 1; %probability of ..? downregulation of queen egg laying of some sort

%Honey consumption rates
% fraction of a cell's honey consumed by a bee in one day, a cellful of honey weighs~~0.5g
h1 = 0.0; %h1=0.12; 
h2 = 0; % h2=0.012; 
h3 = 0;
h4 = 0.0525; % h4=0.1;
h5 = 0.045; % h5=0.1;
h6 = 0.136; % h6 = 0.1;

%Pollen consumption rates
%a cellful of pollen weighs~~0.23g
a1 = 0; % eggs don't consume pollen?
a2 = 0.0047;% fraction of a cell's pollen consumed by a larva in one day
a3 = 0; %capped brood don't consume pollen from stores
a4 = 0.0283;% fraction of a cell's pollen consumed by a nurse bee in one day
a5 = 0.017; % fraction of a cell's pollen removed by a house bee in one day
a6 = 0; %foragers don't consume pollen

st1 = 0.913;%0.5; % st1=0.86; % 0.86--survivorship for egg stage 
st2 = 0.923;%0.5; % st2= 0.85; %---survivorship for larval stage 
st3 = 0.985;%0.86; % suvivorship for -- survivorship for pupa stage
st4 = 0.923;%0.85; % 0.99-85%--survivorship for nurse bee stage 
st5 = 0.913;%0.88; % 0.96-88.6%--survivorship for house bee stage 
st6 = 0.78; % 78.5%--survivorship for forager bee stage %0.653;%


tel = 0.98; %through-stage survival for egg maturing to 1st instar larva
tlp = 0.85; %through-stage survival for larva maturaing to pupa
tpn = 0.98; %through-stage survival for pupa maturing to nurse bee
tnh = 0.98; %through stage survival for nurse bee maturing to house bee
thf = 0.98; %through-stage survival for house been maturing to forager


 %% Stage Structure for field season bees-normal cycle: nonlinearities.1=egg,2=larvae,3=pupae,4=nurse,5=house,6=forager
s = zeros(6,agemax);
s(1,1:3) = 1;% 
s(2,4:11) = 1;
s(3,12:26) = 1;
s(4,27:42) = 1;
s(5,43:48) = 1;
s(6,49:agemax) = 1;

%% Current conditions in bee hive %%%%%%%%
Vt = state(1); % vacant cells 
Pt = state(2); %  pollen stores at time t. 
Ht = state(3);%  honey stores at time t. 
% We don't care about state(4), because those are now the 1-day old eggs,
% and the new state(4) will only depend on how many eggs are layed now.
Nt = state(5:end);% bee number at time t 
stage = s*Nt;

%% Queen reproduction potential (McLellan et al., 1978)
relativedate = mod(date,360);
maxProduction = (0.0000434)*(relativedate)^4.98293*exp(-0.05287*relativedate);

%% Index for the quality of pollen status and nursing quality in the colony
% Negative feedback loops of pollen stores and nursing quality in affecting
% the bee dynamics (Larva, Nurse) in turn affecting food collection and
% storage.

% (Blaschon et al.,1999) The modeled colony regulates the pollen stores around
% a level that represents a reserve for approximately 6 days, based on the current level of demand.
Factorstore=6;

% The colony pollen demand includes the need of egg, larval, nurse and house bee stage. 
% We assume the daily demand of pollen of bees is constant stage-specific parameters.
PollenDemand = a1*stage(1)+a2*stage(2)+a4*stage(4)+a5*stage(5); 
HoneyDemand = h1*stage(1)+h2*stage(2)+h4*stage(4)+h5*stage(5)+h6*stage(6);

if ( (PollenDemand <= 0) || (HoneyDemand <= 0) )
    disp('PollenDemand or HoneyDemand leq zero, dead hive')
end

% the level of the pollen stores in relation to the demand situation of the colony.
%got rid of +1s in the denominators
Indexpollen = max([0  min([1 Pt/(PollenDemand*Factorstore + 1) ])] );%max(0,min(1,Pt/(PollenDemand*Factorstore)))
Indexhoney = max([0 min([1 Ht/HoneyDemand])]); %max(0,min(1,Ht/(HoneyDemand)))
%the level of the active nurse bees population in relation to the total nursing demand of all brood stages.
IndexNursing = max(0,min(1,stage(4)/((stage(2)+stage(1))*FactorBroodNurse+1)));


%% Bee Dynamics : Everyone ages by one day
%except for the larva, these are all totally independant of what is going on in the hive.
%In the older model version, there were effects of food availability, as
%follows:
% survivorship(1:3) = mt1; 
% survivorship(4:11) = mt2*( 1 - max(0,1- Pt/(a2*stage(2))));
% survivorship(12:26) = mt3; 
% survivorship(27:42) = mt4* ( 1 - max(0,1- Pt/(a4*stage(4))-Ht/(h4*stage(4)))); 
% survivorship(43:48) = mt5* ( 1 - max(0,1- Ht/(h5*stage(5))));
% survivorship(49:agemax,1) = (1-v)*mt6;
% survivorship = zeros(agemax,1);
%going off of the above, I am changing the survivorships below to reflect
%these ideas using Indexpollen and Indexhoney

survivorship(1:3) = st1^(1/3); % the daily survival rate of egg stage at age(i=1-3) 

survivorship(3:4) =tel*survivorship(2); % stage transitional rate egg to larva

survivorship(4:11) = (st2*min(1,max(0,1-0.15*(1-Indexpollen*IndexNursing))))^(1/8); %  LARVA 
% st2: the time independent base mortality rate of larval stage at any age (4-11 days old- total 8 days)
% Larvae are frequently cannibalized in a honeybee colony.
% The rate of cannibalism depends on the age of the larvae (Schmickl and Crailsheim, 2001),
% the pollen status of the colony (Schmickl and Crailsheim, 2001)and the nursing quality (Eischen et al., 1982).
% Therefore, larval mortality includes a time-independent base mortality
% rate and the cannibalism factor. 0.15--the time-independent base
% cannibalism mortality rate for larval stage. 

%stage transition rate LARVA to PUPA
survivorship(11:12)=tlp*survivorship(10);

% PUPA: st3 is overal stage survival, cummulative over 15 days
survivorship(12:26)= st3^(1/15);

% stage transition rate PUPA to NURSE bee
survivorship(26:27)=tpn*survivorship(25) ;

% NURSE: who don't precociously forage (1-u) and who survive one day of 16 that make up st4
%It will be varied by the nursing efforts. A higher nursing load will
%cause a higher mortality of the nurse bee stage.
survivorship(27:42)= (1-u)*(st4*max(0,min(1,1-IndexNursing)))^(1/16) ; %= (1-u)*st4^(1/16);
% = (1-u)*(st4*max(0,min(1,1-IndexNursing)))^(1/16) ;
% = (1-u)*max(0,(1-(1-st4)*IndexNurseload))^(1/16);
%stage transition rate NURSE to HOUSE bee
survivorship(42:43)=tnh*survivorship(41) ;

%survivorship of HOUSE bee
survivorship(43:48)= st5^(1/6);%(st5*min(1,1-Indexhoney))^(1/6);

survivorship(48:49)=thf*survivorship(47);

survivorship(49:agemax)= (1-v)*st6^(1/12); % v is reversed probability of the forager bee stage to revert back to in-hive nurse bees. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Everything here just relates to storage and matrix multiplication.

        theta = rt*ones(agemax-1,1); % theta = probabilities of retarded development at each stage
        %all zeros right now

        % A is a matrix that stores the survival rate for each stage
        A = (diag(1-theta,-1)+diag([0;theta]))*diag(survivorship);

        B=zeros(agemax);% the precocious development of nurse bees 
        B(49,27:42)=u*ones(1,16);

        C=zeros(agemax);
        C(27,49:agemax)= v*ones(1,12); % the retarded development of forager bees 
        transit=A+B+C; 

        Nt1 = transit*Nt; % structured dynamics for bees - output is a vector

%% Food is consumed, new eggs are layed

% pollen consumption of egg, larval, nurse and house bee stage
foodeaten =  min([Pt PollenDemand]); 

% The removal of dead brood, hygenic behavior gives total number of scavanged cells
notsurvive = ones(1,26);
for k = 1:26
    notsurvive(k) = 1-survivorship(k);
end

scavanged = notsurvive*Nt(1:26); %this was the line that was generating an error before- causing Vt to be a matrix

% honey consumption of larval, nurse, house and forager bee stage
honeyeaten= min([Ht HoneyDemand]); 

% Empty Cells due to the cleaned food cells and adult emergence
vacated = Nt(26) + foodeaten + honeyeaten; %check this, maybe not Nt(26)- maybe Nt1(26)?
Vt = Vt + vacated + scavanged ;
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
    %Vt+vacated+scavanged cells gives how many cells are allocated to 
    %R = min([qh*maxProduction,stage(4)*FactorBroodNurse,Vt+vacated+scavangedcells]);
    %qh is set to 1 currently- simplified, always max production

    R = min([Vt, qh*maxProduction]); 
    %the only cap on the egg laying right now is the 
end 
%UPDATE VACANT CELL COUNT
Vt = Vt - R ;
    if Vt == 0
            disp('ran out of space after eggs laid')
            disp(date)
    end

%% POLLEN FORAGING- field season

% Pollen foraging feedback mechanism: pollen foraging is regulated
% according to the current pollen demand, which is the amount of pollen
% need for each stage and reserve for next 6 days (Factorstore) need minus
% to current pollen storage.
PollenNeed=max(0,PollenDemand*Factorstore-Pt);

% 0.48 is the pollen collected each day each forager, based on the amount
% of pollen collected per foraging trip(0.06 cellful pollen,Camazine et
% al., 1990), the average foraging trips performed per forager per day(10 trips per day) and the stochastic factor for each pollen
% forager to make a successful foraging trip(80%)
foragingsuccess = 0.48;

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
storedfood = max([0 min([PollenForager*0.48 Vt])]);

%UPDATE VACANT CELL COUNT
Vt = Vt - storedfood ;
    if Vt == 0
            disp('ran out of space after food stored')
            disp(date)
    end

%% Honey dynamics-field season 
% Reference: Edwards and Myerscough 2011 , nectarODE.m called here
% nectar collection is based on the interaction of current nectar forager and the house bees 
% Nectar being processed into honey is reduced in volume by a factor .4
 
% if stage(6) <= 1 
%     disp('no foragers'); %I don't see why this is here... shouldn't house bees just take over this role?
%     disp(date);
%     predictedhoney=0;    
% else
%     %volume ratio of honey/nectar = 0.4
%      predictedhoney = .4 * interp1(hsurfX,hsurf, stage(6)-PollenForager); 
%      %disp(predictedhoney)
%      
%      %this one causes crazy errors and discontinuites
%      %0.4*interp2(hsurfX,hsurfY,hsurf,0.8*stage(5),stage(6)-PollenForager);
%      
%      %this is the old, slow version
% %     initial=[0.8*stage(5),0.8*stage(5),1,0,0,stage(6)-PollenForager]';
% %     predictedhoney = honeycollection(initial);
%         if predictedhoney == 0
%             disp('interp function said no honey')
%         end
% 
% end

predictedhoney=interp2(hsurfX,hsurfY,hsurf,stage(5),stage(6));
if ( 0==exist('storedhoney','var') || isnan(predictedhoney) || predictedhoney<0 )
	predictedhoney=1.e-3;
end
storedhoney = min([predictedhoney Vt]);
    
%UPDATE VACANT CELL COUNT
Vt = Vt - storedhoney ;
%     if Vt == 0
%             disp('ran out of space after honey stored')
%             disp(date)
               %This isn't tecnically an issue, since the eggs emerging in
               %the next stage should make more room... but it shouldn't
               %really  happen
%     end
   
%% Pollen, Honey, Cells net input 
Pt = Pt - foodeaten + storedfood;
Pt1 = max(0,Pt); % Updated pollen stores at end of day
Ht1 = Ht + storedhoney; % Updated honey stores at end of day, capped by total size of hive
Vt1 = Vt; % Vacant cells at end of the day - gets updated throughout file  
Nt1(1) = R; %R; %number of eggs laid today, these are now the age zero eggs

nextstate = [Vt1; Pt1; Ht1; R; Nt1];

return
