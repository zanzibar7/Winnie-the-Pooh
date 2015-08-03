
MSIM:=
MSIM+=simulator.m 
MSIM+=createfigs.m 
MSIM+=hive_summer.m 
MSIM+=hive_winter.m 
MSIM+=one_summer_day.m 
MSIM+=one_winter_day.m 
MSIM+=timfigs.m 

MSURF:=
MSURF+=trialsurf.m 
MSURF+=honeycollection.m 
MSURF+=nectarODE_matlab.m 
MSURF+=nectarODE_octave.m 

all: timeseries.eps

timeseries.eps: histogram_timeseries.gplt t.data
	/usr/bin/gnuplot histogram_timeseries.gplt 

t.data: timoutput.eps


timoutput.eps: $(MSIM)
	/usr/bin/octave -q simulator.m


