%This file contains the parameters which affect forager recruitment and
%honey collection success. All parameters are taken directly from Edwards
%and Myerscough "Intelligent decisions from the Hive Mind." This file then calls on nectarODE
%Notes on parameters: E+M wrote equations, and then they picked parameters which fit Seeley 1992 and 1995 data -aip

function hy = honeycollection(initial) 
 global fa fr fs mS mQ mT ss iQ rs k j m omega td Q nt; 
    

       fa = 900; % forager round-trip time : 15 minutes = 900 seconds
       fr = 0.0010; % forager recruitment rate, units s^-1
       fs = 0.0002; % forage resting rate. s^-1
        mS = 10; % half-maximal search time: 10 seconds
        mQ = 1.5; %  half-maximal forage quality (mol/l)
        mT = 30; % the minimum search time for which tremeble dancing occurs
        ss = 5;% single interaction time : 5 seconds
        iQ = 3.0; % High quality for scaling receiver response 
        rs = 60*20; % receiver storage time: 20 minutes
        k  = 4; % search time coefficient 
        j = 4; % forage quality coefficient 
        m = 5; % the steepness of the response to tremble dancing 
        Q = 3; % true nectar quality defined by its sucrose concentration measured in moles per litre 
         % initial receiver and forager bees size 
        omega = 0.1; % the maximal recruitment rate due to tremeble dance 
        td = 1; % 
       
nt=8; %number of hours that foraging could be going on
trange = [0:60:3600*nt]; %goes through and counts seconds by the minute
       
[t,y] = ode45(@nectarODE,trange,initial);



hy=y(end,5); 

    end 



