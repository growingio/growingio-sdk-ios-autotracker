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
#import "Crasher.h"

@interface GIOCrashMonitorTableViewController ()

@property (nonatomic, strong) Crasher *crasher;

@end

@implementation GIOCrashMonitorTableViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.crasher = [[Crasher alloc] init];
}

#pragma mark - UITableView DataSource & Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            // NSException
            [self.crasher throwUncaughtNSException];
        }
            break;
        case 1: {
            // dereferenceBadPointer
            [self.crasher dereferenceBadPointer];
        }
            break;
        case 2: {
            // dereferenceNullPointer
            [self.crasher dereferenceNullPointer];
        }
            break;
        case 3: {
            // useCorruptObject
            [self.crasher useCorruptObject];
        }
            break;
        case 4: {
            // spinRunloop
            [self.crasher spinRunloop];
            
        }
            break;
        case 5: {
            // StackOverflow
            [self.crasher causeStackOverflow];
        }
            break;
        case 6: {
            // abort()
            [self.crasher doAbort];
        }
            break;
        case 7: {
            // doDiv0
            [self.crasher doDiv0];
        }
            break;
        case 8: {
            // Illegal Instruction
            [self.crasher doIllegalInstruction];
        }
            break;
        case 9: {
            // accessDeallocatedObject
            [self.crasher accessDeallocatedObject];
        }
            break;
        case 10: {
            // accessDeallocatedPtrProxy
            [self.crasher accessDeallocatedPtrProxy];
        }
            break;
        case 11: {
            // zombieNSException
            [self.crasher zombieNSException];
        }
            break;
        case 12: {
            // corruptMemory
            [self.crasher corruptMemory];
        }
            break;
        case 13: {
            // deadlock
            [self.crasher deadlock];
        }
            break;
        case 14: {
            // pthreadAPICrash
            [self.crasher pthreadAPICrash];
        }
            break;
        case 15: {
            // throwUncaughtCPPException
            [self.crasher throwUncaughtCPPException];
        }
            break;
        default:
            break;
    }
}

@end
