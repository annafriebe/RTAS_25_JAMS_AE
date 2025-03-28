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
    .sched_flags = 0x80,
    .sched_runtime  = runtime_us * 1000,
    .sched_deadline = deadline_us * 1000,
    .sched_period   = period_us * 1000
  };
  if (sched_setattr(0, &attr, 0) < 0) {
    perror("setattr() failed");
    exit(1);
  }
}

void get_sched_dl_params(long *p_runtime_ns, long *p_deadline_ns) {
  struct sched_attr attr;
  sched_getattr(0, &attr, sizeof(attr), 0);
  *p_runtime_ns = attr.sched_runtime;
  *p_deadline_ns = attr.sched_deadline;
}

int main(int argc, char *argv[]) {
  sched_set_deadline(10000, 20000, 20000);
  long runtime, deadline;
  for (;;) {
    struct timespec ts1, ts2;
    clock_gettime(CLOCK_MONOTONIC, &ts1);
    get_sched_dl_params(&runtime, &deadline);
    clock_gettime(CLOCK_MONOTONIC, &ts2);
    long ovh1 = (ts2.tv_nsec - ts1.tv_nsec) + (ts2.tv_sec - ts1.tv_sec) * 1000000l;
    printf("getattr: runtime=%ld,deadline=%ld,ovh=%ld\n", runtime, deadline, ovh1);
    double acc = 0;
    for (int i = 0; i < 15000; i++)
      acc += acc + 576633 * 3.456 + 36335.23;
  }
}
