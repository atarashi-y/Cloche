//
// SortedSet.swift
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

/// A collection whose elements are unique and sorted.
///
/// Example
/// =====================================
///
///     var s1: SortedSet = [5, 2, 3, 4]
///     print(s1) // [2, 3, 4, 5]
///
///     s1.insert(1)
///     print(s1[s1.startIndex]) // 1
///     print(s1) // [1, 2, 3, 4, 5]
///
///     print(s1.remove(5)!) // 5
///     print(s1.last!) // 4
///     print(s1) // [1, 2, 3, 4]
///
///     let s2: SortedSet = [3, 7, 1, 9]
///     print(s1.union(s2)) // [1, 2, 3, 4, 7, 9]
public struct SortedSet<Element: Comparable>: SetCollection {
    @usableFromInline
    internal struct _ElementTraits: _RedBlackTreeElementTraits {
        @usableFromInline internal typealias Key = SortedSet.Element
        @usableFromInline internal typealias Element = SortedSet.Element

        @inlinable
        @inline(__always)
        internal static func key(of element: SortedSet.Element) -> Element {
            return element
        }
    }

    @usableFromInline internal typealias _Tree = _RedBlackTree<_ElementTraits>

    @usableFromInline
    internal var _tree: _Tree

    /// Creates an empty SortedSet.
    @inlinable
    @inline(__always)
    public init() {
        self._tree = _Tree()
    }

    /// Create a new SortedSet whose only elements for which the given
    /// closure `isIncluded` returns true.
    ///
    /// - Parameters:
    ///   - isIncluded: A closure that is called with each element in
    ///     this SortedSet and returns whether the element should be
    ///     included in the result.
    /// - Returns: A SortedSet whose elements for which the given
    ///   closure `isIncluded` returns true.
    /// - Complexity: O(*m* + *n*), where *m* is the length of the
    ///   original SortedSet and *n* is the length of the resulting
    ///   SortedSet.
    @inlinable
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows
        -> SortedSet {
        return try self.reduce(into: SortedSet()) {
            result, x in
            if try isIncluded(x) {
                result._tree.insertLargest(x)
            }
        }
    }

