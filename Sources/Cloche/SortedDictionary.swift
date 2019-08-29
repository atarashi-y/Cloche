//
// SortedDictionary.swift
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

/// A collection whose elements are key and value pairs, sorted by keys.
///
/// Unlike Dictionary.Values, SortedDictionary.Values doesn't conform
/// to MutableCollection.
///
/// Example
/// =====================================
///
///     let countries = ["Singapore", "Canada", "Sweden", "Egypt", "Croatia"]
///     var d1 = SortedDictionary(grouping: countries) {
///         country in String(country.first!)
///     }
///     print(d1["C"]!)	// ["Canada", "Croatia"]
///     print(d1) // ["C": ["Canada", "Croatia"], "E": ["Egypt"], "S": ["Singapore", "Sweden"]]
///
///     d1["G", default: []].append("Greece")
///     d1["E", default: []].append("Ecuador")
///     print(d1) // ["C": ["Canada", "Croatia"], "E": ["Egypt", "Ecuador"], "G": ["Greece"], "S": ["Singapore", "Sweden"]]
///
///     let d2 = d1.compactMapValues {
///         v in v.count > 1 ? v.map { $0.uppercased() } : nil
///     }
///     print(d2) // ["C": ["CANADA", "CROATIA"], "E": ["EGYPT", "ECUADOR"], "S": ["SINGAPORE", "SWEDEN"]]
///
public struct SortedDictionary<Key: Comparable, Value>: DictionaryCollection {
    /// The element type of a SortedDictionary: a tuple containing an
    /// individual key-value pair.
    public typealias Element = (key: Key, value: Value)

    @usableFromInline
    internal struct _ElementTraits: _RedBlackTreeElementTraits {
        @inlinable
        @inline(__always)
        static func key(of element: Element) -> Key {
            return element.key
        }
    }

    @usableFromInline
    internal typealias _Tree = _RedBlackTree<_ElementTraits>

    @usableFromInline
    internal var _tree: _Tree

    /// Creates an empty SortedDictionary.
    @inlinable
    @inline(__always)
    public init() {
        self._tree = _Tree()
    }

    /// Creates a new SortedDictionary, initializing its contents with
    /// the given key and value pairs `keysAndvalues`.
    ///
    /// ```
    /// let keys_and_values = [("c", 3), ("b", 2), ("d", 4), ("a", 1)]
    /// let d = SortedDictionary(uniqueKeysWithValues: keys_and_values)
    /// // ["a": 1, "b": 2, "c": 3, "d": 4]
    /// ```
    /// - Parameter keysAndValues: A sequence of key and value pairs.
    /// - Returns: A new SortedDictionary initialized with the
    ///   elements of `keysAndValues`.
    /// - Precondition: Keys must be unique.
    @inlinable
    public init<S: Sequence>(uniqueKeysWithValues keysAndValues: S)
        where S.Element == (Key, Value) {
        self.init()

        for (key, value) in keysAndValues {
            let result = self._tree.insert((key: key, value: value))
            if !result.inserted {
                fatalError("Duplicate Key: \(key)")
            }
        }
    }

