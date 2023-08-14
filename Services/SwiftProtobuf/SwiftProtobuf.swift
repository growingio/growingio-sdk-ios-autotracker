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

typealias EventDto = Io_Growing_Tunnel_Protocol_EventV3Dto
typealias EventList = Io_Growing_Tunnel_Protocol_EventV3List
typealias EventType = Io_Growing_Tunnel_Protocol_EventType

@objc(GrowingSwiftProtobuf)
public class SwiftProtobufWrapper: NSObject {
    var unbox: EventDto
    @objc public let data: Data?
    init(_ unbox: EventDto) {
        self.unbox = unbox
        self.data = try? unbox.serializedData()
    }

    @objc(parseFromData:)
    public static func parse(from data: Data) -> SwiftProtobufWrapper? {
        do {
            let dto = try EventDto(serializedData: data)
            return SwiftProtobufWrapper(dto)
        } catch {
            return nil
        }
    }

    @objc(parseFromJsonObject:)
    public static func parse(from jsonObject: [String: AnyObject]) -> SwiftProtobufWrapper {
        var dto = EventDto()

        dto.dataSourceID = jsonObject["dataSourceId"] as? String ?? ""
        dto.sessionID = jsonObject["sessionId"] as? String ?? ""
        dto.timestamp = (jsonObject["timestamp"] as? NSNumber)?.int64Value ?? 0
        dto.domain = jsonObject["domain"] as? String ?? ""
        dto.userID = jsonObject["userId"] as? String ?? ""
        dto.deviceID = jsonObject["deviceId"] as? String ?? ""
        dto.platform = jsonObject["platform"] as? String ?? ""
        dto.platformVersion = jsonObject["platformVersion"] as? String ?? ""
        dto.eventSequenceID = (jsonObject["eventSequenceId"] as? NSNumber)?.int32Value ?? 0
        dto.appState = jsonObject["appState"] as? String ?? ""
        dto.urlScheme = jsonObject["urlScheme"] as? String ?? ""
        dto.networkState = jsonObject["networkState"] as? String ?? ""
        dto.screenWidth = (jsonObject["screenWidth"] as? NSNumber)?.int32Value ?? 0
        dto.screenHeight = (jsonObject["screenHeight"] as? NSNumber)?.int32Value ?? 0
        dto.deviceBrand = jsonObject["deviceBrand"] as? String ?? ""
        dto.deviceModel = jsonObject["deviceModel"] as? String ?? ""
        dto.deviceType = jsonObject["deviceType"] as? String ?? ""
        dto.appName = jsonObject["appName"] as? String ?? ""
        dto.appVersion = jsonObject["appVersion"] as? String ?? ""
        dto.language = jsonObject["language"] as? String ?? ""
        dto.latitude = (jsonObject["latitude"] as? NSNumber)?.doubleValue ?? 0
        dto.longitude = (jsonObject["longitude"] as? NSNumber)?.doubleValue ?? 0
        dto.sdkVersion = jsonObject["sdkVersion"] as? String ?? ""
        dto.userKey = jsonObject["userKey"] as? String ?? ""
        dto.eventType = self.eventType(jsonObject["eventType"] as? String ?? "")
        dto.idfa = jsonObject["idfa"] as? String ?? ""
        dto.idfv = jsonObject["idfv"] as? String ?? ""
        dto.extraSdk = jsonObject["extraSdk"] as? [String: String] ?? [:]
        dto.path = jsonObject["path"] as? String ?? ""
        dto.textValue = jsonObject["textValue"] as? String ?? ""
        dto.xpath = jsonObject["xpath"] as? String ?? ""
        dto.xcontent = jsonObject["xcontent"] as? String ?? ""
        dto.index = (jsonObject["index"] as? NSNumber)?.int32Value ?? 0
        dto.query = jsonObject["query"] as? String ?? ""
        dto.hyperlink = jsonObject["hyperlink"] as? String ?? ""
        dto.attributes = jsonObject["extraSdk"] as? [String: String] ?? [:]
        dto.orientation = jsonObject["orientation"] as? String ?? ""
        dto.title = jsonObject["title"] as? String ?? ""
        dto.referralPage = jsonObject["referralPage"] as? String ?? ""
        dto.protocolType = jsonObject["protocolType"] as? String ?? ""
        dto.eventName = jsonObject["eventName"] as? String ?? ""

        return SwiftProtobufWrapper(dto)
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
            var list = EventList()
            for box in boxes {
                list.values.append(box.unbox)
            }
            return try list.serializedData()
        } catch {
            return nil
        }
    }

    fileprivate static func eventType(_ eventType: String) -> EventType {
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
}

extension SwiftProtobufWrapper {
    // For GrowingToolsKit NetFlow
    @objc(convertProtobufDataToJsonArray:)
    public static func convertProtobufDataToJsonArray(from data: Data) -> [[String: AnyObject]]? {
        do {
            let list = try EventList(serializedData: data)
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
        var dto = EventDto()

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
        dto.deviceBrand = self.deviceBrand ?? ""
        dto.deviceModel = self.deviceModel ?? ""
        dto.deviceType = self.deviceType ?? ""
        dto.appName = self.appName
        dto.appVersion = self.appVersion
        dto.language = self.language
        dto.latitude = self.latitude
        dto.longitude = self.longitude
        dto.sdkVersion = self.sdkVersion
        dto.userKey = self.userKey ?? ""

        dto.eventType = SwiftProtobufWrapper.eventType(self.eventType)
        dto.idfa = idfa()
        dto.idfv = idfv()
        dto.extraSdk = extraSdk()
        dto.path = path()
        dto.textValue = textValue()
        dto.xpath = xpath()
        dto.xcontent = xcontent()
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

    fileprivate func xcontent() -> String {
        let selector = Selector(("xcontent"))
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
