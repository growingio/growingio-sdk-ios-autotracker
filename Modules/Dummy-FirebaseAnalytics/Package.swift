// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

//
//  Package.swift
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/05/30.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import PackageDescription

let package = Package(
    name: "GrowingDummyFirebaseAnalytics",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "Dummy_FirebaseAnalytics",
            targets: ["Dummy_FirebaseAnalyticsTarget"]
        ),
    ],
    dependencies: [],
    targets: [

        // MARK: - GrowingAnalytics Wrapper (GA Adapter)
        
        .target(
            name: "Dummy_FirebaseAnalyticsTarget",
            dependencies: [
                "Firebase",
                "FirebaseCore",
                "FirebaseAnalytics",
            ],
            path: "Dummy-FirebaseAnalytics-Wrapper"
        ),
        .binaryTarget(
            name: "Firebase",
            path: "Firebase.xcframework"
        ),
        .binaryTarget(
            name: "FirebaseCore",
            path: "FirebaseCore.xcframework"
        ),
        .binaryTarget(
            name: "FirebaseAnalytics",
            path: "FirebaseAnalytics.xcframework"
        ),
    ]
)
