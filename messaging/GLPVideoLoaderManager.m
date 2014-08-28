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
//#import "GLPVideoCellManager.h"

@interface GLPVideoLoaderManager ()

/** Contains post remote key as a key and PBJVideoPlayerController as a value. */
//@property (strong, nonatomic) NSMutableDictionary *videoViews;
/** Contains post remote key as a key and Asset as a value */
@property (strong, nonatomic) NSCache *videoAssetsCache;

//@property (strong, nonatomic) NSMutableDictionary *videoPlayerItems;

//@property (strong, nonatomic) NSCache *videoCellCache;
//@property (strong, nonatomic) NSMutableDictionary *videoCellDictionary;

//@property (strong, nonatomic) NSMutableDictionary *alreadyVisiblePosts;

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
        [self configureNotifications];
    }
    
    return self;
}

- (void)setVideoLoaderActive:(GLPVideoLoaderActive)active
{
    _active = active;
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
    _videoAssetsCache = [[NSCache alloc] init];
//    _videoPlayerItems = [[NSMutableDictionary alloc] init];
//    _videoCellCache = [[NSCache alloc] init];
//    _videoCellDictionary = [[NSMutableDictionary alloc] init];
    
    _insertedPostVideoWithNilAsset = NO;
    
    _timelineJustFetched = YES;
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

        
        
        //Create the player item.
//        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
//        [_videoPlayerItems setObject:playerItem forKey:@(remoteKey)];
        

//        GLPVideoCellManager *videoLoaderCell = [_videoCellDictionary objectForKey:@(remoteKey)];
//        
//        if(![videoLoaderCell containsAsset] && videoLoaderCell)
//        {
//            DDLogDebug(@"Not contained asset Video url: %@ added. %@", videoUrl, videoLoaderCell);
//
//            [videoLoaderCell setAsset:asset];
//        }
    }
    
}

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

- (void)disableTimelineJustFetched
{
    _timelineJustFetched = NO;
}

- (void)enableTimelineJustFetched
{
    _timelineJustFetched = YES;
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
        
//        asset =  [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoUrl] options:nil];
//        [_videoCache setObject:asset forKey:@(remoteKey)];
        
//        [_videoCache setObject:asset forKey:remoteKeyObject];
//        
//        videoPlayer = [[PBJVideoPlayerController alloc] init];
//        [videoPlayer setVideoAsset:asset];
        
//        NSAssert(videoPlayer, @"Video player should not be nil");
        
        DDLogDebug(@"Video player should not be nil");
    }
    
    return videoPlayer;
    
//    [NSThread detachNewThreadSelector:@selector(configureVideoPlayerControllerAndPostNotificationWithRemoteKey:) toTarget:self withObject:@(remoteKey)];

    
}


- (void)visiblePosts:(NSArray *)visiblePosts
{
    NSArray *videoVisiblePosts = [self videoPostsWithPosts:visiblePosts];
    

    
    DDLogDebug(@"Visible video posts: %@", videoVisiblePosts);
    
    //Call videoWithRemoteKey and post notification to cell.
    
    for(GLPPost *p in visiblePosts)
    {
        if([p isVideoPost])
        {
//            NSNumber *remoteKey = [_alreadyVisiblePosts objectForKey:@(p.remoteKey)];
            
//            if(remoteKey)
//            {
//                DDLogDebug(@"Post %@ already viewed.", p.content);
//                
//                continue;
//            }
            
            
            [self postNotificationWithVideoVC:[self videoWithPostRemoteKey:p.remoteKey] andRemoteKey:p.remoteKey];
        }
    }
    
//    [_alreadyVisiblePosts removeAllObjects];
//    
//    
//    for(GLPPost *p in videoVisiblePosts)
//    {
//        [_alreadyVisiblePosts setObject:p forKey:@(p.remoteKey)];
//    }
    
//    [self setOnlyVisibleVideoPostsToCache:visiblePosts];
}

- (void)postNotificationWithVideoVC:(PBJVideoPlayerController *)videoVC andRemoteKey:(NSInteger)remoteKey
{
    NSString *notificationName = [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_VIDEO_READY, (long)remoteKey];

//    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:notificationName object:self userInfo:@{@(remoteKey): videoVC}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:@{@(remoteKey): videoVC}];
}

/**
 Sets the new visible posts (if there are) and removes the invisible ones.
 */
//- (void)setOnlyVisibleVideoPostsToCache:(NSArray *)visiblePosts
//{
////    NSCache *newPosts = [[NSCache alloc] init];
//    NSMutableDictionary *currentPosts = [[NSMutableDictionary alloc] init];
//    
//    for(GLPPost *p in visiblePosts)
//    {
//        if([p isVideoPost])
//        {
//            AVURLAsset *asset = [_videoCache objectForKey:@(p.remoteKey)];
//
//            if(!asset)
//            {
//                DDLogDebug(@"ASSET nil abord");
//            }
//            
//            
//            
////            GLPVideoCellManager *videoCell = [_videoCellCache objectForKey:@(p.remoteKey)];
//            
//            GLPVideoCellManager *videoCell = [_videoCellDictionary objectForKey:@(p.remoteKey)];
//
//            
//            if(videoCell)
//            {
//                continue;
//            }
//            
//            videoCell = [[GLPVideoCellManager alloc] initWithAsset:asset andRemoteKey:p.remoteKey];
//            
////            [newPosts setObject:videoCell forKey:@(p.remoteKey)];
//            [currentPosts setObject:videoCell forKey:@(p.remoteKey)];
//            
//            DDLogDebug(@"Video Cell: %@", videoCell);
//        }
//    }
//    
//}


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
    
    //    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_VIDEO_READY object:self userInfo:@{remoteKey: videoPlayer}];
}

#pragma mark - Set video posts

- (void)setVideoPost:(GLPPost *)post
{
//     dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//
//    dispatch_async(queue, ^{
//        
//
//        
//        
//    });
    [NSThread detachNewThreadSelector:@selector(setVideoFromThread:) toTarget:self withObject:post];

    
}

//- (void)setVideoFromThread:(GLPPost *)post
//{
//    AVURLAsset *asset = [_videoCache objectForKey:@(post.remoteKey)];
//    
//    GLPVideoCellManager *videoCell = [_videoCellDictionary objectForKey:@(post.remoteKey)];
//    
//    DDLogDebug(@"Video cell setVideoPost: %@", videoCell);
//    
//    if(videoCell)
//    {
//        return;
//    }
//    
//    DDLogDebug(@"ASSET before adding: %@", asset);
//    
//    if(asset)
//    {
//        videoCell = [[GLPVideoCellManager alloc] initWithAsset:asset andRemoteKey:post.remoteKey];
//    }
//    else
//    {
//        videoCell = [[GLPVideoCellManager alloc] initWithRemoteKey:post.remoteKey];
//    }
//    
//    
//    [_videoCellDictionary setObject:videoCell forKey:@(post.remoteKey)];
//    
//    DDLogDebug(@"Current videos in the queue: %@", _videoCellDictionary);
//}
//
//- (void)removeVideoPost:(GLPPost *)post
//{
//    [_videoCellDictionary removeObjectForKey:@(post.remoteKey)];
//}

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
