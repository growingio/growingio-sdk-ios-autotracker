// Copyright (c) 2008-2014 Flying Meat Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//  GrowingFMDatabaseAdditions.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 10/30/05.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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

#import "Services/Database/FMDB/GrowingFMDatabase.h"
#import "Services/Database/FMDB/GrowingFMDatabaseAdditions.h"
#import <TargetConditionals.h>

@interface GrowingFMDatabase (PrivateStuff)
- (GrowingFMResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args;
@end

@implementation GrowingFMDatabase (GrowingFMDatabaseAdditions)

#define RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(type, sel)             \
va_list args;                                                        \
va_start(args, query);                                               \
GrowingFMResultSet *resultSet = [self executeQuery:query withArgumentsInArray:0x00 orDictionary:0x00 orVAList:args];   \
va_end(args);                                                        \
if (![resultSet next]) { return (type)0; }                           \
type ret = [resultSet sel:0];                                        \
[resultSet close];                                                   \
[resultSet setParentDB:nil];                                         \
return ret;


- (NSString*)stringForQuery:(NSString*)query, ... {
    RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(NSString *, stringForColumnIndex);
}

- (int)intForQuery:(NSString*)query, ... {
    RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(int, intForColumnIndex);
}

- (long)longForQuery:(NSString*)query, ... {
    RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(long, longForColumnIndex);
}

- (BOOL)boolForQuery:(NSString*)query, ... {
    RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(BOOL, boolForColumnIndex);
}

- (double)doubleForQuery:(NSString*)query, ... {
    RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(double, doubleForColumnIndex);
}

- (NSData*)dataForQuery:(NSString*)query, ... {
    RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(NSData *, dataForColumnIndex);
}

- (NSDate*)dateForQuery:(NSString*)query, ... {
    RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(NSDate *, dateForColumnIndex);
}


- (BOOL)tableExists:(NSString*)tableName {
    
    tableName = [tableName lowercaseString];
    
    GrowingFMResultSet *rs = [self executeQuery:@"select [sql] from sqlite_master where [type] = 'table' and lower(name) = ?", tableName];
    
    //if at least one next exists, table exists
    BOOL returnBool = [rs next];
    
    //close and free object
    [rs close];
    
    return returnBool;
}

/*
 get table with list of tables: result colums: type[STRING], name[STRING],tbl_name[STRING],rootpage[INTEGER],sql[STRING]
 check if table exist in database  (patch from OZLB)
*/
- (GrowingFMResultSet*)getSchema {
    
    //result colums: type[STRING], name[STRING],tbl_name[STRING],rootpage[INTEGER],sql[STRING]
    GrowingFMResultSet *rs = [self executeQuery:@"SELECT type, name, tbl_name, rootpage, sql FROM (SELECT * FROM sqlite_master UNION ALL SELECT * FROM sqlite_temp_master) WHERE type != 'meta' AND name NOT LIKE 'sqlite_%' ORDER BY tbl_name, type DESC, name"];
    
    return rs;
}

/* 
 get table schema: result colums: cid[INTEGER], name,type [STRING], notnull[INTEGER], dflt_value[],pk[INTEGER]
*/
- (GrowingFMResultSet*)getTableSchema:(NSString*)tableName {
    
    //result colums: cid[INTEGER], name,type [STRING], notnull[INTEGER], dflt_value[],pk[INTEGER]
    GrowingFMResultSet *rs = [self executeQuery:[NSString stringWithFormat: @"pragma table_info('%@')", tableName]];
    
    return rs;
}

- (BOOL)columnExists:(NSString*)columnName inTableWithName:(NSString*)tableName {
    
    BOOL returnBool = NO;
    
    tableName  = [tableName lowercaseString];
    columnName = [columnName lowercaseString];
    
    GrowingFMResultSet *rs = [self getTableSchema:tableName];
    
    //check if column is present in table schema
    while ([rs next]) {
        if ([[[rs stringForColumn:@"name"] lowercaseString] isEqualToString:columnName]) {
            returnBool = YES;
            break;
        }
    }
    
    //If this is not done FMG3Database instance stays out of pool
    [rs close];
    
    return returnBool;
}


#if SQLITE_VERSION_NUMBER >= 3007017

- (uint32_t)applicationID {
    
    uint32_t r = 0;
    
    GrowingFMResultSet *rs = [self executeQuery:@"pragma application_id"];
    
    if ([rs next]) {
        r = (uint32_t)[rs longLongIntForColumnIndex:0];
    }
    
    [rs close];
    
    return r;
}

- (void)setApplicationID:(uint32_t)appID {
    NSString *query = [NSString stringWithFormat:@"pragma application_id=%d", appID];
    GrowingFMResultSet *rs = [self executeQuery:query];
    [rs next];
    [rs close];
}


#if TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSString*)applicationIDString {
    NSString *s = NSFileTypeForHFSTypeCode([self applicationID]);
    
    assert([s length] == 6);
    
    s = [s substringWithRange:NSMakeRange(1, 4)];
    
    
    return s;
    
}

- (void)setApplicationIDString:(NSString*)s {
    
    if ([s length] != 4) {
        NSLog(@"setApplicationIDString: string passed is not exactly 4 chars long. (was %ld)", [s length]);
    }
    
    [self setApplicationID:NSHFSTypeCodeFromFileType([NSString stringWithFormat:@"'%@'", s])];
}


#endif

#endif

- (uint32_t)userVersion {
    uint32_t r = 0;
    
    GrowingFMResultSet *rs = [self executeQuery:@"pragma user_version"];
    
    if ([rs next]) {
        r = (uint32_t)[rs longLongIntForColumnIndex:0];
    }
    
    [rs close];
    return r;
}

- (void)setUserVersion:(uint32_t)version {
    NSString *query = [NSString stringWithFormat:@"pragma user_version = %d", version];
    GrowingFMResultSet *rs = [self executeQuery:query];
    [rs next];
    [rs close];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (BOOL)columnExists:(NSString*)tableName columnName:(NSString*)columnName __attribute__ ((deprecated)) {
    return [self columnExists:columnName inTableWithName:tableName];
}

#pragma clang diagnostic pop


- (BOOL)validateSQL:(NSString*)sql error:(NSError**)error {
    sqlite3_stmt *pStmt = NULL;
    BOOL validationSucceeded = YES;
    
    int rc = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &pStmt, 0);
    if (rc != SQLITE_OK) {
        validationSucceeded = NO;
        if (error) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:[self lastErrorCode]
                                     userInfo:[NSDictionary dictionaryWithObject:[self lastErrorMessage]
                                                                          forKey:NSLocalizedDescriptionKey]];
        }
    }
    
    sqlite3_finalize(pStmt);
    
    return validationSucceeded;
}

@end
