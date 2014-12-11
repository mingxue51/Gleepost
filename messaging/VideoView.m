//
//  VideoView.m
//  Gleepost
//
//  Created by Silouanos on 15/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//  This class is used to manage preview of video in PostCell.
//  For different implementation of this calss find more on video branch.

#import "VideoView.h"
#import "GLPVideoLoaderManager.h"
#import "ShapeFormatterHelper.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "GLPPost.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "GLPVideo.h"

@interface VideoView ()

//@property (strong, nonatomic) PBJVideoPlayerController *previewVC;
//@property (strong, nonatomic) MPMoviePlayerController *moviewPlayer;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicatorView;
@property (assign, nonatomic) NSInteger remoteKey;
@property (strong, nonatomic) PBJVideoPlayerController *previewVC;

@property (assign, nonatomic) BOOL registeredNotifications;

//@property (assign, nonatomic, getter = hasVideoStarted) BOOL videoStarted;

@property (strong, nonatomic) GLPPost *post;


//@property (strong, nonatomic) GLPVideo *videoData;

@end

@implementation VideoView


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self initialiseObjects];
    }
    
    return self;
}

-(void)initialiseObjects
{
//    _previewVC = [[PBJVideoPlayerController alloc] init];
//    _previewVC.delegate = self;
    
//    _temporaryThumbnailUrl = @"https://cdn-assets-hall-com.s3.amazonaws.com/production/private/halls/531a19171d16bead700004e8/user_uploaded_files/default_thumbnail.png?AWSAccessKeyId=17VVCSSS3H6YGDY9H3G2&Expires=1403044633&Signature=sZMzPWs503329REQDCEbgKQQmic%3D&response-content-type=image%2Fpng";
    
    
}


-(void)setUpVideoViewWithPost:(GLPPost *)post
{
    if(ON_DEVICE)
    {
        _remoteKey = post.remoteKey;
        
        _post = post;
        
        [self loadThumbnail];
        
        [self registerNotifications];
        
        [self showLoadingElements];

        PBJVideoPlayerController *p = [[GLPVideoLoaderManager sharedInstance] setVideoWithPost:_post];
        
        if(p)
        {
            _previewVC = p;
            
            [NSThread detachNewThreadSelector:@selector(videoLoadedWithPBJVideoVC) toTarget:self withObject:nil];
        }
    }

}

- (void)dealloc
{
    DDLogDebug(@"DEALLOC: %@", _post.content);
    
    [self deregisterNotifications];
}


- (void)videoLoadedWithPBJVideoVC
{
    
//    NSDictionary *d = notification.userInfo;
//    
//    PBJVideoPlayerController *videoPlayer =  d[@(_remoteKey)];
    
    
    DDLogDebug(@"Set up video controller: %@ : %d : %@", _previewVC, _previewVC.bufferingState, _post.content);
    
    if(_previewVC)
    {
        if([_previewVC isVideoLoaded])
        {
            DDLogDebug(@"VIDEO LOADED!!!");
        }
        
//        _previewVC = videoPlayer;
        
        _previewVC.view.frame = _videoView.bounds;

        
        _previewVC.view.tag = _remoteKey;
        
        _previewVC.delegate = self;
        
        
//        [_videoView addSubview:_previewVC.view];
        [_videoView setTag:1];

        
        [self configurePlaybackElementsWithPreviewVC:_previewVC];
    }
}

#pragma mark - Nofications

- (void)videoLoadedFromNotification:(NSNotification *)notification
{
    
    NSDictionary *d = notification.userInfo;
    
    PBJVideoPlayerController *videoPlayer =  d[@(_remoteKey)];
    
    if(_previewVC)
    {
        DDLogDebug(@"Video view contains previewVC: %@ : %d : %@", _previewVC, _previewVC.bufferingState, _post.content);
        
        return;
    }
    
    _previewVC = videoPlayer;
    
    DDLogDebug(@"Video loaded from notification: %@ : %@", _previewVC, _post.content);
    
    if(_previewVC)
    {
        if([_previewVC isVideoLoaded])
        {
            DDLogDebug(@"VIDEO LOADED!!!");
        }
        
        _previewVC.view.frame = _videoView.bounds;

        _previewVC.view.tag = _remoteKey;
        
        _previewVC.delegate = self;
        
        
        [_videoView setTag:1];
        
//        [_videoView addSubview:_previewVC.view];
        
        [self configurePlaybackElementsWithPreviewVC:_previewVC];
        
    }
}

