function [S, V, P, H, R] = hive_summer(year, agemax, summerdays, yeardays,\
	STATE, STAGEMATRIX)

	S=zeros(6,summerdays); % bee population by stage for each day of summer 
	V=zeros(1,summerdays); % # vacant cells for each day of summer 
	P=zeros(1,summerdays); % # pollen cells for each day of summer
	H=zeros(1,summerdays); % # honey cells for each day of summer
	R=zeros(1,summerdays); % # eggs for each day of summer
	% STATE = [V, P, H, R, N]

	% LOOP THROUGH THIS SUMMER
	for t=(yeardays*year+1):(yeardays*year+summerdays)
		STATE = one_summer_day(STATE, t, STAGEMATRIX); % new state of hive
		S(1:6, t-yeardays*year) = STAGEMATRIX*STATE(5:end);
		V(1, t-yeardays*year) = STATE(1);
		P(1, t-yeardays*year) = STATE(2);
		H(1, t-yeardays*year) = STATE(3);
		R(1, t-yeardays*year) = STATE(4);
	end
return
