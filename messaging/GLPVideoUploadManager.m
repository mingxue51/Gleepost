//
//  GLPVideoManager.m
//  Gleepost
//
//  Created by Silouanos on 13/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//  This manager has the responsibility to take care of all recorded videos.
//  It supports operations such as saving the path of a new recorded vivdo.
//

#import "GLPVideoUploadManager.h"
#import "GLPPostUploaderManager.h"
#import "GLPiOS6Helper.h"
#import "GLPVideoUploader.h"
#import "NSNotificationCenter+Utils.h"
#import "WebClient.h"
#import "GLPPostManager.h"
#import "GLPVideo.h"
#import "GLPProgressManager.h"

@interface GLPVideoUploadManager ()

@property (strong, nonatomic) NSMutableDictionary *localSavedVideos;
@property (strong, nonatomic) GLPPostUploaderManager *postUploader;
@property (strong, nonatomic) GLPVideoUploader *videoUploader;
@property (strong, nonatomic) NSTimer *checkForUploadingTimer;
@property (strong, nonatomic) NSTimer *checkForPendingVideoPostsTimer;
@property (assign, nonatomic, getter = isCheckingForPendingVideoPosts) BOOL checkingForPendingVideoPosts;
@property (assign, nonatomic) BOOL isNetworkAvailable;
@end

@implementation GLPVideoUploadManager

static GLPVideoUploadManager *instance = nil;

+(GLPVideoUploadManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPVideoUploadManager alloc] init];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
        [self initialiseObjects];
    }
    
    return self;
}

-(void)initialiseObjects
{
    _localSavedVideos = [[NSMutableDictionary alloc] init];
    _postUploader = [[GLPPostUploaderManager alloc] init];
    _videoUploader = [[GLPVideoUploader alloc] init];
    _checkForUploadingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(checkForPostUpload:) userInfo:nil repeats:YES];
    
    _checkForPendingVideoPostsTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(checkForNonUploadedVideoPosts) userInfo:nil repeats:YES];
    
    _checkingForPendingVideoPosts = NO;
    
    if(![GLPiOS6Helper isIOS6])
    {
        [_checkForUploadingTimer setTolerance:5.0f];
        [_checkForPendingVideoPostsTimer setTolerance:10.0f];
    }
}

#pragma mark - Operation Methods

-(void)checkForPostUpload:(id)sender
{
    
    for(NSDate* t in [_postUploader pendingPosts])
    {
        DDLogInfo(@"Pending posts in checkForPostUpload: %@", [_postUploader pendingPosts]);

        
//        NSString *url = [_videoUploader urlWithTimestamp:t];
        NSNumber *videoId = [_videoUploader videoKeyWithTimestamp:t];

        
        
        if(videoId)
        {
            //If video id received it means that we need to wait until we get web socket
            //event (so until video is processed).
            DDLogInfo(@"Video uploaded with key %@, waiting for web socket event", videoId);

            
            //Post ready for uploading.
//            [_postUploader uploadPostWithTimestamp:t andVideoId:videoId];
            [_postUploader prepareVideoPostForUploadWithTimestamp:t andVideoId:videoId];
            
            //Remove id from the Video Operation.
            [_videoUploader removeVideoIdWithTimestamp:t];
        }
        else
        {
            //Video not uploaded yet.
        }
    }

}

-(void)uploadVideo:(NSString*)videoPath withTimestamp:(NSDate*)timestamp
{
    //Upload video with timestasmp.
    [_videoUploader uploadVideo:videoPath withTimestamp:timestamp];
    [_checkForUploadingTimer fire];
}

/**
 Cancel uploading post.
 
 @param postKey the post's local database key.
 
 @return YES if post pending, returns NO if the post is already uploaded.
 
 */
-(BOOL)cancelPostWithKey:(int)postKey
{
    NSDate *timestamp = [_postUploader cancelPendingPostWithKey:postKey];
    
    if(!timestamp)
    {
        return NO;
    }
    
    //Remove image from progress of uploading.
    [_videoUploader cancelVideoWithTimestamp:timestamp];
    
    return YES;
}

- (void)cancelVideoWithTimestamp:(NSDate *)timestamp
{
    //Remove image from progress of uploading.
    [_videoUploader cancelVideoWithTimestamp:timestamp];
}

/**
 Starts a timer to check every specific interval of seconds
 if there is any video post that is not created (not by user but by the app)
 because the video is still pending.
 
 */
- (void)startCheckingForNonUploadedVideoPosts
{
    [_checkForPendingVideoPostsTimer fire];
}

- (void)checkForNonUploadedVideoPosts
{
    if([self isCheckingForPendingVideoPosts])
    {
        DDLogInfo(@"Can't check for non uploaded video posts, is already checking.");

        return;
    }
    
    if([[GLPProgressManager sharedInstance] isProgressViewVisible])
    {
        DDLogInfo(@"Can't check for non uploaded video posts, progress view visible");
        
        return;
    }
    
    //TODO: Duplications fixed. But we need tests.
    
    _checkingForPendingVideoPosts = YES;
    
    //Check if there are pending video posts.
    [GLPPostManager searchForPendingVideoPostCallback:^(NSArray *videoPosts) {
        
        _checkingForPendingVideoPosts = NO;
        
        if([_postUploader isVideoProcessed])
        {
            DDLogInfo(@"Check for non uploaded video posts abord. A video already processed.");
            
            return;
        }
        

        if(videoPosts.count > 0)
        {
            DDLogDebug(@"Video pending posts: %@", videoPosts);

            GLPPost *videoPost = [videoPosts objectAtIndex:0];
            
            NSNumber *videoKey = videoPost.video.pendingKey;
            
            [[WebClient sharedInstance] checkForReadyVideoWithPendingVideoKey:videoKey callback:^(BOOL success, GLPVideo *result) {
                
                if(success)
                {
                    DDLogDebug(@"Pending video result: %@", result);
                    
                    videoPost.video = result;
                    
                    [_postUploader uploadVideoPost:videoPost];
                }
                
            }];
        }
    }];
    

}


#pragma mark - Modifiers

-(void)setPost:(GLPPost *)post withTimestamp:(NSDate *)timestamp
{
    [_postUploader addPost:post withTimestamp:timestamp];
}

#pragma mark - Notification manager


/**
 Sends a notification with video's thumbnail and url.
 
 @param remoteKey post's remote key.
 @param thumbUrl video's thumbnail.
 @param videoUrl video's url.
 
 */
- (void)refreshVideoPostInCampusWallWithData:(NSDictionary *)data
{
    DDLogInfo(@"GLPVideoUploadManager : Video processed with data: %@", data);
    
//    NSDictionary *data = @{@"remoteKey": [NSNumber numberWithInteger:remoteKey], @"thumbnailUrl" : thumbUrl, @"videoUrl" : videoUrl};
    
    [_videoUploader printVideoUploadedIds];
    
    [_postUploader uploadPostWithVideoData:data];
    
    
    
    
//    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_VIDEO_PROCESSED object:self userInfo:data];
}

@end