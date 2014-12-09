//
//  GLPCWProgressManager.m
//  
//
//  Created by Silouanos on 21/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  

#import "GLPCWProgressManager.h"

@interface GLPCWProgressManager ()

//@property (strong, nonatomic) NSMutableArray *videosTimestamps;


///** This object is used only when the video is uploaded and didn't view to user.*/
//@property (strong, nonatomic) NSDate *uploadedVideoTimestamp;


////This variable is YES only if the uploading view is appeared to the user.
//@property (assign, nonatomic, getter=isProgressUploadingStarted) BOOL progressUploadingStarted;

@end

@implementation GLPCWProgressManager

static GLPCWProgressManager *instance = nil;

+ (GLPCWProgressManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPCWProgressManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        [self configureObjects];
        [self configureProgressView];
    }
    
    return self;
}

#pragma mark - Configuration

- (void)configureProgressView
{
    UploadingProgressView *view = [[[NSBundle mainBundle] loadNibNamed:@"UploadingProgressView" owner:self options:nil] objectAtIndex:0];
    [view setFrame:view.frame];
    CGRectSetY(view, 45);
    _progressView = view;
}

- (void)configureObjects
{
    _currentProcessedTimestamp = nil;
    _uploadedVideoTimestamp = nil;
    [_progressView setHidden:YES];
    _postClicked = NO;
    _progressFinished = YES;
    [_progressView resetView];
}

#pragma mark - Modifiers

- (void)showProgressView
{
    DDLogDebug(@"GLPProgressManager : showProgressView");
    [_progressView setHidden:NO];
}

- (void)hideProgressView
{
    DDLogDebug(@"GLPProgressManager : hideProgressView");
    [_progressView setHidden:YES];
    _postClicked = NO;
}

#pragma mark - Accessors

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
    [self showProgressView];
    _postClicked = YES;
    _progressFinished = NO;
    
    FLog(@"Current processed timestamp %@, uploaded video timestamp %@", _currentProcessedTimestamp, _uploadedVideoTimestamp);
    
    if([_currentProcessedTimestamp isEqualToDate:_uploadedVideoTimestamp])
    {
        [_progressView startProcessing];
    }
}

@end
