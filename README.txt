ARTIFACT EVALUATION FOR THE PAPER ON

  "Nip It In the Bud: Job Acceptance Multi-Server"


DESCRIPTION

This is the Artifact Evaluation companion repository, allowing for
compiling all the software needed for reproducing all the experimental
results described in the paper on a Linux platform. This includes:

-) rtqueue: a C program implementing the JAMS concept
-) kmod/dlparams.ko: a kernel module to be loaded into the kernel before running rtqueue
-) *.sh: a set of BaSH scripts that are used to automate the run of the experiments
  run-ae.sh: this is the particular script that performs everything automatically
  (see below for a detailed step-by-step explanation of what's being done)
-) *.gp: a set of Gnuplot scripts that are used to draw the figures you find in the paper


HW PLATFORM REQUIREMENTS

You need ideally to run the following on a Raspberry PI4 Model B
(RPI4), which is where all experiments described in the paper have
been run.  Running this on a different Raspberry PI model (e.g., RPI3
or RPI5) might lead to slightly different results, albeit compatible
in terms of general conclusions.  The automated scripts below are
based on a Ubuntu 22.04 server distribution for the RPI4, and we
recommend using the same distribution.


OS SET-UP

The instructions below assume you're logged onto a Raspberry PI
device, using an account that can sudo. Some of the scripts you'll
launch, contain commands prefixed with sudo, so you may want to
configure an account with passwordless sudo on the RPI4, in order to
allow for a seamless and automated execution of the scripts below.

The experiments have been run on a platform with isolated CPUs from 1
to 3, this is achievable by adding the isolcpus=1-3 to the boot
command-line in /boot/firmware/cmdline.txt, then rebooting the platform.

Also, the RPI4 needs to be configured in multi-user target mode, to
avoid starting unnecessarily the GUI, which would interfere with the
experiments.  This is done by issuing as root the command:

  sudo systemctl set-default multi-user.target

You can perform the above 2 steps by hand, or try using the bootconfig.sh script:

  sudo ./bootconfig.sh
  sudo reboot

After reboot, you can verify CPUs 1-3 are isolated through

  cat /sys/devices/system/cpu/isolated 
  1-3


SOFTWARE SET-UP

For a new system, install:
sudo apt install build-essential
sudo apt install flex
sudo apt install bison


You can now run the script:

  ./run-ae.sh

or just follow manually the steps below.


DEPENDENCIES INSTALLATION

Install the needed dependencies:

  sudo apt-get install linux-headers-`uname -r`

To perform the post-processing (on the RPI4 or elsewhere), you'll also need:

  sudo apt-get install gnuplot gawk


COMPILE KERNEL MODULE

Just type 'make' from within the kmod/ subfolder.
You should NOT be root to compile the module.

  cd kmod
  make

Now you can insert the just compiled module, and you have to be root for this:

  sudo insmod dlparams.ko
  cd ..

double-check the module is loaded with lsmod:

  lsmod | grep dlparams
  dlparams               20480  0

To compile the rtqueue implementation of JAMS, just type

   make


PLOT THE PRELIMINARY CDF FIGURES IN THE PAPER

This AE includes the entire data-set used for the experimentation in
the paper, as well as scripts that can be used to re-generate the
data. If you just want to reproduce the results we have in the paper,
we advise you to reuse the same data-set.

You can generate the plots of the distributions in Figures 5 and 6 in
the paper as follows.

Figure 5:
  ./draw-exec-times-cdf.gp
  mv exec-times-long-cdf.pdf fig5-top.pdf
  mv exec-times-short-cdf.pdf fig5-bottom.pdf

Figure 5 (top) is obtained as: fig5-top.pdf
Figure 5 (bottom) is obtained as: fig5-bottom.pdf

Figure 6:
  ./draw-exec-times-lognorm-cdf.gp
  mv exec-times-lognorm-cdf.pdf fig6.pdf

Figure 6 is obtained as: fig6.pdf


RUNNING EXPERIMENTS

We prepared a fast experimentation mode, which can be enabled with

  export njobs=1000

this limits the following scripts to perform only 1000 jobs per run,
rather than the full 5K jobs we performed for the results in the paper,
requiring nearly 16 hours to complete. If you just skip the line above,
then you run the full runs over 5K jobs, requiring nearly 3 days to complete.

WARNING: running the experiments with a lower njobs value than 5000, leads
to runs with less critical saturation scenarios, requiring fewer job dismissals.
This means the final plots might be different from those in the paper, albeit
the general conclusions are still the same. However, running the experiments with
too low njobs (such as njobs=100), leads to experiments with very few or even no
deadline misses, where job dismissals doesn't even kick-in, so this might get to
results that seem quite different from those in the paper.

Perform the runs with the MPC and synthetic lognormal workloads:

  ./run-all-new.sh


MONITORING THE PROGRESS AND PRODUCING PARTIAL PLOTS

