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

@interface GLPVideoViewController ()

@property (weak, nonatomic) IBOutlet VideoCaptureView *videoView;

@property (weak, nonatomic) IBOutlet VideoPreviewView *videoPreviewView;


@property (weak, nonatomic) IBOutlet UIView *cameraView;

@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (strong, nonatomic) PBJVideoPlayerController *previewVC;

@property (strong, nonatomic) IBOutlet VideoProgressView *progressView;

@property (assign, nonatomic) BOOL recording;

@property (weak, nonatomic) IBOutlet UILabel *titleLable;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *longPressGestureRecognizer;

@property (weak, nonatomic) IBOutlet UIButton *continueBarButton;

@end

@implementation GLPVideoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNofications];
  
    [self setUpCameraObjects];
    
    [self setUpPreviewView];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self removeObservers];
    
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
}

-(void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_DISMISS_VIDEO_VC object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CONTINUE_TO_PREVIEW object:nil];
}

/**
 This method is called in this main video view controller because there was 
 a problem when I was trying to include it in the view class.
 */
-(void)setUpCameraObjects
{
    _longPressGestureRecognizer.enabled = YES;
    [_longPressGestureRecognizer setDelegate:self];
    
    _recording = NO;
    
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
    _previewVC = [[PBJVideoPlayerController alloc] init];
    _previewVC.delegate = _videoPreviewView;
    _previewVC.view.frame = _previewView.bounds;
    [_previewView addSubview:_previewVC.view];
}

#pragma mark - Preview view

-(void)previewTheVideoWithPath:(NSString *)path
{
    _previewVC.videoPath = path;
    [_previewVC playFromBeginning];
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
    
    
    DDLogInfo(@"Video ready for preview with path: %@", path);
    
    [self previewTheVideoWithPath:path];
    
    [_videoView setHidden:YES];
    [_videoPreviewView setHidden:NO];
}

-(void)showCurrentSecondToTitleText:(NSNotification *)sender
{
    NSDictionary *dict = sender.userInfo;
    
    NSNumber *seconds = [dict objectForKey:@"seconds"];
    
    [_titleLable setText:[NSString stringWithFormat:@"%ld", (long)seconds.integerValue]];
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
