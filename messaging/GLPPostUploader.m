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

- (void)startUploadingImage:(UIImage *)image {
    _postImage = image;
    _imageStatus = GLPImageStatusUploading;
    
    __block NSData *data;
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        UIImage *resizedImage = [ImageFormatterHelper imageWithImage:image scaledToHeight:640];
        data = UIImagePNGRepresentation(resizedImage);
    }];
    
    uploadKey = 3;
    
    [operation setCompletionBlock:^{
        [self uploadResizedImageWithImageData:data];
//        [[GLPQueueManager sharedInstance]uploadImage:image withId:uploadKey];

    }];
    
    [[[NSOperationQueue alloc] init] addOperation:operation];
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
    timestamp = [NSDate date];
    _videoPath = path;
    
    [[GLPVideoUploadManager sharedInstance] uploadVideo:path withTimestamp:timestamp];
}

//ADDED.
/**
 Method used for upload regular post.
 */
-(GLPPost*)uploadPost:(NSString*)content withCategories:(NSArray*)categories eventTime:(NSDate *)eventDate andTitle:(NSString *)title
{
    //Add the date to a new post.
    GLPPost *post = [[GLPPost alloc] init];
    post.content = content;
    post.author = [SessionManager sharedInstance].user;
    post.categories = categories;
    post.dateEventStarts = eventDate;
    post.eventTitle = title;
    
    //Create a new operation.
    
    post = [self uploadPostWithPost:post];
    
//    if(_postImage)
//    {
//        post.date = [NSDate date];
//        post.tempImage = _postImage;
//        post.imagesUrls = [[NSArray alloc] initWithObjects:@"LIVE", nil];
//        
//        [GLPPostManager createLocalPost:post];
//        
//        [[GLPPostOperationManager sharedInstance] setPost:post withTimestamp:timestamp];
//        
////        [[GLPQueueManager sharedInstance] uploadPost:post withId:1];
//    }
//    else
//    {
//        [self createLocalAndUploadPost:post];
//    }
    
    return post;
}

-(GLPPost *)uploadPost:(NSString *)content withCategories:(NSArray *)categories eventTime:(NSDate *)eventDate title:(NSString *)title andGroup:(GLPGroup *)group
{
    //Add information to a new post.
    
    GLPPost *post = [[GLPPost alloc] init];
    post.content = content;
    post.author = [SessionManager sharedInstance].user;
    post.categories = categories;
    post.dateEventStarts = eventDate;
    post.eventTitle = title;
    post.group = group;
    
    return [self uploadPostWithPost:post];
}

-(GLPPost *)uploadPostWithPost:(GLPPost *)post
{
    //Create a new operation.
    if(_postImage)
    {
        post.date = [NSDate date];
        post.tempImage = _postImage;
        post.imagesUrls = [[NSArray alloc] initWithObjects:@"LIVE", nil];
        
        [GLPPostManager createLocalPost:post];
        
        [[GLPPostOperationManager sharedInstance] setPost:post withTimestamp:timestamp];
        
        
        //        [[GLPQueueManager sharedInstance] uploadPost:post withId:1];
    }
    else if(_videoPath)
    {
        post.date = [NSDate date];
        post.videosUrls = [[NSArray alloc] initWithObjects:_videoPath, nil];
        [GLPPostManager createLocalPost:post];
        
        [[GLPVideoUploadManager sharedInstance] setPost:post withTimestamp:timestamp];
    }
    else
    {
        [self createLocalAndUploadPost:post];
    }
    
    return post;
}


- (GLPPost *)uploadPostWithContent:(NSString *)content {
    if (content) {
        _post = [[GLPPost alloc] init];
        _post.content = content;
        _post.author = [SessionManager sharedInstance].user;
        
        
        if (_postImage) {
            _post.date = [NSDate date];
            _post.tempImage = _postImage;
            
            [GLPPostManager createLocalPost:_post];
            
           // [[GLPQueueManager sharedInstance] uploadPost:_post withId:uploadKey];

        }
        
        if (_imageStatus == GLPImageStatusUploaded || _imageStatus == GLPImageStatusNone) {
            
            //[self createLocalAndUploadPost:_post];

            
        } else if (_imageStatus == GLPImageStatusUploading) {
            
            __weak GLPPostUploader *weakSelf = self;
            __weak GLPPost *weakPost = _post;
            _uploadContentBlock = ^{
                
                [weakSelf assignUrlToPost:weakPost];
                [[GLPQueueManager sharedInstance] uploadPost:weakPost withId:-1];

                //[weakSelf createLocalAndUploadPost:weakPost];
            };
        }
    }
    
    return _post;
}

# pragma mark - Uploading

- (void)uploadResizedImageWithImageData:(NSData *)imageData {
    if (imageData) {
        [[WebClient sharedInstance] uploadImage:imageData callback:^(BOOL success, NSString *imageUrl) {
            if (success) {
                _imageStatus    = GLPImageStatusUploaded;
                _imageURL       = imageUrl;
                
                if (_uploadContentBlock) _uploadContentBlock();
                
            } else {
                _imageStatus = GLPImageStatusFailed;
                
                NSLog(@"Error occured. Post image cannot be uploaded.");
            }
        }];
    }
}

-(void)assignUrlToPost:(GLPPost*)post
{
    post.imagesUrls = (_imageURL) ? @[_imageURL] : nil;
    
}

- (void)createLocalAndUploadPost:(GLPPost *)post {
    if (post) {
        post.imagesUrls = (_imageURL) ? @[_imageURL] : nil;
        
        [GLPPostManager createLocalPost:post];
        
        [[WebClient sharedInstance] createPost:post callbackBlock:^(BOOL success, int remoteKey) {
            
            post.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
            post.remoteKey = success ? remoteKey : 0;
            
            [GLPPostManager updatePostAfterSending:post];
            
            //TODO: Communicate with Campus Wall to inform post.
            
            
            [self cleanUpPost];
        }];
    }
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
