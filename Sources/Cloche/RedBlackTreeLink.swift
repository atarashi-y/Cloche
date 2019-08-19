//
// RedBlackTreeLink.swift
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

// This implementation is based on Introduction to Algorithms, 3rd
// Edition (MIT Press, 2009), Thomas H. Cormen and Charles
// E. Leiserson and Ronald L. Rivest and Clifford Stein.
@usableFromInline
internal struct _RedBlackTreeLink {
    @usableFromInline
    internal enum _Color {
        case red
        case black
    }

    @usableFromInline internal var color: _Color

    @inlinable
    internal var parent: UnsafeMutablePointer<_RedBlackTreeLink>? {
        @inline(__always)
        get { return type(of: self).bind(self._parent) }

        @inline(__always)
        set { self._parent = UnsafeMutableRawPointer(newValue) }
    }

    @inlinable
    internal var left: UnsafeMutablePointer<_RedBlackTreeLink>? {
        @inline(__always)
        get { return type(of: self).bind(self._left) }

        @inline(__always)
        set { self._left = UnsafeMutableRawPointer(newValue) }
    }

    @inlinable
    internal var right: UnsafeMutablePointer<_RedBlackTreeLink>? {
        @inline(__always)
        get { return type(of: self).bind(self._right) }

        @inline(__always)
        set { self._right = UnsafeMutableRawPointer(newValue) }
    }

    @usableFromInline internal var _parent: UnsafeMutableRawPointer?
    @usableFromInline internal var _left: UnsafeMutableRawPointer?
    @usableFromInline internal var _right: UnsafeMutableRawPointer?

    @inlinable
    @inline(__always)
    internal static func bind(_ pointer: UnsafeMutableRawPointer?)
        -> UnsafeMutablePointer<_RedBlackTreeLink>? {
        return pointer?.bindMemory(to: _RedBlackTreeLink.self, capacity: 1)
    }

    @inlinable
    @inline(__always)
    internal  static func bind(_ pointer: UnsafeMutableRawPointer)
        -> UnsafeMutablePointer<_RedBlackTreeLink> {
        return pointer.bindMemory(to: _RedBlackTreeLink.self, capacity: 1)
    }

    @inlinable
    internal static func minimum(
        in tree: UnsafeMutablePointer<_RedBlackTreeLink>?)
        -> UnsafeMutablePointer<_RedBlackTreeLink>? {
        var link = tree
        while link?.pointee.left != nil {
            link = link?.pointee.left
        }

        return link
    }

    @inlinable
    internal static func maximum(
        in tree: UnsafeMutablePointer<_RedBlackTreeLink>?)
        -> UnsafeMutablePointer<_RedBlackTreeLink>? {
        var link = tree
        while link?.pointee.right != nil {
            link = link?.pointee.right
        }

        return link
    }

    @inlinable
    internal static func successor(
        of link: UnsafeMutablePointer<_RedBlackTreeLink>?)
        -> UnsafeMutablePointer<_RedBlackTreeLink>? {
        if let right = link?.pointee.right {
            return minimum(in: right)
        }

        var link = link
        while link?.pointee.parent != nil &&
                  link == link?.pointee.parent?.pointee.right  {
            link = link?.pointee.parent
        }

        return link?.pointee.parent
    }

    @inlinable
    internal static func predecessor(
        of link: UnsafeMutablePointer<_RedBlackTreeLink>?)
        -> UnsafeMutablePointer<_RedBlackTreeLink>? {
        if let left = link?.pointee.left {
            return maximum(in: left)
        }

        var link = link
        while link?.pointee.parent != nil &&
                  link == link?.pointee.parent?.pointee.left {
            link = link?.pointee.parent
        }

        return link?.pointee.parent
    }

    @inlinable
    internal static func rotateLeft(
        _ x: UnsafeMutablePointer<_RedBlackTreeLink>?,
        root: inout UnsafeMutablePointer<_RedBlackTreeLink>?) {
        let y = x?.pointee.right
        x?.pointee.right = y?.pointee.left

        if y?.pointee.left != nil {
            y?.pointee.left?.pointee.parent = x
        }
        y?.pointee.parent = x?.pointee.parent

        if x?.pointee.parent == nil {
            root = y
        } else if x == x?.pointee.parent?.pointee.left {
            x?.pointee.parent?.pointee.left = y
        } else {
            x?.pointee.parent?.pointee.right = y
        }

        y?.pointee.left = x
        x?.pointee.parent = y
    }

