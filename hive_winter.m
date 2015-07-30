function [S, V, P, H, R] = hive_winter(year, agemax, agemaxwinter, summerdays, \
		yeardays, Sin, V0, P0, H0, R0)

	S=zeros(6,yeardays-summerdays);
    V=zeros(1,yeardays-summerdays);
    P=zeros(1,yeardays-summerdays);
    H=zeros(1,yeardays-summerdays);
    R=zeros(1,yeardays-summerdays);
    	
    %used for compression age structure from daily to by-class in winter
    W = zeros(4,agemaxwinter);
    W(1,1:3)=1; W(2,4:11)=1; W(3,12:26)=1; W(4,27:agemaxwinter)=1;

    %numbers of bees in each of six stages at end of summer give bees in
    %four stages at beginning of winter. 
    %S0 should be of length agemaxwinter
    S0 = zeros(agemaxwinter,1);
	S0(1:3)= Sin(1)/3; %NOTE: does this work every year or just first year?! should know what year we are in?
	S0(4:11)= Sin(2)/8;
	S0(12:26)= Sin(3)/15;
	S0(27:agemax) = (Sin(4)+Sin(5)+Sin(6))/(agemax-27+1);
    S0(agemax+1:end) = 0;
    
    Y = [ V0; P0; H0; R0; S0];

    for t = (yeardays*year+summerdays+1):(yeardays*(year+1))
        Y = one_winter_day(Y,t);

        V(1,(t-(yeardays*year+summerdays))) = Y(1);
        P(1,(t-(yeardays*year+summerdays))) = Y(2);
        H(1,(t-(yeardays*year+summerdays))) = Y(3);
        R(1,(t-(yeardays*year+summerdays))) = Y(4);
        
        stages = W*Y(5:end);
        
        S(1:3,(t-(yeardays*year+summerdays))) = stages(1:3);
        S(5,(t-(yeardays*year+summerdays))) = stages(4);
        
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
return
