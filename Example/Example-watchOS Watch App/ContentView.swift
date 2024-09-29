//
//  ContentView.swift
//  GrowingAnalytics
//
//  Created by YoloMao on 2024/1/31.
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
#if canImport(GrowingAnalytics)
import GrowingAnalytics
#endif
#if canImport(GrowingTracker)
import GrowingTracker
#endif

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button("TrackCustomEvent") {
                GrowingTracker.sharedInstance().trackCustomEvent("watchOS_custom_event", withAttributes: ["key": "value"])
            }
        }
        .padding()
    }
}

// Xcode 15+
//#Preview {
//    ContentView()
//}

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
