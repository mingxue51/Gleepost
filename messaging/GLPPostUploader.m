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

typedef NS_ENUM(NSUInteger, GLPImageStatus) {
    GLPImageStatusUploaded = 0,
    GLPImageStatusUploading,
    GLPImageStatusFailed,
    GLPImageStatusNone
};

@interface GLPPostUploader() {
    GLPPost         *_post;
    UIImage         *_postImage;
    GLPImageStatus   _imageStatus;
    NSString        *_imageURL;
    
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
    NSLog(@"Image-Uploading has began");
    
    __block NSData *data;
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        UIImage *resizedImage = [ImageFormatterHelper imageWithImage:image scaledToHeight:640];
        data = UIImagePNGRepresentation(resizedImage);
    }];
    
    [operation setCompletionBlock:^{
        [self uploadResizedImageWithImageData:data];
    }];
    
    [[[NSOperationQueue alloc] init] addOperation:operation];
}

- (GLPPost *)uploadPostWithContent:(NSString *)content {
    if (content) {
        NSLog(@"Post button is pressed");
        _post = [[GLPPost alloc] init];
        _post.content = content;
        _post.author = [SessionManager sharedInstance].user;
        
        if (_postImage) {
            _post.date = [NSDate date];
            _post.tempImage = _postImage;
        }
        
        if (_imageStatus == GLPImageStatusUploaded || _imageStatus == GLPImageStatusNone) {
            if (_imageStatus == GLPImageStatusUploaded) NSLog(@"image-status is UPLOADED");
            else if (_imageStatus == GLPImageStatusNone) NSLog(@"image-status is NONE");
            [self createLocalAndUploadPost:_post];
        } else if (_imageStatus == GLPImageStatusUploading) {
            NSLog(@"image is still UPLOADING");
            __weak GLPPostUploader *weakSelf = self;
            __weak GLPPost *weakPost = _post;
            _uploadContentBlock = ^{
                NSLog(@"Posting block is executing");
                [weakSelf createLocalAndUploadPost:weakPost];
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
                NSLog(@"Image-uploading done with success: YES");
                _imageStatus    = GLPImageStatusUploaded;
                _imageURL       = imageUrl;
                NSLog(@"~~~ with imageURL: %@", imageUrl);
                
                if (_uploadContentBlock) _uploadContentBlock();
                
            } else {
                _imageStatus = GLPImageStatusFailed;
                
                NSLog(@"Error occured. Post image cannot be uploaded.");
                #warning TODO: show user an error(?)
            }
        }];
    }
}

- (void)createLocalAndUploadPost:(GLPPost *)post {
    if (post) {
        post.imagesUrls = (_imageURL) ? @[_imageURL] : nil;
        
        [GLPPostManager createLocalPost:post];
        
        [[WebClient sharedInstance] createPost:post callbackBlock:^(BOOL success, int remoteKey) {
            NSLog(@"Post uploaded with success: %d", success);
            
            post.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
            post.remoteKey = success ? remoteKey : 0;
            
            [GLPPostManager updatePostAfterSending:_post];
            
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
