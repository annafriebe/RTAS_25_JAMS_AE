#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <sched.h>
#include <sys/syscall.h>      /* Definition of SYS_* constants */
#include <unistd.h>
#include <sys/types.h>
#include <stdint.h>
#include <linux/sched.h>
#include <pthread.h>

typedef uint32_t u32;
typedef uint64_t u64;
typedef int32_t s32;
typedef int64_t s64;

char buf[4096];

struct sched_attr {
  u32 size;              /* Size of this structure */
  u32 sched_policy;      /* Policy (SCHED_*) */
  u64 sched_flags;       /* Flags */
  s32 sched_nice;        /* Nice value (SCHED_OTHER,
                            SCHED_BATCH) */
  u32 sched_priority;    /* Static priority (SCHED_FIFO,
                            SCHED_RR) */
  /* Remaining fields are for SCHED_DEADLINE */
  u64 sched_runtime;
  u64 sched_deadline;
  u64 sched_period;
};

int sched_setattr(pid_t pid,
 		  const struct sched_attr *attr,
 		  unsigned int flags)
{
  return syscall(__NR_sched_setattr, pid, attr, flags);
}

int sched_getattr(pid_t pid,
 		  struct sched_attr *attr,
 		  unsigned int size,
 		  unsigned int flags)
{
  return syscall(__NR_sched_getattr, pid, attr, size, flags);
}

void sched_set_deadline(unsigned long runtime_us, unsigned long deadline_us, unsigned long period_us) {
  struct sched_attr attr = {
    .size = sizeof(struct sched_attr),
    .sched_policy = SCHED_DEADLINE,
    .sched_flags = 0,
    .sched_runtime  = runtime_us * 1000,
    .sched_deadline = deadline_us * 1000,
    .sched_period   = period_us * 1000
  };
  if (sched_setattr(0, &attr, 0) < 0) {
    perror("setattr() failed");
    exit(1);
  }
}

int tid = 0;

void get_sched_dl_params(long *p_runtime_ns, long *p_deadline_ns) {
  struct sched_attr attr;
  if (sched_getattr(tid, &attr, sizeof(attr), 1) < 0) {
    perror("sched_getattr()");
    exit(1);
  }
  *p_runtime_ns = attr.sched_runtime;
  *p_deadline_ns = attr.sched_deadline;
}

void get_sched_dl_params_real(long *p_runtime_ns, long *p_deadline_ns) {
  struct sched_attr attr;
  if (sched_getattr(tid, &attr, sizeof(attr), 2) < 0) {
    perror("sched_getattr()");
    exit(1);
  }
  *p_runtime_ns = attr.sched_runtime;
  *p_deadline_ns = attr.sched_deadline;
}

pthread_barrier_t bar;

void *body(void *p) {
  tid = gettid();
  sched_set_deadline(10000, 20000, 20000);
  pthread_barrier_wait(&bar);

  for (;;)
    ;

  return 0;
}

int main(int argc, char *argv[]) {
  int child = 0;

  if (argc > 1)
    child = 1;

  struct timespec ts_beg;
  clock_gettime(CLOCK_MONOTONIC, &ts_beg);
  ts_beg.tv_nsec += 100*1000*1000l;
  while (ts_beg.tv_nsec >= 1000000000l) {
    ts_beg.tv_sec--;
    ts_beg.tv_nsec -= 1000000000;
  }
  ts_beg.tv_nsec -= ts_beg.tv_nsec % 10*1000*1000;
  clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &ts_beg, NULL);
  long beg_ns = ts_beg.tv_sec * 1000000000l + ts_beg.tv_nsec;

  if (child) {
    pthread_barrier_init(&bar, NULL, 2);
    pthread_t child;
    assert(pthread_create(&child, NULL, &body, NULL) == 0);
    pthread_barrier_wait(&bar);
  } else {
    sched_set_deadline(10000, 20000, 20000);
  }
  long runtime, deadline;
  // long runtime_real, deadline_real;
  for (;;) {
    struct timespec ts1, ts2; //, tsr;
    clock_gettime(CLOCK_MONOTONIC, &ts1);
    get_sched_dl_params(&runtime, &deadline);
    clock_gettime(CLOCK_MONOTONIC, &ts2);
    //clock_gettime(CLOCK_REALTIME, &tsr);
    //get_sched_dl_params_real(&runtime_real, &deadline_real);
    long ovh1 = (ts2.tv_nsec - ts1.tv_nsec) + (ts2.tv_sec - ts1.tv_sec) * 1000000000l;
    long slack = deadline - (ts1.tv_sec*1000000000l + ts1.tv_nsec);
    //long slack_real = deadline_real - (tsr.tv_sec*1000000000l + tsr.tv_nsec);
    /* printf("getattr: runtime=%ld, deadline=%ld, ts1=%ld,ts2=%ld, slack=%ld, ovh=%ld, dl_real=%ld, tsr=%ld, slack_real=%ld\n", */
    /* 	   runtime, deadline, ts1.tv_sec*1000000000l+ts1.tv_nsec, ts2.tv_sec*1000000000l+ts2.tv_nsec, slack, ovh1, */
    /* 	   deadline_real, tsr.tv_sec*1000000000l+tsr.tv_nsec, slack_real); */
    printf("getattr: runtime=%ld, deadline=%ld, ts1=%ld,ts2=%ld, slack=%ld, ovh=%ld\n",
	   runtime, deadline - beg_ns, ts1.tv_sec*1000000000l+ts1.tv_nsec, ts2.tv_sec*1000000000l+ts2.tv_nsec, slack, ovh1);
    double acc = 0;
    for (int i = 0; i < 15000; i++)
      acc += acc + 576633 * 3.456 + 36335.23;
  }
}
