function snapframe(date, STATE, survivorship)
	dlmwrite(sprintf('data/state_%04d.data',date),STATE);
	dlmwrite(sprintf('data/survivorship_%04d.data',date),survivorship');
return
% subplot(2,1,1)
% plot(Nt,'ko-')
% title(sprintf('Day %3d',date))
% ylim([0,2000])
% subplot(2,1,2)
% plot(survivorship,'gx-'); ylim([0,1]);
% pause(0.2)
