//
//  GLPCommentDao.h
//  Gleepost
//
//  Created by Silouanos on 25/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPComment.h"
#import "FMDatabase.h"

@interface GLPCommentDao : NSObject

+ (NSArray *)findCommentsByPostRemoteKey:(NSInteger)postRemoteKey db:(FMDatabase *)db;
//+ (GLPComment *)findByKey:(NSInteger)key db:(FMDatabase *)db;
+ (void)save:(GLPComment *)entity;
+ (void)updateCommentSendingData:(GLPComment *)entity;
//+ (int)saveIfNotExist:(GLPComment*)entity db:(FMDatabase *)db;
//+ (void)update:(GLPComment*)entity;
//+ (void)updateUserWithRemotKey:(int)remoteKey andProfileImage:(NSString*)imageUrl;

@end
