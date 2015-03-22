//
//  GLPAttendingPostsManager.h
//  Gleepost
//
//  Created by Silouanos on 03/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPost;

@interface GLPAttendingPostsManager : NSObject

- (id)initWithUserRemoteKey:(NSInteger)userRemoteKey;
- (void)getPosts;
- (void)loadPreviousPosts;
- (NSInteger)eventsCount;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfPostsAtSectionIndex:(NSInteger)index;
- (GLPPost *)postWithSection:(NSInteger)section andIndex:(NSInteger)index;
- (NSString *)headerInSection:(NSInteger)sectionIndex;
- (NSDictionary *)removePostWithPost:(GLPPost *)post;
- (NSIndexPath *)indexPathWithPost:(GLPPost **)post;
- (NSIndexPath *)updatePostWithRemoteKey:(NSInteger)postRemoteKey andViewsCount:(NSInteger)viewsCount;

@end
