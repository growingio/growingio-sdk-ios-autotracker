//
//  AppDelegate.swift
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/10/27.
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

import Foundation
import WatchKit
import GrowingAnalytics

class AppDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        let config = GrowingTrackConfiguration(projectId: "bcc4fc9dea27f25d")
        config?.dataSourceId = "be46cd165dcc3c7e"
        config?.dataCollectionServerHost = "https://run.mocky.io/v3/08999138-a180-431d-a136-051f3c6bd306"
        config?.idMappingEnabled = true
        config?.debugEnabled = true
        GrowingTracker.start(with: config!)
    }
    
}
