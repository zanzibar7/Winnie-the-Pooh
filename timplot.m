function timplot(YMatrix1, YMatrix2,Y1)

%CREATEFIGURE1(YMATRIX1,YMATRIX2,Y1)
%  YMATRIX1:  matrix of y data
%  YMATRIX2:  matrix of y data
%  Y1:  vector of y data


% Create figure
figure(1);
clf();
subplot(2,2,1);
plot(YMatrix1);
legend('Egg','Larva','Pupa','Nurse Bee','House Bee','Forager');
ylabel('Number of Bees');
title({'A Honey Bee Colony Population Dynamics'});

subplot(2,2,2);
plot(YMatrix2(:,1),'gx-');
ylabel('Pollen');

subplot(2,2,4)
plot(YMatrix2(:,2),'bx-');
ylabel('Honey');

subplot(2,2,3)
plot(Y1,'k+-');
ylabel('Number of Eggs');

end 
