//
//  VideoCaptureView.m
//  Gleepost
//
//  Created by Silouanos on 13/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "VideoCaptureView.h"
#import "VideoProgressView.h"
#import "AppearanceHelper.h"
#import "GLPProgressManager.h"
#import <AssetsLibrary/ALAsset.h>

@interface VideoCaptureView ()

@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (weak, nonatomic) IBOutlet UIButton *continueBarButton;

@property (weak, nonatomic) IBOutlet UIView *cameraView;

@property (strong, nonatomic) IBOutlet VideoProgressView *progressView;

@property (assign, nonatomic) BOOL recording;

@property (weak, nonatomic) IBOutlet UILabel *titleLable;

@end

@implementation VideoCaptureView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self configureNofications];
        [[PBJVision sharedInstance] setThumbnailEnabled:YES];
    }
    
    return self;
}

-(void)dealloc
{
    [self removeObservers];
}

-(void)configureNofications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoIsReady:) name:GLPNOTIFICATION_CAMERA_LIMIT_REACHED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProcessButton:) name:GLPNOTIFICATION_CAMERA_THRESHOLD_REACHED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCurrentSecondToTitleText:) name:GLPNOTIFICATION_SECONDS_TEXT_TITLE object:nil];
}

-(void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CAMERA_LIMIT_REACHED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CAMERA_THRESHOLD_REACHED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_SECONDS_TEXT_TITLE object:nil];
    
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
    
//    [self stopVideo];
    
//    NSArray *thumbnails = videoDict[PBJVisionVideoThumbnailArrayKey];
    
    UIImage *thumbnail = videoDict[PBJVisionVideoThumbnailKey];
    
    //Add thumbnail to GLPProgressManager.
    [[GLPProgressManager sharedInstance] setThumbnailImage: thumbnail];
    
    
    NSString *videoPath = [videoDict objectForKey:PBJVisionVideoPathKey];
    [self notifyMainVCVideoIsReadyWithVideoPath:videoPath];

    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    
    
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:videoPath] completionBlock:^(NSURL *assetURL, NSError *error1) {

    }];
}

/**
 This method is called the following cases:
 1) The user decide to finish the video.
 2) The time expired and VideoProgressView sends notification to stop.
 
 @param sender the button or the notification.
 
 */
- (IBAction)videoIsReady:(id)sender
{
    [self stopVideo];
}

-(IBAction)goBackToNewPostViewController:(id)sender
{
    [self notifyMainVCDismissVC];
}


-(void)notifyMainVCVideoIsReadyWithVideoPath:(NSString *)path
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CONTINUE_TO_PREVIEW object:nil userInfo:@{@"path": path}];
}

-(void)notifyMainVCDismissVC
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_DISMISS_VIDEO_VC object:nil];

}

/**
 This method is called in order to enable the option to the user
 stop and save the recording.
 */
-(void)showProcessButton:(id)sender
{
    [_continueBarButton setHidden:NO];
}

-(void)stopVideo
{
    [[PBJVision sharedInstance] endVideoCapture];
    [_progressView stopProgress];
    [self showPreviewNavigationBar];
    _recording = NO;
}

#pragma mark - Title

-(void)showPreviewNavigationBar
{
    [_continueBarButton setHidden:YES];
    [_titleLable setText:@"New Video"];
}

-(void)showCurrentSecondToTitleText:(NSNotification *)sender
{
    NSDictionary *dict = sender.userInfo;
    
    NSNumber *seconds = [dict objectForKey:@"seconds"];
    
    [_titleLable setText:[NSString stringWithFormat:@"%ld", (long)seconds.integerValue]];
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
