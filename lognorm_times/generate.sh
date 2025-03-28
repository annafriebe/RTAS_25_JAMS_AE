#!/bin/bash

echo -n "" > lognorm_5000.dat
for ((i=0; i<10; i++)); do
    avg=$[ 40 + $RANDOM * 20 / 32768 ]
    std=$[ 30 + $RANDOM * 10 / 32768 ]
    ./distwalk/src/test_distrib -n 5000 -d lognorm:0.0$avg,std=0.0$std,min=0.010,max=0.150 | awk '{ OFS=","; print l++, $1; }' > lognorm_5000_$i.csv
    real_avg=$(cut -d, -f2 lognorm_5000_$i.csv | awk '{ acc += $1; } END { print acc / NR; }')
    real_dev=$(cut -d, -f2 lognorm_5000_$i.csv | awk '{ acc += ($1 - '$real_avg')^2; } END { print sqrt(acc / NR); }')
    echo $avg $std $real_avg $real_dev >> lognorm_5000.dat
    sleep 1
done

echo -n "" > lnorm_5000.dat
for ((i=0; i<1; i++)); do
    avg=$[ 40 + $RANDOM * 20 / 32768 ]
    std=$[ 30 + $RANDOM * 10 / 32768 ]
    ./distwalk/src/test_distrib -n 5000 -d lognorm:0.0$avg,std=0.0$std,min=0.010,max=0.150 | awk '{ OFS=","; print l++, $1; }' > lnorm_5000_$i.csv
    real_avg=$(cut -d, -f2 lnorm_5000_$i.csv | awk '{ acc += $1; } END { print acc / NR; }')
    real_dev=$(cut -d, -f2 lnorm_5000_$i.csv | awk '{ acc += ($1 - '$real_avg')^2; } END { print sqrt(acc / NR); }')
    echo $avg $std $real_avg $real_dev >> lnorm_5000.dat
    sleep 1
done
