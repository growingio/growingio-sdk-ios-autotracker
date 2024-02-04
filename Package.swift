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
    platforms: [
        .iOS(.v10),
        .macCatalyst(.v13),
        .macOS(.v10_12),
        .tvOS(.v12),
        .watchOS(.v7),
    ],
    products: [
        .autotracker,
        .tracker,
        .Module.imp,
        .Module.hybrid,
        .Module.ads,
        .Module.apm,
        .Module.abTesting,
    ],
    dependencies: [
        .package(
            url: "https://github.com/growingio/growingio-sdk-ios-utilities.git",
            "1.2.0" ..< "1.3.0"
        ),
        .package(
            url: "https://github.com/growingio/growingio-sdk-ios-performance-ext.git",
            "1.0.0" ..< "1.1.0"
        ),
        .package(
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.21.0"
        ),
    ],
    targets: [
        // MARK: - Objc Headers

        .autotracker_objc,
        .tracker_objc,

        // MARK: - Swift Wrapper

        .autotracker,
        .tracker,

        // MARK: - Resources

        .Resources.privacy,
        .Resources.privacy_macos,

        // MARK: - Core

        .Core.trackerCore,
        .Core.autotrackerCore,

        // MARK: - Modules

        .Module.coreServices,
        .Module.mobileDebugger,
        .Module.webCircle,
        .Module.imp,
        .Module.hybrid,
        .Module.ads,
        .Module.apm,
        .Module.abTesting,

        // MARK: - Services

        .Service.database,
        .Service.JSON,
        .Service.protobuf,
        .Service.swiftProtobuf,
        .Service.network,
        .Service.webSocket,
        .Service.compress,
        .Service.encrypt,
        .Service.screenshot,
    ]
)

extension Product {
    static let autotracker = library(name: .autotracker, targets: [.autotracker])
    static let tracker = library(name: .tracker, targets: [.tracker])

    enum Module {
        static let imp = library(name: .imp, targets: [.imp])
        static let hybrid = library(name: .hybrid, targets: [.hybrid])
        static let ads = library(name: .ads, targets: [.ads])
        static let apm = library(name: .apm, targets: [.apm])
        static let abTesting = library(name: .abTesting, targets: [.abTesting])
    }
}

extension Target {
    static let autotracker = target(name: .autotracker,
                                    dependencies: [
                                        .autotracker_objc,
                                        .Module.coreServices,
                                        .Module.hybrid,
                                        .Module.mobileDebugger,
                                        .Module.webCircle,
                                    ],
                                    path: .Path.autotracker)

    static let tracker = target(name: .tracker,
                                dependencies: [
                                    .tracker_objc,
                                    .Module.coreServices,
                                    .Module.mobileDebugger,
                                ],
                                path: .Path.tracker)

    static let autotracker_objc = target(name: .autotracker_objc,
                                         dependencies: [.Core.autotrackerCore],
                                         path: .Path.autotracker_objc,
                                         publicHeadersPath: ".",
                                         cSettings: [.hspFor(.Path.autotracker_objc)])

    static let tracker_objc = target(name: .tracker_objc,
                                     dependencies: [.Core.trackerCore],
                                     path: .Path.tracker_objc,
                                     publicHeadersPath: ".",
                                     cSettings: [.hspFor(.Path.tracker_objc)])

    enum Resources {
        static let privacy = target(name: .privacy,
                                    path: .Path.privacy,
                                    resources: [.copy("Resources/GrowingAnalytics.bundle/PrivacyInfo.xcprivacy")])

        static let privacy_macos = target(name: .privacy_macos,
                                          path: .Path.privacy_macos,
                                          resources: [.copy("Resources/GrowingAnalytics.bundle/PrivacyInfo.xcprivacy")])
    }

    enum Core {
        static let autotrackerCore = target(name: .autotrackerCore,
                                            dependencies: [
                                                .Core.trackerCore,
                                                .autotrackerUtils,
                                            ],
                                            path: .Path.autotrackerCore,
                                            publicHeadersPath: .Path.publicHeaders,
                                            cSettings: [.hspFor(.Path.autotrackerCore)])

        static let trackerCore = target(name: .trackerCore,
                                        dependencies: [
                                            .trackerUtils,
                                            .Resources.privacy,
                                            .Resources.privacy_macos,
                                        ],
                                        path: .Path.trackerCore,
                                        publicHeadersPath: .Path.publicHeaders,
                                        cSettings: [.hspFor(.Path.trackerCore)],
                                        linkerSettings: [
                                            .cPlusPlusLibrary,
                                            .UIKit,
                                        ])
    }

    enum Module {
        static let coreServices = target(name: .coreServices,
                                         dependencies: [
                                             .Core.trackerCore,
                                             .Service.JSON,
                                             .Service.protobuf,
                                             .Service.network,
                                             .Service.encrypt,
                                             .Service.compress,
                                         ],
                                         path: .Path.coreServices,
                                         cSettings: [.hspFor(.Path.coreServices)])

