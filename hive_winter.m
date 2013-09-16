function [yres, yV, yP, yH, yR] = hive_winter(year,aw,a,s,y,resIn,Vin,Pin,Hin,Rin)

	agemaxwinter = aw; %150; %max life of winter bee
    agemax = a;
    summerdays = s;
    yeardays = y;
    T = year;
    res = resIn;
    P = Pin;
    V = Vin;
    H = Hin;
    R = Rin;
	W = zeros(4,agemaxwinter);

	W(1,1:3)=1; W(2,4:11)=1; W(3,12:26)=1; W(4,27:agemaxwinter)=1;

	N = zeros(agemaxwinter,1);

	N(1:3) = res(1,summerdays)/3;

	N(4:11) = res(2,summerdays)/8;

	N(12:26) = res(3,summerdays)/15;

    N(27:agemax) = (res(4,summerdays)+res(5,summerdays)+res(6,summerdays))/34;
    % this doesn't make sense- it's like artificially aging many of them.  
	%N(27:agemaxwinter)=(res(4,summerdays)+res(5,summerdays)+res(6,summerdays))/124; 

	P0 = P(1,summerdays);

    V0 = V(1,summerdays); 

    H0 = H(1,summerdays);

    R0 = R(1,summerdays);
    

    Y = [ V0; P0; H0; R0; N ];

% 	clear res V P H R;

	res=zeros(6,yeardays-summerdays);
    
    V=zeros(1,yeardays-summerdays);

    P=zeros(1,yeardays-summerdays);

    H=zeros(1,yeardays-summerdays);

    R=zeros(1,yeardays-summerdays);
    	

    for t = (yeardays*T+summerdays+1):(yeardays*(T+1))
        
        Y = one_winter_day(Y,t);
        
        wintpop = W*Y(5:end); %this is a 4xmaxagewinter matrix %this pieces causes second season crash- not just bad pic
        res(1:3,(t-(yeardays*T+summerdays))) = wintpop(1:3);
        res(5,(t-(yeardays*T+summerdays))) = wintpop(4);
        
        V(1,(t-(yeardays*T+summerdays))) = Y(1);
        if Y(1)== 0
            disp('ran out of space, on day:')
            disp(t)
            break
        end
        P(1,(t-(yeardays*T+summerdays))) = Y(2);
        if Y(2) == 0
            disp('Hive starved, no pollen, on day:')
            disp(t)
            break
        end
        H(1,(t-(yeardays*T+summerdays))) = Y(3);
        
        if Y(3) == 0
            disp('Hive staved, no honey, on day:')
            disp(t)
            break
        end
        R(1,(t-(yeardays*T+summerdays))) = Y(4);
    end %END OF LOOP THROUGH WINTER
    
	yres = res;
    
    yV = V;
    
    yP = P;
    
    yH = H;
    
    yR = R;
    
    
end
