//
//  CampusWallGroupsPostsManager.h
//  Gleepost
//
//  Created by Σιλουανός on 4/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"

@interface CampusWallGroupsPostsManager : NSObject

+(CampusWallGroupsPostsManager* )sharedInstance;

-(void)setPosts:(NSMutableArray *)posts;
-(GLPPost *)postAtIndex:(int)index;
-(BOOL)arePostsEmpty;
-(NSArray *)allPosts;

-(void)getPostsGroupsFeedWithCallbackBlock:(void (^) (BOOL success, NSArray *posts))callbackBlock;

@end