    @inlinable
    internal static func rotateRight(
        _ x: UnsafeMutablePointer<_RedBlackTreeLink>?,
        root: inout UnsafeMutablePointer<_RedBlackTreeLink>?) {
        let y = x?.pointee.left
        x?.pointee.left = y?.pointee.right

        if y?.pointee.right != nil {
            y?.pointee.right?.pointee.parent = x
        }
        y?.pointee.parent = x?.pointee.parent

        if x?.pointee.parent == nil {
            root = y
        } else if x == x?.pointee.parent?.pointee.right {
            x?.pointee.parent?.pointee.right = y
        } else {
            x?.pointee.parent?.pointee.left = y
        }

        y?.pointee.right = x
        x?.pointee.parent = y
    }

    @usableFromInline
    internal static func rebalanceAfterInsertion(
        _ z: UnsafeMutablePointer<_RedBlackTreeLink>,
        root: inout UnsafeMutablePointer<_RedBlackTreeLink>?) {
        var z = z
        while z.pointee.parent != nil,
            z.pointee.parent!.pointee.color == .red {
            if z.pointee.parent ==
                   z.pointee.parent!.pointee.parent!.pointee.left {
                let y = z.pointee.parent!.pointee.parent!.pointee.right
                if y?.pointee.color == .red {
                    z.pointee.parent!.pointee.color = .black
                    y!.pointee.color = .black
                    z.pointee.parent!.pointee.parent!.pointee.color = .red
                    z = z.pointee.parent!.pointee.parent!
                } else {
                    if z == z.pointee.parent!.pointee.right {
                        z = z.pointee.parent!
                        self.rotateLeft(z, root: &root)
                    }

                    z.pointee.parent!.pointee.color = .black
                    z.pointee.parent!.pointee.parent!.pointee.color = .red
                    self.rotateRight(
                        z.pointee.parent!.pointee.parent, root: &root)
                }
            } else {
                let y = z.pointee.parent!.pointee.parent!.pointee.left
                if y?.pointee.color == .red {
                    z.pointee.parent!.pointee.color = .black
                    y!.pointee.color = .black
                    z.pointee.parent!.pointee.parent!.pointee.color = .red
                    z = z.pointee.parent!.pointee.parent!
                } else {
                    if z == z.pointee.parent!.pointee.left {
                        z = z.pointee.parent!
                        self.rotateRight(z, root: &root)
                    }
                    z.pointee.parent!.pointee.color = .black
                    z.pointee.parent!.pointee.parent!.pointee.color = .red
                    self.rotateLeft(
                        z.pointee.parent!.pointee.parent, root: &root)
                }
            }
        }

        root?.pointee.color = .black
    }

    @inlinable
    internal static func transplant(
        u: UnsafeMutablePointer<_RedBlackTreeLink>?,
        v: UnsafeMutablePointer<_RedBlackTreeLink>?,
        root: inout UnsafeMutablePointer<_RedBlackTreeLink>?) {
        if u?.pointee.parent == nil {
            root = v
        } else if u == u?.pointee.parent?.pointee.left {
            u?.pointee.parent?.pointee.left = v
        } else {
            u?.pointee.parent?.pointee.right = v
        }

        v?.pointee.parent = u?.pointee.parent
    }

