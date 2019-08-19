//
// SetCollection.swift
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

public protocol SetCollection: Collection, SetAlgebra {
    init<Source: Sequence>(_ sequence: Source) where Element == Source.Element

    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self

    @discardableResult mutating func removeFirst() -> Element

    @discardableResult mutating func remove(at position: Index) -> Element

    mutating func removeAll(keepingCapacity keepCapacity: Bool)
}

extension Set: SetCollection {}
