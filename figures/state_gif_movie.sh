#!/bin/dash

gpheader=`sed -n '/^#gnuplot01#/,/#gnuplot01#/p' $0| grep -v "^#" `
gplooper=`sed -n '/^#gnuplot02#/,/#gnuplot02#/p' $0| grep -v "^#" `

# make temporary file name
n=`basename $0 | cut -d '.' -f 1`; nn=XXXX.gplt; fname=`mktemp /tmp/$n$nn`

lastday=`find data/state/ | sort | tail -n 1 | xargs -I {} basename {} .data`
echo $lastday

# load loop code into temporary file
touch $fname; echo "$gplooper" >> $fname

# run everything
runcommand="load '$fname';"
echo "$gpheader timer_end = $lastday;  $runcommand" | gnuplot
rm $fname
exit

#gnuplot01#
timer = 1;
dt = 1;
set yrange [0:2000];
set xrange [0:60];
set xlabel 'Age';
set ylabel 'Count';
set terminal gif animate delay 5;
set nokey;
set output 'figures/state_animation.gif';
#gnuplot01#


#gnuplot02#
dfile=sprintf("data/state/%04d.data",timer);
set title sprintf("Day %d", timer);
set xlabel "Age" font "Helvetica,18";
set ylabel "Number" font "Helvetica,18";
plot dfile every 1:1:5   w imp lc 0 lw 3;
timer = timer + dt;
if (timer<=timer_end) reread;
#gnuplot02#
