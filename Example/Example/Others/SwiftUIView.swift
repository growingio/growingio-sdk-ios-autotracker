//
//  SwiftUIView.swift
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/8/21.
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

// 参考：https://github.com/firebase/firebase-ios-sdk/tree/master/FirebaseAnalyticsSwift
#if canImport(SwiftUI)
import SwiftUI
#if canImport(GrowingAnalytics)
import GrowingAnalytics
#endif

#if canImport(GrowingAutotracker)
import GrowingAutotracker
#endif

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, *)
@objc class SwiftUIViewWrapper: NSObject {
    @objc static func viewController() -> UIViewController {
        UIHostingController(rootView: SwiftUIView())
    }
}

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, *)
struct SwiftUIView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
                .padding()
            Button("TrackCustomEvent") {
                GrowingAutotracker.sharedInstance().trackCustomEvent("Custom", withAttributes: ["key": "value"])
            }
        }
            .growingTrackView("SwiftUI-View-OnAppear", attributes: ["key": "value"])
//            .onAppear {
//                GrowingAutotracker.sharedInstance().trackCustomEvent("SwiftUI-View-OnAppear", withAttributes: ["key": "value"])
//            }
    }
}

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, *)
extension View {
    func growingTrackView(_ eventName: String, attributes: [String: String]? = nil) -> some View {
        onAppear {
            if let attributes = attributes {
                GrowingAutotracker.sharedInstance().trackCustomEvent(eventName, withAttributes: attributes)
            } else {
                GrowingAutotracker.sharedInstance().trackCustomEvent(eventName)
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
#endif
