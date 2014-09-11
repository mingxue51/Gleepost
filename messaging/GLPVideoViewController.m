//
//  GLPVideoViewController.m
//  Gleepost
//
//  Created by Silouanos on 12/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  Imprortant notes:
//  We are not using set setMaximumCaptureDuration method because does not work as expected. (See more on the code of the library).
//  The altearnative methodology is to have a timer in the VideoProgressView and take care of that. When the video reach the
//  maximum seconds, sends notification to that object and stop the current camera session.

#import "GLPVideoViewController.h"
#import "AppearanceHelper.h"
#import <AssetsLibrary/ALAsset.h>
#import "VideoProgressView.h"
#import "VideoCaptureView.h"
#import "VideoPreviewView.h"
#import "ShapeFormatterHelper.h"
#import "GLPVideoLoaderManager.h"

@interface GLPVideoViewController ()

@property (weak, nonatomic) IBOutlet VideoCaptureView *videoView;

@property (weak, nonatomic) IBOutlet VideoPreviewView *videoPreviewView;

@property (weak, nonatomic) IBOutlet UIView *cameraView;

@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (strong, nonatomic) PBJVideoPlayerController *previewVC;

@property (weak, nonatomic) IBOutlet UIImageView *touchToPauseImageView;

@property (weak, nonatomic) IBOutlet UIImageView *touchToPlayImageView;

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

@property (strong, nonatomic) NSString *videoPath;

@end

@implementation GLPVideoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNofications];
  
    [self setUpCameraObjects];
    
    [self setUpPreviewView];
    
    [self configureNavigationBar];
    
    [self configureGestures];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self removeObservers];
    
    [[PBJVision sharedInstance] stopPreview];
    
    [PBJVision resetInstance];
    
    [super viewDidDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];

    [super viewWillDisappear:animated];
}

#pragma mark - Configuration

-(void)configureNofications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissModalView:) name:GLPNOTIFICATION_DISMISS_VIDEO_VC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoIsReady:) name:GLPNOTIFICATION_CONTINUE_TO_PREVIEW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCaptureView:) name:GLPNOTIFICATION_SHOW_CAPTURE_VIEW object:nil];

}

-(void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_DISMISS_VIDEO_VC object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CONTINUE_TO_PREVIEW object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_SHOW_CAPTURE_VIEW object:nil];

}

- (void)configureGestures
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPausePlayback:)];
    
    [_backImageView addGestureRecognizer:tapGesture];
}

-(void)configureNavigationBar
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

/**
 This method is called in this main video view controller because there was 
 a problem when I was trying to include it in the view class.
 */
-(void)setUpCameraObjects
{
    PBJVision *vision = [PBJVision sharedInstance];
//    CMTime maximumTime = CMTimeMake(MAXIMUM_DURATION, 1);
//    maximumTime.epoch = 0;
//    maximumTime.flags = kCMTimeFlags_Valid;
    vision.delegate = _videoView;
    [vision setCameraMode:PBJCameraModeVideo];
    [vision setCameraDevice:PBJCameraDeviceBack];
    [vision setCameraOrientation:PBJCameraOrientationPortrait];
    [vision setFocusMode:PBJFocusModeAutoFocus];
    [vision setPresentationFrame:self.cameraView.frame];
    [vision previewLayer].frame = self.cameraView.bounds;
    [vision previewLayer].videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.cameraView.layer addSublayer:[vision previewLayer]];
    [vision startPreview];
    
}

-(void)setUpPreviewView
{
    DDLogDebug(@"PreviewView: %@, Preview VC: %@", _previewView, _previewVC);
    
    _previewVC = [[PBJVideoPlayerController alloc] init];
    _previewVC.delegate = self;
    [_previewVC setPlaybackLoops:YES];
    _previewVC.view.frame = _previewView.bounds;
    [_previewView addSubview:_previewVC.view];
}

#pragma mark - Preview view

