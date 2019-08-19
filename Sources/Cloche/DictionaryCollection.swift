//
// DictionaryCollection.swift
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

public protocol DictionaryCollection: Collection {
    associatedtype Key
    associatedtype Value
    associatedtype Element = (key: Key, value: Value)
    associatedtype Keys: Collection & Equatable where Keys.Element == Key
    associatedtype Values: Collection where Values.Element == Value

    var keys: Keys { get }
    var values: Values { get }

    init<S: Sequence>(uniqueKeysWithValues keysAndValues: S)
        where S.Element == (Key, Value)

    init<S: Sequence>(
        _ keysAndValues: S,
        uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows
        where S.Element == (Key, Value)

    @discardableResult
    mutating func updateValue(_ value: Value, forKey key: Key) -> Value?

    mutating func merge<S: Sequence>(
        _ keysAndValues: S,
        uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows
        where S.Element == (Key, Value)

    mutating func merge(
        _ other: Self,
        uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows

    func merging<S: Sequence>(
        _ other: S,
        uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows
        -> Self where S.Element == (Key, Value)

    func merging(
        _ other: Self,
        uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows
        -> Self

    subscript(key: Key) -> Value? { get set }

    subscript(
        key: Key,
        default defaultValue: @autoclosure () -> Value)
        -> Value { get set }

    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self

    @discardableResult
    mutating func removeValue(forKey key: Key) -> Value?

    @discardableResult
    mutating func remove(at position: Index) -> Element

    mutating func removeAll(keepingCapacity keepCapacity: Bool)

    func mapValues<T>(
        _ transform: (Value) throws -> T) rethrows
        -> Self where Self.Value == T

    func compactMapValues<T>(
        _ transform: (Value) throws -> T?) rethrows
        -> Self where Self.Value == T
}

extension Dictionary: DictionaryCollection {}
