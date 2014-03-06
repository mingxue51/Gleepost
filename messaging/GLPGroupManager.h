//
//  GLPGroupManager.h
//  Gleepost
//
//  Created by Σιλουανός on 3/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPGroup.h"

@interface GLPGroupManager : NSObject

+ (NSDictionary *)processGroups:(NSArray *)groups;
+ (void)loadInitialPostsWithGroupId:(int)groupId remoteCallback:(void (^)(BOOL success/*, BOOL remain*/, NSArray *remotePosts))remoteCallback;

+ (void)loadGroups:(NSArray *)groups withLocalCallback:(void (^)(NSArray *groups))localCallback remoteCallback:(void (^)(BOOL success, NSArray *groups))remoteCallback;

+ (void)deleteGroup:(GLPGroup *)group;

@end
