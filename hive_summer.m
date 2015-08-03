function [V, P, H, R, S] = hive_summer(year, summerdays, yeardays,
	STATE, SUMMERSTAGES)


	V=zeros(1,summerdays); % # vacant cells for each day of summer
	P=zeros(1,summerdays); % # pollen cells for each day of summer
	H=zeros(1,summerdays); % # honey cells for each day of summer
	R=zeros(1,summerdays); % # eggs for each day of summer
	S=zeros(min(size(SUMMERSTAGES)),summerdays); % bee population by stage

	for t = (yeardays*year+1):(yeardays*year+summerdays)
		% new state of hive
		STATE = one_summer_day(STATE, t, SUMMERSTAGES);

		% extract information from state
		i = t - yeardays*year;
		V(i) = STATE(1);
		P(i) = STATE(2);
		H(i) = STATE(3);
		R(i) = STATE(4);
		S(:,i) = SUMMERSTAGES*STATE(4:end);

		%error checking
		if STATE(2) == 0
			H(i:end) = H(i);
			break
		end
		if STATE(3) == 0
			P(i:end) = P(i);
			break
		end
		if S(4,i)+S(5,i)+S(6,i) < 10
			disp(sprintf('day %d : Hive collapsed',t));
			H(i:end) = H(i);
			P(i:end) = P(i);
			break
		end
	end
return
