#!/bin/bash

njobs=${njobs:-5000}

echo "#type method id bw ok okp processed processedp missed missedp dismissed dismissedp nonpushed nonpushedp" > run-all.dat;
for f in run-all*/log-*.txt; do
    echo $f $(grep "elapsed_us" $f | awk '{ if ($8 > 0 && $8 <= 480000) { print $0; } }' | wc -l | awk '{ print $1,$1*100/'$njobs'; }') $(grep "elapsed_us" $f | awk '{ if ($8 > 0) { print $0; } }' | wc -l | awk '{ print $1,$1*100/'$njobs'; }') $(grep "elapsed_us" $f | awk '{ if ($8 > 480000) { print $0; } }' | wc -l | awk '{ print $1,$1*100/'$njobs'; }') $(grep "elapsed_us 0" $f | wc -l | awk '{ print $1,$1*100/'$njobs'; }') $(grep "elapsed_us -1" $f | wc -l | awk '{ print $1,$1*100/'$njobs'; }'); done | sed -e 's/run-all-//; s/\(long\|short\|lnorm\|lognorm\)-/\1 /; s#-\([0-9]\+\)/log-.*BW# \1 #; s/\.txt//' >> run-all.dat
