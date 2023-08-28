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

@_exported import GrowingAutotracker_Objc

public typealias AutotrackConfig = GrowingAutotrackConfiguration

public struct Autotracker {
    static var autotracker: GrowingAutotracker = GrowingAutotracker.sharedInstance()

    @available(*, unavailable)
    public init() { }

    public static func start(_ config: AutotrackConfig, launchOptions: [AnyHashable: Any]? = [:]) {
        GrowingAutotracker.start(with: config, launchOptions: launchOptions ?? [:])
    }

    public static func setDataCollectionEnabled(_ enabled: Bool) {
        autotracker.setDataCollectionEnabled(enabled)
    }

    public static func setLoginUserId(_ userId: String, userKey: String? = nil) {
        guard let userKey = userKey else {
            autotracker.setLoginUserId(userId)
            return
        }

        autotracker.setLoginUserId(userId, userKey: userKey)
    }

    public static func cleanLoginUserId() {
        autotracker.cleanLoginUserId()
    }

    public static func setLocation(latitude: Double, longitude: Double) {
        autotracker.setLocation(latitude, longitude: longitude)
    }

    public static func cleanLocation() {
        autotracker.cleanLocation()
    }

    public static func setLoginUserAttributes(_ attributes: [String: String]) {
        autotracker.setLoginUserAttributes(attributes)
    }

    public static func deviceId() -> String {
        autotracker.getDeviceId()
    }

    public static func ignore(_ clazz: AnyClass) {
        autotracker.ignoreViewClass(clazz)
    }

    public static func ignore(_ classes: [AnyClass]) {
        autotracker.ignoreViewClasses(classes)
    }

    public static func track(_ eventName: String, attributes: [String: String]? = nil) {
        guard let attributes = attributes else {
            autotracker.trackCustomEvent(eventName)
            return
        }

        autotracker.trackCustomEvent(eventName, withAttributes: attributes)
    }

    public static func trackTimer(_ eventName: String) -> String? {
        autotracker.trackTimerStart(eventName)
    }

    public static func pauseTimer(_ timerId: String) {
        autotracker.trackTimerPause(timerId)
    }

    public static func resumeTimer(_ timerId: String) {
        autotracker.trackTimerResume(timerId)
    }

    public static func endTimer(_ timerId: String, attributes: [String: String]? = nil) {
        guard let attributes = attributes else {
            autotracker.trackTimerEnd(timerId)
            return
        }

        autotracker.trackTimerEnd(timerId, withAttributes: attributes)
    }

    public static func removeTimer(_ timerId: String) {
        autotracker.removeTimer(timerId)
    }

    public static func clearTimers() {
        autotracker.clearTrackTimer()
    }

    public static func autotrackPage(_ viewController: UIViewController,
                                     alias: String,
                                     attributes: [String: String]? = nil) {
        guard let attributes = attributes else {
            autotracker.autotrackPage(viewController, alias: alias)
            return
        }

        autotracker.autotrackPage(viewController, alias: alias, attributes: attributes)
    }
}

extension UIView {
    public var ignorePolicy: GrowingIgnorePolicy {
        get { growingViewIgnorePolicy }
        set { growingViewIgnorePolicy = newValue }
    }

    public var customContent: String {
        get { growingViewCustomContent }
        set { growingViewCustomContent = newValue }
    }

    public var uniqueTag: String {
        get { growingUniqueTag }
        set { growingUniqueTag = newValue }
    }
}
