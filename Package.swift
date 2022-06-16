// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

//
//  Package.swift
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/03/17.
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
    name: "GrowingAnalytics",
    platforms: [.iOS(.v9)],
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
            name: "GrowingModule_GAAdapter",
            targets: ["GrowingModule_GAAdapter"]
        ),
    ],
    dependencies: [],
    targets: [
        
        // MARK: - GrowingAnalytics Wrapper
        
        .target(
            name: "GrowingAutotracker_cdp_Wrapper",
            dependencies: [
                "GrowingAutotracker_cdp",
                "GrowingUserIdentifier",
                "GrowingModule_Hybrid",
                "GrowingModule_MobileDebugger",
                "GrowingModule_WebCircle",
                "GrowingModule_DefaultServices"
            ],
            path: "SwiftPM-Wrap/GrowingAutotracker-cdp-Wrapper"
        ),
        .target(
            name: "GrowingTracker_cdp_Wrapper",
            dependencies: [
                "GrowingTracker_cdp",
                "GrowingUserIdentifier",
                "GrowingModule_MobileDebugger",
                "GrowingModule_DefaultServices"
            ],
            path: "SwiftPM-Wrap/GrowingTracker-cdp-Wrapper"
        ),
        .target(
            name: "GrowingAutotracker_Wrapper",
            dependencies: [
                "GrowingAutotracker",
                "GrowingUserIdentifier",
                "GrowingModule_Hybrid",
                "GrowingModule_MobileDebugger",
                "GrowingModule_WebCircle",
                "GrowingModule_DefaultServices"
            ],
            path: "SwiftPM-Wrap/GrowingAutotracker-Wrapper"
        ),
        .target(
            name: "GrowingTracker_Wrapper",
            dependencies: [
                "GrowingTracker",
                "GrowingUserIdentifier",
                "GrowingModule_MobileDebugger",
                "GrowingModule_DefaultServices"
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
            cSettings: [
                .headerSearchPath("../../.."),
            ]
        ),
        .target(
            name: "GrowingUserIdentifier_NoIDFA",
            dependencies: [],
            path: "GrowingTrackerCore/Utils/UserIdentifier",
            exclude: ["GrowingUserIdentifier.m"],
            cSettings: [
                .headerSearchPath("../../.."),
            ]
        ),
        .target(
            name: "GrowingTrackerCore",
            dependencies: [],
            path: "GrowingTrackerCore",
            exclude: ["Utils/UserIdentifier"],
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath(".."),
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
                .linkedFramework("UIKit", .when(platforms: [.iOS])),
            ]
        ),
        .target(
            name: "GrowingAutotrackerCore",
            dependencies: ["GrowingTrackerCore"],
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
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),
        .target(
            name: "GrowingService_Network",
            dependencies: ["GrowingTrackerCore"],
            path: "Services/Network",
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),
        .target(
            name: "GrowingService_WebSocket",
            dependencies: ["GrowingTrackerCore"],
            path: "Services/WebSocket",
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),
        .target(
            name: "GrowingService_Compression",
            dependencies: ["GrowingTrackerCore"],
            path: "Services/Compression",
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),
        .target(
            name: "GrowingService_Encryption",
            dependencies: ["GrowingTrackerCore"],
            path: "Services/Encryption",
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
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),
        .target(
            name: "GrowingModule_WebCircle",
            dependencies: [
                "GrowingTrackerCore",
                "GrowingService_WebSocket",
                "GrowingModule_Hybrid"
            ],
            path: "Modules/WebCircle",
            cSettings: [
                .headerSearchPath("../.."),
            ]
        ),
        .target(
            name: "GrowingModule_Hybrid",
            dependencies: ["GrowingTrackerCore"],
            path: "Modules/Hybrid",
            cSettings: [
                .headerSearchPath("../.."),
            ],
            linkerSettings: [
                .linkedFramework("WebKit", .when(platforms: [.iOS])),
            ]
        ),
        .target(
            name: "GrowingModule_GAAdapter",
            dependencies: ["GrowingTrackerCore"],
            path: "Modules/GAAdapter",
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
                "GrowingModule_Hybrid",
                "GrowingModule_MobileDebugger",
                "GrowingModule_WebCircle",
                "GrowingModule_DefaultServices"
            ],
            path: "SwiftPM-Wrap/GrowingAutotracker-cdp-NoIDFA-Wrapper"
        ),
        .target(
            name: "GrowingTracker_cdp_NoIDFA_Wrapper",
            dependencies: [
                "GrowingTracker_cdp",
                "GrowingUserIdentifier_NoIDFA",
                "GrowingModule_MobileDebugger",
                "GrowingModule_DefaultServices"
            ],
            path: "SwiftPM-Wrap/GrowingTracker-cdp-NoIDFA-Wrapper"
        ),
        .target(
            name: "GrowingAutotracker_NoIDFA_Wrapper",
            dependencies: [
                "GrowingAutotracker",
                "GrowingUserIdentifier_NoIDFA",
                "GrowingModule_Hybrid",
                "GrowingModule_MobileDebugger",
                "GrowingModule_WebCircle",
                "GrowingModule_DefaultServices"
            ],
            path: "SwiftPM-Wrap/GrowingAutotracker-NoIDFA-Wrapper"
        ),
        .target(
            name: "GrowingTracker_NoIDFA_Wrapper",
            dependencies: [
                "GrowingTracker",
                "GrowingUserIdentifier_NoIDFA",
                "GrowingModule_MobileDebugger",
                "GrowingModule_DefaultServices"
            ],
            path: "SwiftPM-Wrap/GrowingTracker-NoIDFA-Wrapper"
        )
    ]
)
