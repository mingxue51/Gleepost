//
//  GLPVideoLoaderManager.m
//  Gleepost
//
//  Created by Silouanos on 23/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPVideoLoaderManager.h"
#import "PBJVideoPlayerController.h"
#import "GLPPost.h"
#import "GLPVideo.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVPlayerItem.h>
#import "NSNotificationCenter+Utils.h"
#import "NSMutableArray+QueueAdditions.h"
//#import "GLPVideoCellManager.h"

@interface GLPVideoLoaderManager ()

/** Contains post remote key as a key and Asset as a value */
@property (strong, nonatomic) NSCache *videoAssetsCache;

/** Array saved the last 3 video view controllers. Each place is an NSDictionary
 containing <post_key, videoVC>
 */
//@property (strong, nonatomic) NSMutableArray *savedVideosVC;

@property (assign, nonatomic) BOOL insertedPostVideoWithNilAsset;

@property (assign, nonatomic) BOOL timelineJustFetched;

@property (assign, nonatomic) GLPVideoLoaderActive active;

@end

@implementation GLPVideoLoaderManager

static GLPVideoLoaderManager *instance = nil;

+ (GLPVideoLoaderManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[GLPVideoLoaderManager alloc] init];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
        [self initialiseObjects];
    }
    
    return self;
}

- (void)setVideoLoaderActive:(GLPVideoLoaderActive)active
{
    _active = active;
}

-(void)dealloc
{

}

#pragma mark - Configuration

-(void)initialiseObjects
{
    _videoAssetsCache = [[NSCache alloc] init];
    
//    _savedVideosVC = [[NSMutableArray alloc] init];
    
//    _videoVC1 = [[PBJVideoPlayerController alloc] init];
//    
//    _videoVC2 = [[PBJVideoPlayerController alloc] init];
    
    _insertedPostVideoWithNilAsset = NO;
    
    _timelineJustFetched = YES;
}


/**
 This video is used from GLPTimelineViewController in order to prefetch videos.
 */
-(void)addVideoPosts:(NSArray *)posts
{
    if(!TARGET_IPHONE_SIMULATOR)
    {
        [NSThread detachNewThreadSelector:@selector(addVideos:) toTarget:self withObject:posts];
    }
}


-(void)addVideos:(NSArray *)posts
{
    NSArray *videoPosts = [self videoPostsWithPosts:posts];
    
//    int i = 0;
    
    for(GLPPost *p in videoPosts)
    {
//        [self addVideoWithUrl:p.videosUrls[0] andPostRemoteKey:p.remoteKey];
        
        [self addVideoWithUrl:p.video.url andPostRemoteKey:p.remoteKey];
        
//        if(i < 3)
//        {
//            [self createVideoVCAndAddItToMemoryWithPost:p andAsset:asset];
//        }
//        
//        ++i;
    }
}

- (AVURLAsset *)addVideoWithUrl:(NSString *)videoUrl andPostRemoteKey:(NSInteger)remoteKey
{
    
    AVURLAsset *asset = [_videoAssetsCache objectForKey:@(remoteKey)];
    
    if(!asset)
    {
        @try {
            
            asset =  [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoUrl] options:nil];
            [_videoAssetsCache setObject:asset forKey:@(remoteKey)];
        }
        @catch (NSException *exception || NSInvalidArgumentException *invalidArgument) {
            
            DDLogDebug(@"Exception 173: %@", exception);
            
        }
        @finally {
            
        }
    }
    
    return asset;
    
}

/**
 Creates a new instance of PBJVideoPlayerViewController and enqueues it
 to savedVideoVC
 
 */
//- (void)createVideoVCAndAddItToMemoryWithPost:(GLPPost *)videoPost andAsset:(AVURLAsset *)asset
//{
//    if(_savedVideosVC.count == 3)
//    {
//        DDLogInfo(@"Saved video VC is already contains 3 objects. Abord.");
//        
//        return;
//    }
//        
//    PBJVideoPlayerController *videoPlayer = [[PBJVideoPlayerController alloc] init];
//    [videoPlayer setVideoAsset:asset];
//    
//    [_savedVideosVC enqueue:@{@(videoPost.remoteKey) : videoPlayer}];
//    
//    DDLogDebug(@"Saved videos VCs: %@", _savedVideosVC);
//}


- (PBJVideoPlayerController *)setVideoWithPost:(GLPPost *)post
{
    PBJVideoPlayerController *videoPlayer = nil;
    
    //    NSNumber *remoteKeyObject = [NSNumber numberWithInteger:remoteKey];
    
    AVURLAsset *asset = [_videoAssetsCache objectForKey:@(post.remoteKey)];
    
    if(!asset)
    {
//        videoPlayer = [[PBJVideoPlayerController alloc] init];
//        [videoPlayer setVideoAsset:asset];
        
        
        NSAssert(post.video.url, @"Post video url should be not nil");
        
        asset =  [AVURLAsset URLAssetWithURL:[NSURL URLWithString:post.video.url] options:nil];
        
        DDLogDebug(@"Asset: %@, URL: %@", asset, post.video.url);
        
        
        @try {
            
            [_videoAssetsCache setObject:asset forKey:@(post.remoteKey)];

        }
        @catch (NSException *exception || NSInvalidArgumentException *invalidArgument) {
            
            DDLogDebug(@"Exception 224: %@", exception);
            
        }
        @finally {
            
        }
        

        
        DDLogDebug(@"Asset nil from Video View");

//        [self visiblePosts:@[post]];
        
        //Create the player item.
//        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
//        [_videoPlayerItems setObject:playerItem forKey:@(remoteKey)];
    }
    else
    {
        //        asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoUrl] options:nil];
        DDLogDebug(@"Asset not nil from Video View");
    }
    
    if(_timelineJustFetched)
    {
        videoPlayer = [[PBJVideoPlayerController alloc] init];
        [videoPlayer setVideoAsset:asset];
        
        return videoPlayer;
    }
    
    return nil;
}

