//
//  SwiftProtobuf.swift
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/4/17.
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
import GrowingTrackerCore

@objc(GrowingSwiftProtobuf)
public class SwiftProtobufWrapper: NSObject {
    var unbox: EventV3Dto
    @objc public let data: Data?
    init(_ unbox: EventV3Dto) {
        self.unbox = unbox
        data = try? unbox.serializedData()
    }

    @objc(parseFromData:)
    public static func parse(from data: Data) -> SwiftProtobufWrapper? {
        do {
            let dto = try EventV3Dto(serializedData: data)
            return SwiftProtobufWrapper(dto)
        } catch {
            return nil
        }
    }

    @objc
    public func toJsonObject() -> [String: AnyObject]? {
        do {
            let data = try unbox.jsonUTF8Data()
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject]
            return json
        } catch {
            return nil
        }
    }

    @objc(appendWithExtraParams:)
    public func append(extraParams: [String: String]) {
        let result = unbox.attributes.merging(extraParams) { _, new in new }
        unbox.attributes = result
    }

    @objc(serializedDatasFromList:)
    public static func serializedDatas(from boxes: [SwiftProtobufWrapper]) -> Data? {
        do {
            var list = EventV3List()
            for box in boxes {
                list.values.append(box.unbox)
            }
            return try list.serializedData()
        } catch {
            return nil
        }
    }
}

public extension SwiftProtobufWrapper {
    // For GrowingToolsKit NetFlow
    @objc(convertProtobufDataToJsonArray:)
    static func convertProtobufDataToJsonArray(from data: Data) -> [[String: AnyObject]]? {
        do {
            let list = try EventV3List(serializedData: data)
            var array = [[String: AnyObject]]()
            for dto in list.values {
                let jsonData = try dto.jsonUTF8Data()
                let dic = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: AnyObject]
                if let dic = dic {
                    array.append(dic)
                }
            }
            return array
        } catch {
            return nil
        }
    }
}

public extension GrowingBaseEvent {
    @objc func toProtobuf() -> SwiftProtobufWrapper {
        var dto = EventV3Dto()

        dto.dataSourceID = dataSourceId ?? ""
        dto.gioID = gioId ?? ""
        dto.sessionID = sessionId ?? ""
        dto.timestamp = timestamp
        dto.domain = domain
        dto.userID = userId ?? ""
        dto.deviceID = deviceId
        dto.platform = platform
        dto.platformVersion = platformVersion
        dto.globalSequenceID = globalSequenceId
        dto.eventSequenceID = Int32(eventSequenceId)
        dto.appState = appState == GrowingAppState.foreground.rawValue ? "FOREGROUND" : "BACKGROUND"
        dto.urlScheme = urlScheme
        dto.networkState = networkState ?? ""
        dto.screenWidth = Int32(screenWidth)
        dto.screenHeight = Int32(screenHeight)
        dto.deviceBrand = deviceBrand
        dto.deviceModel = deviceModel
        dto.deviceType = deviceType
        dto.appName = appName
        dto.appVersion = appVersion
        dto.language = language
        dto.latitude = latitude
        dto.longitude = longitude
        dto.sdkVersion = sdkVersion
        dto.userKey = userKey ?? ""

        dto.eventType = eventType()
        dto.idfa = idfa()
        dto.idfv = idfv()
        dto.extraSdk = extraSdk()
        dto.path = path()
        dto.pageShowTimestamp = pageShowTimestamp()
        dto.textValue = textValue()
        dto.xpath = xpath()
        dto.index = index()
        dto.query = query()
        dto.hyperlink = hyperlink()
        dto.attributes = attributes()
        dto.orientation = orientation()
        dto.title = title()
        dto.referralPage = referralPage()
        dto.protocolType = protocolType()
        dto.eventName = eventName()

        return SwiftProtobufWrapper(dto)
    }
}

private extension GrowingBaseEvent {
    func eventType() -> EventType {
        if eventType == "VISIT" {
            return .visit
        } else if eventType == "CUSTOM" {
            return .custom
        } else if eventType == "VISITOR_ATTRIBUTES" {
            return .visitorAttributes
        } else if eventType == "LOGIN_USER_ATTRIBUTES" {
            return .loginUserAttributes
        } else if eventType == "CONVERSION_VARIABLES" {
            return .conversionVariables
        } else if eventType == "APP_CLOSED" {
            return .appClosed
        } else if eventType == "PAGE" {
            return .page
        } else if eventType == "VIEW_CLICK" {
            return .viewClick
        } else if eventType == "VIEW_CHANGE" {
            return .viewChange
        } else if eventType == "FORM_SUBMIT" {
            return .formSubmit
        } else if eventType == "ACTIVATE" {
            return .activate
        }

        return .UNRECOGNIZED(100)
    }

    func idfa() -> String {
        let selector = Selector(("idfa"))
        if responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    func idfv() -> String {
        let selector = Selector(("idfv"))
        if responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    func extraSdk() -> [String: String] {
        let selector = Selector(("extraSdk"))
        if responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> [String: String]?).self)(self, selector) ?? [:]
        }
        return [:]
    }

    func path() -> String {
        if responds(to: Selector(("pageName"))) {
            let selector = Selector(("pageName"))
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        } else if responds(to: Selector(("path"))) {
            let selector = Selector(("path"))
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    func pageShowTimestamp() -> Int64 {
        let selector = Selector(("pageShowTimestamp"))
        if responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            let result = unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> Int64).self)(self, selector)
            return result > 0 ? result : 0
        }
        return 0
    }

    func textValue() -> String {
        let selector = Selector(("textValue"))
        if responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    func xpath() -> String {
        let selector = Selector(("xpath"))
        if responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    func index() -> Int32 {
        let selector = Selector(("index"))
        if responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            let result = unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> Int32).self)(self, selector)
            return result > 0 ? result : 0
        }
        return 0
    }

    func query() -> String {
        let selector = Selector(("query"))
        if responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    func hyperlink() -> String {
        let selector = Selector(("hyperlink"))
        if responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    func attributes() -> [String: String] {
        let selector = Selector(("attributes"))
        if responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            let result = unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> [String: AnyObject]?).self)(self, selector)
            if let result = result {
                return result.filter { $0.value is String } as? [String: String] ?? [:]
            }
        }
        return [:]
    }

    func orientation() -> String {
        let selector = Selector(("orientation"))
        if responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    func title() -> String {
        let selector = Selector(("title"))
        if responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    func referralPage() -> String {
        let selector = Selector(("referralPage"))
        if responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    func protocolType() -> String {
        let selector = Selector(("protocolType"))
        if responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    func eventName() -> String {
        let selector = Selector(("eventName"))
        if responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c) (GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }
}
