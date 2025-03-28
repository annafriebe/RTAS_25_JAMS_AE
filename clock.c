#include <time.h>
#include <stdio.h>

int main() {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  printf("%ld\n", ts.tv_sec * 1000000000l + ts.tv_nsec);
}
