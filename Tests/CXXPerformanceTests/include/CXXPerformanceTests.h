#if !defined(CXX_PERFORMANCE_TESTS_H_INCLUDED)
#  define CXX_PERFORMANCE_TESTS_H_INCLUDED

#include <stddef.h>

#if defined(__cplusplus)
extern "C" {
#endif // !defined(__cplusplus)

typedef struct
{
    double insertion;
    double search;
    double deletion;
} ElapsedTimes;

ElapsedTimes
measureCXXSTDSet(const size_t* keys, size_t count);

#if defined(__cplusplus)
}
#endif // !defined(__cplusplus)

#endif // !defined(CXX_PERFORMANCE_TESTS_H_INCLUDED)
