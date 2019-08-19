//
// SortedSetTests.swift
//
// Copyright (c) 2019 Yoshinori Atarashi
// (https://github.com/atarashi-y/Cloche)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest
@testable import Cloche

struct Value {
    var v: Int
    var str: String
}

extension Value: Equatable {
    static func == (x: Value, y: Value) -> Bool {
        return x.v == y.v
    }
}

extension Value: Comparable {
    static func < (x: Value, y: Value) -> Bool {
        return x.v < y.v
    }
}

final class SortedSetTests : XCTestCase {
    final func testInit() {
        let s = SortedSet<Int>()

        XCTAssertEqual(s.isEmpty, true)
        XCTAssertEqual(s.count, 0)
        XCTAssertEqual(s.startIndex, s.endIndex)
        XCTAssertFalse(s.startIndex < s.endIndex)

        var i = s.makeIterator()
        XCTAssertTrue(i.next() == nil)
    }

    final func testInitSequence() {
        let s = SortedSet(["c", "b", "d", "a", "d", "b", "a", "c"])
        let expected_s = ["a", "b", "c", "d"]

        XCTAssertFalse(s.isEmpty)
        XCTAssertEqual(s.count, expected_s.count)
        assertEqual(s, expected_s)
    }

    final func testFilter() {
        let s1: SortedSet = [4, 2, 1, 3]
        let s2: SortedSet = s1.filter { $0 % 2 == 0 }
        let expected_s2 = [2, 4]

        XCTAssertEqual(s2.count, 2)
        assertEqual(s2, expected_s2)
    }

    final func testRemoveAt() {
        let source = [
            "m", "e", "n", "k", "f", "j", "d", "h", "a", "l", "b", "i", "c",
            "g"
        ]
        let expected_s1 = [
            "a", "b", "c", "d", "e", "f", "h", "j", "k", "l", "m", "n"
        ]
        let expected_s3 = [
            "a", "b", "c", "d", "e", "f", "h", "i", "j", "k", "l", "m", "n"
        ]

        do {
            var s1 = SortedSet(source)

            let g_index = s1.index(s1.startIndex, offsetBy: 6)
            let i_index = s1.index(g_index, offsetBy: 2)
            s1.remove(at: g_index)
            s1.remove(at: i_index)

            assertEqual(s1, expected_s1)
        }

        do {
            var s1 = SortedSet(source)
            let s2 = s1
            s1.remove(at: s1.firstIndex(of: "g")!)
            let s3 = s1
            s1.remove(at: s1.firstIndex(of: "i")!)

            XCTAssertEqual(s1.count, source.count - 2)
            XCTAssertEqual(s2.count, source.count)
            assertEqual(s1, expected_s1)
            assertEqual(s3, expected_s3)
        }
    }

    final func testRemoveAll() {
        var s1: SortedSet = ["d", "b", "a", "c"]
        let s2 = s1
        let expected_s2 = ["a", "b", "c", "d"]

        XCTAssertEqual(s1, s2)
        assertEqual(s1, expected_s2)
        assertEqual(s2, expected_s2)

        s1.removeAll()

        XCTAssertTrue(s1.isEmpty)
        XCTAssertEqual(s1.count, 0)
        XCTAssertNil(s1.first)
        XCTAssertNil(s1.last)

        XCTAssertFalse(s2.isEmpty)
        XCTAssertEqual(s2.count, expected_s2.count)
        assertEqual(s2, expected_s2)
    }

    final func testLowerBoundAndUpperBound() {
        let s: SortedSet = [4, 6, 2, 8, 9]

        XCTAssertEqual(s[s.lowerBound(of: 1)], 2)
        XCTAssertEqual(s[s.upperBound(of: 1)], 2)
        XCTAssertEqual(s[s.lowerBound(of: 2)], 2)
        XCTAssertEqual(s[s.upperBound(of: 2)], 4)
        XCTAssertEqual(s[s.lowerBound(of: 4)], 4)
        XCTAssertEqual(s[s.upperBound(of: 4)], 6)
        XCTAssertEqual(s.lowerBound(of: 10), s.endIndex)
        XCTAssertEqual(s.upperBound(of: 10), s.endIndex)
    }

