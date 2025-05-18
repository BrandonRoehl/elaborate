#ifndef ELB_H
#define ELB_H
#include <stdlib.h>
// #include <stdint.h>
// typedef long long int64_t;

typedef const char cchar_t;

typedef enum Status {
    ERROR = 0,
    VALUE = 1,
    EOF = 2,
    INFO = 3
} Status;

typedef struct Result {
    char* output;
    int64_t line;
    Status status;
} Result;

typedef struct Response {
    Result *results;
    int64_t size;
} Response;

extern Response Execute(cchar_t *content);

#endif
