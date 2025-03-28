CFLAGS_DEBUG=-Wall -pedantic -DDW_DEBUG -g -O0 # -fsanitize=address
CFLAGS=-Wall -pedantic -O3 # -fsanitize=address
LDLIBS=-lm # -fsanitize=address

PROGS=rtqueue rtqueue_debug test_estim test_budget_to_deadline hog test_dl_sync

all: $(PROGS)

rtqueue: rtqueue.o distrib.o estim.o dl_util.o

rtqueue_debug: rtqueue_debug.o distrib_debug.o estim_debug.o dl_util_debug.o

test_estim: test_estim.o estim.o
test_dl_sync: test_dl_sync.o dl_util.o

clean:
	rm -f *.o *~ $(PROGS)

%_debug.o: %.c $(wildcard *.h)
	gcc $(CFLAGS_DEBUG) -o $@ -c $<

AE_FILES=README.txt LICENSE.txt
AE_FILES+=$(patsubst test-%.c,,$(wildcard *.c)) $(wildcard *.h) Makefile
AE_FILES+=kmod/Makefile kmod/dlparams.c
AE_FILES+=run.sh run-all.sh run-all-lognorm.sh run-all-new.sh run-ae.sh run-overheads.sh process-all.sh setup.sh teardown.sh bootconfig.sh
AE_FILES+=draw-missed-dismissed.gp draw-missed-dismissed-load.gp draw-missed-dismissed-lognorm.gp draw-misses.gp draw-exec-times-cdf.gp draw-exec-times-lognorm-cdf.gp kfl
AE_FILES+=mpc_run/libmpc-0.6.2.tar.gz mpc_run/libmpc_edit/examples/ugv_ex_long.cpp mpc_run/libmpc_edit/examples/ugv_ex_short.cpp mpc_run/libmpc_edit/include/mpc/Profiler.hpp
AE_FILES+=mpc_run/run_ugv_ex_10_long.sh mpc_run/run_ugv_ex_10_short.sh mpc_run/parse_duration_log_n.py

AE_NAME=rtas25_ae
artifact: $(AE_NAME).tgz

$(AE_NAME).tgz: $(AE_FILES)
	mkdir -p $(AE_NAME)
	cp --parents -a $(AE_FILES) $(AE_NAME)/
	cp -a ../paper-job-dismissal/MPC_times ../paper-job-dismissal/lognorm_times $(AE_NAME)/
	find $(AE_NAME)/MPC_times -maxdepth 0 -type f -delete
	rm -r $(AE_NAME)/lognorm_times/old
	sed -i -e 's#\.\./\.\./paper-job-dismissal/##g; s#\.\./paper-job-dismissal/##g' $(AE_NAME)/*.sh $(AE_NAME)/*.gp
	sed -i -e 's#~/work/#./#g' $(AE_NAME)/lognorm_times/generate.sh
	tar -czf $(AE_NAME).tgz $(AE_NAME)
	zip -r $(AE_NAME).zip $(AE_NAME)

# DO NOT DELETE

distrib.o: distrib.h dw_debug.h
estim.o: estim.h
rtqueue.o: distrib.h ts.h estim.h dw_debug.h
test_estim.o: estim.h
