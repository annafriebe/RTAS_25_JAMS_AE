#!/bin/bash

sudo ./setup.sh
sudo ./rtqueue -j 100 -c file:MPC_times/MPC_long_10/saved_times_long_0.csv,col=1,unit=s -t 2 -a 1 -dr 48ms -dp 80ms -p 80ms -d 480ms -% 0.217702s -s 1731194488 -ft -o -dlp proc > log-proc.txt
sudo ./rtqueue -j 100 -c file:MPC_times/MPC_long_10/saved_times_long_0.csv,col=1,unit=s -t 2 -a 1 -dr 48ms -dp 80ms -p 80ms -d 480ms -% 0.217702s -s 1731194488 -ft -o -dlp kmod > log-kmod.txt
sudo ./teardown.sh

echo ""
echo "Average pop() duration when parsing /proc/self/sched:" $(cat log-proc.txt | grep pop_elapsed_ns | cut -d' ' -f5 | awk '{ acc += $1 } END { print acc / NR }') ns
echo "Average pop() duration when reading /dev/dlparams   :" $(cat log-kmod.txt | grep pop_elapsed_ns | cut -d' ' -f5 | awk '{ acc += $1 } END { print acc / NR }') ns
echo ""
echo "Average push() duration:" $(cat log-proc.txt log-kmod.txt | grep push_elapsed_ns | cut -d' ' -f5 | awk '{ acc += $1 } END { print acc / NR }') ns
echo ""
