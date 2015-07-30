function timplot(YMatrix1, YMatrix2,Y1)

	% Create figure
	figure(1);
	clf();
	subplot(3,1,1);
	plot(YMatrix1);
	legend('Egg','Larva','Pupa','Nurse Bee','House Bee','Forager');
	ylabel('Number of Bees');
	title('A Honey Bee Colony Population Dynamics');

	subplot(3,1,2);
	plot(YMatrix2(:,1),'gx-', YMatrix2(:,2),'bx-');
	ylabel('Number of Cells');
	legend('Pollen','Honey');

	subplot(3,1,3)
	W = (.047*YMatrix1(:, 2)+.158*YMatrix1(:, 3) + .133*(YMatrix1(:, 4)+YMatrix1(:, 5)+YMatrix1(:, 6)) + .23*YMatrix2(:, 1)+ .5*YMatrix2(:, 2))/1000;
	plot(W,'ko-');
	% Create ylabel
	ylabel('Weight (kg) - no equip');
	xlabel('Day');

	print -depsc output.eps
	print -dpdf output.pdf

	close()

return