While running the above run-*.sh scripts, you'll see outputs like:

Running: sudo ../rtqueue -j 1000 -c file:../../paper-job-dismissal/{lognorm,MPC}_times/{lognorm,long,short}_5000_6.csv,col=1,unit=s -t 2 -a 1 -dr 24ms -dp 80ms -p 80ms -d 480ms -% 0.0678645s -s 1731194497 -ft > run-all-{lognorm,long,short}-percuft85-6/log-t2-P80-BW30.txt
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...

The % progress is relative to a single run, however several runs need
to be completed. Moreover, for each trace file configuration (MPC
long, MPC short, lognorm), 10 iterations are repeated, with different
trace files. Each iteration begins when you see a line like:

  ========== ITERATION n ==========

Ideally, all the 10 iterations should be completed. However, you can
simply run all of the post-processing and plotting commands below
while the experiment is running, in order to gather a preliminary set
of results and partial plots. However, do this after at least 3 or 5
iterations completed, because each iteration corresponds to a single
dot/marker in the procued output figures, as visible in the paper
(all 10 iterations result in the plots in the paper with 10 markers
per configuration).


DATA POST-PROCESSING

The following steps can be performed on the RPI4 as well, or on a
Linux laptop, if preferred (in such case, you need to copy all the
obtained run-*/ figures from the RPI4 to the folder where you unpacked
the rtas25ae.tgz archive on the PC).

Process all data gathered in individual log-*-[0-9]/log-*.txt files, and
produce the main summary run-all.dat file:

  ./process-all.sh

Verify the summary file has been produced:

  head run-all.dat 
  #type method id bw ok okp processed processedp missed missedp dismissed dismissedp nonpushed nonpushedp
  lognorm ep0.85uft 0 30 4692 93.84 4795 95.9 103 2.06 205 4.1 0 0
  lognorm ep0.85uft 0 40 4998 99.96 4999 99.98 1 0.02 1 0.02 0 0
  lognorm ep0.85uft 1 30 4469 89.38 4610 92.2 141 2.82 390 7.8 0 0
  lognorm ep0.85uft 1 40 4998 99.96 5000 100 2 0.04 0 0 0 0
  ...


PLOT THE DEADLINE MISS / DISMISSAL RATE FIGURES

Reproducing Figure 7:
  ./draw-missed-dismissed.sh
  mv mpc-long-missed-dismissed-60.pdf fig7-top.pdf
  mv mpc-long-missed-dismissed-70.pdf fig7-middle.pdf
  mv mpc-short-missed-dismissed-40.pdf fig7-bottom.pdf

Figure 7 (top) has been obtained as: fig7-top.pdf
Figure 7 (middle) has been obtained as: fig7-middle.pdf
Figure 7 (bottom) has been obtained as: fig7-bottom.pdf

Reproducing Figure 8:
  ./draw-misses.gp
  mv misses.pdf fig8.pdf

Figure 8 has been obtained as: fig8.pdf

Reproducing Figure 9:
  ./draw-missed-dismissed-load.sh
  mv mpc-long-missed-dismissed-load-60.pdf fig9.pdf

Figure 9 has been obtained as: fig9.pdf

Reproducing Figure 10:

  ./draw-missed-dismissed-lognorm.sh
  mv lognorm-missed-dismissed-30.pdf fig10.pdf

Figure 10 has been obtained as: fig10.pdf


VALIDATION OF OBTAINED RESULTS

You can verify that the obtained experimental figures, from Figure 5
to Figure 10, are all similar to those included in the paper. If you
launched the scripts with a reduced number of jobs, say 1000 instead
of 5000, then you might have obtained lower values of the dismissal
rates (on the Y axis) in Figures 7, 9 and 10. However, the deadline
misses (on the X axis) should still be well-aligned with our expected
results, namely dots/markers that are green, blue and red should be
located on the plots on the left of the configured deadline-miss
ratios of 5%, 10% and 15%, respectively, in Figures 7, 9 and 10.

