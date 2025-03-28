#ifndef __ESTIM_H__
#define __ESTIM_H__


// P squared estimator data
typedef struct {
  unsigned int count;
  int positions[5];
  double heights[5];
  double incrs[5];
  double des_positions[5];
  double quantile;
} estim;


// init
void estim_init(estim* this, double quantile);

// add sample
void estim_add_sample(estim* this, long unsigned int exec_time);

long unsigned int estim_get_quantile(estim* this);

void insertion_sort(double* arr, unsigned int size);

#endif
