//
//  AttendingPostsOrganiserHelper.h
//  Gleepost
//
//  Created by Silouanos on 26/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPost;

@interface AttendingPostsOrganiserHelper : NSObject

- (void)organisePosts:(NSArray *)posts;
- (NSInteger)numberOfSections;
- (NSString *)headerInSection:(NSInteger)sectionIndex;
- (NSArray *)postsAtSectionIndex:(NSInteger)sectionIndex;
- (GLPPost *)postWithIndex:(NSInteger)postIndex andSectionIndex:(NSInteger)sectionIndex;
- (void)resetData;

@end