        static let mobileDebugger = target(name: .mobileDebugger,
                                           dependencies: [
                                               .Core.trackerCore,
                                               .Service.webSocket,
                                               .Service.screenshot,
                                           ],
                                           path: .Path.mobileDebugger,
                                           cSettings: [.hspFor(.Path.mobileDebugger)])

        static let webCircle = target(name: .webCircle,
                                      dependencies: [
                                          .Core.autotrackerCore,
                                          .Service.webSocket,
                                          .Service.screenshot,
                                          .Module.hybrid,
                                      ],
                                      path: .Path.webCircle,
                                      cSettings: [.hspFor(.Path.webCircle)])

        static let imp = target(name: .imp,
                                dependencies: [.Core.autotrackerCore],
                                path: .Path.imp,
                                publicHeadersPath: .Path.publicHeaders,
                                cSettings: [.hspFor(.Path.imp)])

        static let hybrid = target(name: .hybrid,
                                   dependencies: [.Core.trackerCore],
                                   path: .Path.hybrid,
                                   publicHeadersPath: .Path.publicHeaders,
                                   cSettings: [.hspFor(.Path.hybrid)],
                                   linkerSettings: [.WebKit])

        static let ads = target(name: .ads,
                                dependencies: [.Core.trackerCore],
                                path: .Path.ads,
                                publicHeadersPath: .Path.publicHeaders,
                                cSettings: [.hspFor(.Path.ads)])

        static let apm = target(name: .apm,
                                dependencies: [
                                    .Core.trackerCore,
                                    .apm,
                                ],
                                path: .Path.apm,
                                publicHeadersPath: .Path.publicHeaders,
                                cSettings: [.hspFor(.Path.apm)])

        static let abTesting = target(name: .abTesting,
                                      dependencies: [.Core.trackerCore],
                                      path: .Path.abTesting,
                                      publicHeadersPath: .Path.publicHeaders,
                                      cSettings: [.hspFor(.Path.abTesting)])
    }

    enum Service {
        static let database = target(name: .database,
                                     dependencies: [.Core.trackerCore],
                                     path: .Path.database,
                                     cSettings: [.hspFor(.Path.database)])

        static let JSON = target(name: .JSON,
                                 dependencies: [.Service.database],
                                 path: .Path.JSON,
                                 cSettings: [.hspFor(.Path.JSON)])

        static let protobuf = target(name: .protobuf,
                                     dependencies: [
                                         .Service.database,
                                         .Service.swiftProtobuf,
                                     ],
                                     path: .Path.protobuf,
                                     exclude: ["Proto", "Catagory"],
                                     cSettings: [.hspFor(.Path.protobuf)])

        static let swiftProtobuf = target(name: .swiftProtobuf,
                                          dependencies: [
                                              .Core.trackerCore,
                                              .protobuf,
                                          ],
                                          path: .Path.swiftProtobuf)

        static let network = target(name: .network,
                                    dependencies: [.Core.trackerCore],
                                    path: .Path.network,
                                    cSettings: [.hspFor(.Path.network)])

        static let webSocket = target(name: .webSocket,
                                      dependencies: [.Core.trackerCore],
                                      path: .Path.webSocket,
                                      cSettings: [.hspFor(.Path.webSocket)])

        static let compress = target(name: .compress,
                                     dependencies: [.Core.trackerCore],
                                     path: .Path.compress,
                                     cSettings: [.hspFor(.Path.compress)])

        static let encrypt = target(name: .encrypt,
                                    dependencies: [.Core.trackerCore],
                                    path: .Path.encrypt,
                                    cSettings: [.hspFor(.Path.encrypt)])

        static let screenshot = target(name: .screenshot,
                                       dependencies: [.Core.trackerCore],
                                       path: .Path.screenshot,
                                       cSettings: [.hspFor(.Path.screenshot)])
    }
}

extension Target.Dependency {
    static let autotracker_objc = byName(name: .autotracker_objc, condition: .when(platforms: [.iOS, .macCatalyst, .tvOS]))
    static let tracker_objc = byName(name: .tracker_objc)

    static let autotrackerUtils = product(name: "GrowingUtilsAutotrackerCore", package: "growingio-sdk-ios-utilities")
    static let trackerUtils = product(name: "GrowingUtilsTrackerCore", package: "growingio-sdk-ios-utilities")
    static let apm = product(name: "GrowingAPM", package: "growingio-sdk-ios-performance-ext", condition: .when(platforms: [.iOS]))
    static let protobuf = product(name: "SwiftProtobuf", package: "swift-protobuf")

