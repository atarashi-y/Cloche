//
// RedBlackTree.swift
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

@usableFromInline
internal final class _RedBlackTree<
    _ElementTraits: _RedBlackTreeElementTraits> {
    @usableFromInline typealias _Element = _ElementTraits.Element
    @usableFromInline typealias _Key = _ElementTraits.Key
    @usableFromInline internal typealias _Link = _RedBlackTreeLink

    @usableFromInline
    internal struct _Node {
        @usableFromInline internal typealias _Link = _RedBlackTreeLink
        @usableFromInline internal typealias _Color = _Link._Color

        @usableFromInline internal var color: _Color

        @inlinable
        internal var parent: UnsafeMutablePointer<_Node>? {
            @inline(__always)
            get { return type(of: self).bind(self._rawParent) }

            @inline(__always)
            set { self._rawParent = UnsafeMutableRawPointer(newValue) }
        }

        @inlinable
        internal var left: UnsafeMutablePointer<_Node>? {
            @inline(__always)
            get { return type(of: self).bind(self._rawLeft) }

            @inline(__always)
            set { self._rawLeft = UnsafeMutableRawPointer(newValue) }
        }

        @inlinable
        internal var right: UnsafeMutablePointer<_Node>? {
            @inline(__always)
            get { return type(of: self).bind(self._rawRight) }

            @inline(__always)
            set { self._rawRight = UnsafeMutableRawPointer(newValue) }
        }

        @usableFromInline internal var _rawParent: UnsafeMutableRawPointer?
        @usableFromInline internal var _rawLeft: UnsafeMutableRawPointer?
        @usableFromInline internal var _rawRight: UnsafeMutableRawPointer?
        @usableFromInline internal var element: _Element

        @inlinable
        @inline(__always)
        internal init(_element: _Element, _color: _Color = .red) {
            self.color = _color
            self.element = _element
        }

        @inlinable
        @inline(__always)
        internal static func bind(_ pointer: UnsafeMutableRawPointer?)
            -> UnsafeMutablePointer<_Node>? {
            return pointer?.bindMemory(to: _Node.self, capacity: 1)
        }

        @inlinable
        @inline(__always)
        internal static func bind(_ pointer: UnsafeMutableRawPointer)
            -> UnsafeMutablePointer<_Node> {
            return pointer.bindMemory(to: _Node.self, capacity: 1)
        }

        @inlinable
        @inline(__always)
        internal static func destroy(_ node: UnsafeMutablePointer<_Node>) {
            if !_isPOD(_Node.self) {
                node.deinitialize(count: 1)
            }
            node.deallocate()
        }
    }

    @inlinable
    internal final var root: UnsafeMutablePointer<_Node>? {
        @inline(__always)
        get { return _Node.bind(self._rawRoot) }

        @inline(__always)
        set { self._rawRoot = UnsafeMutableRawPointer(newValue) }
    }

    @inlinable
    internal final var first: UnsafeMutablePointer<_Node>? {
        @inline(__always)
        get { return _Node.bind(self._rawFirst) }

        @inline(__always)
        set { self._rawFirst = UnsafeMutableRawPointer(newValue) }
    }

    @inlinable
    internal final var last: UnsafeMutablePointer<_Node>? {
        @inline(__always)
        get { return _Node.bind(self._rawLast) }

        @inline(__always)
        set { self._rawLast = UnsafeMutableRawPointer(newValue) }
    }

    @inlinable
    internal final var rootLink: UnsafeMutablePointer<_Link>? {
        @inline(__always)
        get { return _Link.bind(self._rawRoot) }

        @inline(__always)
        set { self._rawRoot = UnsafeMutableRawPointer(newValue) }
    }

    @inlinable
    internal final var firstLink: UnsafeMutablePointer<_Link>? {
        @inline(__always)
        get { return _Link.bind(self._rawFirst) }

        @inline(__always)
        set { self._rawFirst = UnsafeMutableRawPointer(newValue) }
    }

    @inlinable
    internal final var lastLink: UnsafeMutablePointer<_Link>? {
        @inline(__always)
        get { return _Link.bind(self._rawLast) }

        @inline(__always)
        set { self._rawLast = UnsafeMutableRawPointer(newValue) }
    }

    @inlinable
    internal final var minimum: UnsafeMutablePointer<_Node>? {
        @inline(__always)
        get { return _Node.bind(_Link.minimum(in: self.rootLink)) }
    }

    @inlinable
    internal final var maximum: UnsafeMutablePointer<_Node>? {
        @inline(__always)
        get { return _Node.bind(_Link.maximum(in: self.rootLink)) }
    }

    @usableFromInline internal final var count: Int
    @usableFromInline internal final var _rawRoot: UnsafeMutableRawPointer?
    @usableFromInline internal final var _rawFirst: UnsafeMutableRawPointer?
    @usableFromInline internal final var _rawLast: UnsafeMutableRawPointer?

    @usableFromInline
    internal init() {
        assert(
            type(of: \_Node._rawParent).valueType ==
                type(of: \_Link._parent).valueType &&
            type(of: \_Node._rawLeft).valueType ==
                type(of: \_Link._left).valueType &&
            type(of: \_Node._rawRight).valueType ==
                type(of: \_Link._right).valueType &&
            MemoryLayout<_Link>.offset(of: \_Link._parent) ==
                MemoryLayout<_Node>.offset(of: \_Node._rawParent) &&
            MemoryLayout<_Link>.offset(of: \_Link._left) ==
                MemoryLayout<_Node>.offset(of: \_Node._rawLeft) &&
            MemoryLayout<_Link>.offset(of: \_Link._right) ==
                MemoryLayout<_Node>.offset(of: \_Node._rawRight))

        self.count = 0
    }

    @inlinable
    internal static func _destroy(_ node: UnsafeMutablePointer<_Node>?) {
        guard let node = node else { return }

        self._destroy(node.pointee.left)
        self._destroy(node.pointee.right)

        _Node.destroy(node)
    }

    @inlinable
    deinit {
        type(of: self)._destroy(self.root)
    }

    @usableFromInline
    internal struct _Iterator: IteratorProtocol {
        @usableFromInline internal var _current: UnsafeMutableRawPointer?

        @inlinable
        @inline(__always)
        internal init(_node: UnsafeMutableRawPointer?) {
            self._current = _node
        }

        @inlinable
        @inline(__always)
        internal mutating func next() -> _Element? {
            defer { self.current = _RedBlackTree.successor(of: self.current) }
            return self.current?.pointee.element
        }

        @inlinable
        var current: UnsafeMutablePointer<_Node>? {
            @inline(__always)
            get { return _Node.bind(self._current) }

            @inline(__always)
            set { self._current = UnsafeMutableRawPointer(newValue) }
        }
    }

    @inlinable
    @inline(__always)
    internal final func makeIterator() -> _Iterator {
        return _Iterator(_node: self.first)
    }

    @inlinable
    internal final func find(_ key: _Key) -> _Index? {
        var node = self.root
        while let x = node {
            let node_key = _ElementTraits.key(of: x.pointee.element)
            if key < node_key {
                node = x.pointee.left
            } else if node_key < key {
                node = x.pointee.right
            } else {
                return _Index(_node: node, _in: self)
            }
        }

        return nil
    }

    @inlinable
    internal final func find(_ key: _Key, near hint: _Index) -> _Index? {
        precondition(hint._treeIdentifier == ObjectIdentifier(self))

        guard self.count != 0 else { return nil }

        if hint != self.endIndex {
            if !(_ElementTraits.key(of: hint.node!.pointee.element) < key),
               !(key < _ElementTraits.key(of: hint.node!.pointee.element)) {
                return hint
            } else if let successor = self.successor(of: hint.node),
               !(_ElementTraits.key(of: successor.pointee.element) < key),
               !(key < _ElementTraits.key(of: successor.pointee.element)) {
                return _Index(_node: successor, _in: self)
            }
        }

        if hint != self.startIndex,
           let predecessor = self.predecessor(of: hint.node),
           !(_ElementTraits.key(of: predecessor.pointee.element) < key),
           !(key < _ElementTraits.key(of: predecessor.pointee.element)) {
            return _Index(_node: predecessor, _in: self)
        }

        return nil
    }

    @inlinable
    @inline(__always)
    internal final func find(_ key: _Key, hint: _Index) -> _Index? {
        if let position = find(key, near: hint) {
            return position
        }

        return self.find(key)
    }

    @inlinable
    internal final func lowerBound(of key: _Key) -> _Index {
        var parent: UnsafeMutablePointer<_Node>?
        var node = self.root
        while let x = node {
            let node_key = _ElementTraits.key(of: x.pointee.element)
            if !(node_key < key) {
                parent = node
                node = x.pointee.left
            } else {
                node = x.pointee.right
            }
        }

        return _Index(_node: parent, _in: self)
    }

    @inlinable
    internal final func upperBound(of key: _Key) -> _Index {
        var parent: UnsafeMutablePointer<_Node>?
        var node = self.root
        while let x = node {
            let node_key = _ElementTraits.key(of: x.pointee.element)
            if key < node_key {
                parent = node
                node = x.pointee.left
            } else {
                node = x.pointee.right
            }
        }

        return _Index(_node: parent, _in: self)
    }

    @inlinable
    @inline(__always)
    internal static func successor(of node: UnsafeMutablePointer<_Node>?)
        -> UnsafeMutablePointer<_Node>? {
        return _Node.bind(_Link.successor(of: _Link.bind(node)))
    }

    @inlinable
    @inline(__always)
    internal static func predecessor(of node: UnsafeMutablePointer<_Node>?)
        -> UnsafeMutablePointer<_Node>? {
        return _Node.bind(_Link.predecessor(of: _Link.bind(node)))
    }

    @inlinable
    @inline(__always)
    internal final func successor(of node: UnsafeMutablePointer<_Node>?)
        -> UnsafeMutablePointer<_Node>? {
        return type(of: self).successor(of: node)
    }

    @inlinable
    @inline(__always)
    internal final func predecessor(of node: UnsafeMutablePointer<_Node>?)
        -> UnsafeMutablePointer<_Node>? {
        return node != nil
            ? type(of: self).predecessor(of: node)
            : self.last
    }

    @inlinable
    internal final func upperBoundForInsertion(for key: _Key)
        -> (parent: UnsafeMutablePointer<_Node>?, toLeft: Bool?) {
        var parent: UnsafeMutablePointer<_Node>?
        var node = self.root

        var to_left: Bool?
        while let x = node?.pointee {
            parent = node
            if key < _ElementTraits.key(of: x.element) {
                node = x.left
                to_left = true
            } else {
                node = x.right
                to_left = false
            }
        }

        return (parent: parent, toLeft: to_left)
    }

    @discardableResult
    @inlinable
    internal final func insert(
        _ element: _Element,
        at parent: UnsafeMutablePointer<_Node>?, toLeft: Bool?) -> _Index {
        let new_node = UnsafeMutablePointer<_Node>.allocate(capacity: 1)
        new_node.initialize(to: _Node(_element: element))
        new_node.pointee.parent = parent
        new_node.pointee.color = .red

        if let parent = parent {
            if toLeft == true {
                parent.pointee.left = new_node

                if self.first == parent {
                    self.first = new_node
                }
            } else {
                parent.pointee.right = new_node

                if self.last == parent {
                    self.last = new_node
                }
            }
        } else {
            self.root = new_node
            self.first = new_node
            self.last = new_node
        }

        self.rebalanceAfterInsertion(new_node)

        self.count &+= 1

        return _Index(_node: new_node, _in: self)
    }

    @discardableResult
    @inlinable
    @inline(__always)
    internal final func insert(_ element: _Element)
        -> (inserted: Bool, position: _Index) {
        return self.insert(
            key: _ElementTraits.key(of: element), element: element)
    }

    @discardableResult
    @inlinable
    internal final func insert(key: _Key, element: @autoclosure () -> _Element)
        -> (inserted: Bool, position: _Index) {
        let (parent: parent, toLeft: to_left) =
            self.upperBoundForInsertion(for: key)

        var possible_equivalent = parent
        if to_left == true {
            if parent == self.first {
                let position =
                    self.insert(element(), at: parent, toLeft: to_left)
                return (inserted: true, position: position)
            } else {
                possible_equivalent = self.predecessor(of: parent)
            }
        }

        if let node = possible_equivalent,
           !(_ElementTraits.key(of: node.pointee.element) < key) {
            return (inserted: false, position: _Index(_node: node, _in: self))
        }

        let position = self.insert(element(), at: parent, toLeft: to_left)

        return (inserted: true, position: position)
    }

    @discardableResult
    @inlinable
    @inline(__always)
    internal final func insertLargest(_ element: _Element) -> _Index {
        precondition(
            self.last == nil ||
            _ElementTraits.key(of: self.last!.pointee.element) <
                _ElementTraits.key(of: element))

        return self.insert(element, at: self.last, toLeft: false)
    }

    @discardableResult
    @inlinable
    @inline(__always)
    internal final func insert(_ element: _Element, hint: _Index)
        -> (inserted: Bool, position: _Index) {
        return self.insert(
            key: _ElementTraits.key(of: element), element: element, hint: hint)
    }

    // based on:
    // http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2005/n1780.html
    @inlinable
    internal final func lowerBound(of key: _Key, hint: _Index)
        -> (position: _Index, isEquivalent: Bool?,
            insertPosition: UnsafeMutablePointer<_Node>?, toLeft: Bool?) {
        precondition(
            hint._treeIdentifier == ObjectIdentifier(self),
            "Invalid index used")

        if hint == self.endIndex ||
            key < _ElementTraits.key(of: hint.node!.pointee.element) {
            let predecessor =
                (hint == self.startIndex)
                ? nil : self.predecessor(of: hint.node)
            if predecessor == nil ||
               _ElementTraits.key(of: predecessor!.pointee.element) < key {
                // predecessor < element < hint
                if let parent = hint.node, parent.pointee.left == nil {
                    return (
                        position: hint, isEquivalent: false,
                        insertPosition: parent, toLeft: true)
                } else {
                    // `hint` has the left child, so `predecessor` is
                    // the node whose key is maximum in left children
                    // of `hints`. Therefore, `predecessor` doesn't
                    // have the right child.
                    return (
                        position: hint, isEquivalent: false,
                        insertPosition: predecessor, toLeft: false)
                }
            } else if !(
                key < _ElementTraits.key(of: predecessor!.pointee.element)) {
                // predecessor == key
                return (
                    position: _Index(_node: predecessor, _in: self),
                    isEquivalent: true, insertPosition: nil, toLeft: nil)
            } else {
                let position = self.lowerBound(of: key)
                return (position: position, isEquivalent: nil,
                        insertPosition: nil, toLeft: nil)
            }
        } else if _ElementTraits.key(of: hint.node!.pointee.element) < key {
            let successor =
                _Index(_node: self.successor(of: hint.node), _in: self)
            if successor == self.endIndex ||
               key < _ElementTraits.key(of: successor.node!.pointee.element) {
                // hint < element < successor
                if let parent = hint.node, parent.pointee.right == nil {
                    return (
                        position: successor, isEquivalent: false,
                        insertPosition: parent, toLeft: false)
                } else {
                    // `hint` has the right child, so `successor` is
                    // the node whose key is minimum in right children
                    // of `hints`. Therefore, `successor` doesn't have
                    // the left child.
                    return (
                        position: successor, isEquivalent: false,
                        insertPosition: successor.node, toLeft: true)
                }
            } else if !(
                _ElementTraits.key(
                    of: successor.node!.pointee.element) < key) {
                // successor == key
                return (
                    position: successor, isEquivalent: true,
                    insertPosition: nil, toLeft: nil)
            } else {
                let position = self.lowerBound(of: key)
                return (
                    position: position, isEquivalent: nil,
                    insertPosition: nil, toLeft: nil)
            }
        }

        // hint == element
        return (
            position: hint, isEquivalent: true,
            insertPosition: nil, toLeft: nil)
    }

    // based on:
    // http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2005/n1780.html
    @discardableResult
    @inlinable
    internal final func insert(
        key: _Key, element: @autoclosure () -> _Element, hint: _Index)
        -> (inserted: Bool, position: _Index) {
        let (position, is_equivalent, insert_position, to_left) =
            self.lowerBound(of: key, hint: hint)
        if is_equivalent == true {
            return (inserted: false, position)
        } else if position != self.endIndex,
            !(key < _ElementTraits.key(of: position.node!.pointee.element)) {
            return (inserted: false, position)
        } else if let to_left = to_left {
            let position =
                self.insert(element(), at: insert_position, toLeft: to_left)
            return (inserted: true, position)
        }

        return self.insert(key: key, element: element())
    }

    @inlinable
    @inline(__always)
    internal final func rebalanceAfterInsertion(
        _ z: UnsafeMutablePointer<_Node>) {
        var root = self.rootLink
        _Link.rebalanceAfterInsertion(_Link.bind(z), root: &root)
        self.rootLink = root
    }

    @discardableResult
    @inlinable
    @inline(__always)
    internal final func delete(_ key: _Key) -> _Element? {
        guard let position = self.find(key) else { return nil }

        return self.delete(at: position)
    }

    @discardableResult
    @inlinable
    @inline(__always)
    internal final func delete(at position: _Index) -> _Element {
        precondition(
            position._node != nil &&
            position._treeIdentifier == ObjectIdentifier(self),
            "Invalid index used")

        return self.delete(position.node!)
    }

    @discardableResult
    @inlinable
    internal final func delete(
        _ node: UnsafeMutablePointer<_Node>) -> _Element {
        let element =
            withUnsafeMutablePointer(to: &node.pointee.element) {
                pointer in pointer.move()
            }

        let unlinked_node = self.unlink(node)
        unlinked_node.deallocate()

        return element
    }

    @inlinable
    internal final func deleteKey<Value>(at position: _Index)
        where _ElementTraits.Element == (key: _Key, value: Value) {
        precondition(
            position._node != nil &&
            position._treeIdentifier == ObjectIdentifier(self),
            "Invalid index used")

        let unlinked_node = self.unlink(position.node!)

        if !_isPOD(_Key.self)  {
            withUnsafeMutablePointer(to: &unlinked_node.pointee.element.key) {
                pointer in _ = pointer.deinitialize(count: 1)
            }
        }

        unlinked_node.deallocate()
    }

    @inlinable
    internal final func unlink(_ node: UnsafeMutablePointer<_Node>)
        -> UnsafeMutablePointer<_Node> {
        let raw_node = UnsafeMutableRawPointer(node)
        var root = self.rootLink
        var first = self.firstLink
        var last = self.lastLink
        _Link.delete(
            _Link.bind(raw_node), root: &root, first: &first, last: &last)
        self.rootLink = root
        self.firstLink = first
        self.lastLink = last

        self.count &-= 1

        return _Node.bind(raw_node)
    }

    @inlinable
    internal static func copy(
        _ original: UnsafeMutablePointer<_Node>?,
        parent: UnsafeMutablePointer<_Node>? = nil)
        -> UnsafeMutablePointer<_Node>? {
        guard let original = original else { return nil }

        let node = UnsafeMutablePointer<_Node>.allocate(capacity: 1)
        node.initialize(to: _Node(_element: original.pointee.element))
        node.pointee.color = original.pointee.color
        node.pointee.parent = parent
        node.pointee.left = self.copy(original.pointee.left, parent: node)
        node.pointee.right = self.copy(original.pointee.right, parent: node)

        return node
    }

    @inlinable
    internal final func copy() -> _RedBlackTree {
        let result = _RedBlackTree()

        let root = _RedBlackTree.copy(self.root)
        result.replaceRoot(to: root, count: self.count)

        return result
    }

    @inlinable
    internal final func replaceRoot(
        to root: UnsafeMutablePointer<_Node>?, count: Int) {
        self.root = root
        self.first = self.minimum
        self.last = self.maximum
        self.count = count
    }

    @inlinable
    @inline(__always)
    internal final func equivalent(
        ofOtherTreeNode node: UnsafeMutablePointer<_Node>)
        -> UnsafeMutablePointer<_Node> {
        return _Node.bind(
            _Link.equivalent(of: _Link.bind(node), in: self.rootLink!))
    }

    @inlinable
    @inline(__always)
    internal final func equivalent(ofOtherTreeIndex index: _Index) -> _Index {
        guard
            let node = index.node
        else {
            return _Index(_node: nil, _in: self)
        }

        return _Index(_node: self.equivalent(ofOtherTreeNode: node), _in: self)
    }
}

