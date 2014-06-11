#!/bin/sh
INPUT=$1
PLOT=/tmp/plot.$$
READ=/tmp/read.$$
WRITE=/tmp/write.$$
TOTAL=/tmp/total.$$
SEEKREAD=/tmp/sreed.$$
# If I were to do this again I think perl would have been saner.
cat $INPUT | awk -F, 'BEGIN { base=0 } /Read/ {if (base==0) {base=$2} printf("%s,%d,%d,%s,%s,%s,%s,%d\n",$1,$2-base,$3-base,$4,$5,$6,$7/(1024*1023),($8/($3-$2)))}' > $READ
cat $INPUT | awk -F, 'BEGIN { base=0 } /Write/ {if (base==0) {base=$2} printf("%s,%d,%d,%s,%s,%s,%s,%d\n",$1,$2-base,$3-base,$4,$5,$6,$7/(1023*1024),($8/($3-$2)))}'> $WRITE
# This is interesting
paste -d , $READ $WRITE |  awk -F, '{ printf("%s,%d,%d,Total,%d,%d,%d,%d\n",$1,$2,$3,$5+$13,$6+$14,$7+$15,$8+$16)}' > $TOTAL
UNITS=`cat $READ | head -1 | awk -F, '{printf ("(%d seconds)",$3-$2)}'`
rm -f  /tmp/ob.png /tmp/errors.png /tmp/iops.png
cat <<EOT >> $PLOT
reset
set grid
set output "/tmp/data_transfered.png"
set datafile separator ','
set term png small size 1200,600 truecolor 
set title "Data transfered"  
set ylabel "MBytes/$UNITS"
set xlabel "Time (seconds)"
set key inside
set format y "%.2f"
plot '$READ' using 3:7 with lines title "Read", '$WRITE' using 3:7 with lines title "Write",'$TOTAL' using 3:7 with lines title 'Total'
reset
set grid
set output "/tmp/errors.png"
set datafile separator ','
set term png small size 1200,600 truecolor
set title "Errors"
set ylabel "errors/$UNITS"
set xlabel "Time (seconds)"
set key inside
set format y "%.2f"
plot '$READ' using 3:5 with lines title "Read", '$WRITE' using 3:5 with lines title "Write",'$TOTAL' using 3:5 with lines title 'Total'
reset
set grid
set output "/tmp/iops.png"
set datafile separator ','
set term png small size 1200,600 truecolor
set title "Number of operations per second"
set ylabel "operations/$UNITS"
set xlabel "Time (seconds)"
set key inside
set format y "%.2f"
plot '$READ' using 3:6 with lines title "Read", '$WRITE' using 3:6 with lines title "Write",'$TOTAL' using 3:6 with lines title 'Total'
reset
set grid
set output "/tmp/io_per_second.png"
set datafile separator ','
set term png small size 1200,600 truecolor
set title "Number of operations in flight per second"
set ylabel "Average number of operations in flight per second"
set xlabel "Time (seconds)"
set key inside
set format y "%.2f"
plot '$READ' using 3:8 with lines title "Read", '$WRITE' using 3:8 with lines title "Write",'$TOTAL' using 3:8 with lines title 'Total'
EOT
gnuplot $PLOT
rm -f  $PLOT $READ $WRITE $SEEKREAD $TOTAL
