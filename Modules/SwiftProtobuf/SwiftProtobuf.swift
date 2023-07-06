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
        self.data = try? unbox.serializedData()
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

extension SwiftProtobufWrapper {
    // For GrowingToolsKit NetFlow
    @objc(convertProtobufDataToJsonArray:)
    public static func convertProtobufDataToJsonArray(from data: Data) -> [[String: AnyObject]]? {
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

extension GrowingBaseEvent {
    @objc public func toProtobuf() -> SwiftProtobufWrapper {
        var dto = EventV3Dto()

        dto.dataSourceID = self.dataSourceId ?? ""
        dto.sessionID = self.sessionId ?? ""
        dto.timestamp = self.timestamp
        dto.domain = self.domain
        dto.userID = self.userId ?? ""
        dto.deviceID = self.deviceId
        dto.platform = self.platform
        dto.platformVersion = self.platformVersion
        dto.eventSequenceID = Int32(self.eventSequenceId)
        dto.appState = self.appState == GrowingAppState.foreground.rawValue ? "FOREGROUND" : "BACKGROUND"
        dto.urlScheme = self.urlScheme
        dto.networkState = self.networkState ?? ""
        dto.screenWidth = Int32(self.screenWidth)
        dto.screenHeight = Int32(self.screenHeight)
        dto.deviceBrand = self.deviceBrand
        dto.deviceModel = self.deviceModel
        dto.deviceType = self.deviceType
        dto.appName = self.appName
        dto.appVersion = self.appVersion
        dto.language = self.language
        dto.latitude = self.latitude
        dto.longitude = self.longitude
        dto.sdkVersion = self.sdkVersion
        dto.userKey = self.userKey ?? ""

        dto.eventType = eventType()
        dto.idfa = idfa()
        dto.idfv = idfv()
        dto.extraSdk = extraSdk()
        dto.path = path()
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

extension GrowingBaseEvent {
    fileprivate func eventType() -> EventType {
        if self.eventType == "VISIT" {
            return .visit
        } else if self.eventType == "CUSTOM" {
            return .custom
        } else if self.eventType == "VISITOR_ATTRIBUTES" {
            return .visitorAttributes
        } else if self.eventType == "LOGIN_USER_ATTRIBUTES" {
            return .loginUserAttributes
        } else if self.eventType == "CONVERSION_VARIABLES" {
            return .conversionVariables
        } else if self.eventType == "APP_CLOSED" {
            return .appClosed
        } else if self.eventType == "PAGE" {
            return .page
        } else if self.eventType == "VIEW_CLICK" {
            return .viewClick
        } else if self.eventType == "VIEW_CHANGE" {
            return .viewChange
        } else if self.eventType == "FORM_SUBMIT" {
            return .formSubmit
        } else if self.eventType == "ACTIVATE" {
            return .activate
        }

        return .UNRECOGNIZED(100)
    }

    fileprivate func idfa() -> String {
        let selector = Selector(("idfa"))
        if self.responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    fileprivate func idfv() -> String {
        let selector = Selector(("idfv"))
        if self.responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    fileprivate func extraSdk() -> [String: String] {
        let selector = Selector(("extraSdk"))
        if self.responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> [String: String]?).self)(self, selector) ?? [:]
        }
        return [:]
    }

    fileprivate func path() -> String {
        if self.responds(to: Selector(("pageName"))) {
            let selector = Selector(("pageName"))
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        } else if self.responds(to: Selector(("path"))) {
            let selector = Selector(("path"))
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    fileprivate func textValue() -> String {
        let selector = Selector(("textValue"))
        if self.responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    fileprivate func xpath() -> String {
        let selector = Selector(("xpath"))
        if self.responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    fileprivate func index() -> Int32 {
        let selector = Selector(("index"))
        if self.responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            let result = unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> Int32).self)(self, selector)
            return result > 0 ? result : 0
        }
        return 0
    }

    fileprivate func query() -> String {
        let selector = Selector(("query"))
        if self.responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    fileprivate func hyperlink() -> String {
        let selector = Selector(("hyperlink"))
        if self.responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    fileprivate func attributes() -> [String: String] {
        let selector = Selector(("attributes"))
        if self.responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            let result = unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> [String: AnyObject]?).self)(self, selector)
            if let result = result {
                return result.filter({ $0.value is String }) as? [String: String] ?? [:]
            }
        }
        return [:]
    }

    fileprivate func orientation() -> String {
        let selector = Selector(("orientation"))
        if self.responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    fileprivate func title() -> String {
        let selector = Selector(("title"))
        if self.responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    fileprivate func referralPage() -> String {
        let selector = Selector(("referralPage"))
        if self.responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    fileprivate func protocolType() -> String {
        let selector = Selector(("protocolType"))
        if self.responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }

    fileprivate func eventName() -> String {
        let selector = Selector(("eventName"))
        if self.responds(to: selector) {
            let imp: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), selector)!)
            return unsafeBitCast(imp, to: (@convention(c)(GrowingBaseEvent, Selector) -> String?).self)(self, selector) ?? ""
        }
        return ""
    }
}
