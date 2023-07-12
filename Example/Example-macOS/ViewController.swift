//
//  ViewController.swift
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/4/21.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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


import Cocoa
import GrowingAnalytics

class ViewController: NSViewController {

    @IBOutlet weak var userIdTextField: NSTextField!
    @IBOutlet weak var userKeyTextField: NSTextField!
    @IBOutlet weak var timerEventNameTextField: NSTextField!
    @IBOutlet weak var timersPopupButton: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timersPopupButton.removeAllItems()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func setDataCollectionEnabled(_ sender: NSSwitch) {
        GrowingTracker.sharedInstance().setDataCollectionEnabled(sender.state == .on)
    }
    
    @IBAction func setUserIdAction(_ sender: Any) {
        GrowingTracker.sharedInstance().setLoginUserId(userIdTextField.stringValue)
    }
    
    @IBAction func setUserKeyAction(_ sender: Any) {
        GrowingTracker.sharedInstance().setLoginUserId(userIdTextField.stringValue, userKey: userKeyTextField.stringValue)
    }
    
    @IBAction func cleanLoginUserIdAction(_ sender: Any) {
        GrowingTracker.sharedInstance().cleanLoginUserId()
    }
    
    @IBAction func sendCustomEventAction(_ sender: Any) {
        GrowingTracker.sharedInstance().trackCustomEvent("eventName")
    }
    
    @IBAction func sendCustomEventWithAttributesAction(_ sender: Any) {
        GrowingTracker.sharedInstance().trackCustomEvent("eventName", withAttributes: ["key": "value"])
    }
    
    @IBAction func sendLoginUserAttributesEventAction(_ sender: Any) {
        GrowingTracker.sharedInstance().setLoginUserAttributes(["key": "value"])
    }
    
    @IBAction func startTimerAction(_ sender: Any) {
        let timerId = GrowingTracker.sharedInstance().trackTimerStart(timerEventNameTextField.stringValue)
        guard let timerId = timerId else {
            return
        }
        timersPopupButton.addItem(withTitle: timerId)
    }
    
    @IBAction func pauseTimerAction(_ sender: Any) {
        let timerId = timersPopupButton.selectedItem?.title
        guard let timerId = timerId else {
            return
        }
        GrowingTracker.sharedInstance().trackTimerPause(timerId)
    }
    
    @IBAction func resumeTimerAction(_ sender: Any) {
        let timerId = timersPopupButton.selectedItem?.title
        guard let timerId = timerId else {
            return
        }
        GrowingTracker.sharedInstance().trackTimerResume(timerId)
    }
    
    @IBAction func endTimerAction(_ sender: Any) {
        let timerId = timersPopupButton.selectedItem?.title
        guard let timerId = timerId else {
            return
        }
        GrowingTracker.sharedInstance().trackTimerEnd(timerId)
        timersPopupButton.removeItem(withTitle: timerId)
    }
    
    @IBAction func endTimerWithAttributesAction(_ sender: Any) {
        let timerId = timersPopupButton.selectedItem?.title
        guard let timerId = timerId else {
            return
        }
        GrowingTracker.sharedInstance().trackTimerEnd(timerId, withAttributes: ["key": "value"])
        timersPopupButton.removeItem(withTitle: timerId)
    }
    
    @IBAction func clearAllTimersAction(_ sender: Any) {
        GrowingTracker.sharedInstance().clearTrackTimer()
        timersPopupButton.removeAllItems()
    }
}

