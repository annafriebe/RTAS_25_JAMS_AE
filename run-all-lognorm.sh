#!/bin/bash

scriptdir=$(dirname $0)

rm -f log-*.txt run-log.txt

sleep_secs=0

type=lognorm
for ((i=0; i<10; i++)); do
    seed=$[ 1731194488 + $i ]

    dir=run-all-${type}-p0-$i
    mkdir -p $dir
    opts="-s $seed" perc=0 trace=$scriptdir/lognorm_times/lognorm_5000_$i.csv outprefix=$dir/ $scriptdir/run.sh | tee -a $dir/run-log.txt
    cp $scriptdir/run.sh $dir

    sleep $sleep_secs

    for phi in 95 90 85; do
        dir=run-all-${type}-percuft${phi}-$i
        mkdir -p $dir
        export trace=$scriptdir/lognorm_times/lognorm_5000_$i.csv
        export perc=$(cat $trace | cut -d, -f2 | sort -n | head -$[ 1 + ( $(cat $trace | wc -l) - 1 ) * ${phi} / 100 ] | tail -1 | sed -e 's/\r//')
        opts="-s $seed -ft" outprefix=$dir/ $scriptdir/run.sh | tee -a $dir/run-log.txt
        cp $scriptdir/run.sh $dir

        sleep $sleep_secs

        dir=run-all-${type}-ep0.${phi}uft-$i
        mkdir -p $dir
        export trace=$scriptdir/lognorm_times/lognorm_5000_$i.csv
        export perc=$(cat $trace | cut -d, -f2 | sort -n | head -$[ 1 + ( $(cat $trace | wc -l) - 1 ) * ${phi} / 100 ] | tail -1 | sed -e 's/\r//')
        opts="-ep 0.${phi} -s $seed -ft" outprefix=$dir/ $scriptdir/run.sh | tee -a $dir/run-log.txt
        cp $scriptdir/run.sh $dir

        sleep $sleep_secs
    done
done
