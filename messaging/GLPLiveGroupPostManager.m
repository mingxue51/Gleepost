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
#import "GLPGroupProgressManager.h"

@interface GLPLiveGroupPostManager ()

@property (strong, nonatomic) NSMutableDictionary *pendingImagePosts;

/** This class is a singleton but we are creating a new instance  ont this manager too. */
//@property (strong, nonatomic) GLPCampusWallProgressManager *groupProgressManager;

@property (strong, nonatomic) GLPGroupProgressManager *progressManager;



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
//        _groupProgressManager = [[GLPCampusWallProgressManager alloc] init];
        _progressManager = [[GLPGroupProgressManager alloc] init];
    }
    
    return self;
}


#pragma mark - Progress Manager

- (UploadingProgressView *)progressViewWithGroupRemoteKey:(NSInteger)groupRemoteKey
{
    if(groupRemoteKey != [_progressManager postRemoteKey])
    {
        return nil;
    }
    
    return [_progressManager progressView];
}

- (void)registerVideoWithTimestamp:(NSDate *)timestamp withPost:(GLPPost *)post
{
    [_progressManager registerVideoWithTimestamp:timestamp withPost:post];
}

- (void)setThumbnailImage:(UIImage *)thumbnail
{
    [_progressManager setThumbnailImage:thumbnail];
}

- (void)progressFinished
{
    [_progressManager progressFinished];
}

- (void)postButtonClicked
{
    [_progressManager postButtonClicked];
}

- (BOOL)isProgressFinished
{
    return [_progressManager isProgressFinished];
}

- (NSDate *)registeredTimestamp
{
    return [_progressManager registeredTimestamp];
}

- (NSString *)generateNSNotificationNameForPendingGroupPost
{
    return [_progressManager generateNSNotificationNameForPendingGroupPost];
}

- (NSString *)generateNSNotificationUploadFinshedNameForPendingGroupPost
{
    return [_progressManager generateNSNotificationUploadFinshedNameForPendingGroupPost];
}

#pragma mark - Image posts

- (void)addImagePost:(GLPPost *)post withGroupRemoteKey:(NSInteger)groupRemoteKey
{
    if(![post imagePost])
    {
        return;
    }
    
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
        [pendingImagePostsArray removeObjectAtIndex:index];
    }
    
}

- (void)removeAnyUploadedImagePostWithPosts:(NSArray *)posts inGroupRemoteKey:(NSInteger)groupRemoteKey
{
    FLog(@"GLPLiveGroupPostManager : removeAnyUploadedImagePostWithPosts");
    
    NSMutableArray *pendingImagePostsArray = [_pendingImagePosts objectForKey:@(groupRemoteKey)];
    
    //We are calling the copy method because the _pendingImagePosts might be accessed by other thread.
    
    for(GLPPost *pendingPost in [pendingImagePostsArray copy])
    {
        for (GLPPost *livePost in posts)
        {
            if(pendingPost.remoteKey == livePost.remoteKey)
            {
                [self removePost:pendingPost fromGroupWithRemoteKey:groupRemoteKey];
            }
        }
    }
}


- (NSArray *)pendingImagePostsWithGroupRemoteKey:(NSInteger)groupRemoteKey
{
    DDLogDebug(@"Get image posts %ld from GLPLiveGroupPostManager.", (long)groupRemoteKey);

    return [_pendingImagePosts objectForKey:@(groupRemoteKey)];
}


@end
