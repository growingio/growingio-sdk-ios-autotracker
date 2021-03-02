//
// WebSocketTests.m
// ExampleTests
//
//  Created by GrowingIO on 3/1/21.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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


#import <XCTest/XCTest.h>
#import "GrowingSRWebSocket.h"
#import <KIF/KIF.h>
#import "UIImage+GrowingHelper.h"
#import "UIWindow+GrowingHelper.h"
#import "GrowingStatusBarEventManager.h"
#import "GrowingHybridPageEvent.h"
#import "GrowingHybridCustomEvent.h"
#import "GrowingPageCustomEvent.h"
#import "GrowingHybridViewElementEvent.h"
#import "GrowingFMDatabaseQueue.h"
#import "GrowingFMDatabase.h"
#import "GrowingFMDatabasePool.h"
#import "GrowingLoginRequest.h"
#import "GrowingNodeItem.h"

@interface WebSocketTests : KIFTestCase

@end

@implementation WebSocketTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

-(void)testGrowingSRWebSocket{
    NSURL *url = [NSURL URLWithString:@"https://www.growingio.com"];
    GrowingSRWebSocket *webSocket = [[GrowingSRWebSocket alloc]initWithURL:url];
    [webSocket open];
    XCTAssertNotNil(webSocket.url);
    //    XCTAssertNotNil(webSocket.readyState);
    //    XCTAssertNotNil(webSocket.protocol);
    webSocket.readyState;
    
    //    [webSocket send:[[NSData alloc]init] ];
    //    [webSocket sendPing:nil];
    //    [webSocket _sendFrameWithOpcode:GrowingSROpCodePing data:nil];
    
    //    [webSocket setDelegate:self];
    [webSocket setDelegateDispatchQueue:dispatch_get_main_queue()];
    [webSocket setDelegateOperationQueue:nil];
    [webSocket.delegate webSocketDidOpen:webSocket];
    [webSocket.delegate webSocket:webSocket didReceivePong:nil];
    [webSocket.delegate webSocket:webSocket didReceiveMessage:nil];
    [webSocket.delegate webSocket:nil didReceiveMessage:@{@"a":@"value"}];
    [webSocket.delegate webSocketDidOpen:self];
    [webSocket.delegate webSocket:webSocket didFailWithError:nil];
    [webSocket.delegate webSocket:webSocket didCloseWithCode:@1001 reason:@"fail" wasClean:YES];
    [webSocket scheduleInRunLoop:NSRunLoop.currentRunLoop forMode:NSRunLoopCommonModes];
    [webSocket unscheduleFromRunLoop:NSRunLoop.currentRunLoop forMode:NSRunLoopCommonModes];
    [NSRunLoop growing_SR_networkRunLoop];
    [webSocket close];
    [webSocket closeWithCode:@502 reason:@"fail"];
}

-(void)testImageHelper{
    UIImage *image = [[UIImage alloc]init];
    NSData *data = [image growingHelper_JPEG:0.8];
    [image growingHelper_PNG];
    [image growingHelper_Base64PNG];
    [image growingHelper_Base64JPEG:0.9];
    [image growingHelper_getSubImage:CGRectMake(0.8, 0.8, 0.8, 0.8)];
    
}
-(void)testUIWindowHelper{
    [UIWindow growingHelper_screenshotWithWindows:nil andMaxScale:0.8];
    [UIWindow growingHelper_screenshotWithWindows:nil andMaxScale:0.8 block:nil];
}

-(void)testGrowingStatusBarEventManager{
    [[GrowingStatusBarEventManager sharedInstance] dispatchTapStatusBar:nil];
    [[GrowingStatusBarEventManager sharedInstance] addStatusBarObserver:self];
    [[GrowingStatusBarEventManager sharedInstance] removeStatusBarObserver:self];
}
-(void)testGrowingHybridPageEvent{
    [GrowingHybridPageEvent builder];
    
    GrowingHybridPageEvent.builder.setProtocolType(@"KEY_PROTOCOL_TYPE")
    .setQuery(@"KEY_QUERY")
    .setTitle(@"KEY_TITLE")
    .setReferralPage(@"KEY_REFERRAL_PAGE")
    .setPath(@"KEY_PATH")
    .setTimestamp(@"KEY_TIMESTAMP")
    .setDomain(@"domain");
}


-(void)testGrowingHybridCustomEvent{
    [GrowingHybridCustomEvent builder];
    GrowingHybridCustomEvent.builder.setQuery(@"KEY_QUERY")
    .setPath(@"KEY_PATH")
    .setPageShowTimestamp(@"KEY_PAGE_SHOW_TIMESTAMP")
    .setAttributes(@"KEY_ATTRIBUTES")
    .setEventName(@"KEY_EVENT_NAME")
    .setDomain(@"domain");
}

-(void)testGrowingPageCustomEvent{
    [GrowingPageCustomEvent builder];
    [GrowingPageCustomEvent builder].setPath(@"KEY_PATH")
    .setEventName(@"KEY_EVENT_NAME")
    .setAttributes(@"KEY_ATTRIBUTES")
    .setPageShowTimestamp(@"KEY_PAGE_SHOW_TIMESTAMP");
}

