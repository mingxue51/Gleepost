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

@interface GLPVideoViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *longPressGestureRecognizer;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *continueBarButton;

@property (weak, nonatomic) IBOutlet UIView *cameraView;

@property (strong, nonatomic) IBOutlet VideoProgressView *progressView;

@property (assign, nonatomic) BOOL recording;

@end

@implementation GLPVideoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initialiseObjects];
    
    [self configureNofications];
    
    [self configureNavigationBar];
    
    [self configureProgressBar];
    
    [self setUpCamperaObjects];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self removeObservers];
}

-(void)configureNofications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoIsReady:) name:GLPNOTIFICATION_CAMERA_LIMIT_REACHED object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProcessButton:) name:GLPNOTIFICATION_CAMERA_THRESHOLD_REACHED object:nil];
}

-(void)initialiseObjects
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CAMERA_LIMIT_REACHED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CAMERA_THRESHOLD_REACHED object:nil];
}

-(void)configureProgressBar
{
    
}

-(void)configureNavigationBar
{
    [AppearanceHelper setNavigationBarFontForNavigationBar:_navigationBar];
}

-(void)removeObservers
{
    
}

-(void)setUpCamperaObjects
{
    _longPressGestureRecognizer.enabled = YES;
    [_longPressGestureRecognizer setDelegate:self];
    
    _recording = NO;
    
    PBJVision *vision = [PBJVision sharedInstance];
//    CMTime maximumTime = CMTimeMake(MAXIMUM_DURATION, 1);
//    maximumTime.epoch = 0;
//    maximumTime.flags = kCMTimeFlags_Valid;
    vision.delegate = self;
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

- (IBAction)handleLongPressedGesture:(id)sender
{
    switch (_longPressGestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            if (!_recording)
            {
                [[PBJVision sharedInstance] startVideoCapture];
                _recording = YES;
            }
            else
            {
                [[PBJVision sharedInstance] resumeVideoCapture];
            }
            
            [_progressView startProgress];
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [[PBJVision sharedInstance] pauseVideoCapture];
            [_progressView pauseProgress];
            break;
        }
        default:
            break;
    }
}
- (IBAction)changeCamera:(id)sender
{
    PBJVision *vision = [PBJVision sharedInstance];

    PBJCameraDevice cameraType;
    
    if(vision.cameraDevice == PBJCameraDeviceFront)
    {
        cameraType = PBJCameraDeviceBack;
    }
    else
    {
        cameraType = PBJCameraDeviceFront;
    }
    
    
    [vision setCameraDevice:cameraType];
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    DDLogDebug(@"Error: %@, Video Dict: %@", error, videoDict);
    
    [_progressView stopProgress];
    
    NSString *videoPath = [videoDict objectForKey:PBJVisionVideoPathKey];
    
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];

    
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:videoPath] completionBlock:^(NSURL *assetURL, NSError *error1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Saved!" message: @"Saved to the camera roll."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }];
}

- (IBAction)videoIsReady:(id)sender
{
    [[PBJVision sharedInstance] endVideoCapture];
    [_progressView stopProgress];
}


- (IBAction)dismissModalView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
       
    }];
}

/**
 This method is called in order to enable the option to the user
 stop ther recording.
 */
-(void)showProcessButton:(id)sender
{
    [_continueBarButton setEnabled:YES];
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
