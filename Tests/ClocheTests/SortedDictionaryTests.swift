//
// SortedDictionaryTests.swift
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
import Cloche

final class SortedDictionaryTests : XCTestCase {
    final func testInit() {
        let d = SortedDictionary<Int, Int>()

        XCTAssertEqual(d.isEmpty, true)
        XCTAssertEqual(d.count, 0)
        XCTAssertEqual(d.startIndex, d.endIndex)
        XCTAssertFalse(d.startIndex < d.endIndex)

        var i = d.makeIterator()
        XCTAssertTrue(i.next() == nil)
    }

    final func testInitUniqueKeysWithValues() {
        let keys_and_values = [("c", 3), ("b", 2), ("d", 4), ("a", 1)]
        let d = SortedDictionary(uniqueKeysWithValues: keys_and_values)
        let expected_d = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]

        XCTAssertNotEqual(d.isEmpty, true)
        XCTAssertEqual(d.count, expected_d.count)
        assertEqual(d, expected_d)
        XCTAssertTrue(d[d.startIndex] == expected_d[expected_d.startIndex])
    }

    final func testInitKeysAndValuesUniquingKeysWith() {
        let keys_and_values = [("b", 2), ("a", 1), ("a", 3), ("b", 4)]
        let d1 = SortedDictionary(keys_and_values) { old, _ in old }
        let d2 = SortedDictionary(keys_and_values) { _, new in new }
        let expected_d1 = [("a", 1), ("b", 2)]
        let expected_d2 = [("a", 3), ("b", 4)]

        assertEqual(d1, expected_d1)
        assertEqual(d2, expected_d2)
    }

    final func testInitGroupingBy() {
        let countries = ["Singapore", "Canada", "Sweden", "Egypt", "Croatia"]
        let d = SortedDictionary(grouping: countries) {
            country in String(country.first!)
        }
        let expected_d = [
            ("C", ["Canada", "Croatia"]),
            ("E", ["Egypt"]),
            ("S", ["Singapore", "Sweden"])
        ]

        assertEqual(d, expected_d)
    }

    final func testUpdateValueForKey() {
        let d1: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]
        var d2 = d1

        let expected_d1 = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
        let expected_d2 = [
            ("a", 11), ("b", 22), ("c", 33), ("d", 44), ("e", 55), ("f", 66)
        ]

        XCTAssertEqual(d2.updateValue(11, forKey: "a"), 1)
        XCTAssertEqual(d2.updateValue(22, forKey: "b"), 2)
        XCTAssertEqual(d2.updateValue(33, forKey: "c"), 3)
        XCTAssertEqual(d2.updateValue(44, forKey: "d"), 4)
        XCTAssertEqual(d2.updateValue(55, forKey: "e"), nil)
        XCTAssertEqual(d2.updateValue(66, forKey: "f"), nil)

        assertEqual(d1, expected_d1)
        assertEqual(d2, expected_d2)
    }

    final func testUpdateValueAtIndex() {
        let d1: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]
        var d2 = d1

        let expected_d1 = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
        let expected_d2 = [("a", 11), ("b", 22), ("c", 33), ("d", 44)]

        XCTAssertEqual(d2.updateValue(11, at: d2.startIndex), 1)
        XCTAssertEqual(
            d2.updateValue(22, at: d2.index(after: d2.startIndex)), 2)
        XCTAssertEqual(
            d2.updateValue(33, at: d2.index(d2.startIndex, offsetBy: 2)), 3)
        XCTAssertEqual(
            d2.updateValue(44, at: d2.index(before: d2.endIndex)), 4)

        assertEqual(d1, expected_d1)
        assertEqual(d2, expected_d2)
    }

    final func testMergeKeysAndValuesUniquingKeysWith() {
        let d1: SortedDictionary = ["d": 4, "a": 1, "c": 3]
        let new_keys_and_values = [
            ("c", 33), ("w", 23), ("u", 21), ("r", 18), ("b", 22)
        ]
        let expected_d1 = [("a", 1), ("c", 3), ("d", 4)]
        let expected_d2_d4 = [
            ("a", 1), ("b", 22), ("c", 3), ("d", 4), ("r", 18), ("u", 21),
            ("w", 23)
        ]
        let expected_d3_d5 = [
            ("a", 1), ("b", 22), ("c", 33), ("d", 4), ("r", 18), ("u", 21),
            ("w", 23)
        ]

        var d2 = d1
        d2.merge(new_keys_and_values) { old, _ in old }

        var d3 = d1
        d3.merge(new_keys_and_values) { _, new in new }

        var d4 = d1
        d4.merge(SortedDictionary(uniqueKeysWithValues: new_keys_and_values)) {
            old, _ in old
        }

        var d5 = d1
        d5.merge(SortedDictionary(uniqueKeysWithValues: new_keys_and_values)) {
            _, new in new
        }

        assertEqual(d1, expected_d1)
        assertEqual(d2, expected_d2_d4)
        assertEqual(d3, expected_d3_d5)
        assertEqual(d4, expected_d2_d4)
        assertEqual(d5, expected_d3_d5)
    }

    final func testMergeOtherUniquingKeysWith() {
        let d1: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]
        let new_keys_and_values: SortedDictionary = ["d": 44, "e": 5, "b": 22]
        let expected_d1 = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
        let expected_d2 = [("a", 1), ("b", 2), ("c", 3), ("d", 4), ("e", 5)]
        let expected_d3 = [("a", 1), ("b", 22), ("c", 3), ("d", 44), ("e", 5)]

        var d2 = d1
        d2.merge(new_keys_and_values) { old, _ in old }

        var d3 = d1
        d3.merge(new_keys_and_values) { _, new in new }

        assertEqual(d1, expected_d1)
        assertEqual(d2, expected_d2)
        assertEqual(d3, expected_d3)
    }

    final func testMergingKeysAndValuesUniquingKeysWith() {
        let d1: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]
        let new_keys_and_values = [("d", 44), ("e", 5), ("b", 22)]
        let expected_d1 = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
        let expected_d2 = [("a", 1), ("b", 2), ("c", 3), ("d", 4), ("e", 5)]
        let expected_d3 = [("a", 1), ("b", 22), ("c", 3), ("d", 44), ("e", 5)]

        let d2 = d1.merging(new_keys_and_values) { old, _ in old }
        let d3 = d1.merging(new_keys_and_values) { _, new in new }

        assertEqual(d1, expected_d1)
        assertEqual(d2, expected_d2)
        assertEqual(d3, expected_d3)
    }

    final func testMergingOtherUniquingKeysWith() {
        let d1: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]
        let new_keys_and_values: SortedDictionary = ["d": 44, "e": 5, "b": 22]
        let expected_d1 = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
        let expected_d2 = [("a", 1), ("b", 2), ("c", 3), ("d", 4), ("e", 5)]
        let expected_d3 = [("a", 1), ("b", 22), ("c", 3), ("d", 44), ("e", 5)]

        let d2 = d1.merging(new_keys_and_values) { old, _ in old }
        let d3 = d1.merging(new_keys_and_values) { _, new in new }

        assertEqual(d1, expected_d1)
        assertEqual(d2, expected_d2)
        assertEqual(d3, expected_d3)
    }

    final func testSubscriptKey() {
        var d: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]

        XCTAssertEqual(d["a"], 1)
        XCTAssertEqual(d["b"], 2)
        XCTAssertEqual(d["c"], 3)
        XCTAssertEqual(d["d"], 4)
        XCTAssertEqual(d["e"], nil)
        XCTAssertEqual(d["A"], nil)
        XCTAssertEqual(d.count, 4)

        d["e"] = 6
        XCTAssertEqual(d.count, 5)
        XCTAssertEqual(d["e"], 6)
        d["e"] = 7
        XCTAssertEqual(d.count, 5)
        XCTAssertEqual(d["e"], 7)

        d["e"] = nil
        d["a"] = nil
        XCTAssertEqual(d.count, 3)
        XCTAssertNil(d["a"])
        XCTAssertNil(d["e"])
    }

    final func testSubscriptKeyDefault() {
        let d1: SortedDictionary = ["b": [2], "d": [4], "a": [1], "c": [3]]
        let expected_d1 = [("a", [1]), ("b", [2]), ("c", [3]), ("d", [4])]
        let expected_d2 =
            [("a", [1]), ("b", [2]), ("c", [3]), ("d", [4, 5]), ("e", [7, 6])]

        var d2 = d1
        XCTAssertEqual(d2.count, d1.count)
        XCTAssertEqual(d2["e", default:[]], [])
        XCTAssertEqual(d2["d", default:[]], [4])
        XCTAssertEqual(d2.count, d1.count)

        d2["e", default: []].append(7)
        d2["e", default: []].append(6)
        d2["d", default: []].append(5)
        assertEqual(d1, expected_d1)
        assertEqual(d2, expected_d2)
    }

    final func testSubscriptKeyDefaultHint() {
        let d1: SortedDictionary = ["B": [-2]]
        var d2 = d1
        let expected_d1 = [("B", [-2])]
        let expected_d2 = [
            ("A", [-1]), ("B", [-2]), ("a", [1, 11, 12]), ("b", [2]),
            ("c", [3]), ("d", [4]),  ("e", [5]), ("f", [6]), ("g", [7])
        ]

        XCTAssertTrue(d2["B", hint: d2.startIndex, default: []] == [-2])
        XCTAssertTrue(d2["a", hint: d2.startIndex, default: []] == [])
        d2["a", hint: d2.endIndex, default: []].append(1)
        XCTAssertTrue(d2["a", hint: d2.startIndex] == [1])
        d2["a", hint: d2.startIndex, default:[]].append(11)
        XCTAssertTrue(d2["a", hint: d2.startIndex] == [1, 11])
        d2["a", hint: d2.endIndex, default: []].append(12)
        XCTAssertTrue(d2["a", hint: d2.startIndex] == [1, 11, 12])
        d2["b", hint: d2.endIndex, default: []].append(2)
        XCTAssertTrue(d2["b", hint: d2.endIndex] == [2])
        d2["d", hint: d2.endIndex, default: []].append(4)
        XCTAssertTrue(d2["d", hint: d2.endIndex] == [4])
        d2["c", hint: d2.index(forKey: "b")!, default: []].append(3)
        XCTAssertTrue(d2["c", hint: d2.endIndex] == [3])

        d2["f", hint: d2.index(forKey: "d")!, default: []].append(6)
        d2["e", hint: d2.index(forKey: "f")!, default: []].append(5)
        d2["g", hint: d2.startIndex, default: []].append(7)

        d2["A", hint: d2.endIndex, default: []].append(-1)

        assertEqual(d1, expected_d1)
        assertEqual(d2, expected_d2)
    }

    final func testMapValues() {
        let d1: SortedDictionary = ["b": 2, "a": 1, "d": 4, "c": 3]
        let d2: SortedDictionary<String, String?> =
            d1.mapValues { ($0 % 2 == 0) ? String($0 * 2) : nil }
        let expected_d1 = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
        let expected_d2 = [("a", nil), ("b", "4"), ("c", nil), ("d", "8")]

        XCTAssertEqual(d1.count, expected_d1.count)
        assertEqual(d1, expected_d1)
        XCTAssertEqual(d2.count, expected_d2.count)
        assertEqual(d2, expected_d2)
    }

    final func testCompactMapValues() {
        let d: SortedDictionary = ["a": "1", "b": "three", "c": "///4///"]
        let expected_c = [("a", 1)]

        let c = d.compactMapValues { v in Int(v) }
        assertEqual(c, expected_c)
    }

    final func testFilter() {
        let d1: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]
        let d2: SortedDictionary = d1.filter { $0.value % 2 == 0 }
        let expected_d2 = [("b", 2), ("d", 4)]

        XCTAssertEqual(d2.count, 2)
        assertEqual(d2, expected_d2)
    }

    final func testInsertAndRemove() {
        let sorted_keys = [
            "!", "\"", "#", "$", "%", "&", "\'", "(", ")", "*", "+", ",", "-",
            ".", "/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":",
            ";", "<", "=", ">", "?", "@", "A", "B", "C", "D", "E", "F", "G",
            "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
            "U", "V", "W", "X", "Y", "Z", "[", "\\", "]", "^", "_", "`", "a",
            "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n",
            "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{",
            "|", "}", "~"
        ]
        let keys_to_insert = [
            "q", "Q", "u", ">", "A", "_", "\\", "a", "0", "B", "=", "|", "L",
            "-", "y", "&", "z", "T", "/", ";", "h", "1", "p", "4", "x", "R",
            "K", "w", "n", "W", "\"", ",", "H", "t", "^", "`", "m", "+", "M",
            "J", "]", "*", "%", "?", "$", "S", "P", "v", "}", "#", ":", "!",
            "7", "\'", "d", "C", "b", "@", "e", "X", "F", "6", "i", "s", "j",
            "U", "{", "f", "Z", "N", "E", "c", "g", "o", "3", "Y", "I", "r",
            ")", "9", "<", "8", "D", "~", ".", "[", "5", "k", "O", "(", "l",
            "2", "G", "V"
        ]
        let keys_to_remove = [
            "m", "(", "]", "$", "*", "e", "%", "=", "&", "3", "k", "~", "4",
            ":", "H", "`", "\'", "z", "x", "5", "S", "P", "p", "J", "@", "F",
            "_", "o", "Q", "M", "1", "r", "d", "n", "\\", "/", "f", "y", "I",
            "T", "C", "w", "j", "N", "v", "a", "\"", "-", "c", "s", "+", "U",
            "[", "g", "Y", "Z", ">", "{", "7", "G", "|", "A", "9", "W", "B",
            "O", "V", "t", "u", ")", "#", "K", "!", "D", "?", "q", "R", "E",
            "<", "h", "2", "0", "X", ",", "L", "6", "^", "l", "}", ";", "i",
            "8", "b", "."
        ]
        let expected_d2 = sorted_keys.enumerated().map { i, v in (v, i)}
        let value_by_key = Dictionary(uniqueKeysWithValues: expected_d2)

        let d1: SortedDictionary<String, Int> = [:]
        var d2 = d1
        for (i, k) in keys_to_insert.enumerated() {
            XCTAssertEqual(d2.count, i)

            let v = value_by_key[k]!
            d2[k] = v

            XCTAssertTrue(d1.isEmpty)
            XCTAssertEqual(d1.count, 0)
            XCTAssertEqual(d2.count, i + 1)
            XCTAssertEqual(d2[k], v)
            assertEqual(d2.keys, keys_to_insert.prefix(i + 1).sorted())
        }

        assertEqual(d2, expected_d2)

        var d3 = d2
        for (i, k) in keys_to_remove.enumerated() {
            XCTAssertEqual(d3.count, keys_to_remove.count - i)

            d3[k] = nil

            XCTAssertTrue(d1.isEmpty)
            XCTAssertEqual(d1.count, 0)
            XCTAssertEqual(d2.count, expected_d2.count)
            XCTAssertEqual(d3.count, keys_to_remove.count - i - 1)
            XCTAssertNil(d3[k])
            assertEqual(
                d3.keys,
                keys_to_remove.suffix(keys_to_remove.count - i - 1).sorted())
        }

        assertEqual(d1, [])
        assertEqual(d2, expected_d2)
        assertEqual(d3, [])
    }

    final func testRemove() {
        let d1: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]
        let expected_d1 = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
        var d2 = d1
        XCTAssertEqual(d2.removeValue(forKey: "a"), 1)
        XCTAssertEqual(d2.removeValue(forKey: "b"), 2)
        XCTAssertNil(d2.removeValue(forKey: "a"))
        XCTAssertNil(d2.removeValue(forKey: "b"))

        XCTAssertTrue(d1.count == expected_d1.count)
        assertEqual(d1, expected_d1)
        XCTAssertEqual(d2.count, d1.count - 2)
        assertEqual(d2, [("c", 3), ("d", 4)])

        XCTAssertEqual(d2.removeValue(forKey: "c"), 3)
        XCTAssertEqual(d2.removeValue(forKey: "d"), 4)
        XCTAssertNil(d2.removeValue(forKey: "c"))
        XCTAssertNil(d2.removeValue(forKey: "d"))

        XCTAssertTrue(d2.isEmpty)
        XCTAssertEqual(d2.count, 0)
        assertEqual(d2, [])
        XCTAssertTrue(d1.count == expected_d1.count)
        assertEqual(d1, expected_d1)
    }

    final func testRemoveAt() {
        let source = [
            ("m", 13), ("e", 5), ("n", 14), ("k", 11), ("f", 6), ("j", 10),
            ("d", 4), ("h", 8), ("a", 1), ("l", 12), ("b", 2), ("i", 9),
            ("c", 3), ("g", 7)
        ]
        let expected_d1 = [
            ("a", 1), ("b", 2), ("c", 3), ("d", 4), ("e", 5), ("f", 6),
            ("h", 8), ("j", 10), ("k", 11), ("l", 12),
            ("m", 13), ("n", 14)
        ]
        let expected_d3 = [
            ("a", 1), ("b", 2), ("c", 3), ("d", 4), ("e", 5), ("f", 6),
            ("h", 8), ("i", 9), ("j", 10), ("k", 11), ("l", 12),
            ("m", 13), ("n", 14)
        ]

        do {
            var d1 = SortedDictionary(uniqueKeysWithValues: source)

            let g_index = d1.index(d1.startIndex, offsetBy: 6)
            let i_index = d1.index(g_index, offsetBy: 2)
            d1.remove(at: g_index)
            d1.remove(at: i_index)

            assertEqual(d1, expected_d1)
        }

        do {
            var d1 = SortedDictionary(uniqueKeysWithValues: source)
            let d2 = d1
            d1.remove(at: d1.index(forKey: "g")!)
            let d3 = d1
            d1.remove(at: d1.index(forKey: "i")!)

            XCTAssertEqual(d1.count, source.count - 2)
            XCTAssertEqual(d2.count, source.count)
            assertEqual(d1, expected_d1)
            assertEqual(d3, expected_d3)
        }
    }

    final func testRemoveAll() {
        var d1: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]
        let d2 = d1
        let expected_d2 = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]

        XCTAssertEqual(d1, d2)
        assertEqual(d1, expected_d2)
        assertEqual(d2, expected_d2)

        d1.removeAll()

        XCTAssertTrue(d1.isEmpty)
        XCTAssertEqual(d1.count, 0)
        XCTAssertNil(d1.first)
        XCTAssertNil(d1.last)

        XCTAssertFalse(d2.isEmpty)
        XCTAssertEqual(d2.count, expected_d2.count)
        assertEqual(d2, expected_d2)
    }

    final func testPopFirst() {
        var d: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]

        XCTAssertTrue(d.popFirst()! == ("a", 1))
        XCTAssertTrue(d.popFirst()! == ("b", 2))
        XCTAssertTrue(d.popFirst()! == ("c", 3))
        XCTAssertTrue(d.popFirst()! == ("d", 4))
        XCTAssertTrue(d.popFirst() == nil)
        XCTAssertTrue(d.isEmpty)
        XCTAssertEqual(d.count, 0)
    }

    final func testPopLast() {
        var d: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]

        XCTAssertTrue(d.popLast()! == ("d", 4))
        XCTAssertTrue(d.popLast()! == ("c", 3))
        XCTAssertTrue(d.popLast()! == ("b", 2))
        XCTAssertTrue(d.popLast()! == ("a", 1))
        XCTAssertTrue(d.popLast() == nil)
        XCTAssertTrue(d.isEmpty)
        XCTAssertEqual(d.count, 0)
    }

    final func testLowerBoundAndUpperBound() {
        let d: SortedDictionary = ["d": 4, "f": 6, "b": 2, "h": 8, "i": 9]

        XCTAssertTrue(d[d.lowerBound(of: "a")] == ("b", 2))
        XCTAssertTrue(d[d.upperBound(of: "a")] == ("b", 2))
        XCTAssertTrue(d[d.lowerBound(of: "b")] == ("b", 2))
        XCTAssertTrue(d[d.upperBound(of: "b")] == ("d", 4))
        XCTAssertTrue(d[d.lowerBound(of: "d")] == ("d", 4))
        XCTAssertTrue(d[d.upperBound(of: "d")] == ("f", 6))
        XCTAssertEqual(d.lowerBound(of: "j"), d.endIndex)
        XCTAssertEqual(d.upperBound(of: "j"), d.endIndex)
    }

    final func testSubscriptWithHint() {
        let d1: SortedDictionary<String, Int> = [:]
        var d2 = d1
        let expected_d1: [(String, Int)] = []
        let expected_d2 = [
            ("A", 0), ("a", 1), ("b", 2), ("c", 3), ("d", 4), ("e", 5),
            ("f", 6), ("g", 7)
        ]

        d2["a", hint: d2.endIndex] = 0
        XCTAssertTrue(d2["a", hint: d2.startIndex] == 0)
        d2["a", hint: d2.startIndex] = 2
        XCTAssertTrue(d2["a", hint: d2.startIndex] == 2)
        d2["a", hint: d2.endIndex] = 1
        XCTAssertTrue(d2["a", hint: d2.startIndex] == 1)
        d2["b", hint: d2.endIndex] = 3
        XCTAssertTrue(d2["b", hint: d2.startIndex] == 3)
        d2["b", hint: d2.startIndex] = 2
        XCTAssertTrue(d2["b", hint: d2.startIndex] == 2)
        d2["d", hint: d2.endIndex] = 4
        XCTAssertTrue(d2["d", hint: d2.endIndex] == 4)
        d2["c", hint: d2.index(forKey: "b")!] = 3
        XCTAssertTrue(d2["c", hint: d2.endIndex] == 3)

        d2["f", hint: d2.index(forKey: "d")!] = 6
        d2["e", hint: d2.index(forKey: "f")!] = 5
        d2["g", hint: d2.startIndex] = 7

        d2["A", hint: d2.endIndex] = 0

        assertEqual(d1, expected_d1)
        assertEqual(d2, expected_d2)
    }

    final func testKeysAndValues() {
        let empty_d: SortedDictionary<String, Int> = [:]
        let d1: SortedDictionary = ["b": 2, "a": 1, "d": 4, "c": 3]
        let d2 = d1
        let d3: SortedDictionary = ["a": 2, "c": 4, "b": 3, "d": 5]
        var d4 = d1
        d4["e"] = 6
        let d5: SortedDictionary = ["b": 2]

        let expected_d1_d2_d3_keys = ["a", "b", "c", "d"]
        let expected_d4_keys = ["a", "b", "c", "d", "e"]
        let expected_d1_d2_values = [1, 2, 3, 4]
        let expected_d3_values = [2, 3, 4, 5]
        let expected_d4_values = [1, 2, 3, 4, 6]

        XCTAssertEqual(empty_d.keys.count, 0)
        XCTAssertEqual(d1.keys.count, expected_d1_d2_d3_keys.count)
        XCTAssertEqual(d2.keys.count, expected_d1_d2_d3_keys.count)
        XCTAssertEqual(d3.keys.count, expected_d1_d2_d3_keys.count)
        XCTAssertEqual(d4.keys.count, expected_d4_keys.count)
        XCTAssertTrue(empty_d.keys.isEmpty)
        XCTAssertFalse(d1.keys.isEmpty)
        XCTAssertFalse(d2.keys.isEmpty)
        XCTAssertFalse(d3.keys.isEmpty)
        XCTAssertFalse(d4.keys.isEmpty)

        assertEqual(d1.keys, expected_d1_d2_d3_keys)
        assertEqual(d2.keys, expected_d1_d2_d3_keys)
        assertEqual(d3.keys, expected_d1_d2_d3_keys)
        assertEqual(d4.keys, expected_d4_keys)
        XCTAssertEqual(d1.keys, d2.keys)
        XCTAssertEqual(d1.keys, d3.keys)
        XCTAssertNotEqual(d1.keys, d4.keys)
        XCTAssertNotEqual(d2.keys, d4.keys)
        XCTAssertNotEqual(d3.keys, d4.keys)
        XCTAssertFalse(d1.keys < d2.keys)
        XCTAssertFalse(d1.keys < d3.keys)
        XCTAssertLessThan(d1.keys, d4.keys)
        XCTAssertLessThan(d1.keys, d5.keys)

        XCTAssertEqual(empty_d.values.count, 0)
        XCTAssertEqual(d1.values.count, expected_d1_d2_values.count)
        XCTAssertEqual(d2.values.count, expected_d1_d2_values.count)
        XCTAssertEqual(d3.values.count, expected_d3_values.count)
        XCTAssertEqual(d4.values.count, expected_d4_values.count)
        XCTAssertTrue(empty_d.isEmpty)
        XCTAssertFalse(d1.values.isEmpty)
        XCTAssertFalse(d2.values.isEmpty)
        XCTAssertFalse(d3.values.isEmpty)
        XCTAssertFalse(d4.values.isEmpty)

        assertEqual(d1.values, expected_d1_d2_values)
        assertEqual(d2.values, expected_d1_d2_values)
        assertEqual(d3.values, expected_d3_values)
        assertEqual(d4.values, expected_d4_values)
        assertNotEqual(d1.values, d3.values)
        assertNotEqual(d2.values, d3.values)
        assertNotEqual(d1.values, d4.values)
        assertNotEqual(d2.values, d4.values)
    }

    final func testIndex() {
        let d: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]
        XCTAssertNil(d.index(forKey: "e"))
        XCTAssertEqual(d.index(forKey: "a"), d.startIndex)
        XCTAssertLessThan(d.startIndex, d.index(forKey: "b")!)
        XCTAssertLessThan(d.startIndex, d.index(forKey: "c")!)
        XCTAssertLessThan(d.startIndex, d.index(forKey: "d")!)
        XCTAssertEqual(d.index(forKey: "d"), d.index(before: d.endIndex))
        XCTAssertLessThan(d.index(forKey: "a")!, d.endIndex)
        XCTAssertLessThan(d.index(forKey: "b")!, d.endIndex)
        XCTAssertLessThan(d.index(forKey: "c")!, d.endIndex)
        XCTAssertLessThan(d.index(forKey: "d")!, d.endIndex)

        XCTAssertEqual(d.index(d.startIndex, offsetBy: 0), d.startIndex)
        XCTAssertTrue(
            d[d.index(d.startIndex, offsetBy: 0)] == (key: "a", value: 1))
        XCTAssertTrue(
            d[d.index(d.startIndex, offsetBy: 1)] == (key: "b", value: 2))
        XCTAssertTrue(
            d[d.index(d.startIndex, offsetBy: 2)] == (key: "c", value: 3))
        XCTAssertTrue(
            d[d.index(d.startIndex, offsetBy: 3)] == (key: "d", value: 4))
        XCTAssertEqual(d.index(d.startIndex, offsetBy: 4), d.endIndex)
        XCTAssertEqual(d.index(d.endIndex, offsetBy: 0), d.endIndex)
        XCTAssertTrue(
            d[d.index(d.endIndex, offsetBy: -1)] == (key: "d", value: 4))
        XCTAssertTrue(
            d[d.index(d.endIndex, offsetBy: -2)] == (key: "c", value: 3))
        XCTAssertTrue(
            d[d.index(d.endIndex, offsetBy: -3)] == (key: "b", value: 2))
        XCTAssertTrue(
            d[d.index(d.endIndex, offsetBy: -4)] == (key: "a", value: 1))
    }

    final func testIndexHashable() {
        let s: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]
        let index_set = Set(s.indices.map { $0 })

        var i = s.startIndex
        while i != s.endIndex {
            XCTAssertTrue(index_set.contains(i))

            s.formIndex(after: &i)
        }
    }

    final func testMinMax() {
        let d: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]
        XCTAssertTrue(d.min()! == (key: "a", value: 1))
        XCTAssertTrue(d.max()! == (key: "d", value: 4))
        XCTAssertTrue(d[d.startIndex] == (key: "a", value: 1))
        XCTAssertTrue(d[d.index(before: d.endIndex)] == (key: "d", value: 4))
        XCTAssertEqual(d.keys[d.keys.startIndex], "a")
        XCTAssertEqual(d.keys[d.keys.index(before: d.keys.endIndex)], "d")
        XCTAssertEqual(d.values[d.values.startIndex], 1)
        XCTAssertEqual(d.values[d.values.index(before: d.values.endIndex)], 4)
    }

    final func testSorted() {
        let a = [("c", 3), ("b", 2), ("a", 1), ("e", 5), ("d", 4)]
        let d = SortedDictionary(uniqueKeysWithValues: a)
        let expected = [("a", 1), ("b", 2), ("c", 3), ("d", 4), ("e", 5)]

        assertEqual(d.sorted(), expected)
    }

    final func testEquatable() {
        let d1: SortedDictionary = ["c": 3, "d": 4, "a": 1, "b": 2]
        let d2: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]
        let d3: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 4]
        let d4: SortedDictionary = ["d": 4, "b": 2, "a": 1]
        XCTAssertEqual(d1, d1)
        XCTAssertEqual(d1, d2)
        XCTAssertNotEqual(d1, d3)
        XCTAssertNotEqual(d2, d3)
        XCTAssertNotEqual(d1, d4)
        XCTAssertNotEqual(d2, d4)
    }

    final func testComparable() {
        let d1: SortedDictionary = ["c": 3, "d": 4, "a": 1, "b": 2]
        let d2: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]
        let d3: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 4]
        let d4: SortedDictionary = ["d": 4, "b": 2, "a": 1]
        XCTAssertFalse(d1 < d1)
        XCTAssertFalse(d1 < d2)
        XCTAssertLessThan(d1, d3)
        XCTAssertLessThan(d2, d3)
        XCTAssertLessThan(d1, d4)
        XCTAssertLessThan(d2, d4)
    }

    final func testHashable() {
        let d1: SortedDictionary = ["c": 3, "d": 4, "a": 1, "b": 2]
        let d2: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]
        let d3: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 4]
        let d4: SortedDictionary = ["d": 4, "b": 2, "a": 1, "e": 3]
        XCTAssertEqual(d1.hashValue, d2.hashValue)
        XCTAssertNotEqual(d1.hashValue, d3.hashValue)
        XCTAssertNotEqual(d1.hashValue, d4.hashValue)
        XCTAssertNotEqual(d2.hashValue, d3.hashValue)
        XCTAssertNotEqual(d2.hashValue, d4.hashValue)
        XCTAssertNotEqual(d3.hashValue, d4.hashValue)
    }

    final func testInitDictionary() {
        let d1 = ["d": 4, "b": 2, "a": 1, "c": 3]
        let d2 = SortedDictionary(d1)
        let d2_expected = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]

        assertEqual(d2, d2_expected)
    }

    final func testDescription() {
        let empty: SortedDictionary<String, Int> = [:]
        let d: SortedDictionary<String, Any> =
            ["d": "6", "b": [2, 3], "a": 1, "c": ["4", "5"]]

        let expected_empty_description = "[:]"
        let expected_empty_debug_description = "SortedDictionary([:])"
        let expected_empty_keys_description = "[]"
        let expected_empty_keys_debug_description = "SortedDictionary.Keys([])"
        let expected_empty_values_description = "[]"
        let expected_empty_values_debug_description =
            "SortedDictionary.Values([])"
        let expected_description =
            "[\"a\": 1, \"b\": [2, 3], \"c\": [\"4\", \"5\"], \"d\": \"6\"]"
        let expected_debug_description =
            "SortedDictionary([\"a\": 1, \"b\": [2, 3], \"c\": [\"4\", \"5\"], \"d\": \"6\"])"
        let expected_keys_description = "[\"a\", \"b\", \"c\", \"d\"]"
        let expected_keys_debug_description =
            "SortedDictionary.Keys([\"a\", \"b\", \"c\", \"d\"])"
        let expected_values_description = "[1, [2, 3], [\"4\", \"5\"], \"6\"]"
        let expected_values_debug_description =
            "SortedDictionary.Values([1, [2, 3], [\"4\", \"5\"], \"6\"])"

        XCTAssertEqual(empty.description, expected_empty_description)
        XCTAssertEqual(
            empty.debugDescription, expected_empty_debug_description)

        XCTAssertEqual(empty.keys.description, expected_empty_keys_description)
        XCTAssertEqual(
            empty.keys.debugDescription, expected_empty_keys_debug_description)

        XCTAssertEqual(
            empty.values.description, expected_empty_values_description)
        XCTAssertEqual(
            empty.values.debugDescription,
            expected_empty_values_debug_description)

        XCTAssertEqual(d.description, expected_description)
        XCTAssertEqual(d.debugDescription, expected_debug_description)

        XCTAssertEqual(d.keys.description, expected_keys_description)
        XCTAssertEqual(
            d.keys.debugDescription, expected_keys_debug_description)

        XCTAssertEqual(d.values.description, expected_values_description)
        XCTAssertEqual(
            d.values.debugDescription, expected_values_debug_description)
    }

    final func testEncodeAndDecode() {
        let d1: SortedDictionary = ["d": 4, "b": 2, "a": 1, "c": 3]
        let expected_d1_d2 = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]

        assertEqual(d1, expected_d1_d2)

        let encoder = JSONEncoder()
        let data = try! encoder.encode(d1)

        let decoder = JSONDecoder()
        let d2 = try! decoder.decode(type(of: d1), from: data)

        assertEqual(d2, expected_d1_d2)

        let corrupted_data =
            "[\"a\",1,\"b\",2,\"c\",\"d\",4]".data(using: .ascii)!
        XCTAssertThrowsError(
            try decoder.decode(type(of: d1), from: corrupted_data))
    }

    #if os(Linux)
    static var allTests = [
        ("testInit", testInit),
        ("testInitUniqueKeysWithValues", testInitUniqueKeysWithValues),
        ("testInitKeysAndValuesUniquingKeysWith",
         testInitKeysAndValuesUniquingKeysWith),
        ("testInitGroupingBy", testInitGroupingBy),
        ("testUpdateValueForKey", testUpdateValueForKey),
        ("testUpdateValueAtIndex", testUpdateValueAtIndex),
        ("testMergeKeysAndValuesUniquingKeysWith",
         testMergeKeysAndValuesUniquingKeysWith),
        ("testMergeOtherUniquingKeysWith", testMergeOtherUniquingKeysWith),
        ("testMergingKeysAndValuesUniquingKeysWith",
         testMergingKeysAndValuesUniquingKeysWith),
        ("testMergingOtherUniquingKeysWith", testMergingOtherUniquingKeysWith),
        ("testSubscriptKey", testSubscriptKey),
        ("testSubscriptKeyDefault", testSubscriptKeyDefault),
        ("testSubscriptKeyDefaultHint", testSubscriptKeyDefaultHint),
        ("testMapValues", testMapValues),
        ("testCompactMapValues", testCompactMapValues),
        ("testFilter", testFilter),
        ("testInsertAndRemove", testInsertAndRemove),
        ("testRemove", testRemove),
        ("testRemoveAt", testRemoveAt),
        ("testRemoveAll", testRemoveAll),
        ("testPopFirst", testPopFirst),
        ("testPopLast", testPopLast),
        ("testLowerBoundAndUpperBound", testLowerBoundAndUpperBound),
        ("testSubscriptWithHint", testSubscriptWithHint),
        ("testKeysAndValues", testKeysAndValues),
        ("testIndex", testIndex),
        ("testIndexHashable", testIndexHashable),
        ("testMinMax", testMinMax),
        ("testSorted", testSorted),
        ("testEquatable", testEquatable),
        ("testComparable", testComparable),
        ("testHashable", testHashable),
        ("testInitDictionary", testInitDictionary),
        ("testDescription", testDescription),
        ("testEncodeAndDecode", testEncodeAndDecode),
    ]
    #endif // os(Linux)
}
