//
//  GLPLiveGroupPostManager.m
//  Gleepost
//
//  Created by Silouanos on 25/09/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This manager is responsible for managing the pending image posts (for now) in order to preserve
//  the uploading image post even if user dismiss the GroupViewController.

#import "GLPLiveGroupPostManager.h"
#import "GLPPost.h"

@interface GLPLiveGroupPostManager ()

@property (strong, nonatomic) NSMutableDictionary *pendingImagePosts;

@end

@implementation GLPLiveGroupPostManager

static GLPLiveGroupPostManager *instance = nil;

+ (GLPLiveGroupPostManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[GLPLiveGroupPostManager alloc] init];

    });
    
    return instance;
}


- (id)init
{
    self = [super init];
    
    if(self)
    {
        _pendingImagePosts = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)addImagePost:(GLPPost *)post withGroupRemoteKey:(NSInteger)groupRemoteKey
{
    DDLogDebug(@"Added image post %@ to GLPLiveGroupPostManager.", post);
    
    NSMutableArray *pendingImagePostsArray = [_pendingImagePosts objectForKey:@(groupRemoteKey)];
    
    if(pendingImagePostsArray)
    {
        //Just add the new post in the array.
        [pendingImagePostsArray addObject:post];
    }
    else
    {
        pendingImagePostsArray = [[NSMutableArray alloc] initWithObjects:post, nil];
        
        [_pendingImagePosts setObject:pendingImagePostsArray forKey:@(groupRemoteKey)];
        
    }
    
}

- (void)removePost:(GLPPost *)post fromGroupWithRemoteKey:(NSInteger)groupRemoteKey
{
    
    DDLogDebug(@"Removed image post %@ from GLPLiveGroupPostManager.", post);

    NSMutableArray *pendingImagePostsArray = [_pendingImagePosts objectForKey:@(groupRemoteKey)];

    if(!pendingImagePostsArray)
    {
        DDLogError(@"Error group with remote key %ld doesn't exist in GLPLiveGroupManager.", (long)groupRemoteKey);
        
        return;
    }
    
    int index = 0;
    BOOL postFound = NO;
    
    for(GLPPost *p in pendingImagePostsArray)
    {
        if(p.remoteKey == post.remoteKey)
        {
            postFound = YES;
            break;
        }
        
        ++index;
    }
    
    if(postFound)
    {
        DDLogDebug(@"Post %@ removed. New group array: %@", post, pendingImagePostsArray);
        
        [pendingImagePostsArray removeObjectAtIndex:index];
    }
    
}

- (void)removeAnyUploadedImagePostWithPosts:(NSArray *)posts inGroupRemoteKey:(NSInteger)groupRemoteKey
{
    NSMutableArray *pendingImagePostsArray = [_pendingImagePosts objectForKey:@(groupRemoteKey)];
    
    for(GLPPost *pendingPost in pendingImagePostsArray)
    {
        for (GLPPost *livePost in posts)
        {
            if(pendingPost.remoteKey == livePost.remoteKey)
            {
                [self removePost:pendingPost fromGroupWithRemoteKey:groupRemoteKey];
                
                DDLogDebug(@"Post exist %@ removed!", pendingPost);
            }
        }
    }
}


- (NSArray *)pendingImagePostsWithGroupRemoteKey:(NSInteger)groupRemoteKey
{
    DDLogDebug(@"Get image posts %ld from GLPLiveGroupPostManager.", (long)groupRemoteKey);

    return [_pendingImagePosts objectForKey:@(groupRemoteKey)];
}

#pragma mark - Helpers



@end
