//
//  GLPCampusWallAsyncProcessor.h
//  Gleepost
//
//  Created by Silouanos on 08/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPCampusWallAsyncProcessor : NSObject

- (void)parseAndUpdatedViewsCountPostWithPostRemoteKey:(NSInteger)postRemoteKey andPosts:(NSArray *)posts withCallbackBlock:(void (^) (NSInteger index))callback;
- (NSInteger)findIndexFromPostsArray:(NSArray *)posts withPostRemoteKey:(NSInteger)postRemoteKey;

@end