    /// Creates a new SortedDictionary, initializing its contents with
    /// the given key and value pairs `keysAndValues`, eliminating
    /// values that have duplicate key using closure `combine`.
    ///
    /// ```
    /// let keys_and_values = [("b", 2), ("a", 1), ("a", 3), ("b", 4)]
    /// let d1 = SortedDictionary(keys_and_values) { old, _ in old }
    /// // ["a": 1, "b": 2]
    /// let d2 = SortedDictionary(keys_and_values) { _, new in new }
    /// // ["a": 3, "b": 4]
    /// ```
    ///
    /// - Parameters:
    ///   - keysAndValues: A sequence of key and value pairs.
    ///   - combine: A closure that is called with the old and new
    ///     values for duplicate key.
    @inlinable
    public init<S: Sequence>(
        _ keysAndValues: S,
        uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows
        where S.Element == (Key, Value) {
        self.init()

        try self.merge(keysAndValues, uniquingKeysWith: combine)
    }

    /// Creates a new SortedDictionary, initializing its contents with
    /// the given values and its key retrieving from closure
    /// `keyForValue`.
    ///
    /// ```
    /// let countries = ["Singapore", "Canada", "Sweden", "Egypt", "Croatia"]
    /// let countries_by_first_letter =
    ///     SortedDictionary(grouping: countries) {
    ///         country in String(country.first!)
    ///     }
    /// // ["C": ["Canada", "Croatia"], "E": ["Egypt"],
    /// //  "S": ["Singapore", "Sweden"]]
    /// ```
    ///
    /// - Parameters:
    ///   - values: A sequence of values.
    ///   - keyForValue: A closure that is called with each element in
    ///     `values` and returns its key.
    @inlinable
    public init<S: Sequence>(
        grouping values: S, by keyForValue: (S.Element) throws -> Key) rethrows
        where Value == [S.Element] {
        self.init()

        for value in values {
            let key = try keyForValue(value)
            let (_, position) =
                self._tree.insert(key: key, element: (key: key, value: []))
            position.node!.pointee.element.value.append(value)
        }
    }

    /// Updates the value associated with the key. If the
    /// SortedDictionary does not contain element whose key is
    /// equivalent to `key`, inserts key and value pair.
    ///
    /// - Parameters:
    ///   - value: The new value for `key`.
    ///   - key: The key for `value`.
    /// - Returns: If the new element was inserted, nil, otherwise the
    ///   old value.
    /// - Complexity: O(log *n*), where *n* is the length of the
    ///   SortedDictionary.
    @discardableResult
    @inlinable
    public mutating func updateValue(
        _ value: Value, forKey key: Key) -> Value? {
        self.ensureUnique()

        let position = self.lowerBound(of: key)
        if position != self.endIndex,
            !(key < _ElementTraits.key(of: self[position])) {
            return withUnsafeMutablePointer(
                to: &position._index.node!.pointee.element.value) {
                pointer in
                let old_value = pointer.move()
                pointer.initialize(to: value)
                return old_value
            }
        }

        self._tree.insert((key: key, value: value), hint: position._index)

        return nil
    }

    /// Merges key and value pairs into the SortedDictionary,
    /// eliminating values that have duplicate key using closure
    /// `combine`.
    ///
    /// - Parameters:
    ///   - keysAndValues: A sequence of key and value pairs.
    ///   - combine: A closure that is called with the old and new
    ///     values for duplicate key.
    /// - Complexity: O(*n* * log(*m* + *n*)), where *m* is the length
    ///   of the SortedDictionary and *n* is the length of the
    ///   `keysAndValues`.
    @inlinable
    public mutating func merge<S: Sequence>(
        _ keysAndValues: S,
        uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows
        where S.Element == (Key, Value) {
        self.ensureUnique()

        for (key, value) in keysAndValues {
            let (inserted, position) =
                self._tree.insert((key: key, value: value))
            if !inserted {
                position.node!.pointee.element.value =
                    try combine(position.node!.pointee.element.value, value)
            }
        }
    }

    /// Merges the other SortedDictionary into the SortedDictionary,
    /// eliminating values that have duplicate key using closure
    /// `combine`.
    ///
    /// - Parameters:
    ///   - other: An other SortedDictionary.
    ///   - combine: A closure that is called with the old and new
    ///     values for duplicate key.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedDictionary and *n* is the length of the other
    ///   SortedDictionary.
    @inlinable
    public mutating func merge(
        _ other: SortedDictionary,
        uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        self.ensureUnique()

        var current = self.startIndex
        var other_current = other.startIndex
        while current != self.endIndex && other_current != other.endIndex {
            let x = self[current]
            let y = other[other_current]
            if x.key < y.key {
                self.formIndex(after: &current)
            } else if y.key < x.key {
                self._tree.insert(y, hint: current._index)

                other.formIndex(after: &other_current)
            } else {
                current._index.node!.pointee.element.value =
                    try combine(x.value, y.value)

                self.formIndex(after: &current)
                other.formIndex(after: &other_current)
            }
        }

        for e in other[other_current ..< other.endIndex] {
            self._tree.insertLargest(e)
        }
    }

    /// Creates a new SortedDictionary by merging this
    /// SortedDictionary and the given sequence, eliminating values
    /// that have dupliacte key using closure `combine`.
    ///
    /// - Parameters:
    ///   - keysAndValues: A sequence of key and value pairs.
    ///   - combine: A closure that is called with the old and new
    ///     values for duplicate key.
    /// - Complexity: O(*n* * log(*n*)), where *n* is the length of
    ///   the resulting SortedDictionary.
    @inlinable
    public func merging<S: Sequence>(
        _ other: S,
        uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows
        -> SortedDictionary where S.Element == (Key, Value) {
        var result = self
        try result.merge(other, uniquingKeysWith: combine)

        return result
    }

    /// Creates a new SortedDictionary by merging the SortedDictionary
    /// and the other SortedDictionary, eliminating values that have
    /// dupliacte key using closure `combine`.
    ///
    /// - Parameters:
    ///   - other: An other SortedDictionary.
    ///   - combine: A closure that is called with the old and new
    ///     values for duplicate key.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedDictionary and *n* is the length of the other
    ///   SortedDictionary.
    @inlinable
    public func merging(
        _ other: SortedDictionary,
        uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows
        -> SortedDictionary {
        var result = self
        try result.merge(other, uniquingKeysWith: combine)

        return result
    }

    /// Accesses the value for the specified key.
    ///
    /// If you assign `nil` to the value for the specified key, the
    /// element whose key is equivalent to `key` is deleted.
    ///
    /// - Parameters:
    ///   - key: The key for the value.
    /// - Returns: The value for the specified key if the element
    ///   exists in this SortedDictionary, otherwise nil.
    /// - Complexity: O(log *n*), where *n* is the length of this
    ///   SortedDictionary.
    @inlinable
    public subscript(key: Key) -> Value? {
        @inline(__always)
        _read {
            defer { _fixLifetime(self) }
            yield self._tree.find(key)?.node?.pointee.element.value
        }
        _modify {
            self.ensureUnique()

            let position = self.lowerBound(of: key)
            if position != self.endIndex,
                !(key < _ElementTraits.key(of: self[position])) {
                var value: Value? =
                    withUnsafeMutablePointer(
                        to: &position._index.node!.pointee.element.value) {
                        pointer in pointer.move()
                    }

                defer {
                    if let value = value {
                        withUnsafeMutablePointer(
                            to: &position._index.node!.pointee.element.value) {
                            pointer in pointer.initialize(to: value)
                        }
                    } else {
                        self._tree.deleteKey(at: position._index)
                    }
                }
                yield &value
            } else {
                var value: Value? = nil

                defer {
                    if let value = value {
                        self._tree.insert(
                            (key: key, value: value), hint: position._index)
                    }
                }
                yield &value
            }
        }
    }

    /// Accesses the value for the specified key.
    ///
    /// If the SortedDictionary doesn't contain the element whose key
    /// is equivalent to `key`, the `key` and `defaultValue` pair is
    /// inserted into the SortedDictionary.
    ///
    /// - Parameters:
    ///   - key: The key for the value.
    ///   - default: The default value for the key.
    /// - Returns: The value for the specified key if the element
    ///   exists in this SortedDictionary, or `defaultValue`.
    /// - Complexity: O(log *n*), where *n* is the length of this
    ///   SortedDictionary.
    @inlinable
    public subscript(
        key: Key,
        default defaultValue: @autoclosure () -> Value) -> Value {
        @inline(__always)
        _read {
            defer { _fixLifetime(self) }
            yield self._tree.find(key)?.node?.pointee.element.value
                ?? defaultValue()
        }
        _modify {
            self.ensureUnique()

            let (_, position) =
                self._tree.insert(
                    key: key, element: (key: key, value: defaultValue()))

            defer { _fixLifetime(self) }
            yield &position.node!.pointee.element.value
        }
    }

    /// Creates a new SortedDictionary whose values are transformed by
    /// the given closure `transform`.
    ///
    /// - Parameters:
    ///   - transform: A closure that is called with each value in
    ///     this SortedDictionary and returns a transformed value.
    /// - Returns: A SortedDictionary whose values are transformed.
    /// - Complexity: O(*n*), where *n* is the length of the
    ///   SortedDictionary.
    @inlinable
    public func mapValues<T>(
        _ transform: (Value) throws -> T) rethrows
        -> SortedDictionary<Key, T> {
        var result = SortedDictionary<Key, T>()
        try self._tree.mapValues(into: &result._tree, by: transform)

        return result
    }

    /// Creates a new SortedDictionary whose values are transformed by
    /// the given closure `transform` and the results aren't nil.
    ///
    /// - Parameters:
    ///   - transform: A closure that is called with each value in
    ///     this SortedDictionary and returns an optional transformed
    ///     value.
    /// - Returns: A SortedDictionary whose values are non-nil
    ///   transformed.
    /// - Complexity: O(*m* + *n*), where *m* is the length of the
    ///   original SortedDictionary and *n* is the length of the
    ///   resulting SortedDictionary.
    @inlinable
    public func compactMapValues<T>(
        _ transform: (Value) throws -> T?) rethrows
        -> SortedDictionary<Key, T> {
        return try self.reduce(into: SortedDictionary<Key, T>()) {
            result, x in
            if let value = try transform(x.value) {
                result._tree.insertLargest((key: x.key, value: value))
            }
        }
    }

    /// Creates a new SortedDictionary whose only elements for which
    /// the given closure `isIncluded` returns true.
    ///
    /// - Parameters:
    ///   - isIncluded: A closure that is called with each element in
    ///     this SortedDictionary and returns whether the element
    ///     should be included in the result.
    /// - Returns: A SortedDictionary whose elements for which the
    ///   given closure `isIncluded` returns true.
    /// - Complexity: O(*m* + *n*), where *m* is the length of the
    ///   original SortedDictionary and *n* is the length of the
    ///   resulting SortedDictionary.
    @inlinable
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows
        -> SortedDictionary {
        return try self.reduce(into: SortedDictionary()) {
            result, x in
            if try isIncluded(x) {
                result._tree.insertLargest((key: x.key, value: x.value))
            }
        }
    }

    /// Removes the element for the specified key.
    ///
    /// - Parameters:
    ///   - key: The key for the element to remove.
    /// - Returns: If the element for the specified key was removed,
    ///   returns the value of the element, otherwise nil.
    /// - Complexity: O(log *n*), where *n* is the length of this
    ///   SortedDictionary.
    @discardableResult
    @inlinable
    @inline(__always)
    public mutating func removeValue(forKey key: Key) -> Value? {
        self.ensureUnique()

        return self._tree.delete(key)?.value
    }

    /// Removes the element for the specified index.
    ///
    /// - Parameters:
    ///   - position: The index for the element to remove.
    /// - Returns: If the element for the specified key was removed,
    ///   returns the value of the element, otherwise nil.
    /// - Complexity: Amortized O(1).
    @discardableResult
    @inlinable
    @inline(__always)
    public mutating func remove(at position: Index) -> Element {
        precondition(position != self.endIndex)

        var position = position
        self.ensureUniqueAndFormEquivalantIndex(of: &position)

        return self._tree.delete(at: position._index)
    }

    /// Removes all elements in the SortedDictionary.
    ///
    /// - Parameters:
    ///   - keepCapacity: The value is always ignored.
    /// - Complexity: O(n), where *n* is the length of this
    ///   SortedDictionary.
    /// - Note: `keepingCapacity` is always ignored.
    @inlinable
    @inline(__always)
    public mutating func removeAll(
        keepingCapacity keepCapacity: Bool = false) {
        self = SortedDictionary()
    }

    @discardableResult
    @inlinable
    @inline(__always)
    internal mutating func ensureUnique() -> Bool {
        guard
            !isKnownUniquelyReferenced(&self._tree)
        else { return false }

        self._tree = self._tree.copy()

        return true
    }

    @inlinable
    @inline(__always)
    internal mutating func ensureUniqueAndFormEquivalantIndex(
        of position: inout Index) {
        precondition(
            position._index._treeIdentifier == ObjectIdentifier(self._tree))

        let copied = self.ensureUnique()
        guard copied else { return }

        let index = self._tree.equivalent(ofOtherTreeIndex: position._index)
        position = Index(_index: index)
    }
}

extension SortedDictionary {
    /// Returns an index to the element with key not less than `key`
    /// in the SortedDictionary.
    /// - Returns: The index to the element if it exists in the sorted
    ///   dictionary, otherwise `endIndex`.
    /// - Parameters:
    ///   - key: the key for the element.
    /// - Complexity: O(log *n*), where *n* is the length of this
    ///   SortedDictionary.
    @inlinable
    @inline(__always)
    public func lowerBound(of key: Key) -> Index {
        return Index(_index: self._tree.lowerBound(of: key))
    }

    /// Returns an index to the element with key greater than `key` in
    /// the SortedDictionary.
    /// - Returns: The index to the element if it exists in this
    ///   SortedDictionary, otherwise `endIndex`.
    /// - Parameters:
    ///   - key: the key for the element.
    /// - Complexity: O(log *n*), where *n* is the length of this
    ///   SortedDictionary.
    @inlinable
    @inline(__always)
    public func upperBound(of key: Key) -> Index {
        return Index(_index: self._tree.upperBound(of: key))
    }

    /// Updates the value of the element for the specified index.
    ///
    /// - Parameters:
    ///   - value: The new value for `key`.
    ///   - position: The index for the element to update.
    /// - Returns: The old value for `key`.
    /// - Complexity: O(1).
    @discardableResult
    @inlinable
    @inline(__always)
    public mutating func updateValue(_ value: Value, at position: Index)
        -> Value {
        precondition(position != self.endIndex)

        var position = position
        self.ensureUniqueAndFormEquivalantIndex(of: &position)

        return withUnsafeMutablePointer(
            to: &position._index.node!.pointee.element.value) {
            pointer in
            let old_value = pointer.move()
            pointer.initialize(to: value)
            return old_value
        }
    }

    /// Accesses the value for the specified key.
    ///
    /// If you assign `nil` to the value for the specified key, the
    /// element whose key is equivalent to `key` is deleted.
    ///
    /// - Parameters:
    ///   - key: The key for the value.
    ///   - hint: The closest position where the element for `key`
    ///     is located.
    /// - Returns: The value for the specified key if the element
    ///   exists in this SortedDictionary, otherwise nil.
    /// - Complexity: O(log *n*), where *n* is the length of this
    ///   SortedDictionary. If the new element for `key` is located
    ///   either at, or just before, or just after `hint`, amortized
    ///   O(1).
    @inlinable
    public subscript(key: Key, hint hint: Index) -> Value? {
        @inline(__always)
        _read {
            let position = self._tree.find(key, hint: hint._index)

            defer { _fixLifetime(self) }
            yield position?.node?.pointee.element.value
        }
        _modify {
            var hint = hint
            self.ensureUniqueAndFormEquivalantIndex(of: &hint)

            let (position, is_equivalent, insert_position, to_left) =
                self.lowerBound(of: key, hint: hint)
            if is_equivalent == true ||
               (position != self.endIndex &&
                !(key < _ElementTraits.key(of: self[position]))) {
                var value: Value? =
                    withUnsafeMutablePointer(
                        to: &position._index.node!.pointee.element.value) {
                        pointer in pointer.move()
                    }

                defer {
                    if let value = value {
                        withUnsafeMutablePointer(
                            to: &position._index.node!.pointee.element.value) {
                            pointer in pointer.initialize(to: value)
                        }
                    } else {
                        self._tree.deleteKey(at: position._index)
                    }
                }
                yield &value
            } else {
                var value: Value? = nil

                defer {
                    if let value = value {
                        if let to_left = to_left {
                            self._tree.insert(
                                (key: key, value: value), at: insert_position,
                                toLeft: to_left)
                        } else {
                            self._tree.insert(
                                (key: key, value: value),
                                hint: position._index)
                        }
                    }
                }
                yield &value
            }
        }
    }

    /// Accesses the value for the specified key.
    ///
    /// If the SortedDictionary doesn't contain the element whose key
    /// is equivalent to `key`, the `key` and `defaultValue` pair is
    /// inserted into the SortedDictionary.
    ///
    /// - Parameters:
    ///   - key: The key for the value.
    ///   - hint: The closest position where the element for `key`
    ///     is located.
    ///   - default: The default value for the key.
    /// - Returns: The value for the specified key if the element
    ///   exists in this SortedDictionary, or `defaultValue`.
    /// - Complexity: O(log *n*), where *n* is the length of this
    ///   SortedDictionary. If the new element for `key` is located
    ///   either at, or just before, or just after `hint`, amortized
    ///   O(1).
    @inlinable
    public subscript(
        key: Key, hint hint: Index,
        default defaultValue: @autoclosure () -> Value) -> Value {
        @inline(__always)
        _read {
            let position = self._tree.find(key, hint: hint._index)

            defer { _fixLifetime(self) }
            yield position?.node?.pointee.element.value ?? defaultValue()
        }
        @inline(__always)
        _modify {
            var hint = hint
            self.ensureUniqueAndFormEquivalantIndex(of: &hint)
            let (_, position) =
                self._tree.insert(
                    key: key, element: (key: key, value: defaultValue()),
                    hint: hint._index)

            defer { _fixLifetime(self) }
            yield &position.node!.pointee.element.value
        }
    }

    @inlinable
    @inline(__always)
    internal mutating func lowerBound(of key: Key, hint: Index)
        -> (position: Index, isEquivalent: Bool?,
            insertPosition: UnsafeMutablePointer<_Tree._Node>?,
            toLeft: Bool?) {
        let (position, is_equivalent, insert_position, to_left) =
            self._tree.lowerBound(of: key, hint: hint._index)
        return (
            position: Index(_index: position), isEquivalent: is_equivalent,
            insertPosition: insert_position, toLeft: to_left)
    }
}

extension SortedDictionary where Key: Hashable {
    /// Creates a new SortedDictionary, initializing its contents with
    /// the given Dictionary.
    ///
    /// - Parameter dictionary: A Dictionary.
    /// - Returns: A new dictionary initialized with the elements of
    ///   `dictionary`.
    @inlinable
    @inline(__always)
    public init(_ dictionary: Dictionary<Key, Value>) {
        self.init()

        for (key, value) in dictionary {
            self._tree.insert((key: key, value: value))
        }
    }
}

extension SortedDictionary: Equatable where Value: Equatable {
    @inlinable
    @inline(__always)
    public static func == (
        lhs: SortedDictionary<Key, Value>, rhs: SortedDictionary<Key, Value>)
        -> Bool {
        if lhs._tree === rhs._tree { return true }
        guard lhs.count == rhs.count else { return false }

        return lhs.elementsEqual(rhs, by: ==)
    }
}

extension SortedDictionary: Comparable where Value: Comparable {
    @inlinable
    @inline(__always)
    public static func < (
        lhs: SortedDictionary, rhs: SortedDictionary) -> Bool {
        if lhs._tree === rhs._tree { return false }

        return lhs.lexicographicallyPrecedes(rhs, by: <)
    }
}

extension SortedDictionary: Hashable where Key: Hashable, Value: Hashable {
    @inlinable
    @inline(__always)
    public func hash(into hasher: inout Hasher) {
        for element in self {
            hasher.combine(element.key)
            hasher.combine(element.value)
        }
    }
}

extension SortedDictionary {
    /// A view of keys in a SortedDictionary.
    public struct Keys {
        @usableFromInline
        internal var _dictionary: SortedDictionary

        @inlinable
        @inline(__always)
        internal init(_dictionary: SortedDictionary) {
            self._dictionary = _dictionary
        }
    }

    /// A collection whose keys in the SortedDictionary.
    @inlinable
    public var keys: Keys {
        @inline(__always)
        get { return Keys(_dictionary: self) }
    }
}

extension SortedDictionary.Keys: Collection {
    public typealias Index = SortedDictionary.Index
    public typealias Element = SortedDictionary.Key

    @inlinable
    public var startIndex: Index {
        @inline(__always)
        get { return self._dictionary.startIndex }
    }

    @inlinable
    public var endIndex: Index {
        @inline(__always)
        get { return self._dictionary.endIndex }
    }

    @inlinable
    @inline(__always)
    public func index(after i: Index) -> Index {
        return self._dictionary.index(after: i)
    }

    @inlinable
    public subscript(position: Index) -> Element {
        @inline(__always)
        _read {
            precondition(position != self.endIndex)

            defer { _fixLifetime(self._dictionary) }
            yield self._dictionary[position].key
        }
    }

    @inlinable
    public var count: Int {
        @inline(__always)
        get { return self._dictionary.count }
    }

    @inlinable
    public var isEmpty: Bool {
        @inline(__always)
        get { return self._dictionary.isEmpty }
    }
}

extension SortedDictionary.Keys: BidirectionalCollection {
    @inlinable
    @inline(__always)
    public func index(before i: Index) -> Index {
        return self._dictionary.index(before: i)
    }
}

extension SortedDictionary.Keys: Equatable {
    @inlinable
    @inline(__always)
    public static func == (
        lhs: SortedDictionary.Keys, rhs: SortedDictionary.Keys) -> Bool {
        if lhs._dictionary._tree === rhs._dictionary._tree { return true }
        guard lhs.count == rhs.count else { return false }

        return lhs.elementsEqual(rhs)
    }
}

extension SortedDictionary.Keys: Comparable {
    @inlinable
    @inline(__always)
    public static func < (
        lhs: SortedDictionary.Keys, rhs: SortedDictionary.Keys) -> Bool {
        if lhs._dictionary._tree === rhs._dictionary._tree { return false }

        return lhs.lexicographicallyPrecedes(rhs)
    }
}

extension SortedDictionary.Keys: CustomStringConvertible {
    public var description: String {
        return _description(of: self)
    }
}

extension SortedDictionary.Keys: CustomDebugStringConvertible {
    public var debugDescription: String {
        return _description(of: self, name: "SortedDictionary.Keys")
    }
}

extension SortedDictionary {
    /// A view of values in a SortedDictionary.
    public struct Values {
        @usableFromInline
        internal var _dictionary: SortedDictionary

        @inlinable
        @inline(__always)
        internal init(_dictionary: SortedDictionary) {
            self._dictionary = _dictionary
        }
    }

    /// A collection whose values in the SortedDictionary.
    @inlinable
    public var values: Values {
        @inline(__always)
        get { return Values(_dictionary: self) }
    }
}

extension SortedDictionary.Values: Collection {
    public typealias Index = SortedDictionary.Index
    public typealias Element = SortedDictionary.Value

    @inlinable
    public var startIndex: Index {
        @inline(__always)
        get { return self._dictionary.startIndex }
    }

    @inlinable
    public var endIndex: Index {
        @inline(__always)
        get { return self._dictionary.endIndex }
    }

    @inlinable
    @inline(__always)
    public func index(after i: Index) -> Index {
        return self._dictionary.index(after: i)
    }

    @inlinable
    public subscript(position: Index) -> Value {
        @inline(__always)
        _read {
            precondition(position != self.endIndex)

            defer { _fixLifetime(self._dictionary) }
            yield position._index.node!.pointee.element.value
        }
    }

    @inlinable
    public var count: Int {
        @inline(__always)
        get { return self._dictionary.count }
    }

    @inlinable
    public var isEmpty: Bool {
        @inline(__always)
        get { return self._dictionary.isEmpty }
    }
}

extension SortedDictionary.Values: BidirectionalCollection {
    @inlinable
    @inline(__always)
    public func index(before i: Index) -> Index {
        return self._dictionary.index(before: i)
    }
}

extension SortedDictionary.Values: CustomStringConvertible {
    public var description: String {
        return _description(of: self)
    }
}

extension SortedDictionary.Values: CustomDebugStringConvertible {
    public var debugDescription: String {
        return _description(of: self, name: "SortedDictionary.Values")
    }
}

extension SortedDictionary: Sequence {
    public struct Iterator: IteratorProtocol  {
        @usableFromInline internal var _iterator: _Tree._Iterator

        @inlinable
        @inline(__always)
        init(_iterator: _Tree._Iterator) {
            self._iterator = _iterator
        }

        @inlinable
        @inline(__always)
        public mutating func next() -> Element? {
            return self._iterator.next()
        }
    }

    @inlinable
    @inline(__always)
    public func makeIterator() -> Iterator {
        return Iterator(_iterator: self._tree.makeIterator())
    }

    /// Returns the element whose key is the minimum in the
    /// SortedDictionary.
    ///
    /// - Returns: The element whose key is the minimum in the sorted
    ///   dictionary. If the SortedDictionary has no elements,
    ///   returns nil.
    /// - Complexity: O(1).
    @inlinable
    @warn_unqualified_access
    @inline(__always)
    public func min() -> Element? {
        return self.first
    }

    /// Returns the element whose key is the maximum in the
    /// SortedDictionary.
    ///
    /// - Returns: The element that key is the maximum in the sorted
    ///   dictionary. If the SortedDictionary has no elements,
    ///   returns nil.
    /// - Complexity: O(1).
    @inlinable
    @warn_unqualified_access
    @inline(__always)
    public func max() -> Element? {
        return self.last
    }

    /// Returns the sorted elements of the SortedDictionary.
    ///
    /// - Returns: The sorted elements of the SortedDictionary.
    /// - Complexity: O(n), where *n* is the length of this SortedDictionary.
    @inlinable
    @inline(__always)
    public func sorted() -> [Element] {
        return self.map { $0 }
    }
}

extension SortedDictionary: Collection {
    public struct Index: Comparable, Hashable {
        @inlinable
        @inline(__always)
        internal init(_index: _Tree._Index) {
            self._index = _index
        }

        @inlinable
        @inline(__always)
        public static func < (lhs: Index, rhs: Index) -> Bool {
            return lhs._index < rhs._index
        }

        @usableFromInline internal var _index: _Tree._Index
    }

    @inlinable
    public var startIndex: Index {
        @inline(__always)
        get { return Index(_index: self._tree.startIndex) }
    }

    @inlinable
    public var endIndex: Index {
        @inline(__always)
        get { return Index(_index: self._tree.endIndex) }
    }

    @inlinable
    public subscript(position: Index) -> Element {
        @inline(__always)
        get {
            precondition(position != self.endIndex)

            return position._index.node!.pointee.element
        }
    }

    @inlinable
    @inline(__always)
    public func index(after index: Index) -> Index {
        return Index(_index: self._tree.index(after: index._index))
    }

    @inlinable
    @inline(__always)
    public func index(forKey key: Key) -> Index? {
        guard let position = self._tree.find(key) else { return nil }

        return Index(_index: position)
    }

    /// Removes the element whose key is minimum, and returns the
    /// element.
    ///
    /// - Returns: If this SortedDictionary isn't empty, the element
    ///   whose key is minimum, otherwise `nil`.
    /// - Complexity: Amortized O(1).
    @inlinable
    @inline(__always)
    public mutating func popFirst() -> Element? {
        guard !self.isEmpty else { return nil }

        return self.remove(at: self.startIndex)
    }

    @inlinable
    public var count: Int {
        @inline(__always)
        get { return self._tree.count }
    }

    @inlinable
    public var isEmpty: Bool {
        @inline(__always)
        get { return self.count == 0 }
    }
}

extension SortedDictionary: BidirectionalCollection {
    @inlinable
    @inline(__always)
    public func index(before index: Index) -> Index {
        return Index(_index: self._tree.index(before: index._index))
    }

    /// Removes the element whose key is maximum, and returns the
    /// element.
    ///
    /// - Returns: If this SortedDictionary isn't empty, the element
    ///   whose key is maximum, otherwise `nil`.
    /// - Complexity: Amortized O(1).
    @inlinable
    @inline(__always)
    public mutating func popLast() -> Element? {
        guard !self.isEmpty else { return nil }

        return self.remove(at: self.index(before: self.endIndex))
    }
}

extension SortedDictionary: ExpressibleByDictionaryLiteral {
    @inlinable
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init()
        for element in elements {
            self._tree.insert(element)
        }
    }
}

extension SortedDictionary: Encodable where Key: Encodable, Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in self {
            try container.encode(element.key)
            try container.encode(element.value)
        }
    }
}

extension SortedDictionary: Decodable where Key: Decodable, Value: Decodable {
    public init(from decoder: Decoder) throws {
        self.init()

        var container = try decoder.unkeyedContainer()
        guard
            let count = container.count,
            count % 2 == 0
        else {
            let context =
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Missing key or value")
            throw DecodingError.dataCorrupted(context)
        }

        while !container.isAtEnd {
            let key = try container.decode(Key.self)
            guard
                !container.isAtEnd
            else {
                let context =
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unexpected end of data")
                throw DecodingError.dataCorrupted(context)
            }

            let value = try container.decode(Value.self)
            self._tree.insertLargest((key: key, value: value))
        }
    }
}

extension SortedDictionary: CustomStringConvertible {
    public var description: String {
        return Cloche._description(of: self, emptyDescription: "[:]") {
            element in type(of: self)._description(of: element)
        }
    }

    internal static func _description(of element: Element) -> String {
        var result = ""
        debugPrint(element.key, terminator: "", to: &result)
        result += ": "
        debugPrint(element.value, terminator: "", to: &result)

        return result
    }
}

extension SortedDictionary: CustomDebugStringConvertible {
    public var debugDescription: String {
        return Cloche._description(
            of: self, name: "SortedDictionary", emptyDescription: "[:]") {
            element in type(of: self)._description(of: element)
        }
    }
}

extension SortedDictionary: CustomReflectable {
    public var customMirror: Mirror {
        let style = Mirror.DisplayStyle.dictionary
        return Mirror(self, unlabeledChildren: self, displayStyle: style)
    }
}

public typealias SortedDictionaryIndex<Key: Comparable, Value> =
    SortedDictionary<Key, Value>.Index
public typealias SortedDictionaryIterator<Key: Comparable, Value> =
    SortedDictionary<Key, Value>.Iterator
