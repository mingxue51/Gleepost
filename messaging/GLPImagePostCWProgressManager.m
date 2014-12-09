//
//  GLPImagePostCWProgressManager.m
//  Gleepost
//
//  Created by Silouanos on 21/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This manager is responsible for receiving the progress of the uploading element
//  (image only in this class) calculate the percentage and send it to GLPTimelineViewController.
//  //NOT USED.

#import "GLPImagePostCWProgressManager.h"

@implementation GLPImagePostCWProgressManager

const NSString *IMAGE_DATA_WRITTEN = @"data_written";
const NSString *IMAGE_DATA_EXPECTED = @"data_expected";

static GLPImagePostCWProgressManager *instance = nil;

+ (GLPImagePostCWProgressManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPImagePostCWProgressManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        [self configureNotifications];
    }
    
    return self;
}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploadingProgress:) name:GLPNOTIFICATION_IMAGE_PROGRESS_UPDATE object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_IMAGE_PROGRESS_UPDATE object:nil];
}

#pragma mark - Accessors

- (void)registerImageWithTimestamp:(NSDate *)timestamp withPost:(GLPPost *)post
{
    self.currentProcessedTimestamp = timestamp;
    self.pendingPost = post;
//    [self.progressView setTransparencyToView:NO];
}

#pragma mark - Notification methods

- (void)imageUploadingProgress:(NSNotification *)notification
{
    NSDictionary *imageData = notification.userInfo;
    
    NSDictionary *progress = imageData[@"update"];
    
    NSDate *timestamp = imageData[@"timestamp"];
    
    DDLogDebug(@"Timestamp: %@, Updates: %@, %@", timestamp, progress[IMAGE_DATA_WRITTEN], progress[IMAGE_DATA_EXPECTED]);
    
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
    
    NSNumber *dataWritten = progress[IMAGE_DATA_WRITTEN];
    
    NSNumber *dataExpected = progress[IMAGE_DATA_EXPECTED];
    
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