    final func testInsertWithHint() {
        let s1: SortedSet<String> = []
        var s2 = s1

        let expected_s1: [String] = []
        let expected_s2 = ["a", "b", "c", "d", "e", "f"]

        XCTAssertTrue(s2.insert("a", hint: s2.endIndex) == (true, "a"))
        XCTAssertTrue(s2.insert("a", hint: s2.startIndex) == (false, "a"))
        XCTAssertTrue(s2.insert("b", hint: s2.startIndex) == (true, "b"))
        XCTAssertTrue(s2.insert("b", hint: s2.startIndex) == (false, "b"))
        XCTAssertTrue(s2.insert("e", hint: s2.endIndex) == (true, "e"))
        XCTAssertTrue(
            s2.insert("c", hint: s2.firstIndex(of: "b")!) == (true, "c"))
        s2.insert("f")
        XCTAssertTrue(
            s2.insert("d", hint: s2.firstIndex(of: "f")!) == (true, "d"))

        assertEqual(s1, expected_s1)
        assertEqual(s2, expected_s2)
    }

    final func testEquatable() {
        let s1: SortedSet = ["c", "d", "a", "b"]
        let s2: SortedSet = ["d", "b", "a", "c"]
        let s3: SortedSet = ["d", "b", "a"]
        XCTAssertEqual(s1, s1)
        XCTAssertEqual(s1, s2)
        XCTAssertNotEqual(s1, s3)
        XCTAssertNotEqual(s2, s3)
    }

    final func testComparable() {
        let s1: SortedSet = ["c", "d", "a", "b"]
        let s2: SortedSet = ["d", "b", "a", "c"]
        let s3: SortedSet = ["d", "b", "a"]
        XCTAssertFalse(s1 < s1)
        XCTAssertFalse(s1 < s2)
        XCTAssertLessThan(s1, s3)
        XCTAssertLessThan(s2, s3)
    }

    final func testHashable() {
        let s1: SortedSet = ["c", "d", "a", "b"]
        let s2: SortedSet = ["d", "b", "a", "c"]
        let s3: SortedSet = ["d", "b", "a", "e"]
        XCTAssertEqual(s1.hashValue, s2.hashValue)
        XCTAssertNotEqual(s1.hashValue, s3.hashValue)
        XCTAssertNotEqual(s2.hashValue, s3.hashValue)
    }

    final func testMinMax() {
        let s: SortedSet = ["d", "b", "a", "c"]
        XCTAssertEqual(s.min(), "a")
        XCTAssertEqual(s.max(), "d")
        XCTAssertEqual(s[s.startIndex], "a")
        XCTAssertEqual(s[s.index(before: s.endIndex)], "d")
    }

    final func testContains() {
        let s: SortedSet = ["d", "b", "a", "c"]

        for v in ["a", "b", "c", "d"] {
            XCTAssertTrue(s.contains(v))
        }

        for v in ["aa", "bb", "cc", "dd", "e", "f", "g"] {
            XCTAssertFalse(s.contains(v))
        }
    }