-(void)testGrowingHybridViewElementEvent{
    [GrowingHybridViewElementEvent builder];
    GrowingHybridViewElementEvent.builder.setQuery(@"KEY_QUERY")
    .setPath(@"KEY_PATH")
    .setPageShowTimestamp(@"KEY_PAGE_SHOW_TIMESTAMP")
    .setHyperlink(@"Hyperlink")
    .setEventType(@"KEY_EVENT_Type")
    .setXpath(@"Xpath")
    .setIndex(@"Index")
    .setDomain(@"domain");
}

-(void)testGrowingFMDatabaseQueue{
    [GrowingFMDatabaseQueue databaseQueueWithPath:@"testpath"];
    [GrowingFMDatabaseQueue databaseQueueWithPath:@"testpath" flags:@1];
    [[GrowingFMDatabaseQueue databaseQueueWithPath:@"testpath"] initWithPath:@"testpath"];
    [[GrowingFMDatabaseQueue databaseQueueWithPath:@"testpath"] initWithPath:@"testpath" flags:@2];
    [[GrowingFMDatabaseQueue databaseQueueWithPath:@"testpath"] initWithPath:@"testpath" flags:@3 vfs:@"vfs"];
    [GrowingFMDatabaseQueue databaseClass];
    [[GrowingFMDatabaseQueue databaseQueueWithPath:@"testpath"] close];
    [[GrowingFMDatabaseQueue databaseQueueWithPath:@"testpath"] inDatabase:nil];
    [[GrowingFMDatabaseQueue databaseQueueWithPath:@"testpath"] inTransaction:nil];
    [[GrowingFMDatabaseQueue databaseQueueWithPath:@"testpath"] inDeferredTransaction:nil];
}

-(void)testGrowingFMDatabase{
    [GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] initWithPath:@"/tmp/tmp.db"];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] open];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] openWithFlags:@1];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] openWithFlags:@2 vfs:@"virtual file system (VFS)"];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] close];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] goodConnection];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] executeUpdate:@"test" withErrorAndBindings:nil];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] executeUpdate:@"test" withErrorAndBindings:nil];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] executeUpdate:@"test"];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] executeUpdateWithFormat:@"testFormat"];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] executeUpdate:@"testsql" withVAList:nil];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] executeUpdate:@"testsql" withArgumentsInArray:nil];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] executeUpdate:@"testsql" withParameterDictionary:nil];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] executeStatements:@"sql"];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] executeStatements:@"sql" withResultBlock:nil];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] changes];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] executeQuery:@"test"];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] executeQuery:@"test" withParameterDictionary:nil];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] executeQuery:@"test" withArgumentsInArray:nil];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] executeQuery:@"test" withVAList:nil];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] beginTransaction];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] beginDeferredTransaction];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] commit];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] rollback];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] inTransaction];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] closeOpenResultSets];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] hasOpenResultSets];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] shouldCacheStatements];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] setKey:@"testKey"];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] rekey:@"testKey"];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] setCheckedOut:YES];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] setLogsErrors:YES];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] setCrashOnErrors:YES];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] setTraceExecution:YES];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] setShouldCacheStatements:YES];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] lastError];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] lastErrorCode];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] lastInsertRowId];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] lastErrorMessage];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] logsErrors];
    [GrowingFMDatabase isSQLiteThreadSafe];
    [GrowingFMDatabase sqliteLibVersion];
    [GrowingFMDatabase FMG3DBUserVersion];
    [GrowingFMDatabase FMG3DBVersion];
    [[GrowingFMDatabase databaseWithPath:@"/tmp/tmp.db"] close];
    
}

-(void)testGrowingFMDatabasePool{
    [GrowingFMDatabasePool databasePoolWithPath:@"test"];
    [GrowingFMDatabasePool databasePoolWithPath:@"test" flags:@1];
    [[GrowingFMDatabasePool databasePoolWithPath:@"test"] initWithPath:@"testpath"];
    [[GrowingFMDatabasePool databasePoolWithPath:@"test"] initWithPath:@"testpath" flags:@2];
    [[GrowingFMDatabasePool databasePoolWithPath:@"test"] initWithPath:@"testpath" flags:@2];
    [[GrowingFMDatabasePool databasePoolWithPath:@"test"] countOfCheckedInDatabases];
    [[GrowingFMDatabasePool databasePoolWithPath:@"test"] countOfCheckedOutDatabases];
    [[GrowingFMDatabasePool databasePoolWithPath:@"test"] releaseAllDatabases];
    [[GrowingFMDatabasePool databasePoolWithPath:@"test"] inSavePoint:nil];
}

-(void)testGrowingLoginRequest{
    
    [GrowingLoginRequest loginRequestWithHeader:@{@"header":@"h1"} parameter:@{@"parameter":@"p1"}];
    [GrowingWebSocketRequest webSocketRequestWithParameter:@{@"param":@"p2"}];
}
-(void)testGrowingNodeItem{
    [GrowingNodeItemComponent indexNotFound];
    [GrowingNodeItemComponent indexNotDefine];
    
}

@end
