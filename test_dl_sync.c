#define _GNU_SOURCE
#include <unistd.h>
#include "ts.h"
#include "dl_util.h"
#include "dw_debug.h"
#include <time.h>

int main() {
  dl_sync(gettid(), 100000);
}