    final func testIndex() {
        let s: SortedSet = ["d", "b", "a", "c"]

        XCTAssertNil(s.firstIndex(of: "e"))
        XCTAssertEqual(s.firstIndex(of: "a"), s.startIndex)
        XCTAssertLessThan(s.startIndex, s.firstIndex(of: "b")!)
        XCTAssertLessThan(s.startIndex, s.firstIndex(of: "c")!)
        XCTAssertLessThan(s.startIndex, s.firstIndex(of: "d")!)
        XCTAssertEqual(s.firstIndex(of: "d"), s.index(before: s.endIndex))
        XCTAssertLessThan(s.firstIndex(of: "a")!, s.endIndex)
        XCTAssertLessThan(s.firstIndex(of: "b")!, s.endIndex)
        XCTAssertLessThan(s.firstIndex(of: "c")!, s.endIndex)
        XCTAssertLessThan(s.firstIndex(of: "d")!, s.endIndex)

        XCTAssertNil(s.lastIndex(of: "e"))
        XCTAssertEqual(s.lastIndex(of: "a"), s.startIndex)
        XCTAssertLessThan(s.startIndex, s.lastIndex(of: "b")!)
        XCTAssertLessThan(s.startIndex, s.lastIndex(of: "c")!)
        XCTAssertLessThan(s.startIndex, s.lastIndex(of: "d")!)
        XCTAssertEqual(s.lastIndex(of: "d"), s.index(before: s.endIndex))
        XCTAssertLessThan(s.lastIndex(of: "a")!, s.endIndex)
        XCTAssertLessThan(s.lastIndex(of: "b")!, s.endIndex)
        XCTAssertLessThan(s.lastIndex(of: "c")!, s.endIndex)
        XCTAssertLessThan(s.lastIndex(of: "d")!, s.endIndex)

        XCTAssertEqual(s.index(s.startIndex, offsetBy: 0), s.startIndex)
        XCTAssertEqual(s[s.index(s.startIndex, offsetBy: 0)], "a")
        XCTAssertEqual(s[s.index(s.startIndex, offsetBy: 1)], "b")
        XCTAssertEqual(s[s.index(s.startIndex, offsetBy: 2)], "c")
        XCTAssertEqual(s[s.index(s.startIndex, offsetBy: 3)], "d")
        XCTAssertEqual(s.index(s.startIndex, offsetBy: 4), s.endIndex)
        XCTAssertEqual(s.index(s.endIndex, offsetBy: 0), s.endIndex)
        XCTAssertEqual(s[s.index(s.endIndex, offsetBy: -1)], "d")
        XCTAssertEqual(s[s.index(s.endIndex, offsetBy: -2)], "c")
        XCTAssertEqual(s[s.index(s.endIndex, offsetBy: -3)], "b")
        XCTAssertEqual(s[s.index(s.endIndex, offsetBy: -4)], "a")
    }

    final func testIndexHashable() {
        let s: SortedSet = ["d", "b", "a", "c"]
        let index_set = Set(s.indices.map { $0 })

        var i = s.startIndex
        while i != s.endIndex {
            XCTAssertTrue(index_set.contains(i))

            s.formIndex(after: &i)
        }
    }

    final func testInsert() {
        let empty: SortedSet<String> = []
        var s1 = empty

        let expected_s1 = ["a", "b", "c", "d"]
        let expected_s2 = ["a", "b", "c", "d", "e", "f"]

        XCTAssertTrue(s1.insert("a") == (true, "a"))
        XCTAssertTrue(s1.insert("b") == (true, "b"))
        XCTAssertTrue(s1.insert("c") == (true, "c"))
        XCTAssertTrue(s1.insert("d") == (true, "d"))

        XCTAssertTrue(s1.insert("a") == (false, "a"))
        XCTAssertTrue(s1.insert("b") == (false, "b"))
        XCTAssertTrue(s1.insert("c") == (false, "c"))
        XCTAssertTrue(s1.insert("d") == (false, "d"))

        var s2 = s1

        XCTAssertTrue(s2.insert("e") == (true, "e"))
        XCTAssertTrue(s2.insert("f") == (true, "f"))
        XCTAssertTrue(s2.insert("a") == (false, "a"))
        XCTAssertTrue(s2.insert("b") == (false, "b"))
        XCTAssertTrue(s2.insert("c") == (false, "c"))
        XCTAssertTrue(s2.insert("d") == (false, "d"))

        assertEqual(empty, [])
        assertEqual(s1, expected_s1)
        assertEqual(s2, expected_s2)
    }

    final func testRemove() {
        var s1: SortedSet = ["d", "b", "a", "c"]
        let s2 = s1
        let sorted_values = ["a", "b", "c", "d"]

        for (i, v) in s1.enumerated() {
            XCTAssertEqual(s1.count, sorted_values.count - i)
            XCTAssertEqual(s2.count, sorted_values.count)
            assertEqual(s1, sorted_values.suffix(sorted_values.count - i))
            assertEqual(s2, sorted_values)

            XCTAssertEqual(s1.remove(v), v)

            XCTAssertEqual(s1.count, sorted_values.count - i - 1)
            assertEqual(s1, sorted_values.suffix(sorted_values.count - i - 1))
            assertEqual(s2, sorted_values)
        }
    }

