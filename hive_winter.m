function [S, V, P, H, R] = hive_winter(year, agemax, agemaxwinter, summerdays, \
		yeardays, Sin, V0, P0, H0, R0)

	S=zeros(6,yeardays-summerdays);
    V=zeros(1,yeardays-summerdays);
    P=zeros(1,yeardays-summerdays);
    H=zeros(1,yeardays-summerdays);
    R=zeros(1,yeardays-summerdays);
    	
    %used for compression age structure from daily to by-class in winter
    WINTERSTAGEMATRIX = zeros(4,agemaxwinter);
    WINTERSTAGEMATRIX(1,1:3)=1;
	WINTERSTAGEMATRIX(2,4:11)=1;
	WINTERSTAGEMATRIX(3,12:26)=1;
	WINTERSTAGEMATRIX(4,27:agemaxwinter)=1;

    %numbers of bees in each of six stages at end of summer give bees in
    %four stages at beginning of winter. 
    %S0 should be of length agemaxwinter

	% BUG!!! hardwired stage structure for summer population
	% Alternative?
	%    CC = eye(4,6); CC(4,5:6) = 1;
	%    S0 = ((CC*Sin')./sum(WINTERSTAGEMATRIX'))*WINTERSTAGEMATRIX
    S0 = zeros(agemaxwinter,1);
	S0(1:3)= Sin(1)/3; %NOTE: does this work every year or just first year?! should know what year we are in?
	S0(4:11)= Sin(2)/8;
	S0(12:26)= Sin(3)/15;
	S0(27:agemax) = (Sin(4)+Sin(5)+Sin(6))/(agemax-27+1);
    S0(agemax+1:end) = 0;
    
    Y = [ V0; P0; H0; R0; S0];

    for t = (yeardays*year+summerdays+1):(yeardays*(year+1))
        Y = one_winter_day(Y,t);

        i = t - (yeardays*year+summerdays);
        V(1,i) = Y(1);
        P(1,i) = Y(2);
        H(1,i) = Y(3);
        R(1,i) = Y(4);
        
        stages = WINTERSTAGEMATRIX*Y(5:end);
        
        S(1:3,i) = stages(1:3);
        S(5,i) = stages(4);
        
        %error checking
		if Y(1)== 0
			disp(['ran out of space, on day: ',num2str(t)])
			break
		end
		if Y(2) == 0
			disp(['Hive starved, no pollen, on day: ',num2str(t)])
			break
		end
		if Y(3) == 0
			disp(['Hive starved, no honey, on day: ',num2str(t)])
		end

    end %END OF LOOP THROUGH WINTER
return
