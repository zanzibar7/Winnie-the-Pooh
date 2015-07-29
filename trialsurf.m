% treluga, 20120324.
% This code calculates the surface for honey collected based
% on the number of bees involved in collection, and stores
% it in a matrix that we can later use for interpolation.
% This will significantly speed up the model.

% H = stage(5)
% F = stage(6)

% The larger the integers Hn and Fn, the more accurate your interpolation

Hn = 128; Fn = 128;
global hsurfX hsurfY hsurf;

% 
% x and y are the ranges for stage(5) and stage(6).
% The code has a problem if we plug 0 into the ODE's below, so we
% start at 1.  I'm just guessing that 4000 is a large enough
% upper bound, but this may need to be increased.
H = 10.^linspace(-1,4.2,Hn);
F = 10.^linspace(-1,4.2,Fn);
hsurfX=H;
hsurfY=F;
hsurf = zeros(length(H),length(F));
for i=1:1:Hn
        for j=1:1:Fn
                A(1+(i-1)+Hn*(j-1)).d = [ H(i), F(j) ];
        end
end
predictedhoney = @(x) honeycollection( x.d(1), x.d(2) );
fA = arrayfun( predictedhoney, A );
%fA = pararrayfun( predictedhoney, A );
for i=1:1:Hn
        for j=1:1:Fn
                hsurf(i,j) = fA(1+(i-1)+Hn*(j-1));
        end
end

save hsurfX.data hsurfX -ascii
save hsurfY.data hsurfY -ascii
save hsurf.data hsurf -ascii
