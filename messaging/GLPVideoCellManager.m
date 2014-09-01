//
//  GLPVideoCellManager.m
//  Gleepost
//
//  Created by Σιλουανός on 26/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class should be in a queue in GLPVideoLoaderManager. Each instance of this class
//  is managing each VISIBLE VIDEO table view cell.
//

#import "GLPVideoCellManager.h"
#import "NSNotificationCenter+Utils.h"

@interface GLPVideoCellManager ()

@property (strong, nonatomic) PBJVideoPlayerController *videoPlayer;

@property (strong, nonatomic) NSNumber *remoteKey;

@property (assign, nonatomic) BOOL containsAsset;

@end

@implementation GLPVideoCellManager

- (id)initWithAsset:(AVURLAsset *)asset andRemoteKey:(NSInteger)remoteKey
{
    self = [super init];
    
    if(self)
    {
        _remoteKey = @(remoteKey);
        _videoPlayer = [[PBJVideoPlayerController alloc] init];
        [_videoPlayer setDelegate:self];
        [_videoPlayer setVideoAsset:asset];
        _videoPlayer.view.frame = CGRectMake(0.0, 0.0, 298.0, 305.0);
        
        _containsAsset = YES;
        
        [self registerNotifications];

//        [_videoView addSubview:_previewVC.view];

//        [_videoPlayer playFromBeginning];
    }
    
    return self;
}

- (id)initWithRemoteKey:(NSInteger)remoteKey
{
    self = [super init];
    
    if(self)
    {
        _remoteKey = @(remoteKey);
        _videoPlayer = [[PBJVideoPlayerController alloc] init];
        [_videoPlayer setDelegate:self];
        
        _containsAsset = NO;
        
        [self registerNotifications];
    }
    
    return self;
}

- (void)registerNotifications
{

}

- (BOOL)containsAsset
{
    return _containsAsset;
}

- (void)setAsset:(AVURLAsset *)asset
{
    if(asset)
    {
        _containsAsset = YES;
        [_videoPlayer setVideoAsset:asset];
        _videoPlayer.view.frame = CGRectMake(0.0, 0.0, 298.0, 305.0);
    }
    else
    {
        DDLogError(@"Asset should not be nil");
    }
}

#pragma mark - PBJVideoPlayerControllerDelegate

- (void)readyToPlay:(BOOL)ready withPlayerController:(PBJVideoPlayerController *)videoPlayer
{
    if(videoPlayer.playbackState != PBJVideoPlayerPlaybackStatePlaying && videoPlayer.playbackState != PBJVideoPlayerPlaybackStatePaused)
    {
        DDLogDebug(@"GLPVideoCellManager : ready to play with remote key: %@ - %@", _remoteKey, videoPlayer);
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_VIDEO_LOADED object:self];

    }
    
}

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    DDLogDebug(@"GLPVideoCellManager : videoPlayerReady");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_VIDEO_READY object:self userInfo:@{_remoteKey: videoPlayer}];

}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    DDLogDebug(@"GLPVideoCellManager : videoPlayerPlaybackStateDidChange");

}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
    DDLogDebug(@"GLPVideoCellManager : videoPlayerPlaybackWillStartFromBeginning");

}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    DDLogDebug(@"GLPVideoCellManager : videoPlayerPlaybackDidEnd");

}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Video player status: %d, Remote Key: %@", _videoPlayer.playbackState, _remoteKey];
}

- (void)dealloc
{
    DDLogDebug(@"GLPVideoCellManager : dealloc");
    _videoPlayer = nil;
}

@end
