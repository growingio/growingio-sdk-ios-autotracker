//
//  Exports.swift
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/8/24.
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

@_exported import GrowingTracker_Objc

public typealias TrackConfig = GrowingTrackConfiguration

public struct Tracker {
    static var tracker: GrowingTracker = GrowingTracker.sharedInstance()

    @available(*, unavailable)
    public init() { }

    public static func start(_ config: TrackConfig, launchOptions: [AnyHashable: Any]? = [:]) {
        GrowingTracker.start(with: config, launchOptions: launchOptions ?? [:])
    }

    public static func setDataCollectionEnabled(_ enabled: Bool) {
        tracker.setDataCollectionEnabled(enabled)
    }

    public static func setLoginUserId(_ userId: String, userKey: String? = nil) {
        guard let userKey = userKey else {
            tracker.setLoginUserId(userId)
            return
        }

        tracker.setLoginUserId(userId, userKey: userKey)
    }

    public static func cleanLoginUserId() {
        tracker.cleanLoginUserId()
    }

    public static func setLocation(latitude: Double, longitude: Double) {
        tracker.setLocation(latitude, longitude: longitude)
    }

    public static func cleanLocation() {
        tracker.cleanLocation()
    }

    public static func setLoginUserAttributes(_ attributes: [String: String]) {
        tracker.setLoginUserAttributes(attributes)
    }

    public static func deviceId() -> String {
        tracker.getDeviceId()
    }

    public static func track(_ eventName: String, attributes: [String: String]? = nil) {
        guard let attributes = attributes else {
            tracker.trackCustomEvent(eventName)
            return
        }

        tracker.trackCustomEvent(eventName, withAttributes: attributes)
    }

    public static func trackTimer(_ eventName: String) -> String? {
        tracker.trackTimerStart(eventName)
    }

    public static func pauseTimer(_ timerId: String) {
        tracker.trackTimerPause(timerId)
    }

    public static func resumeTimer(_ timerId: String) {
        tracker.trackTimerResume(timerId)
    }

    public static func endTimer(_ timerId: String, attributes: [String: String]? = nil) {
        guard let attributes = attributes else {
            tracker.trackTimerEnd(timerId)
            return
        }

        tracker.trackTimerEnd(timerId, withAttributes: attributes)
    }

    public static func removeTimer(_ timerId: String) {
        tracker.removeTimer(timerId)
    }

    public static func clearTimers() {
        tracker.clearTrackTimer()
    }
}