extension _RedBlackTree {
    @usableFromInline
    internal struct _Index {
        @usableFromInline internal var _node: UnsafeMutableRawPointer?
        @usableFromInline internal let _treeIdentifier: ObjectIdentifier

        @inlinable
        @inline(__always)
        internal init(
            _node: UnsafeMutableRawPointer?, _in _tree: _RedBlackTree) {
            self._node = _node
            self._treeIdentifier = ObjectIdentifier(_tree)
        }

        @inlinable
        internal var node: UnsafeMutablePointer<_Node>? {
            @inline(__always)
            get { return _Node.bind(self._node) }
        }
    }
}

extension _RedBlackTree._Index: Equatable {
    @inlinable
    @inline(__always)
    static func == (
        lhs: _RedBlackTree._Index, rhs: _RedBlackTree._Index) -> Bool {
        precondition(
            lhs._treeIdentifier == rhs._treeIdentifier,
            "Invalid index used")

        return lhs._node == rhs._node
    }
}

extension _RedBlackTree._Index: Comparable {
    @inlinable
    internal static func < (
        lhs: _RedBlackTree._Index, rhs: _RedBlackTree._Index) -> Bool {
        precondition(
            lhs._treeIdentifier == rhs._treeIdentifier,
            "Invalid index used")

        guard lhs.node != rhs.node else { return false }

        typealias Node = _RedBlackTree._Node
        if let x = lhs.node, let y = rhs.node {
            return
                _ElementTraits.key(of: Node.bind(x).pointee.element) <
                   _ElementTraits.key(of: Node.bind(y).pointee.element)
        }

        return rhs.node == nil ? true : false
    }
}

