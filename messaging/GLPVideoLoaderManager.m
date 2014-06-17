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

@interface GLPVideoLoaderManager ()

/** Contains post remote key as a key and PBJVideoPlayerController as a value. */
@property (strong, nonatomic) NSMutableDictionary *videoViews;

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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPlayVideo" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GLPPauseVideo" object:nil];
}

#pragma mark - Configuration

-(void)initialiseObjects
{
    _videoViews = [[NSMutableDictionary alloc] init];
}

-(void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideo:) name:@"GLPPlayVideo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseVideo:) name:@"GLPPauseVideo" object:nil];

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

-(void)playVideo:(NSNotification *)notification
{
    DDLogDebug(@"playVideo: %@", notification);
    
    NSDictionary *notificationDict = notification.userInfo;
    
    NSNumber *remoteKey = [notificationDict objectForKey:@"RemoteKey"];
    
    [self playVideoWithRemoteKey:remoteKey];
    
}

-(void)pauseVideo:(NSNotification *)notification
{
    DDLogDebug(@"pauseVideo: %@", notification);

    NSDictionary *notificationDict = notification.userInfo;
    
    NSNumber *remoteKey = [notificationDict objectForKey:@"RemoteKey"];
    
    [self pauseVideoWithRemoteKey:remoteKey];
}

#pragma mark - Video actions

-(void)playVideoWithRemoteKey:(NSNumber *)remoteKey
{
    PBJVideoPlayerController *video = [_videoViews objectForKey:remoteKey];
    [video playFromCurrentTime];
}

-(void)pauseVideoWithRemoteKey:(NSNumber *)remoteKey
{
    PBJVideoPlayerController *video = [_videoViews objectForKey:remoteKey];
    [video pause];
}

-(void)addVideos:(NSArray *)posts
{
    NSArray *videoPosts = [self videoPostsWithPosts:posts];
    
    for(GLPPost *p in videoPosts)
    {
        [self addVideoWithUrl:p.videosUrls[0] andPostRemoteKey:p.remoteKey];
    }
}

- (void)addVideoWithUrl:(NSString *)videoUrl andPostRemoteKey:(NSInteger)remoteKey
{
//    DDLogDebug(@"GLPVideoLoaderManager : In addVideoWithUrl");
    
    PBJVideoPlayerController *foundVideoViewController = [self videoWithPostRemoteKey:remoteKey];
    
    if(foundVideoViewController)
    {
        //Already in the list.
//        DDLogDebug(@"Found video view controller already in list!");
        
//        return foundVideoViewController;
    }
    else
    {
        PBJVideoPlayerController *videoViewController = [[PBJVideoPlayerController alloc] init];
        [videoViewController setPlaybackLoops:NO];
        [videoViewController setVideoPath:videoUrl];
        [videoViewController.view setBounds:CGRectMake(0, 0, 298, 298)];
        
//        DDLogDebug(@"Video not found but ready: %@", videoUrl);
        
        [_videoViews setObject:videoViewController forKey:[NSNumber numberWithInteger:remoteKey]];
        
//        return nil;
    }

}

-(PBJVideoPlayerController *)videoWithPostRemoteKey:(NSInteger)remoteKey
{
    return [_videoViews objectForKey:[NSNumber numberWithInteger:remoteKey]];
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
