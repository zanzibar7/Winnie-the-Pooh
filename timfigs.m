function timfigs(STAGE, STORAGE, EGGS)

	L = length(STORAGE);
	% Create figure
	figure(1);
	clf();
	subplot(4,1,1);
	plot(STAGE);
	legend('Egg','Larva','Pupa','Nurse Bee','House Bee','Forager');
	ylabel('Number of Bees','fontsize',24);
	title('A Honey Bee Colony Population Dynamics','fontsize',24);
	xlim([0,L]);

	subplot(4,1,2);
	%plot(STORAGE(:,1),'gx-', STORAGE(:,2),'bx-');
	%legend('Pollen','Honey');
	plot(STORAGE(:,1),'g-','linewidth',3);
	title('Pollen Stores','fontsize',24);
	ylabel('Number of Cells','fontsize',24);
	xlim([0,L]);

	subplot(4,1,3);
	plot(STORAGE(:,2),'y-','linewidth',3);
	title('Honey Stores','fontsize',24);
	ylabel('Number of Cells','fontsize',24);
	xlim([0,L]);

	subplot(4,1,4)
	weight = (.047*STAGE(:, 2)+.158*STAGE(:, 3) + .133*(STAGE(:, 4)+STAGE(:, 5)+STAGE(:, 6)) + .23*STORAGE(:, 1)+ .5*STORAGE(:, 2))/1000;
	plot(weight,'k-','linewidth',3);
	% Create ylabel
	title('Hive weight - no equipment','fontsize',24);
	ylabel('Weight (kg)','fontsize',24);
	xlabel('Day','fontsize',24);
	xlim([0,L]);

	print -depsc figures/timoutput.eps

	close()

return
