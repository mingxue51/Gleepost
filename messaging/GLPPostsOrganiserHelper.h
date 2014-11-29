//
//  GLPPostsOrganiserHelper.h
//  Gleepost
//
//  Created by Silouanos on 26/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"

@interface GLPPostsOrganiserHelper : NSObject

@property (strong, nonatomic) NSString *firstHeader;
@property (strong, nonatomic) NSString *secondHeader;

- (id)initWithFirstHeader:(NSString *)firstHeader andSecondHeader:(NSString *)secondHeader;
- (void)addPost:(GLPPost *)post withHeader:(NSString *)header;
- (NSInteger)numberOfSections;
- (NSString *)headerInSection:(NSInteger)sectionIndex;
- (NSArray *)postsAtSectionIndex:(NSInteger)sectionIndex;
- (GLPPost *)postWithIndex:(NSInteger)postIndex andSectionIndex:(NSInteger)sectionIndex;
- (void)resetData;
- (NSIndexPath *)indexPathWithPost:(GLPPost *)post;
- (NSIndexPath *)removePost:(GLPPost *)post;

@end
