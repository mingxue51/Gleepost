//
//  GLPCampusWallAsyncProcessor.m
//  Gleepost
//
//  Created by Silouanos on 08/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  This class is responsible of doing all the aynchronous operations for the campus wall only.
//  Will handle operations like: parsing all the posts and find one in order to update it.
//  We can't do these kind of operations in GLPTimelineViewController because it's going to be
//  in the main thread and we will have vey bad user experience.

#import "GLPCampusWallAsyncProcessor.h"
#import "GLPPost.h"

@implementation GLPCampusWallAsyncProcessor

- (void)parseAndUpdatedViewsCountPostWithPostRemoteKey:(NSInteger)postRemoteKey andPosts:(NSArray *)posts withCallbackBlock:(void (^) (NSInteger index))callback
{
    NSInteger index = [self findIndexFromPostsArray:posts withPostRemoteKey:postRemoteKey];
    callback(index);
}

- (NSInteger)findIndexFromPostsArray:(NSArray *)posts withPostRemoteKey:(NSInteger)postRemoteKey
{
    for(int index = 0; index < posts.count; ++index)
    {
        GLPPost *p = [posts objectAtIndex:index];
        
        if(p.remoteKey == postRemoteKey)
        {
            return index;
        }
    }
    
    return -1;
}

@end
