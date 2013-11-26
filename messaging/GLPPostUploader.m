//
//  GLPPostUploader.m
//  Gleepost
//
//  Created by Lukas on 11/14/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPostUploader.h"
#import "ImageFormatterHelper.h"
#import "WebClient.h"
#import "GLPPostManager.h"
#import "SessionManager.h"

@interface GLPPostUploader()

@property (strong, nonatomic) GLPPost *post;
@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) UIImage *tempImage;
@property (assign, nonatomic) BOOL imageUploaded;
@property (assign, nonatomic) BOOL postUploading;
@property (assign, nonatomic) BOOL postUploaded;
@property (assign, nonatomic) BOOL savedLocally;


@end

@implementation GLPPostUploader

@synthesize post=_post;
@synthesize imageUrl=_imageUrl;
@synthesize imageUploaded=_imageUploaded;
@synthesize postUploaded=_postUploaded;
@synthesize postUploading=_postUploading;
@synthesize savedLocally = _savedLocally;

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _post = [[GLPPost alloc] init];
    _imageUploaded = NO;
    _postUploaded = NO;
    _postUploading = NO;
    _savedLocally = NO;
    
    return self;
}

//TODO: recheck
//TODO: manage image changes and some stuff like this
- (void)uploadImage:(UIImage *)image
{
    self.tempImage = image;
    
    __block NSData *data;
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        UIImage *resizedImage = [ImageFormatterHelper imageWithImage:image scaledToHeight:640];
        data = UIImagePNGRepresentation(resizedImage);
    }];
    
    [operation setCompletionBlock:^{
        [self uploadResizedImage:data];
    }];
    
    
    [[[NSOperationQueue alloc] init] addOperation:operation];
}

- (void)uploadResizedImage:(NSData *)imageData
{
    [[WebClient sharedInstance] uploadImage:imageData callback:^(BOOL success, NSString *imageUrl) {
        NSLog(@"Upload resized image with success: %d with link: %@", success, imageUrl);
        
        //TODO: Show some error
        if(!success) {
            return;
        }
        
        _imageUrl = imageUrl;
        _imageUploaded = YES;
        
        [self uploadFinalPostWithImage:YES];
    }];
}

- (GLPPost*)uploadPostWithContent:(NSString *)content hasImage:(BOOL)hasImage
{
    _post = [[GLPPost alloc] init];
    _post.content = content;
    _post.author = [SessionManager sharedInstance].user;
    
    //    [self uploadFinalPostWithImage:hasImage];

    if(hasImage)
    {
        _post.date = [NSDate date];
        _post.tempImage = self.tempImage;
        _post.imagesUrls = [[NSArray alloc] initWithObjects:@"tempImage", nil];
        
    }
    else
    {
        _post.imagesUrls = nil;
        //[self uploadFinalPostWithImage:hasImage];
        [self uploadTextWithPost:_post];

    }
    
    return _post;
}

-(void)uploadTextWithPost:(GLPPost*)post
{
    
    [GLPPostManager createLocalPost:post];
    
    
    // send it to remote
    [[WebClient sharedInstance] createPost:post callbackBlock:^(BOOL success, int remoteKey) {
        NSLog(@"Upload post with success: %d", success);
        
        post.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
        post.remoteKey = success ? remoteKey : 0;
        
        [GLPPostManager updatePostAfterSending:post];
        
        _postUploaded = success;
        _postUploading = NO;
    }];
}

- (void)uploadFinalPostWithImage:(BOOL)withImage
{
    if(_postUploading) {
        NSLog(@"Post is already uploading");
        return;
    }
    
    if(_postUploaded) {
        NSLog(@"Post is already uploaded");
        return;
    }
    
    if(!_post) {
        NSLog(@"There is no post to upload yet, abort");
        return;
    }
    
    _postUploading = YES;
    __block GLPPost *post = _post; // shall we copy there?
    
    // post with image
    

    
//    if(!_savedLocally)
//    {
//        // create local post
////        [GLPPostManager createLocalPost:post];
//        _savedLocally = YES;
//    }

    
    
    if(withImage) {
//        if(!_imageUploaded) {
//            _postUploading = NO;
//            NSLog(@"Do not upload post, image upload not finished yet");
//            return;
//        }
        
        post.imagesUrls = [NSArray arrayWithObject:_imageUrl];
    }

    
    [GLPPostManager createLocalPost:post];
    
    
    // send it to remote
    [[WebClient sharedInstance] createPost:_post callbackBlock:^(BOOL success, int remoteKey) {
        NSLog(@"Upload post with success: %d", success);
        
        post.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
        post.remoteKey = success ? remoteKey : 0;
        
        [GLPPostManager updatePostAfterSending:_post];
        
        _postUploaded = success;
        _postUploading = NO;
    }];
}



@end
