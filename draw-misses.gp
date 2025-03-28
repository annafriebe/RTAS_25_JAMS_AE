#!/usr/bin/gnuplot

dir=system("dirname ".ARG0)

set terminal pdf color crop
set output 'misses.pdf'
set xlabel 'Job Id'
set ylabel 'Job response time (ms)'
set grid

#set size 1,0.5

plot [0:1000] \
     '< cut -d, -f2 '.dir.'/MPC_times/MPC_short_10/saved_times_short_0.csv' u ($1*1000) t 'short trace 0 exec times' w l lc "gray60", \
     'run-all-short-p0-0/log-t2-P80-BW40.txt' u 2:($8/1000) t 'short trace 0, baseline' w p ps 0.1 lc "blue", \
     'run-all-short-percuft95-0/log-t2-P80-BW40.txt' u 2:($8/1000) t 'short trace 0, JAMS' w p ps 0.1 lc "green", \
     '' u 2:($8 == 0 ? 0 : 1.0/0) t 'short trace 0, JAMS dismissals' w p ps 0.6 lc "dark-red" pt 2, \
     480 t 'deadline' w l dt 7 lc "dark-red"