- (void)addFinalVideoView
{
    if(_videoView.tag == 2)
        return;
    
    [_videoView setHidden:NO];
    
    DDLogDebug(@"Set subview for post: %@", _post.content);
    
    [_videoView addSubview:_previewVC.view];
    
    [_videoView setTag:2];

}

- (void)registerNotifications
{
    if(_previewVC)
    {
        DDLogDebug(@"Abort registering notifications for post: %@", _post.content);
        
        return;
    }
    
    DDLogDebug(@"Register notifications for post: %@ RegNotVar: %d", _post.content, _registeredNotifications);
    
    _registeredNotifications = YES;


    NSString *notificationName = [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_VIDEO_READY, (long)_post.remoteKey];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoLoadedFromNotification:) name:notificationName object:nil];
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoLoaded) name:GLPNOTIFICATION_VIDEO_LOADED object:nil];
}

- (void)deregisterNotifications
{
    DDLogDebug(@"Deregister Notifications: %@ RegNotVar: %d", _post.content, _registeredNotifications);
    
    _registeredNotifications = NO;
    _previewVC = nil;
    NSString *notificationName = [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_VIDEO_READY, (long)_post.remoteKey];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
}

- (void)videoLoaded
{
    DDLogDebug(@"videoLoaded: %@", _post.content);
    
//    [self setHiddenLoader:YES];
}


- (void)configurePlaybackElementsWithPreviewVC:(PBJVideoPlayerController *)previewVC
{
    if([previewVC isVideoLoaded])
    {
        [self hideLoadingElements];
        [self configurePlaybackWithStatus:previewVC.playbackState];
    }
    else
    {
        [self showLoadingElements];
    }
}

#pragma mark - Video operations

-(void)playVideo
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPPlayVideo" object:self userInfo:@{@"RemoteKey": [NSNumber numberWithInteger:_remoteKey]}
//     ];
    
//    [_previewVC playFromBeginning];
    [_previewVC playFromCurrentTime];
}

-(void)pauseVideo
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPPauseVideo" object:self userInfo:@{@"RemoteKey": [NSNumber numberWithInteger:_remoteKey]}
//     ];
    
    [_previewVC pause];
}

-(IBAction)video:(id)sender
{
    if(![_previewVC isVideoLoaded])
    {
        return;
    }
    
    if(_playButton.tag == 0)
    {
        [self setHiddenToPlayImage:YES];
        [self setHiddenThumbnail:YES];
        [self playVideo];
    }
    else
    {
        [self setHiddenToPlayImage:NO];
        [self pauseVideo];
    }
}

- (void)loadThumbnail
{
//    [_thumbnailImageView setImageWithURL:[NSURL URLWithString: _post.video.thumbnailUrl] placeholderImage:nil options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    //TODO: Load image from cache.

    DDLogDebug(@"Thumbnail view hidden: %d, Post content: %@, Url: %@", [_thumbnailImageView isHidden], _post.content, _post.video.thumbnailUrl);
    
    
    [_thumbnailImageView sd_setImageWithURL:[NSURL URLWithString: _post.video.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"default_thumbnail"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        DDLogDebug(@"Video image loaded with post %@ : %@ Cache type: %d", _post.content, image, cacheType);

        
    }];
}

#pragma mark - Animation

-(void)setHiddenToPlayImage:(BOOL)hidden
{
    _playButton.tag = (hidden) ? 1 : 0;
    
    [UIView animateWithDuration:0.3f animations:^{
        
        [self.playImageView setHidden:hidden];
        
    } completion:^(BOOL finished) {
        
        
    }];
}

- (void)setHiddenLoader:(BOOL)hidden
{
    if(hidden)
    {
        [_loadingIndicatorView stopAnimating];

        [self setHiddenToPlayImage:NO];
    }
    else
    {
        [_loadingIndicatorView setHidden:NO];
        [_loadingIndicatorView startAnimating];

        [self setHiddenToPlayImage:YES];
    }
}

