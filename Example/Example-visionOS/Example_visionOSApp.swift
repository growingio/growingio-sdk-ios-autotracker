//
//  Example_visionOSApp.swift
//  GrowingAnalytics
//
//  Created by YoloMao on 2024/2/4.
//  Copyright (C) 2024 Beijing Yishu Technology Co., Ltd.
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

import SwiftUI
import GrowingAnalytics

@main
struct Example_visionOSApp: App {
    init() {
        let config = GrowingTrackConfiguration(accountId: "0a1b4118dd954ec3bcc69da5138bdb96")
        config?.dataSourceId = "ab555003531e0fd1"
        config?.urlScheme = "growing.bf30ad277eaae1aa"
        config?.debugEnabled = true
        GrowingTracker.start(with: config!)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
