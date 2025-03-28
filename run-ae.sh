#!/bin/bash

scriptdir=$(dirname $0)

echo "Installing Linux build essentials..."
sudo apt-get install build-essential flex bison

echo "Installing gnuplot and awk..."
sudo apt-get install gnuplot gawk

echo "Installing Linux headers needed to compile kernel modules..."
sudo apt-get install linux-headers-`uname -r`

echo "Compiling dlparams module..."
cd $scriptdir/kmod
make
echo "Inserting dlparams module..."
sudo insmod dlparams.ko
cd -

echo "Compiling JAMS..."
cd $scriptdir
make
cd -

export njobs=${njobs:-1000}
echo "Running JAMS experiments ($njobs jobs per run)..."
$scriptdir/run-all-new.sh

echo "Processing obtained data..."

$scriptdir/process-all.sh

echo "Drawing figures..."

echo "Plotting preliminary figures..."

$scriptdir/draw-exec-times-cdf.gp
mv exec-times-long-cdf.pdf fig5-top.pdf
mv exec-times-short-cdf.pdf fig5-bottom.pdf

echo "Fig.5 (top) has been obtained as: fig5-top.pdf"
echo "Fig.5 (bottom) has been obtained as: fig5-bottom.pdf"

$scriptdir/draw-exec-times-lognorm-cdf.gp
mv exec-times-lognorm-cdf.pdf fig6.pdf
echo "Fig.6 has been obtained as: fig6.pdf"

$scriptdir/draw-missed-dismissed.gp
mv mpc-long-missed-dismissed-60.pdf fig7-top.pdf
mv mpc-long-missed-dismissed-70.pdf fig7-middle.pdf
mv mpc-short-missed-dismissed-40.pdf fig7-bottom.pdf
echo "Fig.7 (top) has been obtained as: fig7-top.pdf"
echo "Fig.7 (middle) has been obtained as: fig7-middle.pdf"
echo "Fig.7 (bottom) has been obtained as: fig7-bottom.pdf"

$scriptdir/draw-misses.gp
mv misses.pdf fig8.pdf
echo "Fig.8 has been obtained as: fig8.pdf"

$scriptdir/draw-missed-dismissed-load.gp
mv mpc-long-missed-dismissed-load-60.pdf fig9.pdf
echo "Fig.9 has been obtained as: fig9.pdf"

$scriptdir/draw-missed-dismissed-lognorm.gp
mv lognorm-missed-dismissed-30.pdf fig10.pdf
echo "Fig.10 has been obtained as: fig10.pdf"