extension _RedBlackTree._Index: Hashable {
    @inlinable
    @inline(__always)
    func hash(into hasher: inout Hasher) {
        hasher.combine(self._node)
    }
}

extension _RedBlackTree {
    @inlinable
    @inline(__always)
    internal final var startIndex: _Index {
        return _Index(_node: self.first, _in: self)
    }

    @inlinable
    @inline(__always)
    internal final var endIndex: _Index {
        return _Index(_node: nil, _in: self)
    }

    @inlinable
    @inline(__always)
    internal final func index(after index: _Index) -> _Index {
        precondition(
            index._node != nil &&
            index._treeIdentifier == ObjectIdentifier(self),
            "Invalid index used")

        let successor = self.successor(of: index.node)
        return _Index(_node: successor, _in: self)
    }
}

extension _RedBlackTree {
    @inlinable
    @inline(__always)
    internal final func index(before index: _Index) -> _Index {
        precondition(
            index._treeIdentifier == ObjectIdentifier(self),
            "Invalid index used")

        let predecessor = self.predecessor(of: index.node)
        return _Index(_node: predecessor, _in: self)
    }
}

extension _RedBlackTree {
    @inlinable
    internal final func mapValues<
        Value, MappedValue,
        MappedElementTraits: _RedBlackTreeElementTraits>(
        into result: inout _RedBlackTree<MappedElementTraits>,
        by transform: (Value) throws -> MappedValue) rethrows
        where _ElementTraits.Element == (key: _Key, value: Value),
              MappedElementTraits.Element == (key: _Key, value: MappedValue) {
        typealias MappedNode = _RedBlackTree<MappedElementTraits>._Node
        let parent: UnsafeMutablePointer<MappedNode>? = nil
        let root =
            try type(of: self).mapValues(
                self.root, parent: parent, by: transform)

        result.replaceRoot(to: root, count: self.count)
    }

    @inlinable
    internal static func mapValues<
        Value, MappedValue,
        MappedElementTraits: _RedBlackTreeElementTraits>(
        _ original: UnsafeMutablePointer<_Node>?,
        parent:
            UnsafeMutablePointer<_RedBlackTree<MappedElementTraits>._Node>?,
        by transform: (Value) throws -> MappedValue) rethrows
        -> UnsafeMutablePointer<_RedBlackTree<MappedElementTraits>._Node>?
        where _ElementTraits.Element == (key: _Key, value: Value),
              MappedElementTraits.Element == (key: _Key, value: MappedValue) {
        guard let original = original else { return nil }

        typealias MappedNode = _RedBlackTree<MappedElementTraits>._Node
        let node = UnsafeMutablePointer<MappedNode>.allocate(capacity: 1)
        let element =
            (key: original.pointee.element.key,
             value: try transform(original.pointee.element.value))

        node.initialize(to:
            MappedNode(_element: element, _color: original.pointee.color))
        node.pointee.parent = parent
        node.pointee.left =
            try self.mapValues(
                original.pointee.left, parent: node, by: transform)
        node.pointee.right =
            try self.mapValues(
                original.pointee.right, parent: node, by: transform)

        return node
    }
}
