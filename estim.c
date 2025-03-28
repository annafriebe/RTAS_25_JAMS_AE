#include "estim.h"

#include <string.h>
#include <stdio.h>
#include <math.h>

/*
 * Anna Friebe
 * Based on github.com/FooBarWidget/p2
 * MIT License copyright Aaron Small/ Hongli Lai
 */

void insertion_sort(double* arr, unsigned int size) {
  for (unsigned int i=1; i<size; i++) {
    double tmp = arr[i];
    unsigned int j = i;
    while (j > 0 && tmp < arr[j-1]) {
      arr[j] = arr[j-1];
      j--;
    }
    arr[j] = tmp;
  }
  return;
}

double parabolic(estim* this, int i, int d) {
  return this->heights[i]
    + d / (double)(this->positions[i + 1] - this->positions[i - 1])
    * ((this->positions[i] - this->positions[i - 1] + d)
       * (this->heights[i + 1] - this->heights[i])
       / (this->positions[i + 1] - this->positions[i])
       + (this->positions[i + 1] - this->positions[i] - d)
       * (this->heights[i] - this->heights[i - 1])
       / (this->positions[i] - this->positions[i - 1])
       );
}

double linear(estim* this, int i, int d) {
  return this->heights[i] + d * (this->heights[i + d] - this->heights[i]) /
    (this->positions[i + d] - this->positions[i]);
}

int sign(double value) {
  return (value >= 0.0) ? 1.0 : -1.0;
}

void run_algorithm(estim* this, double value) {
  unsigned int cell_index;
  unsigned int i;

  // Algorithm step B.1
  if (value < this->heights[0]) {
    this->heights[0] = value;
    cell_index = 1;
  } else if (value >= this->heights[4]) {
    this->heights[4] = value;
    cell_index = 4;
  } else {
    cell_index = 1;
    for (i = 1; i < 5; i++) {
      if (value < this->heights[i]) {
	cell_index = i;
	break;
      }
    }
  }
  // Algorithm step B.2
  for (i = cell_index; i < 5; i++) {
    this->positions[i]++;
    this->des_positions[i] = this->des_positions[i] +this-> incrs[i];
  }
  for (i = 0; i < cell_index; i++) {
    this->des_positions[i] = this->des_positions[i] + this->incrs[i];
  }

  // Algorithm step B.3
  for (i = 1; i < 4; i++) {
    double d = this->des_positions[i] - this->positions[i];
    if ((d >=  1.0 && this->positions[i + 1] - this->positions[i] > 1)
	|| (d <= -1.0 && this->positions[i - 1] - this->positions[i] < -1.0)) {
      double newq = parabolic(this, i, sign(d));
      if (this->heights[i - 1] < newq && newq < this->heights[i + 1]) {
	this->heights[i] = newq;
      } else {
	this->heights[i] = linear(this, i, sign(d));
      }
      this->positions[i] += sign(d);
    }
  }
}

long unsigned result(estim* this, double quantile) {
  if (this->count < 5) {
    unsigned int closest = 1;
    insertion_sort(this->heights, this->count);
    for (unsigned int i = 2; i < this->count; i++) {
      if (fabs((double)i / this->count - quantile) < fabs((double)closest / 5 - quantile)) {
	closest = i;
      }
    }
    return this->heights[closest];
  } else {
    // Figure out which quantile is the one we're looking for by nearest increment.
    unsigned int closest = 1;
    for (unsigned int i = 2; i < 4; i ++) {
      if (fabs(this->incrs[i] - quantile) < fabs(this->incrs[closest] - quantile)) {
	closest = i;
      }
    }
    return this->heights[closest];
  }
}

// init
void estim_init(estim* this, double quantile) {
  memset(this->positions, 0, sizeof(this->positions));
  memset(this->heights, 0, sizeof(this->heights));
  memset(this->incrs, 0, sizeof(this->incrs));
  memset(this->des_positions, 0, sizeof(this->des_positions));
  this->count = 0;
  this->incrs[0] = 0.0;
  this->incrs[1] = 1.0;
  this->incrs[2] = quantile;
  this->incrs[3] = quantile/2;
  this->incrs[4] = (1.0 + quantile)/2; 
  this->quantile = quantile;
  insertion_sort(this->incrs, 5);
  for (unsigned int i = 0; i < 5; i++)
    this->des_positions[i] = 4 * this->incrs[i] + 1;
}

// add sample
void estim_add_sample(estim* this, long unsigned int exec_time) {
  if (this->count < 5) {
    this->heights[this->count] = (double)exec_time;
    this->count++;
    if (this->count == 5) {
      insertion_sort(this->heights, 5);
      for (int i = 0; i < 5; i++)
        this->positions[i]=i+1;
    }
  } else {
    run_algorithm(this, (double)exec_time); 
  }
}

long unsigned int estim_get_quantile(estim* this) {
  return (long unsigned int)(result(this, this->incrs[2]) + 0.5);
}
