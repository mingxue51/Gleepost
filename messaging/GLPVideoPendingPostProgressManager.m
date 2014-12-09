//
//  GLPVideoPendingPostProgressManager.m
//  Gleepost
//
//  Created by Silouanos on 08/12/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPVideoPendingPostProgressManager.h"

@implementation GLPVideoPendingPostProgressManager

const NSString *PENDING_POST_DATA_WRITTEN = @"data_written";
const NSString *PENDING_POST_DATA_EXPECTED = @"data_expected";

static GLPVideoPendingPostProgressManager *instance = nil;

+ (GLPVideoPendingPostProgressManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPVideoPendingPostProgressManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
    }
    
    return self;
}

//- (void)configureNotifications
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoUploadingProgress:) name:GLPNOTIFICATION_PENDING_VIDEO_PROGRESS_UPDATE object:nil];
//}

//- (void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_PENDING_VIDEO_PROGRESS_UPDATE object:nil];
//}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoUploadingProgress:) name:[self generateNSNotificationNameForPendingPost] object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoUploadCompleted:) name:[self generateNSNotificationUploadFinshedNameForPendingPost] object:nil];
    
    DDLogDebug(@"GLPVideoPendingPostManager : notification progress %@", [self generateNSNotificationNameForPendingPost]);
    
    DDLogDebug(@"Configure notifications: %@", [self generateNSNotificationUploadFinshedNameForPendingPost]);
}

- (void)dealloc
{
    [self deregisterNotifications];
}

- (void)deregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self generateNSNotificationNameForPendingPost] object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self generateNSNotificationUploadFinshedNameForPendingPost] object:nil];
}

- (void)progressFinished
{
    [super progressFinished];
    [self deregisterNotifications];
    self.pendingPost = nil;
}

#pragma mark - Accessors

- (void)registerWithTimestamp:(NSDate *)timestamp withPost:(GLPPost *)post
{
    self.currentProcessedTimestamp = timestamp;
    self.pendingPost = post;
    [self.progressView setTransparencyToView:NO];
    [self configureNotifications];
}

- (NSString *)generateNSNotificationNameForPendingPost
{
    NSString *notificationName = [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_PENDING_VIDEO_PROGRESS_UPDATE, (long)self.pendingPost.remoteKey];
    
    return notificationName;
}

- (NSString *)generateNSNotificationUploadFinshedNameForPendingPost
{
    NSString *notificationName = [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_VIDEO_PROGRESS_UPLOADING_COMPLETED, (long)self.pendingPost.remoteKey];
    
    return notificationName;
}

#pragma mark - Notification methods

/**
 This method should be called only when the video is finished uploading and the progress bar is NOT already shown.
 
 @param notification the notification should contain the timestamp in order to avoid issues.
 
 */
- (void)videoUploadCompleted:(NSNotification *)notification
{
    NSDictionary *timestampData = notification.userInfo;
    
    self.uploadedVideoTimestamp = timestampData[@"timestamp"];
    
    FLog(@"Video upload completed : GLPGroupProgressManager");
}

- (void)videoUploadingProgress:(NSNotification *)notification
{
    NSDictionary *imageData = notification.userInfo;
    
    NSDictionary *progress = imageData[@"update"];
    
    NSDate *timestamp = imageData[@"timestamp"];
    
    DDLogDebug(@"Timestamp: %@, Updates: %@, %@", timestamp, progress[PENDING_POST_DATA_WRITTEN], progress[PENDING_POST_DATA_EXPECTED]);
    
    if(![timestamp isEqualToDate:self.currentProcessedTimestamp])
    {
        DDLogDebug(@"Timestamp not equal abort viewing.");
        
        return;
    }
    else
    {
        DDLogDebug(@"Timestamp equal show viewing.");
        
    }
    
    if(self.postClicked)
    {
        [self showProgressView];
    }
    
    NSNumber *dataWritten = progress[PENDING_POST_DATA_WRITTEN];
    
    NSNumber *dataExpected = progress[PENDING_POST_DATA_EXPECTED];
    
    if([dataExpected isEqualToNumber:dataWritten])
    {
        [self.progressView startProcessing];
    }
    else
    {
        [self.progressView updateProgressWithValue:(dataWritten.floatValue/dataExpected.floatValue)];
    }
}

@end
