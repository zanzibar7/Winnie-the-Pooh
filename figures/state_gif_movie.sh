#!/bin/dash

gpheader=`sed -n '/^#gnuplot01#/,/#gnuplot01#/p' $0| grep -v "^#" `
gplooper=`sed -n '/^#gnuplot02#/,/#gnuplot02#/p' $0| grep -v "^#" `

# make temporary file name
n=`basename $0 | cut -d '.' -f 1`; nn=XXXX.gplt; fname=`mktemp $n$nn`

# load loop code into temporary file
touch $fname; echo $gplooper >> $fname

# run everything
runcommand="load '$fname';"
echo $gpheader $runcommand | gnuplot
rm $fname
echo "Now do                                "
echo "            animate -loop 1 /tmp/animation.gif"
echo "               cp   /tmp/animation.gif ./ "
echo "            animate      animation.gif"
exit

#gnuplot01#
timer_end = 230;
timer = 1;
dt = 1;
set yrange [0:2000];
set xrange [0:60];
set xlabel 'Age';
set ylabel 'Count';
set terminal gif animate delay 40;
set nokey;
set output '/tmp/animation.gif';
#gnuplot01#


#gnuplot02#
dfile=sprintf("../data/state_%04d.data",timer);
plot dfile every 1:1:5   w imp lc 0 lw 3;
timer = timer + dt;
if (timer<=timer_end) reread;
#gnuplot02#
