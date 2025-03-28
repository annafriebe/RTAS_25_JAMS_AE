#!/usr/bin/gnuplot

dir=system("dirname ".ARG0)

set terminal pdf color

set grid

set xlabel "Missed jobs (%)"
set ylabel "Dismissed jobs (%)"
set key bottom right

f(x) = (x == 0 ? -1.5 : log(x)/log(10))
g(x) = (x == 0 ? -0.5 : log(x)/log(10))

set arrow from f(5),g(0) to f(5),g(100) nohead lc rgb "dark-green" dt 2
set arrow from f(10),g(0) to f(10),g(100) nohead lc rgb "dark-blue" dt 2
set arrow from f(15),g(0) to f(15),g(100) nohead lc rgb "brown" dt 2

set xtics ("0" f(0), "0.10" f(0.10), "0.20" f(0.20), "0.5" f(0.5), "1" f(1), "2" f(2), "5" f(5), "10" f(10), "20" f(20), "50" f(50), "100" f(100))
set ytics ("0" g(0), "1" g(1), "2" g(2), "5" g(5), "10" g(10), "20" g(20), "50" g(50), "100" g(100))

set label "//" at f(0.05),g(0)
set label "--" at f(0)-0.030,g(0.5)
set label "--" at f(0)-0.030,g(0.5)+0.04

set xrange [f(0):f(100)]
set yrange [g(0):g(100)]

do for [ bw in "60 70" ] {
set output 'mpc-long-missed-dismissed-load-'.bw.'.pdf'
set title 'MPC heavy traces, 2x'.bw.'% bandwidth'

plot \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "long.* p0load [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'No dismissal' w circles fillstyle transparent solid 0.5 noborder, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "long.* percuft95load [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))+0.02):(g(column("dismissedp"))+0.02):(0.03) t 'Static 95th percentile' w p lc "dark-green" pt 1, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "long.* ep0.95uftload [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))+0.02):(g(column("dismissedp"))+0.02):(0.03) t 'Dynamic 95th percentile' w p lc "dark-green" pt 2, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "long.* percuft90load [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))-0.02):(g(column("dismissedp"))-0.02):(0.03) t 'Static 90th percentile' w p lc "dark-blue" pt 1, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "long.* ep0.90uftload [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))-0.02):(g(column("dismissedp"))-0.02):(0.03) t 'Dynamic 90th percentile' w p lc "dark-blue" pt 2, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "long.* percuft85load [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'Static 85th percentile' w p lc "brown" pt 1, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "long.* ep0.85uftload [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'Dynamic 85th percentile' w p lc "brown" pt 2
}

do for [ bw in "40" ] {
set output 'mpc-short-missed-dismissed-load-'.bw.'.pdf'
set title 'MPC light traces, 2x'.bw.'% bandwidth'

plot \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "short.* p0load [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'No dismissal' w circles fillstyle transparent solid 0.5 noborder, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "short.* percuft95load [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'Dismissal with static 95th percentile' w circles fillstyle transparent solid 0.5 noborder, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "short.* ep0.95uftload [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'Dismissal with dynamic 95th percentile' w circles fillstyle transparent solid 0.5 noborder
}