-(void)previewTheVideoWithPath:(NSString *)path
{
    //Example url: http://km.support.apple.com/library/APPLE/APPLECARE_ALLGEOS/HT1211/sample_iTunes.mov
    
    for(UIView *v in _previewView.subviews)
    {
        DDLogDebug(@"V: %@", v);
    }
    
    DDLogDebug(@"Path: %@, Preview VC: %@, Preview view: %@", path, _previewVC.view, _previewView);
    
    [_previewVC setVideoPath:path];
    
    
    [_previewVC playFromBeginning];
}

#pragma mark - PBJVideoPlayerControllerDelegate

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    DDLogDebug(@"videoPlayerReady : state: %d", videoPlayer.playbackState);
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    if(videoPlayer.playbackState == PBJVideoPlayerPlaybackStateFailed)
    {
        DDLogDebug(@"videoPlayerPlaybackStateDidChange Play Again");
//        [[GLPVideoLoaderManager sharedInstance] releaseVideo];
        
        
        [videoPlayer setVideoPath:_videoPath];
    }
    
    if(_previewVC.playbackState == PBJVideoPlayerPlaybackStatePlaying)
    {
        [self playVideo];
    }
    else if (_previewVC.playbackState == PBJVideoPlayerPlaybackStatePaused || _previewVC.playbackState == PBJVideoPlayerPlaybackStateStopped)
    {
        [self pauseVideo];
    }
    
    
    DDLogDebug(@"videoPlayerPlaybackStateDidChange : state: %d", videoPlayer.playbackState);

}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
    DDLogDebug(@"videoPlayerPlaybackWillStartFromBeginning : state: %d", videoPlayer.playbackState);

}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    DDLogDebug(@"videoPlayerPlaybackDidEnd : state: %d", videoPlayer.playbackState);

}

- (void)playVideo
{
    [_touchToPauseImageView setHidden:NO];
    [_touchToPlayImageView setHidden:YES];
}

- (void)pauseVideo
{
    [_touchToPauseImageView setHidden:YES];
    [_touchToPlayImageView setHidden:NO];
}

#pragma mark - Notifications

/**
 This method is called when the user finished the capture.
 This method hides the VideoCaptureView and shows the VideoPreviewView.
 */
- (void)videoIsReady:(NSNotification *)notification
{
//    [[PBJVision sharedInstance] endVideoCapture];
//    [_progressView stopProgress];
    NSDictionary *dict = notification.userInfo;
    
    NSString *path = [dict objectForKey:@"path"];
    
    _videoPath = path;
    
    DDLogInfo(@"Video ready for preview with path: %@", path);
    
    [self previewTheVideoWithPath:path];
    
    [self showPreviewView];
}

-(void)showCaptureView:(NSNotification *)notification
{
//    [self setUpCameraObjects];
    if([[PBJVision sharedInstance] isCaptureSessionActive])
    {
        DDLogDebug(@"Capture session active.");
    }
    else
    {
        DDLogDebug(@"Capture session not active.");
    }
    
    [_previewVC stop];
    
    [self showCaptureView];
}

#pragma mark - Selectors

- (void)playPausePlayback:(id)sender
{
    if(_previewVC.playbackState == PBJVideoPlayerPlaybackStatePlaying)
    {
        [_previewVC pause];
//        [self pauseVideo];
    }
    else if (_previewVC.playbackState == PBJVideoPlayerPlaybackStatePaused || _previewVC.playbackState == PBJVideoPlayerPlaybackStateStopped)
    {
        [_previewVC playFromCurrentTime];
//        [self playVideo];
    }
}

- (void)dismissModalView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
       
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI methods

-(void)showPreviewView
{
    [_videoView setHidden:YES];
    [_videoPreviewView setHidden:NO];
    
}

-(void)showCaptureView
{
    [_videoPreviewView setHidden:YES];
    [_videoView setHidden:NO];
}

-(IBAction)saveVideo:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
       
        [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_RECEIVE_VIDEO_PATH object:nil userInfo:@{@"video path": _videoPath}];
        
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
