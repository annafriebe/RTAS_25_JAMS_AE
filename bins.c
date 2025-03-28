#include <stdio.h>
#include <math.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>

#define SZ 128
int bins[SZ];
int transposed = 0;
int header = 1;

int main(int argc, char *argv[]) {
  double thr = NAN;
  argc--;  argv++;
  while (argc > 0) {
    if (strcmp(*argv, "-h") == 0 || strcmp(*argv, "--help") == 0) {
      printf("Usage: bins [-t|--threshold value] [-tr|--transposed] [-nh|--no-header]\n");
      exit(0);
    } else if (strcmp(*argv, "-t") == 0 || strcmp(*argv, "--threshold") == 0) {
      argc--;  argv++;
      assert(argc > 0);
      sscanf(*argv, "%lf", &thr);
    } else if (strcmp(*argv, "-tr") == 0 || strcmp(*argv, "--transposed") == 0) {
      transposed = 1;
    } else if (strcmp(*argv, "-nh") == 0 || strcmp(*argv, "--no-header") == 0) {
      header = 0;
    } else {
      fprintf(stderr, "Unknown option: %s\n", *argv);
      exit(1);
    }
    argc--;  argv++;
  }

  for (int i = 0; i < SZ; i++)
    bins[i] = 0;
  int cnt = 0;
  double val;
  while (!feof(stdin)) {
    int rv = scanf("%lf", &val);
    if (rv == EOF)
      break;
    assert(rv == 1);
    if ((isnan(thr) && val == 0) || (!isnan(thr) && val > thr))
      cnt++;
    else {
      if (cnt > SZ - 1)
        cnt = SZ - 1;
      bins[cnt]++;
      cnt = 0;
    }
  }
  if (transposed) {
    if (header)
      for (int i = 0; i < SZ; i++)
        printf("%d%s", i, i < SZ - 1 ? " " : "\n");
    for (int i = 0; i < SZ; i++)
      printf("%d%s", bins[i], i < SZ - 1 ? " " : "\n");
  } else {
    for (int i = 0; i < SZ; i++)
      if (header)
        printf("%d %d\n", i, bins[i]);
      else
        printf("%d\n", bins[i]);
  }
}