    /// Removes the minimum element in the SortedSet.
    ///
    /// - Returns: The minimum element in the SortedSet.
    /// - Complexity: Amortized O(1).
    @discardableResult
    @inlinable
    public mutating func removeFirst() -> Element {
        precondition(!self.isEmpty)

        return self.remove(at: self.startIndex)
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
    public mutating func remove(at position: Index) -> Element {
        precondition(position != self.endIndex)

        var position = position
        self.ensureUniqueAndFormEquivalantIndex(of: &position)

        return self._tree.delete(
            at: self._tree.equivalent(ofOtherTreeIndex: position._index))
    }

    /// Removes all elements in the SortedSet.
    ///
    /// - Parameters:
    ///   - keepCapacity: The value is always ignored.
    /// - Complexity: O(n), where *n* is the length of this SortedSet.
    /// - Note: `keepingCapacity` is always ignored.
    @inlinable
    @inline(__always)
    public mutating func removeAll(
        keepingCapacity keepCapacity: Bool = false) {
        self = SortedSet()
    }

    @discardableResult
    @inlinable
    internal mutating func ensureUnique() -> Bool {
        guard
            !isKnownUniquelyReferenced(&self._tree)
        else { return false }

        self._tree = self._tree.copy()

        return true
    }

    @inlinable
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

extension SortedSet: Equatable {
    @inlinable
    @inline(__always)
    public static func == (
        lhs: SortedSet<Element>, rhs: SortedSet<Element>) -> Bool {
        if lhs._tree === rhs._tree { return true }
        guard lhs.count == rhs.count else { return false }

        return lhs.elementsEqual(rhs)
    }
}

extension SortedSet: Comparable {
    @inlinable
    @inline(__always)
    public static func < (lhs: SortedSet, rhs: SortedSet) -> Bool {
        if lhs._tree === rhs._tree { return false }

        return lhs.lexicographicallyPrecedes(rhs)
    }
}

extension SortedSet: Hashable where Element: Hashable {
    @inlinable
    @inline(__always)
    public func hash(into hasher: inout Hasher) {
        for element in self {
            hasher.combine(element)
        }
    }
}

extension SortedSet: Sequence {
    public struct Iterator: IteratorProtocol  {
        @usableFromInline
        internal var _iterator: _Tree._Iterator

        @inlinable
        @inline(__always)
        internal init(_iterator: _Tree._Iterator) {
            self._iterator = _iterator
        }

        @inlinable
        @inline(__always)
        public mutating func next() -> Element? {
            return _iterator.next()
        }
    }

    @inlinable
    @inline(__always)
    public func makeIterator() -> Iterator {
        return Iterator(_iterator: self._tree.makeIterator())
    }

    /// Returns the element which is the minimum in the SortedSet.
    ///
    /// - Returns: The element which is the minimum in this
    ///   SortedSset. If the this SortedSet has no elements, returns
    ///   nil.
    /// - Complexity: O(1).
    @inlinable
    @inline(__always)
    @warn_unqualified_access
    public func min() -> Element? {
        return self.first
    }

    /// Returns the element which is the maximum in the SortedSet.
    ///
    /// - Returns: The element which is the maximum in the SortedSet.
    ///   If this SortedSet has no elements, returns nil.
    /// - Complexity: O(1).
    @inlinable
    @inline(__always)
    @warn_unqualified_access
    public func max() -> Element? {
        return self.last
    }

    @inlinable
    @inline(__always)
    public func contains(_ element: Element) -> Bool {
        return self._tree.find(element) != nil
    }

    /// Returns the sorted elements of the SortedSet.
    ///
    /// - Returns: The sorted elements of the SortedSet.
    /// - Complexity: O(n), where *n* is the length of this SortedSet.
    @inlinable
    @inline(__always)
    public func sorted() -> [Element] {
        return self.map { $0 }
    }
}

extension SortedSet: Collection {
    public struct Index: Comparable, Hashable {
        @inlinable
        @inline(__always)
        public static func < (lhs: Index, rhs: Index) -> Bool {
            return lhs._index < rhs._index
        }

        @inlinable
        @inline(__always)
        internal init(_index: _Tree._Index) {
            self._index = _index
        }

        @usableFromInline
        internal var _index: _Tree._Index
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
    @inline(__always)
    public subscript(position: Index) -> Element {
        precondition(position != self.endIndex)

        return position._index.node!.pointee.element
    }

    @inlinable
    @inline(__always)
    public func index(after index: Index) -> Index {
        return Index(_index: self._tree.index(after: index._index))
    }

    /// Returns an index to the element equivalent to `element` in the
    /// SortedSet.
    /// - Parameters:
    ///   - member: An element to search.
    /// - Returns: The index to the element if it exists in the Sorted
    ///   Set, otherwise nil.
    /// - Complexity: O(log *n*), where *n* is the length of the
    ///   sequence.
    @inlinable
    @inline(__always)
    public func firstIndex(of member: Element) -> Index? {
        guard let position = self._tree.find(member) else { return nil }

        return Index(_index: position)
    }

    /// Removes and returns the minimum element in the SortedSet.
    ///
    /// - Returns: If this SortedSet isn't empty, the minimum element,
    ///   otherwise `nil`.
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

extension SortedSet: BidirectionalCollection {
    @inlinable
    @inline(__always)
    public func index(before index: Index) -> Index {
        return Index(_index: self._tree.index(before: index._index))
    }

    /// Returns an index to the element equivalent to `element` in the
    /// SortedSet.
    /// - Parameters:
    ///   - member: An element to search.
    /// - Returns: The index to the element if it exists in the
    ///   SortedSet, otherwise nil.
    /// - Complexity: O(log *n*), where *n* is the length of the
    ///   sequence.
    @inlinable
    @inline(__always)
    public func lastIndex(of element: Element) -> Index? {
        return self.firstIndex(of: element)
    }

    /// Removes the maximum element in the SortedSet.
    ///
    /// - Returns: The maximum element in the SortedSet.
    /// - Complexity: Amortized O(1).
    @discardableResult
    @inlinable
    public mutating func removeLast() -> Element {
        precondition(!self.isEmpty)

        return self.remove(at: self.index(before: self.endIndex))
    }

    /// Removes and returns the maximum element in the SortedSet.
    ///
    /// - Returns: If this SortedSet isn't empty, the maximum element,
    ///   otherwise `nil`.
    /// - Complexity: Amortized O(1).
    @inlinable
    @inline(__always)
    public mutating func popLast() -> Element? {
        guard !self.isEmpty else { return nil }

        return self.remove(at: self.index(before: self.endIndex))
    }
}

extension SortedSet: SetAlgebra {
    /// Inserts the new element to the SortedSet.
    ///
    /// - Parameters:
    ///   - newMember: An element to insert into the SortedSet.

    /// - Returns: If `newMember` was already included in the
    ///   SortedSet,
    ///   `(inserted: false, memberAfterInsert: existing-element)`,
    ///   otherwise
    ///   `(inserted: true, memberAfterInsert: newMember)`.
    /// - Complexity: O(log *n*), where *n* is the length of this
    ///   SortedSet.
    @discardableResult
    @inlinable
    @inline(__always)
    public mutating func insert(_ newMember: Element)
        -> (inserted: Bool, memberAfterInsert: Element) {
        self.ensureUnique()
        let result = self._tree.insert(newMember)
        return (
            inserted: result.inserted,
            memberAfterInsert: result.position.node!.pointee.element)
    }

    /// Removes the element from the SortedSet.
    ///
    /// - Parameters:
    ///   - element: The element to remove.
    /// - Returns: If the element for the specified key was removed,
    ///   returns the value of the element, otherwise nil.
    /// - Complexity: O(log *n*), where *n* is the length of this
    ///   SortedSet.
    @inlinable
    @inline(__always)
    public mutating func remove(_ member: Element) -> Element? {
        self.ensureUnique()
        return self._tree.delete(member)
    }

    /// Updates the element in the SortedSet.
    ///
    /// - Parameters:
    ///   - newMember: An element to insert into this SortedSet.
    /// - Returns: If `newMember` was already included in this
    ///   SortedSet, the old element, otherwise nil.
    /// - Complexity: O(log *n*), where *n* is the length of this
    ///   SortedSet.
    @inlinable
    public mutating func update(with newMember: Element) -> Element? {
        self.ensureUnique()
        let (inserted, position) = self._tree.insert(newMember)
        if inserted {
            return nil
        }

        return withUnsafeMutablePointer(to: &position.node!.pointee.element) {
            pointer in
            let old = pointer.move()
            pointer.initialize(to: newMember)
            return old
        }
    }

    /// Returns a new SortedSet whose elements are union of `self` and
    /// `other`.
    ///
    /// - Parameters:
    ///   - other: A sequence of elements.
    /// - Returns: A new SortedSet whose elements are union of `self`
    ///   and `other`.
    @inlinable
    public func union<S: Sequence>(_ other: S) -> SortedSet
        where Element == S.Element {
        var result = self
        result.formUnion(other)
        return result
    }

    /// Forms union of `self` and `other`.
    ///
    /// - Parameters:
    ///   - other: A sequence of elements.
    @inlinable
    public mutating func formUnion<S: Sequence>(_ other: S)
        where Element == S.Element {
        self.ensureUnique()
        for v in other {
            self._tree.insert(v)
        }
    }

    /// Returns a new SortedSet whose elements are intersection of
    /// `self` and `other`.
    ///
    /// - Parameters:
    ///   - other: A sequence of elements.
    /// - Returns: A new SortedSet whose elements are intersection of
    ///   `self` and `other`.
    @inlinable
    public func intersection<S: Sequence>(_ other: S) -> SortedSet
        where Element == S.Element {
        let result = SortedSet()
        for v in other {
            if self.contains(v) {
                result._tree.insert(v)
            }
        }

        return result
    }

    /// Forms intersection of `self` and `other`.
    ///
    /// - Parameters:
    ///   - other: A sequence of elements.
    @inlinable
    public mutating func formIntersection<S: Sequence>(_ other: S)
        where Element == S.Element  {
        self.ensureUnique()
        let result = self.intersection(other)
        if self.count != result.count {
            self = result
        }
    }

    /// Returns a new SortedSet whose elements are symmetric
    /// difference of `self` and `other`.
    ///
    /// - Parameters:
    ///   - other: A sequence of elements.
    /// - Returns: A new SortedSet whose elements are symmetric
    ///   difference of `self` and `other`.
    @inlinable
    public func symmetricDifference<S: Sequence>(_ other: S) -> SortedSet
        where Element == S.Element {
        var result = self
        result.formSymmetricDifference(other)
        return result
    }

    /// Forms symmetric difference of `self` and `other`.
    ///
    /// - Parameters:
    ///   - other: A sequence of elements.
    @inlinable
    public mutating func formSymmetricDifference<S: Sequence>(_ other: S)
        where Element == S.Element  {
        self.ensureUnique()

        for v in other {
            let position = self.lowerBound(of: v)
            if position == self.endIndex || v < self[position] {
                self._tree.insert(v, hint: position._index)
            } else {
                self._tree.delete(at: position._index)
            }
        }
    }

    /// Returns a new SortedSet whose elements are difference of
    /// `self` and `other`.
    ///
    /// - Parameters:
    ///   - other: A sequence of elements.
    /// - Returns: A new SortedSet whose elements are difference of
    ///   `self` and `other`.
    @inlinable
    public func subtracting<S: Sequence>(_ other: S) -> SortedSet
        where Element == S.Element {
        var result = self
        result.subtract(other)

        return result
    }

    /// Subtracts `other` from `self`.
    ///
    /// - Parameters:
    ///   - other: A sequence of elements.
    @inlinable
    public mutating func subtract<S: Sequence>(_ other: S)
        where Element == S.Element {
        self.ensureUnique()

        for v in other {
            self._tree.delete(v)
        }
    }

    /// Returns whether `self` is disjoint with `other` or not.
    ///
    /// - Returns: `true` if `self` is disjoint with `other`,
    ///   otherwise `false`.
    /// - Parameters:
    ///   - other: A sequence of elements.
    @inlinable
    public func isDisjoint<S: Sequence>(with other: S) -> Bool
        where Element == S.Element {
        for v in other {
            if self.contains(v) {
                return false
            }
        }

        return true
    }

    /// Returns whether `self` is superset of `other` or not.
    ///
    /// - Returns: `true` if `self` is superset of `other`, otherwise
    ///   `false`.
    /// - Parameters:
    ///   - other: A sequence of elements.
    @inlinable
    public func isSuperset<S: Sequence>(of other: S) -> Bool
        where Element == S.Element  {
        for v in other {
            if !self.contains(v) {
                return false
            }
        }

        return true
    }

    /// Returns whether `self` is superset of `other` or not.
    ///
    /// - Returns: `true` if `self` is superset of `other`, otherwise
    ///   `false`.
    /// - Parameters:
    ///   - other: A sequence of elements.
    @inlinable
    public func isSubset<S: Sequence>(of other: S) -> Bool
        where Element == S.Element  {
        return self.isSubset(of: SortedSet(other))
    }

    /// Returns whether `self` is strict superset of `other` or not.
    ///
    /// - Returns: `true` if `self` is strict superset of `other`,
    ///   otherwise `false`.
    /// - Parameters:
    ///   - other: A sequence of elements.
    @inlinable
    public func isStrictSuperset<S: Sequence>(of other: S) -> Bool
        where Element == S.Element  {
        return self.isStrictSuperset(of: SortedSet(other))
    }

    /// Returns whether `self` is strict subset of `other` or not.
    ///
    /// - Returns: `true` if `self` is strict subset of `other`,
    ///   otherwise `false`.
    /// - Parameters:
    ///   - other: A sequence of elements.
    @inlinable
    public func isStrictSubset<S: Sequence>(of other: S) -> Bool
        where Element == S.Element  {
        return self.isStrictSubset(of: SortedSet(other))
    }
}

extension SortedSet {
    /// Returns an index to the element not less than `element` in the
    /// SortedSet.
    ///
    /// - Returns: The index to the element if it exists in the sorted
    ///   set, otherwise `endIndex`.
    /// - Parameters:
    ///   - key: the key for the element.
    /// - Complexity: O(log *n*), where *n* is the length of this
    ///   SortedSet.
    @inlinable
    @inline(__always)
    public func lowerBound(of element: Element) -> Index {
        return Index(_index: self._tree.lowerBound(of: element))
    }

    /// Returns an index to the element greater than `element` in the
    /// SortedSet.
    ///
    /// - Returns: The index to the element if it exists in the sorted
    ///   set, otherwise `endIndex`.
    /// - Parameters:
    ///   - key: the key for the element.
    /// - Complexity: O(log *n*), where *n* is the length of this
    ///   SortedSet.
    @inlinable
    @inline(__always)
    public func upperBound(of element: Element) -> Index {
        return Index(_index: self._tree.upperBound(of: element))
    }

    /// Inserts the new element to the SortedSet.
    ///
    /// - Parameters:
    ///   - newMember: An element to insert into this SortedSet.
    ///   - hint: The closest position where `newMember` is located.
    /// - Returns: If `newMember` was already included in the
    ///   SortedSet,
    ///   `(inserted: false, memberAfterInsert: existing-element)`,
    ///   otherwise
    ///   `(inserted: true, memberAfterInsert: newMember)`.
    /// - Complexity: O(log *n*), where *n* is the length of this
    ///   SortedSet. If `newMember` is located either at, or just
    ///   before, or just after `hint`, amortized O(1).
    @discardableResult
    @inlinable
    public mutating func insert(_ newMember: Element, hint: Index)
        -> (inserted: Bool, memberAfterInsert: Element) {
        var hint = hint
        self.ensureUniqueAndFormEquivalantIndex(of: &hint)

        let result = self._tree.insert(newMember, hint: hint._index)
        return (
            inserted: result.inserted,
            memberAfterInsert: result.position.node!.pointee.element)
    }

    /// Updates the element in the SortedSet.
    ///
    /// - Parameters:
    ///   - newMember: An element to insert into this SortedSet.
    ///   - hint: The closest position where `newMember` is located.
    /// - Returns: If `newMember` was already included in this
    ///   SortedSet, the old element, otherwise nil.
    /// - Complexity: O(log *n*), where *n* is the length of this
    ///   SortedSset. If `newMember` is located either at, or just
    ///   before, or just after `hint`, amortized O(1).
    @inlinable
    public mutating func update(with newMember: Element, hint: Index)
        -> Element? {
        var hint = hint
        self.ensureUniqueAndFormEquivalantIndex(of: &hint)

        let (inserted, position) =
            self._tree.insert(newMember, hint: hint._index)
        if inserted {
            return nil
        }

        return withUnsafeMutablePointer(to: &position.node!.pointee.element) {
            pointer in
            let old = pointer.move()
            pointer.initialize(to: newMember)
            return old
        }
    }
}

extension SortedSet {
    /// Returns a new SortedSet whose elements are union of `self` and
    /// `other`.
    ///
    /// - Parameters:
    ///   - other: A SorteSet of the same type as self.
    /// - Returns: A new SortedSet whose elements are union of `self`
    ///   and `other`.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedSet and *n* is the length of the other SortedSet.
    @inlinable
    public func union(_ other: SortedSet) -> SortedSet {
        var result = self
        result.formUnion(other)
        return result
    }

    /// Forms union of `self` and `other`.
    ///
    /// - Paramrters:
    ///   - other: A SorteSet of the same type as self.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedSet and *n* is the length of the other SortedSet.
    @inlinable
    public mutating func formUnion(_ other: SortedSet) {
        self.ensureUnique()

        var current = self.startIndex
        var other_current = other.startIndex
        while current != self.endIndex && other_current != other.endIndex {
            let x = self[current]
            let y = other[other_current]
            if x < y {
                self.formIndex(after: &current)
            } else if y < x {
                self._tree.insert(y, hint: current._index)

                other.formIndex(after: &other_current)
            } else {
                self.formIndex(after: &current)
                other.formIndex(after: &other_current)
            }
        }

        for v in other[other_current ..< other.endIndex] {
            self._tree.insertLargest(v)
        }
    }

    /// Returns a new SortedSet whose elements are intersection of
    /// `self` and `other`.
    ///
    /// - Parameters:
    ///   - other: A SorteSet of the same type as self.
    /// - Returns: A new SortedSet whose elements are intersection of
    ///   `self` and `other`.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedSet and *n* is the length of the other SortedSet.
    @inlinable
    public func intersection(_ other: SortedSet) -> SortedSet {
        let result = SortedSet()

        var current = self.startIndex
        var other_current = other.startIndex
        while current != self.endIndex && other_current != other.endIndex {
            let x = self[current]
            let y = other[other_current]

            if x < y {
                self.formIndex(after: &current)
            } else if y < x {
                other.formIndex(after: &other_current)
            } else {
                result._tree.insert(x, hint: result.endIndex._index)

                self.formIndex(after: &current)
                other.formIndex(after: &other_current)
            }
        }

        return result
    }

    /// Forms intersection of `self` and `other`.
    ///
    /// - Parameters:
    ///   - other: A SorteSet of the same type as self.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedSet and *n* is the length of the other SortedSet.
    @inlinable
    public mutating func formIntersection(_ other: SortedSet) {
        self.ensureUnique()
        let result = self.intersection(other)
        if self.count != result.count {
            self = result
        }
    }

    /// Returns a new SortedSet whose elements are symmetric
    /// difference of `self` and `other`.
    ///
    /// - Parameters:
    ///   - other: A SorteSet of the same type as self.
    /// - Returns: A new SortedSet whose elements are intersection of
    ///   `self` and `other`.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedSet and *n* is the length of the other SortedSet.
    @inlinable
    public func symmetricDifference(_ other: SortedSet) -> SortedSet {
        let result = SortedSet()

        var current = self.startIndex
        var other_current = other.startIndex
        while current != self.endIndex && other_current != other.endIndex {
            let x = self[current]
            let y = other[other_current]

            if x < y {
                result._tree.insert(x, hint: result.endIndex._index)

                self.formIndex(after: &current)
            } else if y < x {
                result._tree.insert(y, hint: result.endIndex._index)

                other.formIndex(after: &other_current)
            } else {
                self.formIndex(after: &current)
                other.formIndex(after: &other_current)
            }
        }

        for v in self[current ..< self.endIndex] {
            result._tree.insertLargest(v)
        }

        for v in other[other_current ..< other.endIndex] {
            result._tree.insertLargest(v)
        }

        return result
    }

    /// Forms symmetric difference of `self` and `other`.
    ///
    /// - Parameters:
    ///   - other: A SorteSet of the same type as self.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedSet and *n* is the length of the other SortedSet.
    @inlinable
    @inline(__always)
    public mutating func formSymmetricDifference(_ other: SortedSet) {
        self = self.symmetricDifference(other)
    }

    /// Returns a new SortedSet whose elements are difference of
    /// `self` and `other`.
    ///
    /// - Parameters:
    ///   - other: A SorteSet of the same type as self.
    /// - Returns: A new SortedSet whose elements are difference of
    ///   `self` and `other`.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedSet and *n* is the length of the other SortedSet.
    @inlinable
    public func subtracting(_ other: SortedSet) -> SortedSet {
        var result = self
        result.subtract(other)
        return result
    }

    /// Subtracts `other` from `self`.
    ///
    /// - Parameters:
    ///   - other: A SorteSet of the same type as self.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedSet and *n* is the length of the other SortedSet.
    @inlinable
    public mutating func subtract(_ other: SortedSet) {
        self.ensureUnique()

        var current = self.startIndex
        var other_current = other.startIndex
        while current != self.endIndex && other_current != other.endIndex {
            let x = self[current]
            let y = other[other_current]

            if x < y {
                self.formIndex(after: &current)
            } else if y < x {
                other.formIndex(after: &other_current)
            } else {
                let next = self.index(after: current)
                other.formIndex(after: &other_current)

                self._tree.delete(at: current._index)

                current = next
            }
        }
    }

    /// Returns whether `self` is disjoint with `other` or not.
    ///
    /// - Returns: `true` if `self` is disjoint with `other`,
    ///   otherwise `false`.
    /// - Parameters:
    ///   - other: A SorteSet of the same type as self.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedSet and *n* is the length of the other SortedSet.
    @inlinable
    public func isDisjoint(with other: SortedSet) -> Bool {
        var current = self.startIndex
        var other_current = other.startIndex
        while current != self.endIndex && other_current != other.endIndex {
            let x = self[current]
            let y = other[other_current]

            if x < y {
                self.formIndex(after: &current)
            } else if y < x {
                other.formIndex(after: &other_current)
            } else {
                return false
            }
        }

        return true
    }

    /// Returns whether `self` is superset of `other` or not.
    ///
    /// - Returns: `true` if `self` is superset of `other`, otherwise
    ///   `false`.
    /// - Parameters:
    ///   - other: A SorteSet of the same type as self.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedSet and *n* is the length of the other SortedSet.
    @inlinable
    public func isSuperset(of other: SortedSet) -> Bool {
        return self.includes(other)
    }

    /// Returns whether `self` is superset of `other` or not.
    ///
    /// - Returns: `true` if `self` is superset of `other`, otherwise
    ///   `false`.
    /// - Parameters:
    ///   - other: A SorteSet of the same type as self.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedSet and *n* is the length of the other SortedSet.
    @inlinable
    public func isSubset(of other: SortedSet) -> Bool {
        return other.includes(self)
    }

    /// Returns whether `self` is strict superset of `other` or not.
    ///
    /// - Returns: `true` if `self` is strict superset of `other`,
    ///   otherwise `false`.
    /// - Parameters:
    ///   - other: A SorteSet of the same type as self.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedSet and *n* is the length of the other SortedSet.
    @inlinable
    public func isStrictSuperset(of other: SortedSet) -> Bool {
        return self.isSuperset(of: other) && self != other
    }

    /// Returns whether `self` is strict subset of `other` or not.
    ///
    /// - Returns: `true` if `self` is strict subset of `other`,
    ///   otherwise `false`.
    /// - Parameters:
    ///   - other: A SorteSet of the same type as self.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedSet and *n* is the length of the other SortedSet.
    @inlinable
    public func isStrictSubset(of other: SortedSet) -> Bool {
        return self.isSubset(of: other) && self != other
    }

    /// Returns whether `self` contains all the elements of `other`.
    ///
    /// - Returns: `true` if `self` contains all the elements of
    ///   `other`, otherwise `false`.
    /// - Parameters:
    ///   - other: A SorteSet of the same type as self.
    /// - Complexity: O(*m* + *n*), where *m* is the length of this
    ///   SortedSet and *n* is the length of the other SortedSet.
    @inlinable
    internal func includes(_ other: SortedSet) -> Bool {
        if self.count < other.count {
            return false
        }

        var current = self.startIndex
        var other_current = other.startIndex
        while other_current != other.endIndex {
            if current == self.endIndex {
                return false
            }

            let x = self[current]
            let y = other[other_current]
            if y < x {
                return false
            } else if !(x < y) {
                other.formIndex(after: &other_current)
            }

            self.formIndex(after: &current)
        }

        return true
    }
}

extension SortedSet: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in self {
            try container.encode(element)
        }
    }
}

extension SortedSet: Decodable where Element: Decodable {
    public init(from decoder: Decoder) throws {
        self.init()

        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            let element = try container.decode(Element.self)
            self._tree.insertLargest(element)
        }
    }
}

extension SortedSet: CustomReflectable {
    public var customMirror: Mirror {
        let style = Mirror.DisplayStyle.`set`
        return Mirror(self, unlabeledChildren: self, displayStyle: style)
    }
}

extension SortedSet: CustomStringConvertible {
    public var description: String {
        return _description(of: self)
    }
}

extension SortedSet: CustomDebugStringConvertible {
    public var debugDescription: String {
        return _description(of: self, name: "SortedSet")
    }
}

public typealias SortedSetIndex<Element: Comparable> =
    SortedSet<Element>.Index
public typealias SortedSetIterator<Element: Comparable> =
    SortedSet<Element>.Iterator
