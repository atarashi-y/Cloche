#include "CXXPerformanceTests.h"
#include <chrono>
#include <iostream>
#include <numeric>
#include <set>
#include <iterator>
#include <vector>

namespace
{

class ElapsedTimer
{
    using millis = std::chrono::duration<double, std::ratio<1, 1000>>;

public:
    double
    elapsed() const
    { return std::chrono::duration_cast<millis>(now() - start_).count(); }

    void
    reset()
    { start_ = now(); }

private:
    static std::chrono::steady_clock::time_point
    now()
    { return std::chrono::steady_clock::now(); }

private:
    std::chrono::steady_clock::time_point start_ = now();
};

} // anonymous namespace

ElapsedTimes
measureCXXSTDSet(const size_t* keys, size_t count)
{
    ElapsedTimer timer;

    std::set<std::size_t> set;
    for (std::size_t i = 0; i < count; ++i)
        set.insert(keys[i]);
    const double insertion_time = timer.elapsed();
    timer.reset();

    for (std::size_t i = 0; i < count; ++i)
        if (set.find(keys[i]) == set.end())
            std::cerr << "not found: " << keys[i] << '\n';
    const double search_time = timer.elapsed();
    timer.reset();

    for (std::size_t i = 0; i < count; ++i)
        set.erase(keys[i]);
    const double deletion_time = timer.elapsed();

    return ElapsedTimes {
        .insertion = insertion_time,
        .search = search_time,
        .deletion = deletion_time
    };
}
