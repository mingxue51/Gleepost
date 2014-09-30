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

#import "GLPCampusWallProgressManager.h"
#import "UploadingProgressView.h"
#import "GLPPost.h"

@interface GLPCampusWallProgressManager ()

//@property (strong, nonatomic) NSMutableArray *videosTimestamps;
@property (strong, nonatomic) NSDate *currentProcessedTimestamp;
@property (strong, nonatomic) UploadingProgressView *progressView;
@property (assign, nonatomic, getter=isPostButtonClicked) BOOL postClicked;
@property (assign, nonatomic, getter = isProgressFinished) BOOL progressFinished;
@property (strong, nonatomic) GLPPost *pendingPost;

@end

@implementation GLPCampusWallProgressManager

const NSString *DATA_WRITTEN = @"data_written";
const NSString *DATA_EXPECTED = @"data_expected";

static GLPCampusWallProgressManager *instance = nil;

+ (GLPCampusWallProgressManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPCampusWallProgressManager alloc] init];
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
    _currentProcessedTimestamp = nil;
    
//    _progressView = [[ProgressView alloc] init];
    [_progressView setHidden:YES];
    
    _postClicked = NO;

    _progressFinished = YES;
    
    [_progressView resetView];

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
    
//    _progressViewVisible = YES;
}

- (void)hideProgressView
{
    DDLogDebug(@"GLPProgressManager : hideProgressView");

    [_progressView setHidden:YES];
    
    
    _postClicked = NO;
    
//    _progressViewVisible = NO;

}

#pragma mark - Accessors

- (void)registerVideoWithTimestamp:(NSDate *)timestamp withPost:(GLPPost *)post
{
    _currentProcessedTimestamp = timestamp;
    _pendingPost = post;
    
    if(_pendingPost.group)
    {
        [_progressView setTransparencyToView:YES];
    }
    else
    {
        [_progressView setTransparencyToView:NO];
    }
    
//    [_videosTimestamps addObject:timestamp];
    
//    if(!_currentProcessed)
//    {
//        _currentProcessed = timestamp;
//    }

//    _progressViewVisible = YES;
}

- (NSDate *)registeredTimestamp
{
    return _currentProcessedTimestamp;
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
    
    [_progressView resetView];
    
    _currentProcessedTimestamp = nil;
    
    _progressFinished = YES;


}

- (void)postButtonClicked
{
    DDLogDebug(@"GLPProgressManager : postButtonClicked");
    [self showProgressView];

    _postClicked = YES;
    
    _progressFinished = NO;
}

#pragma mark - Notification methods

- (void)videoProgress:(NSNotification *)notification
{
    NSDictionary *videoData = notification.userInfo;
    
    NSDictionary *progress = videoData[@"update"];
    
    NSDate *timestamp = videoData[@"timestamp"];
    
    DDLogDebug(@"Timestamp: %@, Updates: %@, %@", timestamp, progress[DATA_WRITTEN], progress[DATA_EXPECTED]);
    
    if(![timestamp isEqualToDate:_currentProcessedTimestamp])
    {
        DDLogDebug(@"Timestamp not equal abort viewing.");
        
        return;
    }
    else
    {
        DDLogDebug(@"Timestamp equal show viewing.");

    }
    
    if(_postClicked)
    {
        [self showProgressView];
    }
//    else
//    {
//        [self hideProgressView];
//    }
    

    
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
