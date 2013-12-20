//
//  GLPPostOperationManager.m
//  Gleepost
//
//  Created by Silouanos on 20/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPostOperationManager.h"
#import "GLPImageUploaderManager.h"
#import "GLPPostUploaderManager.h"

@interface GLPPostOperationManager ()

@property (strong, nonatomic) GLPImageUploaderManager *imageUploader;
@property (strong, nonatomic) GLPPostUploaderManager *postUploader;
@property (strong, nonatomic) NSTimer *checkForUploadingTimer;

@end

static GLPPostOperationManager *instance = nil;

@implementation GLPPostOperationManager

@synthesize imageUploader = _imageUploader;
@synthesize postUploader = _postUploader;
@synthesize checkForUploadingTimer = _checkForUploadingTimer;

+ (GLPPostOperationManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPPostOperationManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _imageUploader = [[GLPImageUploaderManager alloc] init];
        _postUploader = [[GLPPostUploaderManager alloc] init];
        //[NSTimer timerWithTimeInterval:3.0f target:self selector:@selector(checkForPostUpload:) userInfo:nil repeats:YES];
        _checkForUploadingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(checkForPostUpload:) userInfo:nil repeats:YES];
        [_checkForUploadingTimer setTolerance:5.0f];
    }
    
    return self;
}

#pragma mark - Operation Methods

-(void)checkForPostUpload:(id)sender
{
    NSLog(@"Timer is checking for new posts.");
    
    //TODO: Check if there is network.
    
    for(NSDate* t in [_postUploader pendingPosts])
    {
        NSString *url = [_imageUploader urlWithTimestamp:t];
        
        NSLog(@"Ready URL: %@",url);
        
        if(url)
        {
            NSLog(@"Post ready for upload!");
            
            //Post ready for uploading.
            [_postUploader uploadPostWithTimestamp:t andImageUrl:url];
            
            //Remove url from the Image Operation.
            [_imageUploader removeUrlWithTimestamp:t];
        }
        else
        {
            //Image not uploaded yet.
        }
    }
    
}

-(void)uploadImage:(UIImage*)image withTimestamp:(NSDate*)timestamp
{
    //Upload image with timestasmp.
    [_imageUploader uploadImage:image withTimestamp:timestamp];
    [_checkForUploadingTimer fire];
}

-(void)uploadTextPost:(GLPPost*)post
{
    
}

-(void)setPost:(GLPPost*)post withTimestamp:(NSDate*)timestamp
{
    //Set post with timestamp.
    [_postUploader addPost:post withTimestamp:timestamp];
}

@end