    final func testRemoveFirst() {
        var s: SortedSet = ["d", "b", "a", "c"]
        assertEqual(s, ["a", "b", "c", "d"])

        XCTAssertEqual(s.removeFirst(), "a")
        assertEqual(s, ["b", "c", "d"])

        XCTAssertEqual(s.removeFirst(), "b")
        assertEqual(s, ["c", "d"])

        XCTAssertEqual(s.removeFirst(), "c")
        assertEqual(s, ["d"])

        XCTAssertEqual(s.removeFirst(), "d")
        assertEqual(s, [])
        XCTAssertTrue(s.isEmpty)
        XCTAssertEqual(s.count, 0)
    }

    final func testRemoveLast() {
        var s: SortedSet = ["d", "b", "a", "c"]
        assertEqual(s, ["a", "b", "c", "d"])

        XCTAssertEqual(s.removeLast(), "d")
        assertEqual(s, ["a", "b", "c"])

        XCTAssertEqual(s.removeLast(), "c")
        assertEqual(s, ["a", "b"])

        XCTAssertEqual(s.removeLast(), "b")
        assertEqual(s, ["a"])

        XCTAssertEqual(s.removeLast(), "a")
        assertEqual(s, [])
        XCTAssertTrue(s.isEmpty)
        XCTAssertEqual(s.count, 0)
    }

    final func testPopFirst() {
        var s: SortedSet = ["d", "b", "a", "c"]
        assertEqual(s, ["a", "b", "c", "d"])

        XCTAssertEqual(s.popFirst(), "a")
        assertEqual(s, ["b", "c", "d"])

        XCTAssertEqual(s.popFirst(), "b")
        assertEqual(s, ["c", "d"])

        XCTAssertEqual(s.popFirst(), "c")
        assertEqual(s, ["d"])

        XCTAssertEqual(s.popFirst(), "d")
        assertEqual(s, [])
        XCTAssertTrue(s.popFirst() == nil)
        XCTAssertTrue(s.isEmpty)
        XCTAssertEqual(s.count, 0)
    }

    final func testPopLast() {
        var s: SortedSet = ["d", "b", "a", "c"]
        assertEqual(s, ["a", "b", "c", "d"])

        XCTAssertEqual(s.popLast(), "d")
        assertEqual(s, ["a", "b", "c"])

        XCTAssertEqual(s.popLast(), "c")
        assertEqual(s, ["a", "b"])

        XCTAssertEqual(s.popLast(), "b")
        assertEqual(s, ["a"])

        XCTAssertEqual(s.popLast(), "a")
        assertEqual(s, [])
        XCTAssertTrue(s.popLast() == nil)
        XCTAssertTrue(s.isEmpty)
        XCTAssertEqual(s.count, 0)
    }

