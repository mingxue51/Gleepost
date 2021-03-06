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
#import "GLPiOSSupportHelper.h"

@interface GLPPostOperationManager ()

@property (strong, nonatomic) GLPImageUploaderManager *imageUploader;
@property (strong, nonatomic) GLPPostUploaderManager *postUploader;
@property (strong, nonatomic) NSTimer *checkForUploadingTimer;
@property (assign, nonatomic) BOOL isNetworkAvailable;

@end


//static dispatch_once_t *once_token;


@implementation GLPPostOperationManager

static GLPPostOperationManager *instance = nil;


@synthesize imageUploader = _imageUploader;
@synthesize postUploader = _postUploader;
@synthesize checkForUploadingTimer = _checkForUploadingTimer;

+ (GLPPostOperationManager *)sharedInstance
{
    static dispatch_once_t onceToken;
//    once_token = &onceToken;
    
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
        _checkForUploadingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(checkForPostUpload:) userInfo:nil repeats:YES];
        
        if(![GLPiOSSupportHelper isIOS6])
        {
            [_checkForUploadingTimer setTolerance:5.0f];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:@"GLPNetworkStatusUpdate" object:nil];

    }
    
    return self;
}

#pragma mark - Notification Methods

- (void)updateNetworkStatus:(NSNotification *)notification
{
    BOOL isNetwork = [notification.userInfo[@"status"] boolValue];
    DDLogInfo(@"Background requests manager network status update POST OPERATION: %d", isNetwork);
    
    self.isNetworkAvailable = isNetwork;
    
//    if(isNetwork)
//    {
//        [self.queue setSuspended:NO];
//        //        [self startConsuming];
//    } else
//    {
//        [self.queue setSuspended:YES];
//        //        [self suspendConsuming];
//    }
}


#pragma mark - Operation Methods

-(void)checkForPostUpload:(id)sender
{
    
//    if(self.isNetworkAvailable)
//    {
        for(NSDate* t in [_postUploader pendingPosts])
        {
            NSString *url = [_imageUploader urlWithTimestamp:t];
            
            DDLogInfo(@"Ready URL: %@",url);
            
            if(url)
            {
                DDLogInfo(@"Post ready for upload!");
                
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
//    }
//    else
//    {
//        //Spin.
//    }
}

-(void)uploadComment:(GLPComment*)comment
{
    [_postUploader addComment:comment];
}

-(NSArray *)getCommentsWithPostKey:(int)postKey
{
    return [_postUploader getPendingCommentsWithPostKey:postKey];
}

-(void)uploadImage:(UIImage*)image withTimestamp:(NSDate*)timestamp
{
    //Upload image with timestasmp.
    [_imageUploader uploadImage:image withTimestamp:timestamp];
    [_checkForUploadingTimer fire];
}

/**
 Cancel uploading post.
 
 @param postKey the post's local database key.
 
 @return YES if post pending, returns NO if the post is already uploaded.
 
 */
-(BOOL)cancelPostWithKey:(NSInteger)postKey
{
    NSDate *timestamp = [_postUploader cancelPendingPostWithKey:postKey];
    
    if(!timestamp)
    {
        return NO;
    }

    //Remove image from progress of uploading.
    [_imageUploader cancelImageWithTimestamp:timestamp];
    
    return YES;
}

-(void)uploadTextPost:(GLPPost*)post
{
    [_postUploader uploadTextPost:post];
}

-(void)stopTimer
{
    [self.checkForUploadingTimer invalidate];
    //once_token = 0;
}

-(void)setPost:(GLPPost*)post withTimestamp:(NSDate*)timestamp
{
    //Set post with timestamp.
    [_postUploader addPost:post withTimestamp:timestamp];
}

@end
