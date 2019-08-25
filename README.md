# Cloche

[![Swift >=5.0](https://img.shields.io/badge/swift-%3E%3D5.0-blue.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Ubuntu-blue.svg)](https://github.com/atarashi-y/Cloche)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/atarashi-y/Cloche/blob/master/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Cloche.svg)](https://cocoapods.org/pods/Cloche)
[![Build Status](https://travis-ci.com/atarashi-y/Cloche.svg?branch=master)](https://travis-ci.com/atarashi-y/Cloche)
[![codecov](https://codecov.io/gh/atarashi-y/Cloche/branch/master/graph/badge.svg)](https://codecov.io/gh/atarashi-y/Cloche)

Cloche is a pure Swift library for sorted collections.

## Features

* Cloche provides SortedSet and SortedDictionary, these have almost the same
  interfaces as Set and Dictionary in the Swift standard Library,
  respectively.
* Cloche.SortedSet and Cloche.SortedDictionary are implemented using
  RedBlack-Tree, so can perform insertion, search, deletion operations in
  logarithmic time.

## Performance Comparisons

### macOS

||Description|
|:--:|:--:|
|OS|macOS Mojave 10.14.6|
|CPU|Core i5 8259U|
|Swift|5.0.1 (Xcode 10.3)|

<p align=center>
    <img src="https://raw.githubusercontent.com/atarashi-y/Cloche/master/Resources/Performance-macOS-Insertion.png" width=80% alt="Insertion Performance Comparison under macOS"/>
</p>
<p align=center>
    <img src="https://raw.githubusercontent.com/atarashi-y/Cloche/master/Resources/Performance-macOS-Search.png" width=80% alt="Search Performance Comparison under macOS"/>
</p>
<p align=center>
    <img src="https://raw.githubusercontent.com/atarashi-y/Cloche/master/Resources/Performance-macOS-Deletion.png" width=80% alt="Deletion Performance Comparison under macOS"/>
</p>

### Ubuntu

||Description|
|:--:|:--:|
|OS|Ubuntu 18.04|
|CPU|Core i9 9900K|
|Swift|5.0.1|

<p align=center>
    <img src="https://raw.githubusercontent.com/atarashi-y/Cloche/master/Resources/Performance-Ubuntu-Insertion.png" width=80% alt="Insertion Performance Comparison under Ubuntu"/>
</p>
<p align=center>
    <img src="https://raw.githubusercontent.com/atarashi-y/Cloche/master/Resources/Performance-Ubuntu-Search.png" width=80% alt="Search Performance Comparison under Ubuntu"/>
</p>
<p align=center>
    <img src="https://raw.githubusercontent.com/atarashi-y/Cloche/master/Resources/Performance-Ubuntu-Deletion.png" width=80% alt="Deletion Performance Comparison under Ubuntu"/>
</p>

## Requirements

- iOS 10.0+ / macOS 10.12+ / tvOS 10.0+ / watchOS 3.0+ / Ubuntu 16.04+
- Xcode 10.2+
- Swift 5.0+

## Installation

### CocoaPods

Add the following line to your `Podfile`:

```ruby
pod 'Cloche'
```

### Carthage

Add the following line to your `Cartfile`:

```ogdl
github "atarashi-y/Cloche"
```

### Swift Package Manager

To integrate `Cloche` into your project, specify it in your `Package.swift`
file:

```swift
let package = Package(
    name: "YourProject",
    dependencies: [
        .package(
            url: "https://github.com/atarashi-y/Cloche.git",
            from: "0.1.0")
    ])
```

## Example

### SortedSet

```swift
import Cloche

var s1: SortedSet = [5, 2, 3, 4]
print(s1) // [2, 3, 4, 5]

s1.insert(1)
print(s1[s1.startIndex]) // 1
print(s1) // [1, 2, 3, 4, 5]

print(s1.remove(5)!) // 5
print(s1.last!) // 4
print(s1) // [1, 2, 3, 4]

let s2: SortedSet = [3, 7, 1, 9]
print(s1.union(s2)) // [1, 2, 3, 4, 7, 9]
```

### SortedDictionary

```swift
import Cloche

let countries = ["Singapore", "Canada", "Sweden", "Egypt", "Croatia"]
var d1 = SortedDictionary(grouping: countries) {
    country in String(country.first!)
}
print(d1["C"]!)	// ["Canada", "Croatia"]
print(d1) // ["C": ["Canada", "Croatia"], "E": ["Egypt"], "S": ["Singapore", "Sweden"]]

d1["G", default: []].append("Greece")
d1["E", default: []].append("Ecuador")
print(d1) // ["C": ["Canada", "Croatia"], "E": ["Egypt", "Ecuador"], "G": ["Greece"], "S": ["Singapore", "Sweden"]]

let d2 = d1.compactMapValues {
    v in v.count > 1 ? v.map { $0.uppercased() } : nil
}
print(d2) // ["C": ["CANADA", "CROATIA"], "E": ["EGYPT", "ECUADOR"], "S": ["SINGAPORE", "SWEDEN"]]
```

## License

Cloche is released under the Apache-2.0
license.
[See LICENSE](https://github.com/atarashi-y/Cloche/blob/master/LICENSE.txt)
for details.
