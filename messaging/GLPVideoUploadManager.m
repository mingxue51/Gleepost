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
        NSString *url = [_videoUploader urlWithTimestamp:t];
        
        DDLogInfo(@"Ready video URL: %@",url);
        
        if(url)
        {
            DDLogInfo(@"Post ready for upload!");
            
            //Post ready for uploading.
            [_postUploader uploadPostWithTimestamp:t andVideoUrl:url];
            
            //Remove url from the Image Operation.
            [_videoUploader removeUrlWithTimestamp:t];
        }
        else
        {
            //Video not uploaded yet.
        }
    }

}

-(void)uploadVideo:(NSString*)videoPath withTimestamp:(NSDate*)timestamp
{
    //Upload image with timestasmp.
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




@end
