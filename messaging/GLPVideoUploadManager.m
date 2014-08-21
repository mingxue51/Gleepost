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

@interface GLPVideoUploadManager ()

@property (strong, nonatomic) NSMutableDictionary *localSavedVideos;
@property (strong, nonatomic) GLPPostUploaderManager *postUploader;
@property (strong, nonatomic) GLPVideoUploader *videoUploader;
@property (strong, nonatomic) NSTimer *checkForUploadingTimer;
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
    
    if(![GLPiOS6Helper isIOS6])
    {
        [_checkForUploadingTimer setTolerance:5.0f];
    }
}

#pragma mark - Operation Methods

-(void)checkForPostUpload:(id)sender
{
    DDLogDebug(@"checkForPostUpload - Video");
    
    for(NSDate* t in [_postUploader pendingPosts])
    {
//        NSString *url = [_videoUploader urlWithTimestamp:t];
        NSNumber *videoId = [_videoUploader videoKeyWithTimestamp:t];

        
        DDLogInfo(@"Ready video with id: %@",videoId);
        
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
    
    [_postUploader uploadPostWithVideoData:data];
    
    
//    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_VIDEO_PROCESSED object:self userInfo:data];
}

@end