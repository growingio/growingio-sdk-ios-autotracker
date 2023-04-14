// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

//
//  Package.swift
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/03/17.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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
    name: "GrowingAnalytics",
    platforms: [.iOS(.v10), .macCatalyst(.v13), .macOS(.v10_12)],
    products: [
        .library(
            name: "GrowingAutotracker_cdp",
            targets: ["GrowingAutotracker_cdp_Wrapper"]
        ),
        .library(
            name: "GrowingTracker_cdp",
            targets: ["GrowingTracker_cdp_Wrapper"]
        ),
        .library(
            name: "GrowingAutotracker",
            targets: ["GrowingAutotracker_Wrapper"]
        ),
        .library(
            name: "GrowingTracker",
            targets: ["GrowingTracker_Wrapper"]
        ),
        .library(
            name: "GrowingAutotracker_cdp_NoIDFA",
            targets: ["GrowingAutotracker_cdp_NoIDFA_Wrapper"]
        ),
        .library(
            name: "GrowingTracker_cdp_NoIDFA",
            targets: ["GrowingTracker_cdp_NoIDFA_Wrapper"]
        ),
        .library(
            name: "GrowingAutotracker_NoIDFA",
            targets: ["GrowingAutotracker_NoIDFA_Wrapper"]
        ),
        .library(
            name: "GrowingTracker_NoIDFA",
            targets: ["GrowingTracker_NoIDFA_Wrapper"]
        ),
        .library(
            name: "GrowingModule_Hybrid",
            targets: ["GrowingModule_Hybrid"]
        ),
        .library(
            name: "GrowingModule_Advert",
            targets: ["GrowingModule_Advert"]
        ),
        .library(
            name: "GrowingModule_APM",
            targets: ["GrowingModule_APM"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/growingio/growingio-sdk-ios-utilities.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/growingio/growingio-sdk-ios-performance-ext.git",
            branch: "master"
        ),
    ],
    targets: [
        
        // MARK: - GrowingAnalytics Wrapper
        
        .target(
            name: "GrowingAutotracker_cdp_Wrapper",
            dependencies: [
                "GrowingAutotracker_cdp",
                "GrowingUserIdentifier",
                "GrowingModule_DefaultServices",
                .target(name: "GrowingModule_Hybrid", condition: .when(platforms: [.iOS, .macCatalyst])),
                .target(name: "GrowingModule_MobileDebugger", condition: .when(platforms: [.iOS])),
                .target(name: "GrowingModule_WebCircle", condition: .when(platforms: [.iOS])),
            ],
            path: "SwiftPM-Wrap/GrowingAutotracker-cdp-Wrapper"
        ),
        .target(
            name: "GrowingTracker_cdp_Wrapper",
            dependencies: [
                "GrowingTracker_cdp",
                "GrowingUserIdentifier",
                "GrowingModule_DefaultServices",
                .target(name: "GrowingModule_MobileDebugger", condition: .when(platforms: [.iOS])),
            ],
            path: "SwiftPM-Wrap/GrowingTracker-cdp-Wrapper"
        ),
        .target(
            name: "GrowingAutotracker_Wrapper",
            dependencies: [
                "GrowingAutotracker",
                "GrowingUserIdentifier",
                "GrowingModule_DefaultServices",
                .target(name: "GrowingModule_Hybrid", condition: .when(platforms: [.iOS, .macCatalyst])),
                .target(name: "GrowingModule_MobileDebugger", condition: .when(platforms: [.iOS])),
                .target(name: "GrowingModule_WebCircle", condition: .when(platforms: [.iOS])),
            ],
            path: "SwiftPM-Wrap/GrowingAutotracker-Wrapper"
        ),
        .target(
            name: "GrowingTracker_Wrapper",
            dependencies: [
                "GrowingTracker",
                "GrowingUserIdentifier",
                "GrowingModule_DefaultServices",
                .target(name: "GrowingModule_MobileDebugger", condition: .when(platforms: [.iOS])),
            ],
            path: "SwiftPM-Wrap/GrowingTracker-Wrapper"
        ),
        
        // MARK: - GrowingAnalytics Public API
        
        .target(
            name: "GrowingAutotracker_cdp",
            dependencies: [
                "GrowingTrackerCore_cdp",
                "GrowingAutotrackerCore"
            ],
            path: "GrowingAutotracker-cdp",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".."),
            ]
        ),
        .target(
            name: "GrowingTracker_cdp",
            dependencies: ["GrowingTrackerCore_cdp"],
            path: "GrowingTracker-cdp",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".."),
            ]
        ),
        .target(
            name: "GrowingAutotracker",
            dependencies: ["GrowingAutotrackerCore"],
            path: "GrowingAutotracker",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".."),
            ]
        ),
        .target(
            name: "GrowingTracker",
            dependencies: ["GrowingTrackerCore"],
            path: "GrowingTracker",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".."),
            ]
        ),
        
        // MARK: - GrowingAnalytics Core
        
        .target(
            name: "GrowingUserIdentifier",
            dependencies: [],
            path: "GrowingTrackerCore/Utils/UserIdentifier",
            exclude: ["GrowingUserIdentifier_NoIDFA.m"],
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("../../.."),
            ]
        ),
        .target(
            name: "GrowingUserIdentifier_NoIDFA",
            dependencies: [],
            path: "GrowingTrackerCore/Utils/UserIdentifier",
            exclude: ["GrowingUserIdentifier.m"],
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("../../.."),
            ]
        ),
        .target(
            name: "GrowingTrackerCore",
            dependencies: [
                .product(name: "GrowingUtilsTrackerCore", package: "growingio-sdk-ios-utilities"),
            ],
            path: "GrowingTrackerCore",
            exclude: ["Utils/UserIdentifier"],
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath(".."),
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
                .linkedFramework("UIKit", .when(platforms: [.iOS, .macCatalyst])),
            ]
        ),
        .target(
            name: "GrowingAutotrackerCore",
            dependencies: [
                "GrowingTrackerCore",
                .product(name: "GrowingUtilsAutotrackerCore", package: "growingio-sdk-ios-utilities"),
            ],
            path: "GrowingAutotrackerCore",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath(".."),
            ]
        ),
        .target(
            name: "GrowingTrackerCore_cdp",
            dependencies: ["GrowingTrackerCore"],
            path: "GrowingTrackerCore-cdp",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath(".."),
            ]
        ),

        // MARK: - GrowingAnalytics Services

        .target(
            name: "GrowingService_Database",
            dependencies: ["GrowingTrackerCore"],
            path: "Services/Database",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),
        .target(
            name: "GrowingService_Network",
            dependencies: ["GrowingTrackerCore"],
            path: "Services/Network",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),
        .target(
            name: "GrowingService_WebSocket",
            dependencies: ["GrowingTrackerCore"],
            path: "Services/WebSocket",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),
        .target(
            name: "GrowingService_Compression",
            dependencies: ["GrowingTrackerCore"],
            path: "Services/Compression",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),
        .target(
            name: "GrowingService_Encryption",
            dependencies: ["GrowingTrackerCore"],
            path: "Services/Encryption",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),

        // MARK: - GrowingAnalytics Modules

        .target(
            name: "GrowingModule_DefaultServices",
            dependencies: [
                "GrowingTrackerCore",
                "GrowingService_Database",
                "GrowingService_Network",
                "GrowingService_Encryption",
                "GrowingService_Compression"
            ],
            path: "Modules/DefaultServices",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),
        .target(
            name: "GrowingModule_MobileDebugger",
            dependencies: [
                "GrowingTrackerCore",
                "GrowingService_WebSocket"
            ],
            path: "Modules/MobileDebugger",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),
        .target(
            name: "GrowingModule_WebCircle",
            dependencies: [
                "GrowingAutotrackerCore",
                "GrowingService_WebSocket",
                "GrowingModule_Hybrid"
            ],
            path: "Modules/WebCircle",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),
        .target(
            name: "GrowingModule_Hybrid",
            dependencies: ["GrowingTrackerCore"],
            path: "Modules/Hybrid",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../.."),
            ],
            linkerSettings: [
                .linkedFramework("WebKit", .when(platforms: [.iOS, .macCatalyst])),
            ]
        ),
        .target(
            name: "GrowingModule_Advert",
            dependencies: ["GrowingTrackerCore"],
            path: "Modules/Advert",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),
        .target(
            name: "GrowingModule_APM",
            dependencies: [
                "GrowingTrackerCore",
                .product(name: "GrowingAPM", package: "growingio-sdk-ios-performance-ext"),
            ],
            path: "Modules/APM",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),

        // MARK: - GrowingAnalytics Wrapper (No IDFA)
    
        .target(
            name: "GrowingAutotracker_cdp_NoIDFA_Wrapper",
            dependencies: [
                "GrowingAutotracker_cdp",
                "GrowingUserIdentifier_NoIDFA",
                "GrowingModule_DefaultServices",
                .target(name: "GrowingModule_Hybrid", condition: .when(platforms: [.iOS, .macCatalyst])),
                .target(name: "GrowingModule_MobileDebugger", condition: .when(platforms: [.iOS])),
                .target(name: "GrowingModule_WebCircle", condition: .when(platforms: [.iOS])),
            ],
            path: "SwiftPM-Wrap/GrowingAutotracker-cdp-NoIDFA-Wrapper"
        ),
        .target(
            name: "GrowingTracker_cdp_NoIDFA_Wrapper",
            dependencies: [
                "GrowingTracker_cdp",
                "GrowingUserIdentifier_NoIDFA",
                "GrowingModule_DefaultServices",
                .target(name: "GrowingModule_MobileDebugger", condition: .when(platforms: [.iOS])),
            ],
            path: "SwiftPM-Wrap/GrowingTracker-cdp-NoIDFA-Wrapper"
        ),
        .target(
            name: "GrowingAutotracker_NoIDFA_Wrapper",
            dependencies: [
                "GrowingAutotracker",
                "GrowingUserIdentifier_NoIDFA",
                "GrowingModule_DefaultServices",
                .target(name: "GrowingModule_Hybrid", condition: .when(platforms: [.iOS, .macCatalyst])),
                .target(name: "GrowingModule_MobileDebugger", condition: .when(platforms: [.iOS])),
                .target(name: "GrowingModule_WebCircle", condition: .when(platforms: [.iOS])),
            ],
            path: "SwiftPM-Wrap/GrowingAutotracker-NoIDFA-Wrapper"
        ),
        .target(
            name: "GrowingTracker_NoIDFA_Wrapper",
            dependencies: [
                "GrowingTracker",
                "GrowingUserIdentifier_NoIDFA",
                "GrowingModule_DefaultServices",
                .target(name: "GrowingModule_MobileDebugger", condition: .when(platforms: [.iOS])),
            ],
            path: "SwiftPM-Wrap/GrowingTracker-NoIDFA-Wrapper"
        )
    ]
)
