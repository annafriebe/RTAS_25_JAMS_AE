#!/usr/bin/gnuplot

dir=system("dirname ".ARG0)

set terminal pdf enhanced color
set output 'exec-times-lognorm-cdf.pdf'

set xtics 20
set ytics 0.05
set grid

set xlabel 'Execution time (ms)'
set ylabel 'Cumulative probability'
set key bottom right

# uncropped avg, dev, then real avg, dev; here, we take real values
means=system('echo $(cut -d" " -f3 lognorm_times/lognorm_5000.dat)')
stds=system('echo $(cut -d" " -f4 lognorm_times/lognorm_5000.dat)')
# uncropped avg, dev, then real avg, dev; here, we take uncropped values
lmeans=system('echo $(cut -d" " -f1 lognorm_times/lnorm_5000.dat)')
lstds=system('echo $(cut -d" " -f2 lognorm_times/lnorm_5000.dat)')

plot \
     for [ i=0:9 ] '< cut -d, -f2 '.dir.'/lognorm_times/lognorm_5000_'.i.'.csv | sort -n' u ($1*1000):($0/5000) t 'lognorm '.i.' ({/symbol m}='.round(real(word(means,i+1))*1000).'ms, {/symbol s}='.round(real(word(stds,i+1))*1000).'ms)' w l lw 1, '< cut -d, -f2 '.dir.'/lognorm_times/lnorm_5000_0.csv | sort -n' u ($1*1000):($0/5000) t 'lnorm ({/symbol m}='.round(real(word(lmeans,1))*1000).'ms, {/symbol s}='.round(real(word(lstds,1))*1000).'ms)' w l lw 1 dt 2
