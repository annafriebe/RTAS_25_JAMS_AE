#ifndef __TS_H__
#define __TS_H__

#include <sys/time.h>

static inline void ts_add_us(struct timespec *p_ts, long delta_us) {
    p_ts->tv_nsec += delta_us * 1000;
    while (p_ts->tv_nsec > 1000000000l) {
      p_ts->tv_nsec -= 1000000000l;
      p_ts->tv_sec++;
    }
}

static inline long ts_sub_ns(struct timespec *p1, struct timespec *p2) {
  return (p1->tv_sec - p2->tv_sec) * 1000000000l + (p1->tv_nsec - p2->tv_nsec);
}

static inline long ts_sub_us(struct timespec *p1, struct timespec *p2) {
  return (p1->tv_sec - p2->tv_sec) * 1000000 + (p1->tv_nsec - p2->tv_nsec) / 1000;
}

static inline long ts_to_us(struct timespec ts) {
  return ts.tv_sec * 1000000l + ts.tv_nsec / 1000;
}

static inline long ts_to_ns(struct timespec ts) {
  return ts.tv_sec * 1000000000l + ts.tv_nsec;
}

#endif /* __TS_H__ */
