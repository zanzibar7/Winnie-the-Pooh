function [V, P, H, R, S] = hive_winter(firstday, days, STATE, STAGES)

	V=zeros(1,days); % # vacant cells for each day
	P=zeros(1,days); % # pollen cells for each day 
	H=zeros(1,days); % # honey cells for each day
	R=zeros(1,days); % # eggs for each day
	S=zeros(min(size(STAGES)),days); % bee population by stage

	for i = 1:days
		t = firstday + i;
		% new state of hive
		STATE = one_winter_day(STATE, t, STAGES);

		% extract information from state
		V(i) = STATE(1);
		P(i) = STATE(2);
		H(i) = STATE(3);
		R(i) = STATE(4);
		S(:,i) = STAGES*STATE(4:end);

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