    enum Resources {
        static let privacy = byName(name: .privacy, condition: .when(platforms: [.iOS, .macCatalyst]))
        static let privacy_macos = byName(name: .privacy_macos, condition: .when(platforms: [.macOS]))
    }

    enum Core {
        static let autotrackerCore = byName(name: .autotrackerCore, condition: .when(platforms: [.iOS, .macCatalyst, .tvOS]))
        static let trackerCore = byName(name: .trackerCore)
    }

    enum Module {
        static let coreServices = byName(name: .coreServices)
        static let mobileDebugger = byName(name: .mobileDebugger, condition: .when(platforms: [.iOS]))
        static let webCircle = byName(name: .webCircle, condition: .when(platforms: [.iOS]))
        static let hybrid = byName(name: .hybrid, condition: .when(platforms: [.iOS, .macCatalyst]))
    }

    enum Service {
        static let database = byName(name: .database)
        static let JSON = byName(name: .JSON)
        static let protobuf = byName(name: .protobuf)
        static let swiftProtobuf = byName(name: .swiftProtobuf)
        static let network = byName(name: .network)
        static let webSocket = byName(name: .webSocket, condition: .when(platforms: [.iOS]))
        static let compress = byName(name: .compress)
        static let encrypt = byName(name: .encrypt)
        static let screenshot = byName(name: .screenshot, condition: .when(platforms: [.iOS]))
    }
}

extension CSetting {
    static func hspFor(_ path: String) -> PackageDescription.CSetting {
        let count = path.filter { $0 == "/" }.count
        return count == 0 ? headerSearchPath("..") : headerSearchPath("../..")
    }
}

extension LinkerSetting {
    static let cPlusPlusLibrary = linkedLibrary("c++")
    static let UIKit = linkedFramework("UIKit", .when(platforms: [.iOS, .macCatalyst]))
    static let WebKit = linkedFramework("WebKit", .when(platforms: [.iOS, .macCatalyst]))
}

extension String {
    static let autotracker = "GrowingAutotracker"
    static let tracker = "GrowingTracker"
    static let autotracker_objc = "GrowingAutotracker_Objc"
    static let tracker_objc = "GrowingTracker_Objc"

    // Resources
    static let privacy = "GrowingPrivacy"
    static let privacy_macos = "GrowingPrivacy_macOS"

    // Core
    static let autotrackerCore = "GrowingAutotrackerCore"
    static let trackerCore = "GrowingTrackerCore"

    // Modules
    static let coreServices = "GrowingModule_DefaultServices"
    static let mobileDebugger = "GrowingModule_MobileDebugger"
    static let webCircle = "GrowingModule_WebCircle"
    static let imp = "GrowingModule_ImpressionTrack"
    static let hybrid = "GrowingModule_Hybrid"
    static let ads = "GrowingModule_Ads"
    static let apm = "GrowingModule_APM"
    static let abTesting = "GrowingModule_ABTesting"

    // Services
    static let database = "GrowingService_Database"
    static let JSON = "GrowingService_JSON"
    static let protobuf = "GrowingService_Protobuf"
    static let swiftProtobuf = "GrowingService_SwiftProtobuf"
    static let network = "GrowingService_Network"
    static let webSocket = "GrowingService_WebSocket"
    static let compress = "GrowingService_Compression"
    static let encrypt = "GrowingService_Encryption"
    static let screenshot = "GrowingService_Screenshot"

    enum Path {
        static let publicHeaders = "Public"
        static let autotracker = "SwiftPM-Wrap/GrowingAutotracker"
        static let tracker = "SwiftPM-Wrap/GrowingTracker"
        static let autotracker_objc = "GrowingAutotracker"
        static let tracker_objc = "GrowingTracker"

        // Resources
        static let privacy = "SwiftPM-Wrap/GrowingPrivacy-Wrapper"
        static let privacy_macos = "SwiftPM-Wrap/GrowingPrivacy-macOS-Wrapper"

        // Core
        static let autotrackerCore = "GrowingAutotrackerCore"
        static let trackerCore = "GrowingTrackerCore"

        // Modules
        static let mobileDebugger = "Modules/MobileDebugger"
        static let webCircle = "Modules/WebCircle"
        static let imp = "Modules/ImpressionTrack"
        static let hybrid = "Modules/Hybrid"
        static let ads = "Modules/Advertising"
        static let apm = "Modules/APM"
        static let abTesting = "Modules/ABTesting"
        static let coreServices = "Modules/DefaultServices"

        // Services
        static let database = "Services/Database"
        static let JSON = "Services/JSON"
        static let protobuf = "Services/Protobuf"
        static let swiftProtobuf = "Services/SwiftProtobuf"
        static let network = "Services/Network"
        static let webSocket = "Services/WebSocket"
        static let compress = "Services/Compression"
        static let encrypt = "Services/Encryption"
        static let screenshot = "Services/Screenshot"
    }
}
