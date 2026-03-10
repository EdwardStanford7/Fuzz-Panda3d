#ifndef __SHAREHACK_H_
#define __SHAREHACK_H_

#include <cstddef>

extern "C" int LLVMFuzzerTestOneInput(const char *data, size_t len);

#endif
