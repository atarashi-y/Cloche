//
// CollectionDescription.swift
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

internal func _description<C: Collection>(
    of collection: C, name: String = "", emptyDescription: String = "[]",
    describe: ((C.Element) -> String)? = nil) -> String {
    guard
        let first = collection.first
    else {
        if name.isEmpty {
            return emptyDescription
        } else {
            return "\(name)(\(emptyDescription))"
        }
    }

    var description = name.isEmpty ? "[" : "\(name)(["

    let write: (C.Element) -> Void
    if let describe = describe {
        write = { description += describe($0) }
    } else {
        write = { debugPrint($0, terminator: "", to: &description) }
    }

    write(first)
    for element in collection.dropFirst() {
        description += ", "
        write(element)
    }

    description += name.isEmpty ? "]" : "])"

    return description
}
