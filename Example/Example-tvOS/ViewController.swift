//
//  ViewController.swift
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

import UIKit
import GrowingAnalytics

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        GrowingAutotracker.sharedInstance().autotrackPage(self, alias: "tvOSViewController", attributes: ["key1": "value"])
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        GrowingAutotracker.sharedInstance().trackCustomEvent("tvOS_custom_event", withAttributes: ["key2": "value"])
    }
    
}

