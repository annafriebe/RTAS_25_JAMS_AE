#!/bin/bash

scriptdir=$(dirname $0)

# 3 x 5% DL tasks on each CPU with CGROUP worker threads
start_load() {
    sudo taskset -c 2 chrt -d --sched-runtime $[3000*1000] --sched-deadline $[60000*1000] --sched-period $[60000*1000] 0 $scriptdir/hog &
    sudo taskset -c 2 chrt -d --sched-runtime $[5000*1000] --sched-deadline $[100000*1000] --sched-period $[100000*1000] 0 $scriptdir/hog &
    sudo taskset -c 2 chrt -d --sched-runtime $[7000*1000] --sched-deadline $[140000*1000] --sched-period $[140000*1000] 0 $scriptdir/hog &
    sudo taskset -c 3 chrt -d --sched-runtime $[3000*1000] --sched-deadline $[60000*1000] --sched-period $[60000*1000] 0 $scriptdir/hog &
    sudo taskset -c 2 chrt -d --sched-runtime $[5000*1000] --sched-deadline $[100000*1000] --sched-period $[100000*1000] 0 $scriptdir/hog &
    sudo taskset -c 3 chrt -d --sched-runtime $[7000*1000] --sched-deadline $[140000*1000] --sched-period $[140000*1000] 0 $scriptdir/hog &
}

stop_load() {
    pids=$(pidof hog)
    if [ "$pids" != "" ]; then
        sudo kill $pids
    fi
}

#seed=$RANDOM

#trace=MPC_times/MPC_long_10/saved_times_long_0.csv
trace=${trace:-$scriptdir/MPC_times/MPC_short_10/saved_times_short_0.csv}
perc=${perc:-$(cat $trace | cut -d, -f2 | sort -n | head -$[ 1 + ( $(cat $trace | wc -l) - 1 ) * 95 / 100 ] | tail -1 | sed -e 's/\r//')}
wcet=${wcet:-$(cat $trace | cut -d, -f2 | sort -n | tail -1 | sed -e 's/\r//')}
njobs=${njobs:-$(cat $trace | wc -l)}
threads=${threads:-2}

if [ "$prob" == "1" ]; then
    opts="$opts -pd-wcet ${wcet}s"
fi

echo "trace=$trace"
echo "perc=$perc"
echo "opts=$opts"
echo "njobs=$njobs"
echo "threads=$threads"
echo "prob=$prob"
echo "load=$load"
echo "outprefix=$outprefix"

echo kernel: $(uname -a)
echo cmdline: $(cat /proc/cmdline)
echo os-release: $(cat /etc/os-release)
echo cpu/isolated: $(cat /sys/devices/system/cpu/isolated)

sudo sysctl kernel.sched_rt_runtime_us=-1

sudo $scriptdir/setup.sh

for P in 80; do
    if [ "$BWS" == "" ]; then
        if echo $trace | grep long; then
            BWS="60 70";
        elif echo $trace | grep lognorm; then
            BWS="30"
        else # short
            BWS="40"
        fi
    fi
    for BW in $BWS; do
        Q=$[$P * $BW / 100]
        file=${outprefix}log-t$threads-P$P-BW$BW.txt
        if [ -f $file -a -s $file ]; then
            echo "Skipping $file...";
        else
            U=$BW
            stop_load
            if [ "$load" == "1" ]; then
                start_load
                U=$[$U+15]
            fi
            echo "Running: sudo $scriptdir/rtqueue -j $njobs -c file:$trace,col=1,unit=s -t $threads -a 1 -dr ${Q}ms -dp ${P}ms -p 80ms -d 480ms -% ${perc}s $opts > $file"
            sudo $scriptdir/rtqueue -j $njobs -c file:$trace,col=1,unit=s -t $threads -a 1 -dr ${Q}ms -dp ${P}ms -p 80ms -d 480ms -% ${perc}s -u 0.$U $opts > $file
            stop_load
        fi
    done
done

sudo $scriptdir/teardown.sh

sudo sysctl kernel.sched_rt_runtime_us=950000
