#include <math.h>
#include <stdint.h>

double jaccard_C_NaN_aware(uint64_t size, double *a, double *b)
{
    double num = 0, den = 0;

    for(uint64_t i = 0; i < size; ++i)
    {
        num += fmin(a[i], b[i]);
        den += fmax(a[i], b[i]);
    }
    return 1. - num / den;
}

double jaccard_C_comparison(uint64_t size, double *a, double *b)
{
    double num = 0, den = 0;

    for(uint64_t i = 0; i < size; ++i)
    {
        num += (a[i] < b[i] ? a[i] : b[i]);
        den += (a[i] > b[i] ? a[i] : b[i]);
    }
    return 1. - num / den;
}
