
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

data/timeseries.data: figures/timoutput.eps

figures/timoutput.eps: $(MSIM)
	/usr/bin/octave -q simulator.m

clean:
	rm -rf data/state/*.data data/survivorship/*.data data/*.data
	rm -rf figures/*.eps figures/*.gif