    @usableFromInline
    static func rebalanceAfterDeletion(
        _ x: UnsafeMutablePointer<_RedBlackTreeLink>?,
        parent: UnsafeMutablePointer<_RedBlackTreeLink>?,
        root: inout UnsafeMutablePointer<_RedBlackTreeLink>?) {
        var x = x
        var parent = parent
        while x != root && x?.pointee.color == .black {
            if x == parent?.pointee.left {
                var w = parent?.pointee.right
                if w?.pointee.color == .red {
                    w?.pointee.color = .black
                    parent?.pointee.color = .red
                    self.rotateLeft(parent, root: &root)
                    w = parent?.pointee.right
                }

                if (w?.pointee.left == nil ||
                        w?.pointee.left?.pointee.color == .black) &&
                       (w?.pointee.right == nil ||
                            w?.pointee.right?.pointee.color == .black) {
                    w?.pointee.color = .red
                    x = parent
                    parent = parent?.pointee.parent
                } else {
                    if w?.pointee.right == nil ||
                           w?.pointee.right?.pointee.color == .black {
                        w?.pointee.left?.pointee.color = .black
                        w?.pointee.color = .red
                        self.rotateRight(w, root: &root)
                        w = parent?.pointee.right
                    }
                    w?.pointee.color = parent!.pointee.color
                    parent?.pointee.color = .black
                    w?.pointee.right?.pointee.color = .black
                    self.rotateLeft(parent, root: &root)
                    break
                }
            } else {
                var w = parent?.pointee.left
                if w?.pointee.color == .red {
                    w?.pointee.color = .black
                    parent?.pointee.color = .red
                    self.rotateLeft(parent, root: &root)
                    w = parent?.pointee.left
                }

                if (w?.pointee.right == nil ||
                        w?.pointee.right?.pointee.color == .black) &&
                       (w?.pointee.left == nil ||
                            w?.pointee.left?.pointee.color == .black) {
                    w?.pointee.color = .red
                    x = parent
                    parent = parent?.pointee.parent
                } else {
                    if w?.pointee.left == nil ||
                           w?.pointee.left?.pointee.color == .black {
                        w?.pointee.right?.pointee.color = .black
                        w?.pointee.color = .red
                        self.rotateLeft(w, root: &root)
                        w = parent?.pointee.left
                    }
                    w?.pointee.color = parent!.pointee.color
                    parent?.pointee.color = .black
                    w?.pointee.left?.pointee.color = .black
                    self.rotateRight(parent, root: &root)
                    break
                }
            }
        }

        x?.pointee.color = .black
    }

    @usableFromInline
    static func
    delete(
        _ z: UnsafeMutablePointer<_RedBlackTreeLink>,
        root: inout UnsafeMutablePointer<_RedBlackTreeLink>?,
        first: inout UnsafeMutablePointer<_RedBlackTreeLink>?,
        last: inout UnsafeMutablePointer<_RedBlackTreeLink>?) {
        if first == last {
            first = nil
            last = nil
        } else {
            if z == first {
                first = self.successor(of: z)
            }

            if z == last {
                last = self.predecessor(of: z)
            }
        }

        var x: UnsafeMutablePointer<_RedBlackTreeLink>?
        var x_parent: UnsafeMutablePointer<_RedBlackTreeLink>?
        var y = z
        var y_original_color = y.pointee.color

        if z.pointee.left == nil {
            x = z.pointee.right
            x_parent = x?.pointee.parent
            self.transplant(u: z, v: x, root: &root)
        } else if z.pointee.right == nil {
            x = z.pointee.left
            x_parent = x?.pointee.parent
            self.transplant(u: z, v: x, root: &root)
        } else {
            y = self.minimum(in: z.pointee.right)!
            y_original_color = y.pointee.color
            x = y.pointee.right
            if y.pointee.parent == z {
                x_parent = y
                x?.pointee.parent = y
            } else {
                self.transplant(u: y, v: y.pointee.right, root: &root)
                y.pointee.right = z.pointee.right
                y.pointee.right?.pointee.parent = y
            }

            self.transplant(u: z, v: y, root: &root)
            y.pointee.left = z.pointee.left
            y.pointee.left?.pointee.parent = y
            y.pointee.color = z.pointee.color
        }

        if y_original_color == .black {
            self.rebalanceAfterDeletion(x, parent: x_parent, root: &root)
        }
    }
}

extension _RedBlackTreeLink {
    @usableFromInline
    internal enum _PathDirection {
        case left
        case right
    }

    @inlinable
    internal static func path(
        to node: UnsafeMutablePointer<_RedBlackTreeLink>)
        ->  ReversedCollection<[_PathDirection]> {
        var reversed_path = [_PathDirection]()
        var other_tree_node = node
        while let parent = other_tree_node.pointee.parent {
            if parent.pointee.left == other_tree_node {
                reversed_path.append(.left)
            } else {
                reversed_path.append(.right)
            }

            other_tree_node = parent
        }

        return reversed_path.reversed()
    }

    @inlinable
    internal static func equivalent(
        of node: UnsafeMutablePointer<_RedBlackTreeLink>,
        in tree: UnsafeMutablePointer<_RedBlackTreeLink>)
        -> UnsafeMutablePointer<_RedBlackTreeLink> {
        let path = self.path(to: node)

        var equivalent_node = tree
        for direction in path {
            switch direction {
            case .left:
                equivalent_node = equivalent_node.pointee.left!
            case .right:
                equivalent_node = equivalent_node.pointee.right!
            }
        }

        return equivalent_node
    }
}
