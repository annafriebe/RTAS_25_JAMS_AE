#include "estim.h"
#include <stdio.h>


int test_estim_50(){
  estim est;
  estim_init(&est, 0.5);
  long unsigned n_samples = 999;
  for (long unsigned i=0; i<n_samples; i++){
    estim_add_sample(&est, i);
  }
  long unsigned perc_50 = estim_get_quantile(&est);
  printf("est 50 perc: %ld, expected: %ld\n",
         perc_50, (n_samples-1)/2);
  return 0;
}

int test_estim_10(){
  estim est;
  estim_init(&est, 0.1);
  long unsigned n_samples = 999;
  for (long unsigned i=0; i<n_samples; i++){
    estim_add_sample(&est, i);
  }
  long unsigned perc_10 = estim_get_quantile(&est);
  printf("est 10 perc: %ld, expected: %ld\n",
         perc_10, (n_samples-1)/10);
  return 0;
}

int test_estim_99(){
  estim est;
  estim_init(&est, 0.99);
  long unsigned n_samples = 1000;
  for (long unsigned i=1; i<=n_samples; i++){
    estim_add_sample(&est, i);
  }
  long unsigned perc_99 = estim_get_quantile(&est);
  printf("est 99 perc: %ld, expected: %ld\n",
         perc_99, (long unsigned)990);
  estim est_2;
  estim_init(&est_2, 0.99);
  for (long unsigned i=n_samples; i>0; i--){
    estim_add_sample(&est_2, i);
  }
  perc_99 = estim_get_quantile(&est_2);
  printf("est 99 perc: %ld, expected: %ld\n",
         perc_99, (long unsigned)990);
  return 0;
}


int test_insertion_sort(){
  double test_arr[5] = {5.0, 4.0, 2.0, 3.0, 1.0};
  insertion_sort(test_arr, 5);
  for(int i=0; i<5; i++){
    printf("arr[%d]=%f\n", i, test_arr[i]);
  }
  return 0;
}


int main(int argc, char *argv[]) {
  test_estim_50();
  test_estim_10();
  test_estim_99();
  test_insertion_sort();
  return 0;
}
