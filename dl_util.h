#ifndef __DL_UTIL_H__
#define __DL_UTIL_H__

#include <sys/syscall.h>
#include <unistd.h>
#include <linux/types.h>
#include <pthread.h>

typedef enum { DL_PARAMS_AUTO, DL_PARAMS_GETATTR, DL_PARAMS_KMOD, DL_PARAMS_PROC } dl_params_type_t;

struct sched_attr {
	__u32 size;

	__u32 sched_policy;
	__u64 sched_flags;

	/* SCHED_NORMAL, SCHED_BATCH */
	__s32 sched_nice;

	/* SCHED_FIFO, SCHED_RR */
	__u32 sched_priority;

	/* SCHED_DEADLINE (nsec) */
	__u64 sched_runtime;
	__u64 sched_deadline;
	__u64 sched_period;
};

static inline int sched_setattr(pid_t pid,
 		  const struct sched_attr *attr,
 		  unsigned int flags) {
  return syscall(__NR_sched_setattr, pid, attr, flags);
}

static inline int sched_getattr(pid_t pid,
 		  struct sched_attr *attr,
 		  unsigned int size,
 		  unsigned int flags) {
  return syscall(__NR_sched_getattr, pid, attr, size, flags);
}

int dl_params_init(dl_params_type_t type);
void dl_params_get(int tid, long *p_runtime_ns, long *p_deadline_ns);
char *dl_params_str();
void dl_params_cleanup();

void dl_sync(int tid, unsigned long period_us);

extern long dl_sync_delta_ns;
static inline long deadline_to_monotonic(long deadline_ns) {
  return deadline_ns - dl_sync_delta_ns;
}

#endif /* __DL_UTIL_H__ */
