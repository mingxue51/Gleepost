//
//  GLPPostUploader.m
//  Gleepost
//
//  Created by Tanmay Khandelwal on 05/12/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPostUploader.h"
#import "GLPPost.h"
#import "ImageFormatterHelper.h"
#import "WebClient.h"
#import "SessionManager.h"
#import "GLPPostManager.h"
#import "GLPQueueManager.h"
#import "GLPPostOperationManager.h"
#import "GLPVideoUploadManager.h"
#import "GLPVideo.h"
#import "GLPVideoPostCWProgressManager.h"
#import "GLPLiveGroupPostManager.h"
#import "PendingPostManager.h"
#import "NSNotificationCenter+Utils.h"
#import "GLPPendingPostsManager.h"

typedef NS_ENUM(NSUInteger, GLPImageStatus) {
    GLPImageStatusUploaded = 0,
    GLPImageStatusUploading,
    GLPImageStatusFailed,
    GLPImageStatusNone
};

@interface GLPPostUploader() {
    GLPPost         *_post;
    UIImage         *_postImage;
    NSString        *_videoPath;
    GLPImageStatus   _imageStatus;
    NSString        *_imageURL;
    
    //Added.
    NSDate *timestamp;
    
    int uploadKey;
    void (^_uploadContentBlock)();
}

@end

@implementation GLPPostUploader

- (id)init
{
    self = [super init];
    if (self) {
        [self cleanUpPost];
    }
    return self;
}

-(void)uploadImageToQueue:(UIImage*)image
{
    timestamp = [NSDate date];
    _postImage = image;
    
    [[GLPPostOperationManager sharedInstance] uploadImage:image withTimestamp:timestamp];
    
//    [gum uploadImage:image withTimestamp:[NSDate date]];
    
//    [[GLPQueueManager sharedInstance]uploadImage:image withId:1];
}

-(void)uploadVideoInPath:(NSString *)path
{
    if(timestamp)
    {
        [[GLPVideoUploadManager sharedInstance] cancelVideoWithTimestamp:timestamp];
    }
    
    timestamp = [NSDate date];
    
    DDLogDebug(@"LAST TIMESTAMP: %@", timestamp);
    
    _videoPath = path;
    
    [[GLPVideoUploadManager sharedInstance] uploadVideo:path withTimestamp:timestamp];
}

/**
 Method used for upload regular post.
 */
-(GLPPost*)uploadPost:(NSString*)content withCategories:(NSArray *)categories eventTime:(NSDate *)eventDate title:(NSString *)title andLocation:(GLPLocation *)location
{
    FLog(@"REGISTERED TIMESTAMP: %@", timestamp);

    //Add the date to a new post.
    GLPPost *post = [[GLPPost alloc] init];
    post.content = content;
    post.author = [SessionManager sharedInstance].user;
    post.categories = categories;
    post.dateEventStarts = eventDate;
    post.eventTitle = title;
    post.location = location;
    
    if([[PendingPostManager sharedInstance] isEditMode])
    {
        if([post isVideoPost])
        {
            [[GLPPendingPostsManager sharedInstance] registerVideoWithTimestamp:timestamp withPost:post];
        }
        
        post.remoteKey = [[PendingPostManager sharedInstance] pendingPostRemoteKey];
        

        post.pendingInEditMode = YES;
        
        
        post.sendStatus = kSendStatusLocalEdited;
        post.remoteKey = [[PendingPostManager sharedInstance] pendingPostRemoteKey];
        
        //Notify the PendingPostVC and the ViewPendingPostVC that the post is going to be edited.
        //TODO: See if that works for text, image and video together.
        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_POST_STARTED_EDITING object:nil userInfo:@{@"posts_started_editing" : post}];
        
        [self editPostWithPost:post];
    }
    else
    {
        
        if([[PendingPostManager sharedInstance] doesPostNeedsApprove])
        {
            post.pendingInEditMode = NO;
        }
        
        //Register the timestamp in order to avoid problems when a video selected and then unselected.
        [[GLPVideoPostCWProgressManager sharedInstance] registerVideoWithTimestamp:timestamp withPost:post];
        post = [self uploadPostWithPost:post];
    }
    
    return post;
}