    final func testInsertAndRemove() {
        let sorted_values = [
            "!", "\"", "#", "$", "%", "&", "\'", "(", ")", "*", "+", ",", "-",
            ".", "/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":",
            ";", "<", "=", ">", "?", "@", "A", "B", "C", "D", "E", "F", "G",
            "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
            "U", "V", "W", "X", "Y", "Z", "[", "\\", "]", "^", "_", "`", "a",
            "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n",
            "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{",
            "|", "}", "~"
        ]
        let values_to_insert = [
            "q", "Q", "u", ">", "A", "_", "\\", "a", "0", "B", "=", "|", "L",
            "-", "y", "&", "z", "T", "/", ";", "h", "1", "p", "4", "x", "R",
            "K", "w", "n", "W", "\"", ",", "H", "t", "^", "`", "m", "+", "M",
            "J", "]", "*", "%", "?", "$", "S", "P", "v", "}", "#", ":", "!",
            "7", "\'", "d", "C", "b", "@", "e", "X", "F", "6", "i", "s", "j",
            "U", "{", "f", "Z", "N", "E", "c", "g", "o", "3", "Y", "I", "r",
            ")", "9", "<", "8", "D", "~", ".", "[", "5", "k", "O", "(", "l",
            "2", "G", "V"
        ]
        let values_to_remove = [
            "m", "(", "]", "$", "*", "e", "%", "=", "&", "3", "k", "~", "4",
            ":", "H", "`", "\'", "z", "x", "5", "S", "P", "p", "J", "@", "F",
            "_", "o", "Q", "M", "1", "r", "d", "n", "\\", "/", "f", "y", "I",
            "T", "C", "w", "j", "N", "v", "a", "\"", "-", "c", "s", "+", "U",
            "[", "g", "Y", "Z", ">", "{", "7", "G", "|", "A", "9", "W", "B",
            "O", "V", "t", "u", ")", "#", "K", "!", "D", "?", "q", "R", "E",
            "<", "h", "2", "0", "X", ",", "L", "6", "^", "l", "}", ";", "i",
            "8", "b", "."
        ]
        let expected_s2 = sorted_values

        let s1: SortedSet<String> = []
        var s2 = s1
        for (i, v) in values_to_insert.enumerated() {
            XCTAssertEqual(s2.count, i)

            s2.insert(v)

            XCTAssertTrue(s1.isEmpty)
            XCTAssertEqual(s1.count, 0)
            XCTAssertEqual(s2.count, i + 1)
            XCTAssertEqual(s2[s2.firstIndex(of: v)!], v)
            assertEqual(s2, values_to_insert.prefix(i + 1).sorted())
        }

        assertEqual(s2, expected_s2)

        var s3 = s2
        for (i, v) in values_to_remove.enumerated() {
            XCTAssertEqual(s3.count, values_to_remove.count - i)

            XCTAssertEqual(s3.remove(v), v)

            XCTAssertTrue(s1.isEmpty)
            XCTAssertEqual(s1.count, 0)
            XCTAssertEqual(s2.count, expected_s2.count)
            XCTAssertEqual(s3.count, values_to_remove.count - i - 1)
            XCTAssertNil(s3.firstIndex(of: v))
            assertEqual(
                s3,
                values_to_remove.suffix(
                    values_to_remove.count - i - 1).sorted())
        }

        assertEqual(s1, [])
        assertEqual(s2, expected_s2)
        assertEqual(s3, [])
    }

    final func testUpdate() {
        var s1: SortedSet<Value> = [
            Value(v: 4, str: "d"), Value(v: 2, str: "b"),
            Value(v: 1, str: "a"), Value(v: 3, str: "c")
        ]
        let s2 = s1

        let expected_s1 = [
            Value(v: 1, str: "aa"), Value(v: 2, str: "bb"),
            Value(v: 3, str: "cc"), Value(v: 4, str: "dd"),
            Value(v: 5, str: "e")
        ]
        let expected_s2 = [
            Value(v: 1, str: "a"), Value(v: 2, str: "b"),
            Value(v: 3, str: "c"), Value(v: 4, str: "d")
        ]

        XCTAssertEqual(s1, s2)
        assertNotEqual(s1, expected_s1)

        let a = s1.update(with: Value(v: 1, str: "aa"))
        XCTAssertEqual(a?.v, 1)
        XCTAssertEqual(a?.str, "a")
        let b = s1.update(with: Value(v: 2, str: "bb"))
        XCTAssertEqual(b?.v, 2)
        XCTAssertEqual(b?.str, "b")
        let c = s1.update(with: Value(v: 3, str: "cc"))
        XCTAssertEqual(c?.v, 3)
        XCTAssertEqual(c?.str, "c")
        let d = s1.update(with: Value(v: 4, str: "dd"))
        XCTAssertEqual(d?.v, 4)
        XCTAssertEqual(d?.str, "d")
        XCTAssertNil(s1.update(with: Value(v: 5, str: "e")))

        XCTAssertNotEqual(s1, s2)
        assertEqual(s1, expected_s1)
        assertEqual(s2, expected_s2)
    }

