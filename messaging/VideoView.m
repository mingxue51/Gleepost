//
//  VideoView.m
//  Gleepost
//
//  Created by Silouanos on 15/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//  This class is used to manage preview of video in PostCell.

#import "VideoView.h"
#import "ShapeFormatterHelper.h"

@interface VideoView ()

@property (strong, nonatomic) PBJVideoPlayerController *previewVC;
@property (strong, nonatomic) NSString *url;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *videoView;
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
    _previewVC = [[PBJVideoPlayerController alloc] init];
    _previewVC.delegate = self;
}

-(void)setUpPreviewWithUrl:(NSString *)url
{
    _url = url;
    [_previewVC setPlaybackLoops:NO];
    _previewVC.view.frame = _videoView.bounds;
    [_videoView addSubview:_previewVC.view];
    
}

-(IBAction)video:(id)sender
{
    _previewVC.videoPath = _url;
    [_previewVC playFromBeginning];
}

#pragma mark - Animation

-(void)setHiddenToPlayButton:(BOOL)hidden
{
    [UIView animateWithDuration:1.0f animations:^{
        
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
        [self setHiddenToPlayButton:NO];
    }
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
    [self setHiddenToPlayButton:YES];
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    [self setHiddenToPlayButton:NO];
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