If you're preprocessing the data and plotting the figures while the
experiment is still running, then you're going to see on the plots
fewer points than the full 10 markers that should be there at the
end of all the scripts (e.g., if you stopped after iteration 4
completed, then in Figures 7, 9 and 10 you'll see only 4 markers
for each configuration, instead of the 10 we have in the paper.


OVERHEADS REDUCTION DUE TO KERNEL MODULE

You can verify the experimental results in Sections VI.B and VI.C,
about the reduction of the overheads for reading the current runtime
and leftover SCHED_DEADLINE parameters, using the provided kernel
module. This is easily done by exploiting an overhead measurement
feature that can be enabled in rtqueue with the option -o, coupled
with the -dlp {proc,kmod} option that allows for choosing between
parsing /proc/self/sched entries vs using the /dev/dlparams special
device provided by our kernel module.

For example, you can run just 100 jobs from any of the traces
(after locking CPU frequency switching using setup.sh):

  sudo ./setup.sh
  sudo ./rtqueue -j 100 -c file:MPC_times/MPC_long_10/saved_times_long_0.csv,col=1,unit=s -t 2 -a 1 -dr 48ms -dp 80ms -p 80ms -d 480ms -% 0.217702s -s 1731194488 -ft -o -dlp proc > log-proc.txt
  sudo ./rtqueue -j 100 -c file:MPC_times/MPC_long_10/saved_times_long_0.csv,col=1,unit=s -t 2 -a 1 -dr 48ms -dp 80ms -p 80ms -d 480ms -% 0.217702s -s 1731194488 -ft -o -dlp kmod > log-kmod.txt
  sudo ./teardown.sh

Then compare the average duration of pop() and push() operations obtained in the logs:

  cat log-proc.txt | grep pop_elapsed_ns | cut -d' ' -f5 | awk '{ acc += $1 } END { print acc / NR }'
  cat log-kmod.txt | grep pop_elapsed_ns | cut -d' ' -f5 | awk '{ acc += $1 } END { print acc / NR }'
  cat log-proc.txt log-kmod.txt | grep push_elapsed_ns | cut -d' ' -f5 | awk '{ acc += $1 } END { print acc / NR }'

The above operations can be done automatically running the script:

  ./run-overheads.sh

It is evident that the kmod numbers are much smaller. The actual
numbers you obtain may differ from those in the paper, because these
are dependent on how many readings are performed, and under what
conditions. However, you'll see that generally the pull() duration
when using the kernel module are greatly reduced compared to when
parsing /proc/self/sched entries. In the same log files, you can also
see reported how expensive a push() operation is (the commands and
script above report its average as well).


DATA-SET RE-GENERATION (NOT NEEDED TO REPRODUCE THE PAPER OUTPUT)

For completeness, we report below the 2 steps needed to re-generate
the MPC and lognorm distributions, that need also to install
additional dependencies on the platform:

1) Regenerate the lognormal distributions:

  cd lognorm_times
  git clone https://github.com/tomcucinotta/distwalk.git
  cd distwalk
  make
  ./generate.sh
  cd ..

2) Regenerate the MPC distributions:
The MPC times used in the paper have been logged on a Raspberry Pi 3, 
with the PREEMPT_RT patch, as found at:

  https://github.com/kdoren/linux/releases/tag/rpi_5.15.40-rt43
  (the link also contains step-by-step instructions on how to install
  a precompiled PREEMPT_RT kernel, just make sure you reboot the new
  kernel then)

However, you may use a non-PREEMPT_RT kernel as well, but consider
your measured data will likely be slightly more noisy than the one we
used in the paper. Also, consider that regenrating the MPC
distributions on a different platform is likely to give different
results (scaled up/down).

You need to install a few dependencies needed to build libmpc:

  sudo apt install cmake
  sudo apt install python3

Download libmpc-0.6.2.tar.gz from https://github.com/nicolapiccinelli/libmpc/releases/tag/0.6.2
and put it in the mpc_run folder.
Now you can build libmpc with the edited logging and examples:

  cd mpc_run
  tar -xvzf libmpc-0.6.2.tar.gz
  cp -r libmpc_edit/include libmpc-0.6.2
  cp libmpc_edit/examples/* libmpc-0.6.2/examples
  cd libmpc-0.6.2
  sudo ./configure.sh --disable-test
  mkdir build
  cd build
  cmake ..
  make
  sudo make install
  cd ../examples
  cmake .
  make ugv_ex_long
  make ugv_ex_short

Run the MPC task and retrieve the computation times from the logs.
Note that the run_ugv_ex_10_XXX scripts disable USB interrupts, 
so the system is unresponsive during large parts of these runs.
The MPC task runs on CPU 2. In the experiments for the paper this was 
isolated through cpusets, but this is removed in the scripts below
since isolcpus is set above. 
  cd ../..
  mkdir ugv_ex_outputs
  sudo ./run_ugv_ex_10_short.sh
  sudo ./run_ugv_ex_10_long.sh
  python3 parse_duration_log_n.py

The times are found in the saved_times_xxx.csv files in the ugv_ex_outputs directory,
and can be copied to the place where the instructions above are supposed
to find them, as follows:

  cp ugv_ex_outputs/saved_times_short_*.csv ../MPC_times/MPC_short_10/
  cp ugv_ex_outputs/saved_times_long_*.csv ../MPC_times/MPC_long_10/

WARNING: after re-generating these traces, especially the MPC ones,
you're likely to obtain some different scenarios that is likely to
overload the system in a different way, with respect to the traces
used for the paper. This means you're likely to obtain dismissal rates
that are different from the ones in the paper, albeit the general
conclusions should still be there, namely that in each plot showing
deadline misses on the X axis and dismissal rates on the Y axis, the
deadline misses stay below the respective configured target
percentiles, highlighted by the green, blue and red dashed vertical
bars at 5%, 10% and 15%.
