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
@property (strong, nonatomic) MPMoviePlayerController *moviewPlayer;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *loadingImageView;
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (assign, nonatomic) NSInteger remoteKey;
@property (strong, nonatomic) PBJVideoPlayerController *previewVC;
@property (assign, nonatomic) NSInteger pRemoteKey;

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
        
        _pRemoteKey = 0;
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

        
        [[GLPVideoLoaderManager sharedInstance] addVideoWithUrl:_post.video.url andPostRemoteKey:_remoteKey];
        
        [[GLPVideoLoaderManager sharedInstance] videoWithPostRemoteKey:_remoteKey];
        
        
//        if(_pRemoteKey == _remoteKey)
//        {
//            DDLogDebug(@"PremoteKey: %ld", (long)_pRemoteKey);
//            
//            
//
//
//
//            return;
//        }
        
        if(_previewVC)
        {
            return;
        }
        
        _pRemoteKey = _remoteKey;
        
        DDLogDebug(@"PremoteKey after: %ld", (long)_pRemoteKey);
        
        [[GLPVideoLoaderManager sharedInstance] configureVideoPlayerControllerAndPostNotificationWithRemoteKey:@(_remoteKey) callbackBlock:^(NSNumber *remoteKey, PBJVideoPlayerController *player) {
           
            DDLogDebug(@"videoLoadedWithPBJVideoVC: %@ : %@", player, _post.content);

            
            if([remoteKey integerValue] == _remoteKey && player)
            {
                
                [NSThread detachNewThreadSelector:@selector(videoLoadedWithPBJVideoVC:) toTarget:self withObject:player];

                
//                _previewVC = player;
//                
//                _previewVC.view.tag = _remoteKey;
//                
//                _previewVC.delegate = self;
//                
//                _previewVC.view.frame = _videoView.bounds;
//                [_videoView addSubview:_previewVC.view];
//                
//                
//                [self configurePlaybackElementsWithPreviewVC:_previewVC];
            }
            
        }];
        
        if(!_previewVC)
        {
            DDLogInfo(@"Abord playing, wait to load.");
            
            return;
        }
        
        
        
        
        
//        _previewVC.view.tag = _remoteKey;
//                
//        _previewVC.delegate = self;
//        
//        _previewVC.view.frame = _videoView.bounds;
//        [_videoView addSubview:_previewVC.view];
//        
//        
//        [self configurePlaybackElementsWithPreviewVC:_previewVC];
        
    }

}

#pragma mark - Nofications

- (void)videoLoadedWithPBJVideoVC:(PBJVideoPlayerController *)videoPlayer
{
//    PBJVideoPlayerController *videoPlayer =  d[@(_remoteKey)];
    
    DDLogDebug(@"Set up video controller: %@ : %@", videoPlayer, _post.content);
    
    if(videoPlayer)
    {
        _previewVC = videoPlayer;
        
        _previewVC.view.tag = _remoteKey;
        
        _previewVC.delegate = self;
        
        _previewVC.view.frame = _videoView.bounds;
        [_videoView addSubview:_previewVC.view];
        
        
        [self configurePlaybackElementsWithPreviewVC:_previewVC];
    }
}

- (void)registerNotifications
{
//    DDLogDebug(@"Register notifications for post: %@", _post.content);
//
////    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoLoadedWithPBJVideoVC:) name:GLPNOTIFICATION_VIDEO_READY object:nil];
}

- (void)deregisterNotifications
{
    
    _previewVC = nil;
//    DDLogDebug(@"Deregister notifications for post: %@", _post.content);
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_VIDEO_READY object:nil];
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

- (void)checkIfVideoIsReady:(NSTimer *)timer
{
//    PBJVideoPlayerController *previewVC = [[GLPVideoLoaderManager sharedInstance] videoWithPostRemoteKey:_remoteKey];
 
//    for(;YES;)
//    {
    
        if([_previewVC isVideoLoaded])
        {
            DDLogDebug(@"VIDEO IS READY!");
            [self configurePlaybackElementsWithPreviewVC:_previewVC];
            [timer invalidate];
        }
        else
        {
            DDLogDebug(@"VIDEO IS NOT READY: %d", _previewVC.bufferingState);
        }
//    }
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
    
    [_thumbnailImageView setImageWithURL:[NSURL URLWithString: _post.video.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"default_thumbnail"] options:SDWebImageRetryFailed];

    
//    [_thumbnailImageView setImageWithURL:[NSURL URLWithString: _post.video.thumbnailUrl] placeholderImage:nil options:SDWebImageRetryFailed
//     
//        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//            
//            DDLogDebug(@"Video image loaded with post %@", _post.video.thumbnailUrl);
//            
////            [self hideLoadingElements];
//            
//            //TODO: Load image from cache like how we are doing that with images.
//
//            
//        }];
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
        [_loadingImageView setHidden:YES];
        [self setHiddenToPlayImage:NO];
    }
    else
    {
        [_loadingImageView setHidden:NO];
        [_loadingImageView setImageWithURL:nil placeholderImage:nil usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        [self setHiddenToPlayImage:YES];
    }
}

- (void)showLoadingElements
{
    [_loadingImageView setHidden:NO];
    [_loadingImageView setImageWithURL:nil placeholderImage:nil usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self setHiddenToPlayImage:YES];
//    [_playButton setEnabled:NO];
}

- (void)hideLoadingElements
{
    [_loadingImageView setHidden:YES];
//    [_playButton setEnabled:YES];
}

- (void)setHiddenThumbnail:(BOOL)hidden
{
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
    [_videoView setHidden:NO];
}

- (void)readyToPlay:(BOOL)ready withPlayerController:(PBJVideoPlayerController *)videoPlayer
{
    DDLogDebug(@"Post ready to play: %@ : %d", _post.content, ready);
    
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
