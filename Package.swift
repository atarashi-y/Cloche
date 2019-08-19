// swift-tools-version:5.0
//
// Package.swift
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

import PackageDescription

let package = Package(
    name: "Cloche",
    products: [
        .library(name: "Cloche", targets: ["Cloche"]),
    ],
    targets: [
        .target(
            name: "Cloche", dependencies: []),
        .target(
            name:"CXXPerformanceTests",
            dependencies: [],
            path: "Tests/CXXPerformanceTests"),
        .target(
            name: "ClochePerformanceTests",
            dependencies: ["Cloche", "CXXPerformanceTests"],
            path: "Tests/ClochePerformanceTests"),
        .target(
            name: "ClochePerformanceTestsDriver",
            dependencies: ["ClochePerformanceTests"],
            path: "Tests/ClochePerformanceTestsDriver"),
        .testTarget(
            name: "ClocheTests", dependencies: ["Cloche"]),
    ],
    swiftLanguageVersions: [.v5],
    cxxLanguageStandard: .cxx1z
)
