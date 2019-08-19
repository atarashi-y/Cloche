//
// XCTestCase+Extensions.swift
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

import XCTest

extension XCTestCase {
    final func assertEqual<
        Sequence1: Sequence, Sequence2: Sequence,
        Key: Equatable, Value: Equatable
        >(_ expression1: @autoclosure () throws -> Sequence1,
          _ expression2: @autoclosure () throws -> Sequence2,
          _ message: @autoclosure () -> String = "",
        file: StaticString = #file, line: UInt = #line)
        where Sequence1.Element == (key: Key, value: Value),
              Sequence2.Element == (Key, Value) {
        XCTAssertTrue(
            try expression1().elementsEqual(try expression2()) {
                x, y in x.key == y.0 && x.value == y.1
            }, message(), file: file, line: line)
    }

    final func assertNotEqual<
        Sequence1: Sequence, Sequence2: Sequence, T: Equatable
        >(_ expression1: @autoclosure () throws -> Sequence1,
          _ expression2: @autoclosure () throws -> Sequence2,
          _ message: @autoclosure () -> String = "",
        file: StaticString = #file, line: UInt = #line)
        where Sequence1.Element == T, Sequence2.Element == T {
        XCTAssertFalse(
            try expression1().elementsEqual(try expression2()),
            message(), file: file, line: line)
    }

    final func assertEqual<
        Sequence1: Sequence, Sequence2: Sequence, T: Equatable
        >(_ expression1: @autoclosure () throws -> Sequence1,
          _ expression2: @autoclosure () throws -> Sequence2,
          _ message: @autoclosure () -> String = "",
        file: StaticString = #file, line: UInt = #line)
        where Sequence1.Element == T, Sequence2.Element == T {
        XCTAssertTrue(
            try expression1().elementsEqual(try expression2()),
            message(), file: file, line: line)
    }

    final func assertLessThan<
        Sequence1: Sequence, Sequence2: Sequence, T: Comparable
        >(_ expression1: @autoclosure () throws -> Sequence1,
          _ expression2: @autoclosure () throws -> Sequence2,
          _ message: @autoclosure () -> String = "",
        file: StaticString = #file, line: UInt = #line)
        where Sequence1.Element == T, Sequence2.Element == T {
        XCTAssertTrue(
            try expression1().lexicographicallyPrecedes(try expression2()),
            message(), file: file, line: line)
    }

    final func assertNotLessThan<
        Sequence1: Sequence, Sequence2: Sequence, T: Comparable
        >(_ expression1: @autoclosure () throws -> Sequence1,
          _ expression2: @autoclosure () throws -> Sequence2,
          _ message: @autoclosure () -> String = "",
        file: StaticString = #file, line: UInt = #line)
        where Sequence1.Element == T, Sequence2.Element == T {
        XCTAssertFalse(
            try expression1().lexicographicallyPrecedes(try expression2()),
            message(), file: file, line: line)
    }
}
