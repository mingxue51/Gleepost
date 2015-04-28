//
//  GLPPollDao.h
//  Gleepost
//
//  Created by Silouanos on 23/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPoll;
@class FMDatabase;

@interface GLPPollDao : NSObject

+ (GLPPoll *)findPollWithPostRemoteKey:(NSInteger)postRemoteKey db:(FMDatabase *)db;
+ (BOOL)saveOrUpdatePoll:(GLPPoll *)entity withPostRemoteKey:(NSInteger)postRemoteKey db:(FMDatabase *)db;
+ (void)updatePoll:(GLPPoll *)entity withPostRemoteKey:(NSInteger)postRemoteKey;
+ (BOOL)deletePollWithPostRemoteKey:(NSInteger)postRemoteKey db:(FMDatabase *)db;

+ (void)savePollBeforeSent:(GLPPoll *)entity withPostKey:(NSInteger)postKey db:(FMDatabase *)db;
+ (void)updatePollAfterSent:(GLPPoll *)poll withPostKey:(NSInteger)postKey withRemoteKey:(NSInteger)postRemoteKey db:(FMDatabase *)db;

+ (GLPPoll *)findPollWithPostRemoteKey:(NSInteger)postRemoteKey;
+ (BOOL)saveOrUpdatePoll:(GLPPoll *)entity withPostRemoteKey:(NSInteger)postRemoteKey;
+ (BOOL)deletePollWithPostRemoteKey:(NSInteger)postRemoteKey;

@end
