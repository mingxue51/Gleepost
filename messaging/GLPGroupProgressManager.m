//
//  GLPGroupProgressManager.m
//  Gleepost
//
//  Created by Silouanos on 26/09/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  Manager declared in GLPLiveGroupPostManager in order to manage the video loader for the groups' posts.

#import "GLPGroupProgressManager.h"
#import "UploadingProgressView.h"
#import "GLPPost.h"

@interface GLPGroupProgressManager ()

@property (strong, nonatomic) NSDate *currentProcessedTimestamp;
@property (strong, nonatomic) UploadingProgressView *progressView;
@property (assign, nonatomic) BOOL postClicked;
@property (assign, nonatomic, getter = isProgressFinished) BOOL progressFinished;

/** This object is used only when the video is uploaded and don't viewed to user.*/
@property (strong, nonatomic) NSDate *uploadedVideoTimestamp;

@property (strong, nonatomic) GLPPost *groupPost;

@end

@implementation GLPGroupProgressManager

const NSString *GROUP_DATA_WRITTEN = @"data_written";
const NSString *GROUP_DATA_EXPECTED = @"data_expected";

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
    
    _uploadedVideoTimestamp = nil;
    
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
    CGRectSetY(view, -65);
    
    _progressView = view;
}

- (void)configureNotifications
{
    NSString *notificationName = [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_VIDEO_PROGRESS_UPDATE, (long)_groupPost.group.remoteKey];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoProgress:) name:notificationName object:nil];
    
    notificationName = [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_VIDEO_PROGRESS_UPLOADING_COMPLETED, (long)_groupPost.group.remoteKey];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoUploadCompleted:) name:notificationName object:nil];

    
    DDLogDebug(@"Configure notifications: %@", notificationName);
}

- (void)deregisterNotifications
{
    DDLogDebug(@"GLPGroupProgressManager : Notifications deregistered.");
    
    NSString *notificationName = [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_VIDEO_PROGRESS_UPDATE, (long)_groupPost.group.remoteKey];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
    
    notificationName = [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_VIDEO_PROGRESS_UPLOADING_COMPLETED, (long)_groupPost.group.remoteKey];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
}

- (void)dealloc
{
    [self deregisterNotifications];
}

- (void)showProgressView
{
    DDLogDebug(@"GLPGroupProgressManager : showProgressView");
    
    [_progressView setHidden:NO];
    
    //    _progressViewVisible = YES;
}

- (void)hideProgressView
{
    DDLogDebug(@"GLPGroupProgressManager : hideProgressView");
    
    [_progressView setHidden:YES];
    
    
    _postClicked = NO;
    
    //    _progressViewVisible = NO;
    
}

#pragma mark - Accessors

- (void)registerVideoWithTimestamp:(NSDate *)timestamp withPost:(GLPPost *)post
{
    FLog(@"Group PM: Registered timestamp: %@", timestamp);
    
    _currentProcessedTimestamp = timestamp;
    _groupPost = post;
    
    [self configureNotifications];
    
    if(_groupPost.group)
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
    
    DDLogDebug(@"GLPGroupProgressManager : setThumbnailImage");
    
}

- (void)progressFinished
{
    FLog(@"GLPGroupProgressManager : progressFinished");
    
    [self hideProgressView];
    
    [_progressView resetView];
    
    _currentProcessedTimestamp = nil;
    
    _progressFinished = YES;
    
    [self deregisterNotifications];
}

- (void)postButtonClicked
{
    [self showProgressView];
    
    FLog(@"GLPGroupProgressManager : postButtonClicked");

    
    _postClicked = YES;
    
    _progressFinished = NO;
    
    
    FLog(@"Current processed timestamp %@, uploaded video timestamp %@", _currentProcessedTimestamp, _uploadedVideoTimestamp);
    
    if([_currentProcessedTimestamp isEqualToDate:_uploadedVideoTimestamp])
    {
        [_progressView startProcessing];
    }
}

#pragma mark - Notification methods

- (void)videoProgress:(NSNotification *)notification
{
    NSDictionary *videoData = notification.userInfo;
    
    NSDictionary *progress = videoData[@"update"];
    
    NSDate *timestamp = videoData[@"timestamp"];
    
    FLog(@"Timestamp: %@, Updates: %@, %@", timestamp, progress[GROUP_DATA_WRITTEN], progress[GROUP_DATA_EXPECTED]);
    
    if(![timestamp isEqualToDate:_currentProcessedTimestamp])
    {
        FLog(@"Timestamp not equal abort viewing.");
        
        return;
    }
    else
    {
        FLog(@"Timestamp equal show viewing.");
        
    }
    
    if(_postClicked)
    {
        [self showProgressView];
    }

    
    
    NSNumber *dataWritten = progress[GROUP_DATA_WRITTEN];
    
    NSNumber *dataExpected = progress[GROUP_DATA_EXPECTED];
    
    if([dataExpected isEqualToNumber:dataWritten])
    {
        [_progressView startProcessing];
    }
    else
    {
        [_progressView updateProgressWithValue:(dataWritten.floatValue/dataExpected.floatValue)];
    }
}

/**
 This method should be called only when the video is finished uploading and the progress bar is NOT already shown.
 
 @param notification the notification should contain the timestamp in order to avoid issues.
 
 */
- (void)videoUploadCompleted:(NSNotification *)notification
{
    NSDictionary *timestampData = notification.userInfo;
    
    _uploadedVideoTimestamp = timestampData[@"timestamp"];
    
    FLog(@"Video upload completed : GLPGroupProgressManager");
}

- (NSInteger)postRemoteKey
{
    return _groupPost.group.remoteKey;
}

- (NSString *)generateNSNotificationNameForPendingGroupPost
{
    NSString *notificationName = [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_VIDEO_PROGRESS_UPDATE, (long)_groupPost.group.remoteKey];
    
    return notificationName;
}

- (NSString *)generateNSNotificationUploadFinshedNameForPendingGroupPost
{
    NSString *notificationName = [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_VIDEO_PROGRESS_UPLOADING_COMPLETED, (long)_groupPost.group.remoteKey];
    
    return notificationName;
}

@end
