#!/bin/bash

# author: Tommaso Cucinotta <tommaso.cucinotta@santannapisa.it>

for sf in /sys/kernel/debug/sched_features /sys/kernel/debug/sched/features; do
    if [ -f $sf ]; then
        echo NO_HRTICK > $sf
        break;
    fi
done

if [ -f /sys/devices/system/cpu/cpufreq/boost ]; then
    echo 1 > /sys/devices/system/cpu/cpufreq/boost
fi

if [ -d /sys/devices/system/cpu/intel_pstate ]; then
    if [ -e /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
        echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo
    fi
    if [ -e /sys/devices/system/cpu/intel_pstate/max_perf_pct ]; then
        echo 100 > /sys/devices/system/cpu/intel_pstate/max_perf_pct
        echo 0 > /sys/devices/system/cpu/intel_pstate/min_perf_pct
    fi

    grep "" /sys/devices/system/cpu/intel_pstate/*
fi

if [ -d /sys/devices/system/cpu/cpufreq ]; then
    for p in $(ls -d /sys/devices/system/cpu/cpufreq/policy[0-9]*); do
        echo powersave > $p/scaling_governor
        if [ -e $p/scaling_max_freq ]; then
            cat $p/cpuinfo_max_freq > $p/scaling_max_freq
            cat $p/cpuinfo_min_freq > $p/scaling_min_freq
        fi
        if [ -e $p/energy_performance_preference ]; then
	    echo balance_performance > $p/energy_performance_preference
        fi
    done
fi

for c in $(ls -d /sys/devices/system/cpu/cpu[0-9]*); do
    if [ -e $c/power/energy_perf_bias ]; then
	echo normal > $c/power/energy_perf_bias
    fi
    if [ -f $c/power/pm_qos_resume_latency_us ]; then
	echo 0 > $c/power/pm_qos_resume_latency_us
    fi
done

cd /sys/devices/system/cpu/

echo "#CPU scaling_governor scaling_cur_freq energy_perf_pref energy_perf_bias resume_latency"
for c in $(ls -d cpu[0-9]*); do
    echo $c $(cat $c/cpufreq/scaling_governor) $(cat $c/cpufreq/scaling_cur_freq) $(cat $c/cpufreq/energy_performance_preference 2> /dev/null) $(cat $c/power/energy_perf_bias 2> /dev/null)  $(cat $c/power/pm_qos_resume_latency_us 2> /dev/null)
done