    final func testUpdateWithHint() {
        var s1: SortedSet<Value> = [
            Value(v: 4, str: "d"), Value(v: 2, str: "b"),
            Value(v: 1, str: "a"), Value(v: 3, str: "c")
        ]
        let s2 = s1

        let expected_s1 = [
            Value(v: 1, str: "aa"), Value(v: 2, str: "bb"),
            Value(v: 3, str: "cc"), Value(v: 4, str: "dd"),
            Value(v: 5, str: "e")
        ]
        let expected_s2 = [
            Value(v: 1, str: "a"), Value(v: 2, str: "b"),
            Value(v: 3, str: "c"), Value(v: 4, str: "d")
        ]

        XCTAssertEqual(s1, s2)
        assertNotEqual(s1, expected_s1)

        let a = s1.update(with: Value(v: 1, str: "aa"), hint: s1.startIndex)
        XCTAssertEqual(a?.v, 1)
        XCTAssertEqual(a?.str, "a")
        let b = s1.update(with: Value(v: 2, str: "bb"), hint: s1.startIndex)
        XCTAssertEqual(b?.v, 2)
        XCTAssertEqual(b?.str, "b")
        let c = s1.update(with: Value(v: 3, str: "cc"), hint: s1.endIndex)
        XCTAssertEqual(c?.v, 3)
        XCTAssertEqual(c?.str, "c")
        let d = s1.update(with: Value(v: 4, str: "dd"), hint: s1.endIndex)
        XCTAssertEqual(d?.v, 4)
        XCTAssertEqual(d?.str, "d")
        XCTAssertNil(
            s1.update(with: Value(v: 5, str: "e"), hint: s1.endIndex))

        XCTAssertNotEqual(s1, s2)
        assertEqual(s1, expected_s1)
        assertEqual(s2, expected_s2)
    }

    final func testUnion() {
        let s1: SortedSet = ["d", "a", "c"]
        let other = ["c", "w", "u", "r", "b"]

        let expected_s1 = ["a", "c", "d"]
        let expected_s2_s3 = ["a", "b", "c", "d", "r", "u", "w"]

        let s2 = s1.union(other)
        let s3 = s1.union(SortedSet(other))

        assertEqual(s1, expected_s1)
        assertEqual(s2, expected_s2_s3)
        assertEqual(s3, expected_s2_s3)
    }

    final func testFormUnion() {
        var s1: SortedSet = ["d", "a", "c"]
        var s2 = s1
        let s3 = s1
        let other = ["c", "w", "u", "r", "b"]

        let expected_s1_s2 = ["a", "b", "c", "d", "r", "u", "w"]
        let expected_s3 = ["a", "c", "d"]

        s1.formUnion(other)
        s2.formUnion(SortedSet(other))

        assertEqual(s1, expected_s1_s2)
        assertEqual(s2, expected_s1_s2)
        assertEqual(s3, expected_s3)
    }

    final func testIntersection() {
        let s1: SortedSet = ["d", "a", "g", "b"]
        let other = ["f", "z", "d", "a"]

        let expected_s1 = ["a", "b", "d", "g"]
        let expected_s2_s3 = ["a", "d"]

        let s2 = s1.intersection(other)
        let s3 = s1.intersection(SortedSet(other))

        assertEqual(s1, expected_s1)
        assertEqual(s2, expected_s2_s3)
        assertEqual(s3, expected_s2_s3)
    }

    final func testFormIntersection() {
        var s1: SortedSet = ["d", "a", "g", "b"]
        var s2: SortedSet = ["d", "a", "g", "b"]
        let other = ["f", "z", "d", "a"]

        let expected_s1_s2 = ["a", "d"]

        s1.formIntersection(other)
        s2.formIntersection(SortedSet(other))

        assertEqual(s1, expected_s1_s2)
        assertEqual(s2, expected_s1_s2)
    }

    final func testSymmetricDifference() {
        let s1: SortedSet = ["d", "a", "g", "b"]
        let other1 = ["f", "z", "d", "a"]
        let other2 = ["e", "d", "a", "c"]

        let expected_s1 = ["a", "b", "d", "g"]
        let expected_s2_s3 = ["b", "f", "g", "z"]
        let expected_s4_s5 = ["b", "c", "e", "g"]

        let s2 = s1.symmetricDifference(other1)
        let s3 = s1.symmetricDifference(SortedSet(other1))
        let s4 = s1.symmetricDifference(other2)
        let s5 = s1.symmetricDifference(SortedSet(other2))

        assertEqual(s1, expected_s1)
        assertEqual(s2, expected_s2_s3)
        assertEqual(s3, expected_s2_s3)
        assertEqual(s4, expected_s4_s5)
        assertEqual(s5, expected_s4_s5)
    }

