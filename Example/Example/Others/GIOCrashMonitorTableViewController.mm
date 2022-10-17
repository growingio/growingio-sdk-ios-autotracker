//
//  GIOCrashMonitorTableViewController.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/10/9.
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

#import "GIOCrashMonitorTableViewController.h"

@interface GIOCrashMonitorTableViewController ()

@end

@implementation GIOCrashMonitorTableViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UITableView DataSource & Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            // NSException
            __unused id a = @[][1];
        }
            break;
        case 1: {
            // C++ Exception
            throw 0;
        }
            break;
        case 2: {
            // Mach Exception
            char* ptr = (char*)-1;
            *ptr = 10;
        }
            break;
        case 3: {
            // Signal
            raise(SIGABRT);
        }
            break;
        case 4: {
            // WatchDog
            
        }
            break;
        case 5: {
            // Out Of Memory
            
        }
            break;
        default:
            break;
    }
}

@end
