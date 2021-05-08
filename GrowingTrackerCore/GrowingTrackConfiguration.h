//
// Created by xiangyang on 2020/11/6.
//

#import <Foundation/Foundation.h>


@interface GrowingTrackConfiguration : NSObject <NSCopying>
@property(nonatomic, copy, readonly) NSString *projectId;

@property(nonatomic, assign) BOOL debugEnabled;
@property(nonatomic, assign) NSUInteger cellularDataLimit;
@property(nonatomic, assign) NSTimeInterval dataUploadInterval;
@property(nonatomic, assign) NSTimeInterval sessionInterval;
@property(nonatomic, assign) BOOL dataCollectionEnabled;
@property(nonatomic, assign) BOOL uploadExceptionEnable;
@property(nonatomic, copy) NSString *dataCollectionServerHost;

- (instancetype)initWithProjectId:(NSString *)projectId;

+ (instancetype)configurationWithProjectId:(NSString *)projectId;


@end
