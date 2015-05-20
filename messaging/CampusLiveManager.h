//
//  CampusLiveManager.h
//  Gleepost
//
//  Created by Silouanos on 11/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPost;
@class GLPLiveSummary;

@interface CampusLiveManager : NSObject

+ (CampusLiveManager *)sharedInstance;

- (void)getLiveEventPosts;
- (void)getLiveSummary;
- (NSInteger)liveSummaryPartiesCount;
- (NSInteger)liveSummarySpeakersCount;
- (NSInteger)liveSummaryPostsLeftCount;

- (GLPPost *)eventPostAtIndex:(NSInteger)index;
- (NSInteger)eventsCount;
- (void)attendToEvent:(BOOL)attend withPostRemoteKey:(NSInteger)postRemoteKey withImage:(UIImage *)postImage;
- (void)deletePostWithPost:(GLPPost *)post;
-(void)loadCurrentLivePostsWithCallbackBlock:(void (^) (BOOL success, NSArray *posts))callbackBlock;

-(int)findMostCloseToNowLivePostWithPosts:(NSArray *)posts;
-(void)postLike:(BOOL)like withPostRemoteKey:(NSInteger)postRemoteKey;

@end
