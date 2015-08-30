#!/bin/dash

# the gnuplot script raises an error if it cannot find the figure directory
# where it expects to, so we test ahead of time
[ -d "figures" ] || echo "Error: I expect to be run from /home/code/bees/Winnie-the-Pooh" 
[ -d "figures" ] || exit

gpheader=`sed -n '/^#gnuplot01#/,/#gnuplot01#/p' $0| grep -v "^#" `
gplooper=`sed -n '/^#gnuplot02#/,/#gnuplot02#/p' $0| grep -v "^#" `

# make temporary file name
n=`basename $0 | cut -d '.' -f 1`;
nn=XXXX.gplt;
fname=`mktemp /tmp/$n$nn`


lastday=`find data/state/ | sort | tail -n 1 | xargs -I {} basename {} .data`
echo "#Last day of animation is day $lastday"


# load loop code into temporary file
touch $fname; echo "$gplooper" >> $fname

# run everything
runcommand="load '$fname';"
echo "$gpheader timer_end = $lastday;  $runcommand" | gnuplot
rm $fname

# encode gif into an avi movie
framef="/tmp/toavi_44Qe5r_"
convert 'figures/state.gif' $framef%06d.png
ffmpeg -i $framef%06d.png figures/state.avi
rm -rf $framef*

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
set output 'figures/state.gif';
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
