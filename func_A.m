function y = func_A(x,m,c)
	% c = 0 gives the line x
	% c = oo is jumps at x = 0
	% gnuplot> f(x,m,c) = x*(c*m*x - c*m + c - x + 1)/(c*x - x + 1)
	% gnuplot> g(x,c) = f(x,0.15,c)

	assert( c>= 0);
	assert( m >= 0);
	y = x*((1-c*m)*(x - 1) - c)/(x - c*x - 1);
return

