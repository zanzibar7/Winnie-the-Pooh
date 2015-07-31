function timfigs(YMatrix1, YMatrix2,Y1)

	% Create figure
	figure(1);
	clf();
	subplot(3,1,1);
	plot(YMatrix1);
	legend('Egg','Larva','Pupa','Nurse Bee','House Bee','Forager');
	ylabel('Number of Bees','fontsize',24);
	title('A Honey Bee Colony Population Dynamics','fontsize',24);

	subplot(3,1,2);
	%plot(YMatrix2(:,1),'gx-', YMatrix2(:,2),'bx-');
	%legend('Pollen','Honey');
	plot(YMatrix2(:,1),'g-','linewidth',3);
	legend('Pollen');
	ylabel('Number of Cells','fontsize',24);

	subplot(3,1,3)
	weight = (.047*YMatrix1(:, 2)+.158*YMatrix1(:, 3) + .133*(YMatrix1(:, 4)+YMatrix1(:, 5)+YMatrix1(:, 6)) + .23*YMatrix2(:, 1)+ .5*YMatrix2(:, 2))/1000;
	plot(weight,'k-','linewidth',3);
	% Create ylabel
	ylabel('Weight (kg) - no equip','fontsize',24);
	xlabel('Day','fontsize',24);

	print -depsc timoutput.eps

	close()

return
