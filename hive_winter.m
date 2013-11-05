function [yres, yV, yP, yH, yR] = hive_winter(year,a,aw,s,y,resIn,Vin,Pin,Hin,Rin)

	agemaxwinter = aw; %max life of winter bee
    agemax = a;
    summerdays = s;
    yeardays = y;
    T = year;

    %conditions at end of summer are conditions for beginning fo winter
	P0 = Pin(1,summerdays);
    V0 = Vin(1,summerdays);
    H0 = Hin(1,summerdays);
    R0 = Rin(1,summerdays);
    
    %numbers of bees in each of six stages at end of summer give bees in
    %four stages at beginning of winter. 
    %res0 should be of length agemaxwinter
    res0 = zeros(agemaxwinter,1);

	res0(1:3)= resIn(1,summerdays)/3; %NOTE: does this work every year or just first year?! should know what year we are in?

	res0(4:11)= resIn(2,summerdays)/8;

	res0(12:26)= resIn(3,summerdays)/15;

	res0(27:agemax) = (resIn(4,summerdays)+resIn(5,summerdays)+resIn(6,summerdays))/(agemax-27+1);

    res0(agemax+1:end) = 0;
    
    Y = [ V0; P0; H0; R0; res0];

	res=zeros(6,yeardays-summerdays);
    
    V=zeros(1,yeardays-summerdays);

    P=zeros(1,yeardays-summerdays);

    H=zeros(1,yeardays-summerdays);

    R=zeros(1,yeardays-summerdays);
    	
    %used for compression age structure from daily to by-class in winter
    W = zeros(4,agemaxwinter);
    W(1,1:3)=1; W(2,4:11)=1; W(3,12:26)=1; W(4,27:agemaxwinter)=1;


    for t = (yeardays*T+summerdays+1):(yeardays*(T+1))
         
        %Y needs to be compressed to 4 stages before going in to
        %one_winter_day
        Y = one_winter_day(Y,t);
       
        V(1,(t-(yeardays*T+summerdays))) = Y(1);
        P(1,(t-(yeardays*T+summerdays))) = Y(2);
        H(1,(t-(yeardays*T+summerdays))) = Y(3);
        R(1,(t-(yeardays*T+summerdays))) = Y(4);
        
        compressedN = W*Y(5:end);
        
        res(1:3,(t-(yeardays*T+summerdays))) =  compressedN(1:3);
        res(5,(t-(yeardays*T+summerdays))) =  compressedN(4);
        
        %error checking
       if Y(1)== 0
          disp('ran out of space, on day:')
          disp(t)
          break
       end
        if Y(2) == 0
            disp('Hive starved, no pollen, on day:')
            disp(t)
            break
        end
        if Y(3) == 0
            disp('Hive starved, no honey, on day:')
            disp(t)
        end

    end %END OF LOOP THROUGH WINTER
    
	yres = res ;
    
    yV = V;
    
    yP = P;
    
    yH = H;
    
    yR = R;
    
    return
    
end
