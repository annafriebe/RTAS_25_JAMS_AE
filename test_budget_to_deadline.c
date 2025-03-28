#include <stdio.h>

double u_tot = 0.75;

long dl_runtime_us = 10;
long dl_period_us = 20;

long lmax(long a, long b) {
  return a > b ? a : b;
}

// TODO: consider u_tot
long budget_to_deadline(long runtime_left_ns, long time_to_dline_ns, long time_to_job_dline_ns) {
  if (time_to_job_dline_ns <= time_to_dline_ns * u_tot)
    return lmax(0, runtime_left_ns - lmax(0, time_to_dline_ns * u_tot - time_to_job_dline_ns));
  else {
    int periods = (time_to_job_dline_ns - time_to_dline_ns) / (dl_period_us * 1000l);
    long left_ns = (time_to_job_dline_ns - time_to_dline_ns) % (dl_period_us * 1000l);
    // printf("period=%d, left_ns=%ld\n", periods, left_ns);
    return runtime_left_ns + periods * dl_runtime_us * 1000l + lmax(0, dl_runtime_us * 1000 - lmax(0, dl_period_us * 1000l * u_tot - left_ns));
  }
}

int main() {
  long consumed = 0;
  for (long job_dline = 0; job_dline < 3 * dl_period_us * 1000; job_dline += 2000)
    printf("consumed=%ld, time_to_job_dline=%ld, budg=%ld\n", consumed, job_dline, budget_to_deadline(dl_runtime_us * 1000 - consumed, dl_period_us * 1000l - consumed, job_dline));

  consumed = 4000;
  for (long job_dline = 0; job_dline < 3 * dl_period_us * 1000; job_dline += dl_period_us * 1000 / 4)
    printf("consumed=%ld, time_to_job_dline=%ld, budg=%ld\n", consumed, job_dline, budget_to_deadline(dl_runtime_us * 1000 - consumed, dl_period_us * 1000l - consumed, job_dline));

  consumed = 8000;
  for (long job_dline = 0; job_dline < 3 * dl_period_us * 1000; job_dline += dl_period_us * 1000 / 4)
    printf("consumed=%ld, time_to_job_dline=%ld, budg=%ld\n", consumed, job_dline, budget_to_deadline(dl_runtime_us * 1000 - consumed, dl_period_us * 1000l - consumed, job_dline));
}
