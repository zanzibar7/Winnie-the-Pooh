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
		V(1,i) = STATE(1);
		P(1,i) = STATE(2);
		H(1,i) = STATE(3);
		R(1,i) = STATE(4);
		S(:,i) = SUMMERSTAGES*STATE(5:end);

		%error checking
		if STATE(2) == 0
			break
		end
		if STATE(3) == 0
			break
		end
		if S(4,i)+S(5,i)+S(6,i) < 10
			disp(sprintf('day %d : Hive collapsed',t));
			break
		end
	end
return
