//
//  GLPGroupManager.h
//  Gleepost
//
//  Created by Σιλουανός on 3/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPGroup.h"
#import "GLPPost.h"

@interface GLPGroupManager : NSObject

+ (NSDictionary *)processGroups:(NSArray *)groups;
+ (void)loadInitialPostsWithGroupId:(int)groupId remoteCallback:(void (^)(BOOL success, BOOL remain, NSArray *remotePosts))remoteCallback;

+ (void)loadGroups:(NSArray *)groups withLocalCallback:(void (^)(NSArray *groups))localCallback remoteCallback:(void (^)(BOOL success, NSArray *groups))remoteCallback;

+ (void)loadRemotePostsBefore:(GLPPost *)post withGroupRemoteKey:(int)remoteKey callback:(void (^)(BOOL success, BOOL remain, NSArray *posts))callback;

+ (void)loadPreviousPostsAfter:(GLPPost *)post withGroupRemoteKey:(int)remoteKey callback:(void (^)(BOOL success, BOOL remain, NSArray *posts))callback;

+ (void)deleteGroup:(GLPGroup *)group;

+(int)parseNotification:(NSNotification*)notification withGroupsArray:(NSArray*)groups;

+(NSIndexPath *)findIndexPathForGroupRemoteKey:(int)remoteKey withCategorisedGroups:(NSMutableDictionary *)dictionary;

@end
