#!/usr/bin/gnuplot

dir=system("dirname ".ARG0)

set terminal pdf color
set output 'exec-times-cdf.pdf'

set xtics 20
set ytics 0.05
set grid

set xlabel 'Execution time (ms)'
set ylabel 'Cumulative probability'
set key bottom right

set format y "%.2f"

#for f in MPC_times/MPC_long_10/saved_times_long_*.csv; do echo $(printf "%.3f " $(cat $f | cut -d, -f2 | datastat -nh) | sed -e 's/0\.0//g'); done | tr "\n" " "
lmeans="86 87 88 82 85 81 86 80 84 84"
#for f in MPC_times/MPC_long_10/saved_times_long_*.csv; do echo $(printf "%.3f " $(cat $f | cut -d, -f2 | datastat --dev -na -nh) | sed -e 's/0\.0//g'); done | tr "\n" " "
lstds="52 54 54 49 53 48 52 49 52 51"

#for f in MPC_times/MPC_short_10/saved_times_short_*.csv; do echo $(printf "%.3f " $(cat $f | cut -d, -f2 | datastat -nh) | sed -e 's/0\.0//g'); done | tr "\n" " "
smeans="56 57 56 55 56 55 55 55 54 55"
#for f in MPC_times/MPC_short_10/saved_times_short_*.csv; do echo $(printf "%.3f " $(cat $f | cut -d, -f2 | datastat --dev -na -nh) | sed -e 's/0\.0//g'); done | tr "\n" " "
sstds="23 22 22 20 23 22 22 21 19 21"

plot \
     for [ i=0:9 ] '< cut -d, -f2 '.dir.'/MPC_times/MPC_long_10/saved_times_long_'.i.'.csv | sort -n' u ($1*1000):($0/5000) t 'heavy '.i.' ({/symbol m}='.word(lmeans,i+1).'ms, {/symbol s}='.word(lstds,i+1).'ms)' w l lw 2, \
     for [ i=0:9 ] '< cut -d, -f2 '.dir.'/MPC_times/MPC_short_10/saved_times_short_'.i.'.csv | sort -n' u ($1*1000):($0/5000) t 'light '.i.' ({/symbol m}='.word(smeans,i+1).'ms, {/symbol s}='.word(sstds,i+1).'ms)' w l lw 2

set output 'exec-times-long-cdf.pdf'
plot \
     for [ i=0:9 ] '< cut -d, -f2 '.dir.'/MPC_times/MPC_long_10/saved_times_long_'.i.'.csv | sort -n' u ($1*1000):($0/5000) t 'heavy '.i.' ({/symbol m}='.word(lmeans,i+1).'ms, {/symbol s}='.word(lstds,i+1).'ms)' w l lw 2

set output 'exec-times-short-cdf.pdf'
plot \
     for [ i=0:9 ] '< cut -d, -f2 '.dir.'/MPC_times/MPC_short_10/saved_times_short_'.i.'.csv | sort -n' u ($1*1000):($0/5000) t 'light '.i.' ({/symbol m}='.word(smeans,i+1).'ms, {/symbol s}='.word(sstds,i+1).'ms)' w l lw 2