/**
 Replaces a video in manager. This method is used after a video post is edited.
 
 @param post the updated post.
 
 */
- (void)replaceVideoWithPost:(GLPPost *)post
{
    [_videoAssetsCache removeObjectForKey:@(post.remoteKey)];
    
    [self addVideoWithUrl:post.video.url andPostRemoteKey:post.remoteKey];
}

- (void)disableTimelineJustFetched
{
    _timelineJustFetched = NO;
}

- (void)enableTimelineJustFetched
{
    _timelineJustFetched = YES;
}


/**
 If the asset is not in the NSCache, then return nil in order to not block the UI.
 At the meantime set timer in the VideoView to check if asset is ready. Once is ready, return the 
 PBJVideoPlayerController.
 */
- (PBJVideoPlayerController *)videoWithPostRemoteKey:(NSInteger)remoteKey
{
//    PBJVideoPlayerController *v =[_videoViews objectForKey:[NSNumber numberWithInteger:remoteKey]];
    
//    DDLogDebug(@"Video status: %d", v.playbackState);
    
    PBJVideoPlayerController *videoPlayer = nil;

    NSNumber *remoteKeyObject = [NSNumber numberWithInteger:remoteKey];
    
    AVURLAsset *asset = [_videoAssetsCache objectForKey:remoteKeyObject];
    
//    AVPlayerItem *playerItem = [_videoPlayerItems objectForKey:remoteKeyObject];

    if(asset)
    {
        //If cell is visible return the controller.
        
        videoPlayer = [[PBJVideoPlayerController alloc] init];
        [videoPlayer setVideoAsset:asset];
    }
    else
    {
        
        DDLogDebug(@"Video player should not be nil");
    }
    
    return videoPlayer;
    
}


//- (PBJVideoPlayerController *)runningVideoWithPostRemoteKey:(NSInteger)remoteKey
//{
//    for(NSDictionary *keyVideoVC in _savedVideosVC)
//    {
//        PBJVideoPlayerController *videoVC = [keyVideoVC objectForKey:@(remoteKey)];
//        
//        if(videoVC)
//        {
//            return videoVC;
//        }
//    }
//    
//    DDLogDebug(@"Contents of saved videos VC: %@", _savedVideosVC);
//
//    
//    return nil;
//}

//- (void)replaceOldVideoVCWithNew:(PBJVideoPlayerController *)newVideoVC withPostRemoteKey:(NSInteger)remoteKey
//{
//    [_savedVideosVC dequeue];
//    
//    [_savedVideosVC enqueue:@{@(remoteKey): newVideoVC}];
//    
//}

- (void)visiblePosts:(NSArray *)visiblePosts
{
    NSArray *videoVisiblePosts = [self videoPostsWithPosts:visiblePosts];
    
    DDLogDebug(@"Visible video posts: %@", videoVisiblePosts);
    
    //Call videoWithRemoteKey and post notification to cell.
    
    for(GLPPost *p in visiblePosts)
    {
        if([p isVideoPost])
        {
            PBJVideoPlayerController *videoVC = [self videoWithPostRemoteKey:p.remoteKey];

            [self postNotificationWithVideoVC:videoVC andRemoteKey:p.remoteKey];
            
        }
    }
}

- (void)postNotificationWithVideoVC:(PBJVideoPlayerController *)videoVC andRemoteKey:(NSInteger)remoteKey
{
    NSString *notificationName = [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_VIDEO_READY, (long)remoteKey];
    
    if(!videoVC)
    {
        return;
    }
    
    NSDictionary *videoViewData = [[NSDictionary alloc] initWithObjectsAndKeys:videoVC, @(remoteKey), nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:videoViewData];
}

- (void)configureVideoPlayerControllerAndPostNotificationWithRemoteKey:(NSNumber *)remoteKey callbackBlock:(void (^) (NSNumber *remoteKey, PBJVideoPlayerController *player))callbackBlock
{
    PBJVideoPlayerController *videoPlayer = nil;
    
    //    NSNumber *remoteKeyObject = [NSNumber numberWithInteger:remoteKey];
    
    AVURLAsset *asset = [_videoAssetsCache objectForKey:remoteKey];
    
    if(asset)
    {
        videoPlayer = [[PBJVideoPlayerController alloc] init];
        [videoPlayer setVideoAsset:asset];
    }
    else
    {
        //        asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoUrl] options:nil];
        
        [_videoAssetsCache setObject:asset forKey:remoteKey];
        DDLogDebug(@"Asset nil");
    }
    
    DDLogDebug(@"PBJVideoPlayerController generated");
    
    callbackBlock(remoteKey, videoPlayer);
}

#pragma mark - Set video posts

- (void)setVideoPost:(GLPPost *)post
{
    [NSThread detachNewThreadSelector:@selector(setVideoFromThread:) toTarget:self withObject:post];
    
}


#pragma mark - Helpers

-(NSArray *)videoPostsWithPosts:(NSArray *)posts
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(GLPPost *p in posts)
    {
        if([p isVideoPost])
        {
            [array addObject:p];
        }
    }
    
    return array;
}

@end
