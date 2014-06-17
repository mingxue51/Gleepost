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


@interface VideoView ()

@property (strong, nonatomic) PBJVideoPlayerController *previewVC;
@property (strong, nonatomic) MPMoviePlayerController *moviewPlayer;
@property (strong, nonatomic) NSString *url;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (assign, nonatomic) NSInteger remoteKey;

@property (strong, nonatomic) GLPPost *post;

@end

@implementation VideoView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        //[self initialiseObjects];
    }
    
    return self;
}

-(void)initialiseObjects
{
    _previewVC = [[PBJVideoPlayerController alloc] init];
    _previewVC.delegate = self;
}


-(void)setUpVideoViewWithUrl:(NSString *)url withPost:(GLPPost *)post
{
    if(ON_DEVICE)
    {
        _remoteKey = post.remoteKey;
        _post = post;
        
        [[GLPVideoLoaderManager sharedInstance] addVideoWithUrl:url andPostRemoteKey:_remoteKey];
        
        PBJVideoPlayerController *previewVC = [[GLPVideoLoaderManager sharedInstance] videoWithPostRemoteKey:_remoteKey];
        
        NSAssert(previewVC != nil, @"previewVC needs to be not nil");
        
        previewVC.delegate = self;
        
        if(previewVC.playbackState == PBJVideoPlayerPlaybackStatePlaying)
        {
            [self setHiddenToPlayImage:YES];
        }
        else
        {
            [self setHiddenToPlayImage:NO];
        }
        
        
        previewVC.view.frame = _videoView.bounds;
        [_videoView addSubview:previewVC.view];
        
        
        [self setHiddenLoader:[previewVC isVideoLoaded]];
        
    }

}

#pragma mark - Video operations

-(void)playVideo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPPlayVideo" object:self userInfo:@{@"RemoteKey": [NSNumber numberWithInteger:_remoteKey]}
     ];
}

-(void)pauseVideo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPPauseVideo" object:self userInfo:@{@"RemoteKey": [NSNumber numberWithInteger:_remoteKey]}
     ];
}

-(IBAction)video:(id)sender
{
    if(_playButton.tag == 0)
    {
        [self setHiddenToPlayImage:YES];
        [self playVideo];
        
    }
    else
    {
        [self setHiddenToPlayImage:NO];
        [self pauseVideo];
    }
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
        [_thumbnailImageView setHidden:YES];
        [self setHiddenToPlayImage:NO];
    }
    else
    {
        [_thumbnailImageView setHidden:NO];
        [_thumbnailImageView setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"default_thumbnail"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        [self setHiddenToPlayImage:YES];
    }
}

#pragma mark - PBJVideoPlayerControllerDelegate

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    [_videoView setHidden:NO];
}

- (void)readyToPlay:(BOOL)ready
{
    DDLogDebug(@"Post ready to play: %@ : %d", _post.content, ready);
    [self setHiddenLoader:YES];
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    if(videoPlayer.playbackState == PBJVideoPlayerPlaybackStatePaused)
    {
        DDLogDebug(@"PBJVideoPlayerPlaybackStatePaused : %@", _post.content);

        [self pauseVideo];
    }
    else if(videoPlayer.playbackState == PBJVideoPlayerBufferingStateDelayed)
    {
        DDLogDebug(@"PBJVideoPlayerBufferingStateDelayed : %@", _post.content);
    }
    else if (videoPlayer.playbackState == PBJVideoPlayerPlaybackStateFailed)
    {
        DDLogDebug(@"PBJVideoPlayerPlaybackStateFailed : %@", _post.content);
    }
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
//    [self setHiddenToPlayButton:YES];
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
    [_previewVC playFromCurrentTime];
}

-(void)endVideo
{
//    [self setHiddenToPlayButton:NO];
//    [_playButton setTag:0];
    [self setHiddenToPlayImage:NO];
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
