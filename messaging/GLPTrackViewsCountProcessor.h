//
//  GLPTrackViewsCountProcessor.h
//  Gleepost
//
//  Created by Silouanos on 23/12/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GLPPost;

@interface GLPTrackViewsCountProcessor : NSObject

- (void)trackVisiblePosts:(NSArray *)visiblePosts withPostsYValues:(NSArray *)visiblePostsYValues;
- (void)resetVisibleCells;
- (void)resetSentPostsSet;
+ (void)updateViewsCounter:(NSInteger)updatedViewsCount onPost:(NSInteger)postRemoteKey;

@end
