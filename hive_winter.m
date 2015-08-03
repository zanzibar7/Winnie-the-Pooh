function [V, P, H, R, S] = hive_winter(year, summerdays, yeardays,
	STATE, WINTERSTAGES)

	winterdays = yeardays-summerdays;

	V=zeros(1,winterdays); % # vacant cells for each day of winter
	P=zeros(1,winterdays); % # pollen cells for each day of winter
	H=zeros(1,winterdays); % # honey cells for each day of winter
	R=zeros(1,winterdays); % # eggs for each day of winter
	S=zeros(min(size(WINTERSTAGES)),winterdays); % bee population by stage

	for t = (yeardays*year+summerdays+1):(yeardays*(year+1))
		% new state of hive
		STATE = one_winter_day(STATE, t, WINTERSTAGES);

		% extract information from state
		i = t - (yeardays*year+summerdays);
		V(i) = STATE(1);
		P(i) = STATE(2);
		H(i) = STATE(3);
		R(i) = STATE(4);
		S(:,i) = WINTERSTAGES*STATE(4:end);

		%error checking
		if STATE(2) == 0
			break
		end
		if STATE(3) == 0
			break
		end
		if S(4,i) < 10
			disp(sprintf('day %d : Hive collapsed',t));
			break
		end
	end
return