- (void)uploadPollPostWithPost:(GLPPost *)post
{
    post = [self uploadPostWithPost:post];
}

-(GLPPost *)uploadPost:(NSString *)content withCategories:(NSArray *)categories eventTime:(NSDate *)eventDate title:(NSString *)title group:(GLPGroup *)group andLocation:(GLPLocation *)location
{
    //Add information to a new post.
    
    GLPPost *post = [[GLPPost alloc] init];
    post.content = content;
    post.author = [SessionManager sharedInstance].user;
    post.categories = categories;
    post.dateEventStarts = eventDate;
    post.eventTitle = title;
    post.group = group;
    post.location = location;
    
    [[GLPLiveGroupPostManager sharedInstance] registerVideoWithTimestamp:timestamp withPost:post];

    
    return [self uploadPostWithPost:post];
}

- (GLPPost *)uploadPostWithPost:(GLPPost *)post
{
    //Create a new operation.
    if(_postImage)
    {
        post.date = [NSDate date];
        post.tempImage = _postImage;
        post.imagesUrls = [[NSArray alloc] initWithObjects:@"LIVE", nil];
        [GLPPostManager createLocalPost:post];
        [[GLPPostOperationManager sharedInstance] setPost:post withTimestamp:timestamp];
        FLog(@"Image post created: %@ : %@ : %@", post, post.video, post.imagesUrls);
    }
    else if(_videoPath)
    {
        post.date = [NSDate date];
        post.video = [[GLPVideo alloc] initWithPath:_videoPath];
        [GLPPostManager createLocalPost:post];
        [[GLPVideoUploadManager sharedInstance] setPost:post withTimestamp:timestamp];
        FLog(@"Video post created: %@ : %@ : %@", post, post.video, post.imagesUrls);
    }
    else
    {
        FLog(@"Text post created: %@ : %@ : %@", post, post.video, post.imagesUrls);
        [[GLPPostOperationManager sharedInstance] uploadTextPost:post];
    }
    
    FLog(@"VIDEO PATH FOR POST %@: %@", post, _videoPath);
    
    return post;
}

- (void)editPostWithPost:(GLPPost *)post
{
    [[GLPPendingPostsManager sharedInstance] updatePendingPostBeforeEdit:post];

    if(_postImage)
    {
        post.date = [NSDate date];
        post.tempImage = _postImage;
        post.imagesUrls = [[NSArray alloc] initWithObjects:@"LIVE", nil];
        [[GLPPostOperationManager sharedInstance] setPost:post withTimestamp:timestamp];
        FLog(@"Image post created: %@ : %@ : %@", post, post.video, post.imagesUrls);
    }
    else if(_videoPath)
    {
        post.date = [NSDate date];
        post.video = [[GLPVideo alloc] initWithPath:_videoPath];
        [[GLPVideoUploadManager sharedInstance] setPost:post withTimestamp:timestamp];
        FLog(@"Video post created: %@ : %@ : %@", post, post.video, post.imagesUrls);
    }
    else
    {
        FLog(@"Text post created: %@ : %@ : %@", post, post.video, post.imagesUrls);
        [[GLPPostOperationManager sharedInstance] uploadTextPost:post];
    }
}

# pragma mark - Uploading

-(void)assignUrlToPost:(GLPPost*)post
{
    post.imagesUrls = (_imageURL) ? @[_imageURL] : nil;
    
}

# pragma mark - Clean up

- (void)cleanUpPost {
    _imageStatus        = GLPImageStatusNone;
    _imageURL           = nil;
    _postImage          = nil;
    _post               = nil;
    _uploadContentBlock = nil;
}

@end
