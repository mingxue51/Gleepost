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
#import "NSNotificationCenter+Utils.h"

@interface GLPVideoLoaderManager ()

/** Contains post remote key as a key and PBJVideoPlayerController as a value. */
//@property (strong, nonatomic) NSMutableDictionary *videoViews;
/** Contains post remote key as a key and Asset as a value */
@property (strong, nonatomic) NSCache *videoCache;

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
        [self configureNotifications];
    }
    
    return self;
}

-(void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPlayVideo" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPauseVideo" object:nil];
}

#pragma mark - Configuration

-(void)initialiseObjects
{
//    _videoViews = [[NSMutableDictionary alloc] init];
    _videoCache = [[NSCache alloc] init];
}

-(void)configureNotifications
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideo:) name:@"GLPPlayVideo" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseVideo:) name:@"GLPPauseVideo" object:nil];

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

#pragma mark - Notifications

//-(void)playVideo:(NSNotification *)notification
//{
//    NSDictionary *notificationDict = notification.userInfo;
//    
//    NSNumber *remoteKey = [notificationDict objectForKey:@"RemoteKey"];
//    
//    [self playVideoWithRemoteKey:remoteKey];
//    
//}
//
//-(void)pauseVideo:(NSNotification *)notification
//{
//    DDLogDebug(@"pauseVideo: %@", notification);
//
//    NSDictionary *notificationDict = notification.userInfo;
//    
//    NSNumber *remoteKey = [notificationDict objectForKey:@"RemoteKey"];
//    
//    [self pauseVideoWithRemoteKey:remoteKey];
//}

#pragma mark - Video actions

//-(void)playVideoWithRemoteKey:(NSNumber *)remoteKey
//{
//    PBJVideoPlayerController *video = [_videoViews objectForKey:remoteKey];
//    [video playFromCurrentTime];
//}
//
//-(void)pauseVideoWithRemoteKey:(NSNumber *)remoteKey
//{
//    PBJVideoPlayerController *video = [_videoViews objectForKey:remoteKey];
//    [video pause];
//}

-(void)addVideos:(NSArray *)posts
{
    NSArray *videoPosts = [self videoPostsWithPosts:posts];
    
    for(GLPPost *p in videoPosts)
    {
//        [self addVideoWithUrl:p.videosUrls[0] andPostRemoteKey:p.remoteKey];
        
        [self addVideoWithUrl:p.video.url andPostRemoteKey:p.remoteKey];
        
    }
}

- (void)addVideoWithUrl:(NSString *)videoUrl andPostRemoteKey:(NSInteger)remoteKey
{
    
    AVURLAsset *asset = [_videoCache objectForKey:@(remoteKey)];
    
    if(!asset)
    {
        asset =  [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoUrl] options:nil];
        [_videoCache setObject:asset forKey:@(remoteKey)];
        
        DDLogDebug(@"Video url: %@ added.", videoUrl);

    }
    
    
}

//- (void)addVideoWithUrl:(NSString *)videoUrl andPostRemoteKey:(NSInteger)remoteKey
//{
////    DDLogDebug(@"GLPVideoLoaderManager : In addVideoWithUrl");
//    
//    PBJVideoPlayerController *foundVideoViewController = [self videoWithPostRemoteKey:remoteKey];
//    
//    if(foundVideoViewController)
//    {
//        //Already in the list.
////        DDLogDebug(@"Found video view controller already in list!");
//        
////        return foundVideoViewController;
//    }
//    else
//    {
//        PBJVideoPlayerController *videoViewController = [[PBJVideoPlayerController alloc] init];
//        [videoViewController setPlaybackLoops:NO];
//        [videoViewController setVideoPath:videoUrl];
//        [videoViewController.view setBounds:CGRectMake(0, 0, 298, 298)];
//        
////        DDLogDebug(@"Video not found but ready: %@", videoUrl);
//        
//        [_videoViews setObject:videoViewController forKey:[NSNumber numberWithInteger:remoteKey]];
//        
////        return nil;
//    }
//
//}

/**
 If the asset is not in the NSCache, then return nil in order to not block the UI.
 At the meantime set timer in the VideoView to check if asset is ready. Once is ready, return the 
 PBJVideoPlayerController.
 */
- (void)videoWithPostRemoteKey:(NSInteger)remoteKey
{
//    PBJVideoPlayerController *v =[_videoViews objectForKey:[NSNumber numberWithInteger:remoteKey]];
    
//    DDLogDebug(@"Video status: %d", v.playbackState);
    
//    PBJVideoPlayerController *videoPlayer = nil;
//
//    NSNumber *remoteKeyObject = [NSNumber numberWithInteger:remoteKey];
//    
//    AVURLAsset *asset = [_videoCache objectForKey:remoteKeyObject];
//
//    if(asset)
//    {
//        videoPlayer = [[PBJVideoPlayerController alloc] init];
//        [videoPlayer setVideoAsset:asset];
//    }
//    else
//    {
//        [_videoCache setObject:asset forKey:remoteKeyObject];
//    }
    
//    [NSThread detachNewThreadSelector:@selector(configureVideoPlayerControllerAndPostNotificationWithRemoteKey:) toTarget:self withObject:@(remoteKey)];

    
}

- (void)configureVideoPlayerControllerAndPostNotificationWithRemoteKey:(NSNumber *)remoteKey callbackBlock:(void (^) (NSNumber *remoteKey, PBJVideoPlayerController *player))callbackBlock
{
    PBJVideoPlayerController *videoPlayer = nil;
    
//    NSNumber *remoteKeyObject = [NSNumber numberWithInteger:remoteKey];
    
    AVURLAsset *asset = [_videoCache objectForKey:remoteKey];
    
    if(asset)
    {
        videoPlayer = [[PBJVideoPlayerController alloc] init];
        [videoPlayer setVideoAsset:asset];
    }
    else
    {
//        asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoUrl] options:nil];
        [_videoCache setObject:asset forKey:remoteKey];
        DDLogDebug(@"Asset nil");
    }
    
    DDLogDebug(@"PBJVideoPlayerController generated");
    
    callbackBlock(remoteKey, videoPlayer);
    
//    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_VIDEO_READY object:self userInfo:@{remoteKey: videoPlayer}];
}

- (void)visiblePosts:(NSArray *)visiblePosts
{
    
//    NSPredicate *applePred = [NSPredicate predicateWithFormat:
//                              @"p.isVideoPost == TRUEPREDICATE"];
//    
//    
//    NSArray *appleEmployees = [visiblePosts filteredArrayUsingPredicate:applePred];
//    
//    DDLogDebug(@"VIDEO POSTS!!! : %@", appleEmployees);
    
    
//    NSMutableArray *videoPosts =
//    
//    for(GLPPost *post in visiblePosts)
//    {
//        
//    }
}

//- (void)releaseVideo
//{
//    DDLogDebug(@"Number of videos instances: %@", _videoViews);
//    
//    for(NSNumber *key in _videoViews)
//    {
//        [_videoViews removeObjectForKey:key];
//        break;
//    }
//}

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