- (void)showLoadingElements
{
    [_loadingIndicatorView setHidden:NO];
    [_loadingIndicatorView startAnimating];
    [self setHiddenToPlayImage:YES];
    [_videoView setHidden:YES];

//    [_playButton setEnabled:NO];
}

- (void)hideLoadingElements
{
    [_loadingIndicatorView stopAnimating];

//    [_playButton setEnabled:YES];
}

- (void)setHiddenThumbnail:(BOOL)hidden
{
    if(hidden)
    {
        DDLogDebug(@"Thumbnail hidden for post: %@", _post.content);
    }
    
    [_thumbnailImageView setHidden:hidden];
}


/**
 This method change the status of each element in video view depending on the playback state.
 
 In more detail in each playback state are performed the following actions:
 PBJVideoPlayerPlaybackStateStopped : Thumbnail and play button are shown.
 PBJVideoPlayerPlaybackStatePlaying : Thumbnail and play button are hidden.
 PBJVideoPlayerPlaybackStatePaused  : Thumbnail hidden and play button shown.
 
 @param playbackState
 
 */
- (void)configurePlaybackWithStatus:(PBJVideoPlayerPlaybackState)playbackStatus
{
    switch (playbackStatus) {
        case PBJVideoPlayerPlaybackStateStopped:
            DDLogDebug(@"PBJVideoPlayerPlaybackStateStopped");
            [self setHiddenToPlayImage:NO];
            [self setHiddenThumbnail:NO];
            break;
            
        case PBJVideoPlayerPlaybackStatePlaying:
            DDLogDebug(@"PBJVideoPlayerPlaybackStatePlaying");
            [self setHiddenToPlayImage:YES];
            [self setHiddenThumbnail:YES];
            break;
            
            case PBJVideoPlayerPlaybackStatePaused:
            DDLogDebug(@"PBJVideoPlayerPlaybackStatePaused");
            [self setHiddenToPlayImage:NO];
            [self setHiddenThumbnail:YES];
            break;
            

            
        default:
            break;
    }
}

#pragma mark - PBJVideoPlayerControllerDelegate

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
//    [_videoView setHidden:NO];
}

- (void)readyToPlay:(BOOL)ready withPlayerController:(PBJVideoPlayerController *)videoPlayer
{
//    DDLogDebug(@"Play status: %d, Play tag: %d, Self play tag: %d : %@", _previewVC.playbackState, videoPlayer.view.tag, _previewVC.view.tag, _post.content);
    
    if(_previewVC.playbackState == PBJVideoPlayerPlaybackStatePlaying)
    {
        return;
    }
    
    
    
//    if(![videoPlayer.videoPath isEqualToString:_post.video.url])
//    {
//        
//        DDLogDebug(@"WRONG! Post ready to play: %@ : %d", _post.content, ready);
//        
//        return;
//    }
    
    DDLogDebug(@"Post ready to play: %@ : %d", _post.content, ready);
    
    if(ready)
    {
        [self addFinalVideoView];
    }
    
    //When the ready to play is YES it means that the video is fetched as a whole and is ready for playback.
    [self setHiddenLoader:ready];
//    [self configurePlaybackElementsWithPreviewVC:videoPlayer];
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    if(videoPlayer.playbackState == PBJVideoPlayerPlaybackStatePaused)
    {
        [self pauseVideo];
    }
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
//    [self setHiddenToPlayButton:YES];
    
    DDLogDebug(@"Video started from the beginning");
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    DDLogDebug(@"videoPlayerPlaybackDidEnd : %@", _post.content);

    [self endVideo];
}

#pragma mark - Playback operations

//-(void)pauseVideo
//{
//    [self setHiddenToPlayButton:NO];
//    [_playButton setTag:1];
//}

-(void)resumeVideo
{
//    [self setHiddenToPlayButton:YES];
    //[_previewVC playFromCurrentTime];
}

-(void)endVideo
{
//    [self setHiddenToPlayButton:NO];
//    [_playButton setTag:0];
    [self setHiddenToPlayImage:NO];
    [self setHiddenThumbnail:NO];
}

-(void)startVideoFromBeggining
{
//    [_previewVC setVideoPath:_url];
    //[_previewVC playFromBeginning];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
