//
//  GLPProgressManager.m
//  Gleepost
//
//  Created by Σιλουανός on 22/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This manager is responsible for receiving the progress of the uploading element
//  (Video or Image), calculate the percentage and send it to GLPTimelineViewController.
//
//

#import "GLPProgressManager.h"
#import "UploadingProgressView.h"

@interface GLPProgressManager ()

//@property (strong, nonatomic) NSMutableArray *videosTimestamps;
@property (strong, nonatomic) NSDate *currentProcessed;
@property (strong, nonatomic) UploadingProgressView *progressView;
@property (assign, nonatomic) BOOL postClicked;
@property (assign, nonatomic, getter = isProgressViewVisible) BOOL progressViewVisible;
@end

@implementation GLPProgressManager

const NSString *DATA_WRITTEN = @"data_written";
const NSString *DATA_EXPECTED = @"data_expected";

static GLPProgressManager *instance = nil;

+ (GLPProgressManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPProgressManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        [self configureNotifications];
        [self configureProgressView];
        [self configureObjects];
    }
    
    return self;
}

- (void)configureObjects
{
//    _videosTimestamps = [[NSMutableArray alloc] init];
    _currentProcessed = nil;
    
//    _progressView = [[ProgressView alloc] init];
    [_progressView setHidden:YES];
    
    _postClicked = NO;

    _progressViewVisible = NO;
}

- (void)configureProgressView
{
    UploadingProgressView *view = [[[NSBundle mainBundle] loadNibNamed:@"UploadingProgressView" owner:self options:nil] objectAtIndex:0];
    
    [view setFrame:view.frame];

    //    [ShapeFormatterHelper setBorderToView:view withColour:[UIColor redColor] andWidth:1.0];
    CGRectSetY(view, 45);
    
    _progressView = view;
}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoProgress:) name:GLPNOTIFICATION_VIDEO_PROGRESS_UPDATE object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_VIDEO_PROGRESS_UPDATE object:nil];
}

- (void)showProgressView
{
    DDLogDebug(@"GLPProgressManager : showProgressView");
    
    [_progressView setHidden:NO];
    
    _progressViewVisible = YES;
}

- (void)hideProgressView
{
    DDLogDebug(@"GLPProgressManager : hideProgressView");

    [_progressView setHidden:YES];
    
    [_progressView resetView];
    
    _currentProcessed = nil;
    
    _postClicked = NO;
    
    _progressViewVisible = NO;

}

#pragma mark - Accessors

- (void)registerVideoWithTimestamp:(NSDate *)timestamp
{
//    [_videosTimestamps addObject:timestamp];
    
//    if(!_currentProcessed)
//    {
//        _currentProcessed = timestamp;
//    }
}

- (void)setThumbnailImage:(UIImage *)thumbnail
{

    [_progressView setThumbnailImage:[UIImage imageWithCGImage:thumbnail.CGImage]];
    
    DDLogDebug(@"GLPProgressManager : setThumbnailImage");

}

- (void)progressFinished
{
    DDLogDebug(@"GLPProgressManager : progressFinished");

    [self hideProgressView];
}

- (void)postButtonClicked
{
    DDLogDebug(@"GLPProgressManager : postButtonClicked");

    _postClicked = YES;
}

#pragma mark - Notification methods

- (void)videoProgress:(NSNotification *)notification
{
    if(_postClicked)
    {
        [self showProgressView];
    }
    else
    {
        [self hideProgressView];
    }
    
    NSDictionary *videoData = notification.userInfo;
    
    NSDictionary *progress = videoData[@"Update"];
    
    NSNumber *dataWritten = progress[DATA_WRITTEN];
    
    NSNumber *dataExpected = progress[DATA_EXPECTED];
        
    if([dataExpected isEqualToNumber:dataWritten])
    {
        [_progressView startProcessing];
    }
    else
    {
        [_progressView updateProgressWithValue:(dataWritten.floatValue/dataExpected.floatValue)];
    }
}


@end
