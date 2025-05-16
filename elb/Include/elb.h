#ifndef ELB_H
#define ELB_H
#include <stdint.h>

enum Status {
    ERROR = 0,
    VALUE = 1,
    EOF = 2,
    INFO = 3
};

struct Result {
    char* output;
    int64_t line;
    enum Status status;
};

void Execute(const char *content, struct Result *dstArray, int64_t dstSize);

#endif
