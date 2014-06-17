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
@property (weak, nonatomic) IBOutlet UIImageView *loadingImageView;
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (assign, nonatomic) NSInteger remoteKey;

@property (strong, nonatomic) GLPPost *post;

@property (strong, nonatomic) NSString *temporaryThumbnailUrl;
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
    
    _temporaryThumbnailUrl = @"https://cdn-assets-hall-com.s3.amazonaws.com/production/private/halls/531a19171d16bead700004e8/user_uploaded_files/default_thumbnail.png?AWSAccessKeyId=17VVCSSS3H6YGDY9H3G2&Expires=1403044633&Signature=sZMzPWs503329REQDCEbgKQQmic%3D&response-content-type=image%2Fpng";
}


-(void)setUpVideoViewWithUrl:(NSString *)url withPost:(GLPPost *)post
{
    if(ON_DEVICE)
    {
        DDLogDebug(@"Video View : %@", post.content);
        
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
        
        [self loadThumbnail];
        
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
    [_thumbnailImageView setImageWithURL:[NSURL URLWithString:_temporaryThumbnailUrl]];
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

- (void)setHiddenThumbnail:(BOOL)hidden
{
    [_thumbnailImageView setHidden:hidden];
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
    [self setHiddenThumbnail:NO];
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
