#!/usr/bin/gnuplot

dir=system("dirname ".ARG0)

set terminal pdf color

set grid

set xlabel "Missed jobs (%)"
set ylabel "Dismissed jobs (%)"
set key bottom left

#f(x) = (x == 0 ? -2.5 : log(x)/log(10))
f(x) = (x == 0 ? -1.5 : log(x)/log(10))
g(x) = (x == 0 ? -0.5 : log(x)/log(10))

#set xtics ("0" f(0), "0.01" f(0.03), "0.02" f(0.02), "0.05" f(0.05), "0.10" f(0.10), "0.20" f(0.20), "0.5" f(0.5), "1" f(1), "2" f(2), "5" f(5), "10" f(10), "20" f(20), "50" f(50), "100" f(100))
#set ytics ("0" f(0), "0.01" f(0.03), "0.02" f(0.02), "0.05" f(0.05), "0.10" f(0.10), "0.20" f(0.20), "0.5" f(0.5), "1" f(1), "2" f(2), "5" f(5), "10" f(10), "20" f(20), "50" f(50), "100" f(100))
set xtics ("0" f(0), "0.10" f(0.10), "0.20" f(0.20), "0.5" f(0.5), "1" f(1), "2" f(2), "5" f(5), "10" f(10), "20" f(20), "50" f(50), "100" f(100))
set ytics ("0" g(0), "1" g(1), "2" g(2), "5" g(5), "10" g(10), "20" g(20), "50" g(50), "100" g(100))

set label "//" at f(0.05),g(0)
set label "--" at f(0)-0.030,g(0.5)
set label "--" at f(0)-0.030,g(0.5)+0.04

set xrange [f(0):f(100)]
set yrange [g(0):g(20)]

do for [ bw in "60 70" ] {
set output 'mpc-long-missed-dismissed-'.bw.'.pdf'
set title 'MPC heavy traces, 2x'.bw.'% bandwidth'

set arrow 1 from f(5),g(0) to f(5),g(20) nohead lc rgb "dark-green" dt 2
set arrow 2 from f(10),g(0) to f(10),g(20) nohead lc rgb "dark-blue" dt 2
set arrow 3 from f(15),g(0) to f(15),g(20) nohead lc rgb "brown" dt 2

plot \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "long.* p0 [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'No dismissal' w circles fillstyle transparent solid 0.5 noborder, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "long.* percuft95 [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'Static 95th percentile' w p ps 1 lc "dark-green" pt 1, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "long.* ep0.95uft [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'Dynamic 95th percentile' w p ps 1 lc "dark-green" pt 2, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "long.* percuft90 [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'Static 90th percentile' w p ps 1 lc "dark-blue" pt 1, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "long.* ep0.90uft [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'Dynamic 90th percentile' w p ps 1 lc "dark-blue" pt 2, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "long.* percuft85 [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(f(column("dismissedp"))):(0.03) t 'Static 85th percentile' w p ps 1 lc "brown" pt 1, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "long.* ep0.85uft [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(f(column("dismissedp"))):(0.03) t 'Dynamic 85th percentile' w p ps 1 lc "brown" pt 2

}

do for [ bw in "40" ] {
set output 'mpc-short-missed-dismissed-'.bw.'.pdf'
set title 'MPC light traces, 2x'.bw.'% bandwidth'

set xrange [f(0):f(20)]
set yrange [g(0):g(5)]
set key bottom left

set arrow 1 from f(5),g(0) to f(5),g(5) nohead lc rgb "dark-green" dt 2
set arrow 2 from f(10),g(0) to f(10),g(5) nohead lc rgb "dark-blue" dt 2
set arrow 3 from f(15),g(0) to f(15),g(5) nohead lc rgb "brown" dt 2

plot \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "short.* p0 [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'No dismissal' w circles fillstyle transparent solid 0.6 noborder, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "short.* percuft95 [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'Static 95th percentile' w p lc "dark-green" pt 1, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "short.* ep0.95uft [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'Dynamic 95th percentile' w p lc "dark-green" pt 2, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "short.* percuft90 [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'Static 90th percentile' w p lc "dark-blue" pt 1, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "short.* ep0.90uft [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'Dynamic 90th percentile' w p lc "dark-blue" pt 2, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "short.* percuft85 [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'Static 85th percentile' w p lc "brown" pt 1, \
     '< cat run-all.dat | sed -e "s/^#//" | '.dir.'/kfl grep "short.* ep0.85uft [0-9] '.bw.' "' u (f(column("missedp")*100/column("processedp"))):(g(column("dismissedp"))):(0.03) t 'Dynamic 85th percentile' w p lc "brown" pt 2
}
