% treluga, 20120324.
% This code calculates the surface for honey collected based
% on the number of bees involved in collection, and stores
% it in a matrix that we can later use for interpolation.
% This will significantly speed up the model.


global hsurfX hsurfY hsurf;

gn=100;
H = linspace(1,500000,gn)'; %possible numbers of house bees
F = linspace(1,500000,gn)'; %possible numbers of foragers bees
I = [H,H,ones(gn,1),zeros(gn,1),zeros(gn,1),F]; 
hy=zeros(gn,1); 

for i=1:1:gn %i=1:gn
       %initial(i,:)=I (i,:); 
       I(i,:);
      hy(i)= honeycollection(I(i,:));
end 

%repmat is a built-in MATLAB function which replicates and tiles an array.
%In this case, it will take 'hy' and repeat it side by side 'gn' times
Z=repmat(hy, 1, gn);

hsurfX = H;
hsurfY = F;
hsurf = Z; 