    final func testFormSymmetricDifference() {
        let s1: SortedSet = ["d", "a", "g", "b"]
        var s2 = s1
        var s3 = s1
        var s4 = s1
        var s5 = s1
        let other1 = ["f", "z", "d", "a"]
        let other2 = ["e", "d", "a", "c"]

        let expected_s1 = ["a", "b", "d", "g"]
        let expected_s2_s3 = ["b", "f", "g", "z"]
        let expected_s4_s5 = ["b", "c", "e", "g"]

        s2.formSymmetricDifference(other1)
        s3.formSymmetricDifference(SortedSet(other1))
        s4.formSymmetricDifference(other2)
        s5.formSymmetricDifference(SortedSet(other2))

        assertEqual(s1, expected_s1)
        assertEqual(s2, expected_s2_s3)
        assertEqual(s3, expected_s2_s3)
        assertEqual(s4, expected_s4_s5)
        assertEqual(s5, expected_s4_s5)
    }

    final func testSubtracting() {
        let s1: SortedSet = ["e", "c", "g", "a", "f", "b"]
        let other = ["c", "a", "d"]

        let expected_s1 = ["a", "b", "c", "e", "f", "g"]
        let expected_s2_s3 = ["b", "e", "f", "g"]

        let s2 = s1.subtracting(other)
        let s3 = s1.subtracting(SortedSet(other))

        assertEqual(s1, expected_s1)
        assertEqual(s2, expected_s2_s3)
        assertEqual(s3, expected_s2_s3)
    }

    final func testIsDisjoint() {
        let a1 = ["d", "a", "c", "h"]
        let a2 = ["g", "e", "b", "i"]
        let a3 = ["h", "a", "d"]
        let s1 = SortedSet(a1)
        let s2 = SortedSet(a2)
        let s3 = SortedSet(a3)

        XCTAssertTrue(s1.isDisjoint(with: a2))
        XCTAssertTrue(s1.isDisjoint(with: s2))

        XCTAssertFalse(s1.isDisjoint(with: a1))
        XCTAssertFalse(s1.isDisjoint(with: s1))

        XCTAssertFalse(s1.isDisjoint(with: a3))
        XCTAssertFalse(s1.isDisjoint(with: s3))
    }

    final func testIncludes() {
        let s1: SortedSet = ["c", "b", "a", "e", "d"]
        let s2: SortedSet = ["b", "a", "d"]
        let s3: SortedSet = ["d", "c"]
        let s4: SortedSet = ["a", "b", "e"]

        XCTAssertTrue(s1.includes(s2))
        XCTAssertFalse(s2.includes(s1))
        XCTAssertFalse(s2.includes(s3))
        XCTAssertFalse(s2.includes(s4))
    }

    final func testIsSuperset() {
        let a1 = ["c", "b", "a", "e", "d"]
        let a2 = ["b", "a", "d"]
        let a3 = ["c", "b", "e"]
        let s1 = SortedSet(a1)
        let s2 = SortedSet(a2)
        let s3 = SortedSet(a3)

        XCTAssertTrue(s1.isSuperset(of: a2))
        XCTAssertTrue(s1.isSuperset(of: s2))

        XCTAssertFalse(s2.isSuperset(of: a1))
        XCTAssertFalse(s2.isSuperset(of: s1))

        XCTAssertFalse(s3.isSuperset(of: a2))
        XCTAssertFalse(s3.isSuperset(of: s2))
    }

    final func testIsStrictSuperset() {
        let a1 = ["c", "b", "a", "e", "d"]
        let a2 = ["b", "a", "d"]
        let a3 = ["c", "b", "e"]
        let s1 = SortedSet(a1)
        let s2 = SortedSet(a2)
        let s3 = SortedSet(a3)

        XCTAssertTrue(s1.isStrictSuperset(of: a2))
        XCTAssertTrue(s1.isStrictSuperset(of: s2))

        XCTAssertFalse(s1.isStrictSuperset(of: a1))
        XCTAssertFalse(s1.isStrictSuperset(of: s1))

        XCTAssertFalse(s3.isStrictSuperset(of: a2))
        XCTAssertFalse(s3.isStrictSuperset(of: s2))
    }

