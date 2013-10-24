function [yres, yV, yP, yH, yR] = hive_winter(year,aw,a,s,y,resIn,Vin,Pin,Hin,Rin)

	agemaxwinter = aw; %150; %max life of winter bee
    agemax = a;
    summerdays = s;
    yeardays = y;
    T = year;

	P0 = Pin(1,summerdays);

    V0 = Vin(1,summerdays); 

    H0 = Hin(1,summerdays);

    R0 = Rin(1,summerdays);
    

    Y = [ V0; P0; H0; R0; resIn ];
    disp(Y(1:4))
% 	clear res V P H R;

	res=zeros(6,yeardays-summerdays);
    
    V=zeros(1,yeardays-summerdays);

    P=zeros(1,yeardays-summerdays);

    H=zeros(1,yeardays-summerdays);

    R=zeros(1,yeardays-summerdays);
    	

    for t = (yeardays*T+summerdays+1):(yeardays*(T+1))
         
        Y = one_winter_day(Y,t);
        disp(Y(1:4))
        %wintpop = W*Yw; %this is a problem for some reason
        res(1:3,(t-(yeardays*T+summerdays))) =  Y(1:3); %wintpop(1:3);
        res(5,(t-(yeardays*T+summerdays))) = Y(4); %wintpop(4);
        disp(res(:,(t-(yeardays*T+summerdays))))
        
        V(1,(t-(yeardays*T+summerdays))) = Y(1);
        P(1,(t-(yeardays*T+summerdays))) = Y(2);
        H(1,(t-(yeardays*T+summerdays))) = Y(3);
        R(1,(t-(yeardays*T+summerdays))) = Y(4);
        
%        if Y(1)== 0
%           disp('ran out of space, on day:')
%           disp(t)
%           break
%        end
%         if Y(2) == 0
%             disp('Hive starved, no pollen, on day:')
%             disp(t)
%             break
%         end
%         if Y(3) == 0
%             disp('Hive starved, no honey, on day:')
%             disp(t)
%         end

    end %END OF LOOP THROUGH WINTER
    
	yres = res ;
    
    yV = V;
    
    yP = P;
    
    yH = H;
    
    yR = R;
    
    return
    
end
