import Cloche
import Foundation
import CXXPerformanceTests

func generateValues(_ n: Int) -> [Int]  {
    var values = Set<Int>()
    values.reserveCapacity(n)

    while values.count < n {
        values.insert(Int.random(in: 0 ..< Int.max))
    }

    return values.map { $0 }
}

struct ElapsedTimer {
    private var _start = ProcessInfo.processInfo.systemUptime

    var elapsed: TimeInterval {
        return (ProcessInfo.processInfo.systemUptime - self._start) * 1000.0
    }

    mutating func reset() {
        self._start = ProcessInfo.processInfo.systemUptime
    }
}

extension Collection where Element == Double {
    var average: Double {
        return self.reduce(0.0) { result, v in result + v }
            / Double(self.count)
    }
}

func measureSortedSetPerformance<S: Sequence>(with values: S)
    -> ElapsedTimes where S.Element: Comparable {
    var set = SortedSet<S.Element>()
    var timer = ElapsedTimer()

    for v in values {
        set.insert(v)
    }
    let insertion_time = timer.elapsed
    timer.reset()

    for v in values {
        if set.firstIndex(of: v) == nil {
            fatalError("\(v) is not found.")
        }
    }
    let search_time = timer.elapsed
    timer.reset()

    for v in values {
        if set.remove(v) == nil {
            fatalError("could not remove \(v)")
        }
    }
    let deletion_time = timer.elapsed

    return ElapsedTimes(
        insertion: insertion_time, search: search_time,
        deletion: deletion_time)
}

public func runPerformanceTests() {
    let Iterations = 10
    let N = (0 ..< 7).map { 65536 << $0 }

    var collections: SortedDictionary<
        String, SortedDictionary<Int, [ElapsedTimes]>
    > = [:]

    for i in (1 ... Iterations) {
        print("Iteration: \(i)")
        let values = generateValues(N.last!)

        for n in N {
            print("\t\(n)")
            let n_values = values.prefix(n).map { $0 }

            let sorted_set_result = measureSortedSetPerformance(with: n_values)
            collections["SortedSet", default: [:]][
                n, default: []].append(sorted_set_result)

            let cxx_std_set_result = measureCXXSTDSet(n_values, n)
            collections["std::set", default: [:]][
                n, default:[]].append(cxx_std_set_result)
        }
    }

    for (name, collection) in collections {
        print(name, "insertion", "search", "deletion", separator: ",")

        for (n, times) in collection {
            let insertion_time = times.map { $0.insertion }.average
            let search_time = times.map { $0.search }.average
            let deletion_time = times.map { $0.deletion }.average

            let times_description =
                [insertion_time, search_time, deletion_time].map {
                    String(format: "%.3f", $0)
                }.joined(separator: ",")
            print(n, times_description, separator: ",")
        }

        print("")
    }
}
