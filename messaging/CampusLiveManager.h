//
//  CampusLiveManager.h
//  Gleepost
//
//  Created by Silouanos on 11/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPost;

@interface CampusLiveManager : NSObject

+ (CampusLiveManager *)sharedInstance;

- (void)getLiveEventPosts;

- (GLPPost *)eventPostAtIndex:(NSInteger)index;
- (NSInteger)eventsCount;

-(void)loadCurrentLivePostsWithCallbackBlock:(void (^) (BOOL success, NSArray *posts))callbackBlock;

-(int)findMostCloseToNowLivePostWithPosts:(NSArray *)posts;

@end