    final func testIsSubset() {
        let a1 = ["c", "b", "a", "e", "d"]
        let a2 = ["b", "a", "d"]
        let a3 = ["c", "b", "e"]
        let s1 = SortedSet(a1)
        let s2 = SortedSet(a2)
        let s3 = SortedSet(a3)

        XCTAssertTrue(s2.isSubset(of: a1))
        XCTAssertTrue(s2.isSubset(of: s1))

        XCTAssertFalse(s1.isSubset(of: a2))
        XCTAssertFalse(s1.isSubset(of: s2))

        XCTAssertFalse(s3.isSubset(of: a2))
        XCTAssertFalse(s3.isSubset(of: s2))
    }

    final func testIsStrictSubset() {
        let a1 = ["c", "b", "a", "e", "d"]
        let a2 = ["b", "a", "d"]
        let a3 = ["c", "b", "e"]
        let s1 = SortedSet(a1)
        let s2 = SortedSet(a2)
        let s3 = SortedSet(a3)

        XCTAssertTrue(s2.isStrictSubset(of: a1))
        XCTAssertTrue(s2.isStrictSubset(of: s1))

        XCTAssertFalse(s1.isStrictSubset(of: a1))
        XCTAssertFalse(s1.isStrictSubset(of: s1))

        XCTAssertFalse(s3.isStrictSubset(of: a2))
        XCTAssertFalse(s3.isStrictSubset(of: s2))
    }

    final func testDescription() {
        let empty: SortedSet<String> = []
        let s: SortedSet<String> = ["d", "b", "a", "c"]

        let expected_empty_description = "[]"
        let expected_empty_debug_description = "SortedSet([])"
        let expected_description = "[\"a\", \"b\", \"c\", \"d\"]"
        let expected_debug_description =
            "SortedSet([\"a\", \"b\", \"c\", \"d\"])"

        XCTAssertEqual(empty.description, expected_empty_description)
        XCTAssertEqual(
            empty.debugDescription, expected_empty_debug_description)

        XCTAssertEqual(s.description, expected_description)
        XCTAssertEqual(s.debugDescription, expected_debug_description)
    }

    final func testEncodeAndDecode() {
        let s1: SortedSet = ["d", "b", "a", "c"]
        let expected_s1_s2 = ["a", "b", "c", "d"]

        assertEqual(s1, expected_s1_s2)

        let encoder = JSONEncoder()
        let data = try! encoder.encode(s1)

        let decoder = JSONDecoder()
        let s2 = try! decoder.decode(type(of: s1), from: data)

        assertEqual(s2, expected_s1_s2)
    }

    #if os(Linux)
    static var allTests = [
        ("testInit", testInit),
        ("testInitSequence", testInitSequence),
        ("testFilter", testFilter),
        ("testRemoveAt", testRemoveAt),
        ("testRemoveAll", testRemoveAll),
        ("testLowerBoundAndUpperBound", testLowerBoundAndUpperBound),
        ("testInsertWithHint", testInsertWithHint),
        ("testEquatable", testEquatable),
        ("testComparable", testComparable),
        ("testHashable", testHashable),
        ("testMinMax", testMinMax),
        ("testContains", testContains),
        ("testIndex", testIndex),
        ("testIndexHashable", testIndexHashable),
        ("testInsert", testInsert),
        ("testRemove", testRemove),
        ("testRemoveFirst", testRemoveFirst),
        ("testRemoveLast", testRemoveLast),
        ("testPopFirst", testPopFirst),
        ("testPopLast", testPopLast),
        ("testInsertAndRemove", testInsertAndRemove),
        ("testUpdate", testUpdate),
        ("testUpdateWithHint", testUpdateWithHint),
        ("testUnion", testUnion),
        ("testFormUnion", testFormUnion),
        ("testIntersection", testIntersection),
        ("testFormIntersection", testFormIntersection),
        ("testSymmetricDifference", testSymmetricDifference),
        ("testFormSymmetricDifference", testFormSymmetricDifference),
        ("testSubtracting", testSubtracting),
        ("testIsDisjoint", testIsDisjoint),
        ("testIncludes", testIncludes),
        ("testIsSuperset", testIsSuperset),
        ("testIsStrictSuperset", testIsStrictSuperset),
        ("testIsSubset", testIsSubset),
        ("testIsStrictSubset", testIsStrictSubset),
        ("testDescription", testDescription),
        ("testEncodeAndDecode", testEncodeAndDecode),
    ]
    #endif // os(Linux)
}
