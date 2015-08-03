MSIM:=
MSIM+=simulator.m 
MSIM+=createfigs.m 
MSIM+=hive_summer.m 
MSIM+=hive_winter.m 
MSIM+=one_summer_day.m 
MSIM+=one_winter_day.m 
MSIM+=timfigs.m 
MSIM+=snapframe.m 

MSURF:=
MSURF+=trialsurf.m 
MSURF+=honeycollection.m 
MSURF+=nectarODE_matlab.m 
MSURF+=nectarODE_octave.m 

all: figures/timeseries.eps

figures/timeseries.eps: figures/histogram_timeseries.gplt data/timeseries.data
	/usr/bin/gnuplot $<

figures/timoutput.eps: data/timeseries.data

data/timeseries.data: $(MSIM) hsurf.data
	/usr/bin/octave -q simulator.m

figures/state.gif: figures/state_gif_movie.sh data/timeseries.data
	$<

hsurf.data: $(MSURF)
	# also hsurfX.data and hsurfY.data
	/usr/bin/octave -q trialsurf.m
	
clean:
	rm -rf data/state/*.data data/survivorship/*.data data/*.data
	rm -rf figures/*.eps figures/*.gif
