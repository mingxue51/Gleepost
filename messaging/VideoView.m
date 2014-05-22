//
//  VideoView.m
//  Gleepost
//
//  Created by Silouanos on 15/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//  This class is used to manage preview of video in PostCell.

#import "VideoView.h"
#import "ShapeFormatterHelper.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoView ()

@property (strong, nonatomic) PBJVideoPlayerController *previewVC;
//@property (strong, nonatomic) MPMoviePlayerController *moviewPlayer;
@property (strong, nonatomic) NSString *url;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@end

@implementation VideoView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self initialiseObjects];
//        [self initVideo];
//        [self configureNotifications];
    }
    
    return self;
}

//-(void)initVideo
//{
//    _moviewPlayer = [[MPMoviePlayerController alloc] init];
//    
//    [_moviewPlayer prepareToPlay];
//    [_moviewPlayer.view setFrame: self.bounds];  // player's frame must match parent's
//    [self addSubview: _moviewPlayer.view];
//}

//-(void)initialisePreviewWithUrl:(NSString *)url
//{
//    
////    [_playButton setHidden:YES];
//    [_thumbnailImageView setImage:nil];
//    [self bringSubviewToFront:_thumbnailImageView];
//    [self bringSubviewToFront:_playButton];
//    
//    
//    
//    _moviewPlayer.contentURL = [NSURL URLWithString:url];
//    [_moviewPlayer requestThumbnailImagesAtTimes:@[[NSNumber numberWithFloat:1.0f]] timeOption:MPMovieTimeOptionExact];
//    
//}

-(void)initialiseObjects
{
    _previewVC = [[PBJVideoPlayerController alloc] init];
    _previewVC.delegate = self;
}

-(void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thumbnailReceived:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];
}

-(void)thumbnailReceived:(NSNotification *)notification
{
    DDLogDebug(@"Image: %@", notification.userInfo);
    
    NSDictionary *result = notification.userInfo;
    
    UIImage *thumbnail = [result objectForKey:@"MPMoviePlayerThumbnailImageKey"];
    
    [_thumbnailImageView setImage:thumbnail];
    
}



-(void)setUpPreviewWithUrl:(NSString *)url withRemoteKey:(NSInteger)remoteKey
{
    
//    if(_previewVC.playbackState == PBJVideoPlayerPlaybackStatePlaying)
//    {
//        [_videoView setHidden:YES];
//        [_previewVC stop];
//        [self endVideo];
//        [_previewVC setVideoPath:url];
//        [_previewVC resetVideo];
//    }
//    else
//    {
    
    [_videoView setAlpha:0.0f];

    
    _url = url;
    
    [_previewVC setPlaybackLoops:NO];
    
    

    if([self isPreviewViewInVideoViewWithRemoteKey:remoteKey])
    {
        DDLogDebug(@"Preview already exists");
    }
    else
    {

        
//        [_previewVC setVideoPath:_url];
    }
    
    [_previewVC.view removeFromSuperview];
    
    _previewVC.view.tag = remoteKey;
    _previewVC.view.frame = _videoView.bounds;
    [_videoView addSubview:_previewVC.view];
    
    [_previewVC setVideoPath:_url];




}

-(BOOL)isPreviewViewInVideoViewWithRemoteKey:(NSInteger)remoteKey
{
    for(UIView *view in _videoView.subviews)
    {
        if(view.tag == remoteKey)
        {
            return YES;
        }
    }
    
    return NO;
}

-(IBAction)video:(id)sender
{
//    [_moviewPlayer play];

    
    if(_playButton.tag == 0)
    {
        [self startVideoFromBeggining];
    }
    else
    {
        [self resumeVideo];
    }

}

#pragma mark - Animation

-(void)setHiddenToPlayButton:(BOOL)hidden
{
    [UIView animateWithDuration:0.3f animations:^{
        
        [self.playButton setAlpha:(hidden) ? 0.0f : 1.0f];
        
    } completion:^(BOOL finished) {
        
        
    }];
}

#pragma mark - PBJVideoPlayerControllerDelegate

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    

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
    [self setHiddenToPlayButton:YES];
    [_videoView setHidden:NO];
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    [self endVideo];
}

-(void)videoPlayerNewVideoReady:(PBJVideoPlayerController *)videoPlayer
{
    DDLogDebug(@"videoPlayerNewVideoReady");
    [_videoView setAlpha:1.0f];

}

#pragma mark - Playback operations

-(void)pauseVideo
{
    [self setHiddenToPlayButton:NO];
    [_playButton setTag:1];
}

-(void)resumeVideo
{
    [self setHiddenToPlayButton:YES];
    [_previewVC playFromCurrentTime];
}

-(void)endVideo
{
    [self setHiddenToPlayButton:NO];
    [_playButton setTag:0];
}

-(void)startVideoFromBeggining
{
//    [_previewVC setVideoPath:_url];
    [_previewVC playFromBeginning];
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
