#include "dl_util.h"
#include "dw_debug.h"
#include "ts.h"
#include <string.h>
#include <fcntl.h>

char buf[4096];
int fd_dlparams = -1;
long dl_sync_delta_ns = 0;
dl_params_type_t dlp_type = -1;

int dl_params_init(dl_params_type_t type) {
  int rv;
  struct sched_attr attr;
  switch (type) {
  case DL_PARAMS_AUTO:
  case DL_PARAMS_GETATTR:
      rv = sched_getattr(0, &attr, sizeof(attr), 0x01 /* SCHED_FLAG_DL_PARAMS */);
      if (rv == 0) {
        dlp_type = DL_PARAMS_GETATTR;
        break;
      }
      if (type == DL_PARAMS_GETATTR)
        return -1;
      /* fallback on AUTO */
  case DL_PARAMS_KMOD:
    fd_dlparams = open("/dev/dlparams", O_RDONLY);
    printf("fd=%d\n", fd_dlparams);
    if (fd_dlparams > 0) {
      dlp_type = DL_PARAMS_KMOD;
      break;
    }
    if (type == DL_PARAMS_KMOD)
      return -1;
    /* fallback on AUTO */
  case DL_PARAMS_PROC:
    dlp_type = DL_PARAMS_PROC;
    break;
  default:
    fprintf(stderr, "dl_params_init(): unknown type %d\n", type);
    exit(1);
  }
  return 0;
}

void dl_params_cleanup() {
  if (dlp_type == DL_PARAMS_KMOD && fd_dlparams != -1)
    close(fd_dlparams);
}

char *dl_params_str() {
  switch (dlp_type) {
  case DL_PARAMS_GETATTR:
    return "sched_getattr()";
  case DL_PARAMS_KMOD:
    return "/dev/dlparams";
  case DL_PARAMS_PROC:
    return "/proc";
  default:
    fprintf(stderr, "dl_params_str(): unknown type %d\n", dlp_type);
    exit(1);
  }
}

void dl_params_get(int tid, long *p_runtime_ns, long *p_deadline_ns) {
  struct sched_attr attr;
  char fname[80];

  switch (dlp_type) {
  case DL_PARAMS_GETATTR:
    sched_getattr(0, &attr, sizeof(attr), 0x01);
    *p_runtime_ns = attr.sched_runtime;
    *p_deadline_ns = attr.sched_deadline;
    dw_log("getattr: runtime=%ld, deadline=%ld", *p_runtime_ns, *p_deadline_ns);
    break;

  case DL_PARAMS_KMOD:
    if (fd_dlparams == -1) {
      fprintf(stderr, "dl_params_get(): /dev/dlparams not open\n");
      exit(1);
    }
    long vals[2];
    check(read(fd_dlparams, vals, sizeof(vals)) == sizeof(vals));
    *p_runtime_ns = vals[0];
    *p_deadline_ns = vals[1];
    dw_log("kmod: runtime=%ld, deadline=%ld", *p_runtime_ns, *p_deadline_ns);
    break;

  case DL_PARAMS_PROC:
    sprintf(fname, "/proc/self/task/%d/sched", tid);
    FILE *f = fopen(fname, "r");
    check(f != NULL);
    size_t bytes = fread(buf, 1, sizeof(buf) - 1, f);
    //printf("Read %lu bytes from sched\n", bytes);
    check(bytes > 0);
    buf[bytes] = '\0';
    fclose(f);

    char *p = strstr(buf, "dl.runtime");
    if (!p) {
      fprintf(stderr, "dl_params_get(): not a DEADLINE task!\n");
      exit(1);
    }

    check(sscanf(p+47, "%ld", p_runtime_ns) == 1);
    p = strstr(p, "dl.deadline");
    check(p);
    check(sscanf(p+47, "%ld", p_deadline_ns) == 1);
    dw_log("proc: runtime=%ld, deadline=%ld", *p_runtime_ns, *p_deadline_ns);
    break;

  default:
    fprintf(stderr, "dl_params_get(): unknown type %d\n", dlp_type);
    exit(1);
  }
}

// read the abs deadline after having slept for a period
void dl_sync(int tid, unsigned long period_us) {
  struct timespec ts_next;
  int clock_id = CLOCK_BOOTTIME; // CLOCK_MONOTONIC; 
  clock_gettime(clock_id, &ts_next);
  ts_add_us(&ts_next, 2*period_us);
  check(clock_nanosleep(clock_id, TIMER_ABSTIME, &ts_next, NULL) == 0);
  long runtime_ns, deadline_ns;
  dl_params_get(tid, &runtime_ns, &deadline_ns);
  ts_add_us(&ts_next, period_us);
  long deadline_guess_ns = ts_next.tv_sec * 1000000000l + ts_next.tv_nsec;
  dl_sync_delta_ns = deadline_ns - deadline_guess_ns;
  printf("dl_sync_delta: %ld, deadline_guess_ns: %ld\n",
         dl_sync_delta_ns, deadline_guess_ns);
  long deadline_monotonic_ns = deadline_to_monotonic(deadline_ns);
  printf("deadline_ns: %ld, deadline_monotonic_ns: %ld\n",
         deadline_ns, deadline_monotonic_ns);
}
