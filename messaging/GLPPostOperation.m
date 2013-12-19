//
//  GLPTaskOperation.m
//  Gleepost
//
//  Created by Silouanos on 18/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPostOperation.h"
#import "NSNotificationCenter+Utils.h"
#import "GLPPostManager.h"
#import "WebClient.h"

@interface GLPPostOperation ()

@property (assign, nonatomic) int incomingRemoteKey;
@property (strong, nonatomic) NSString *imageUrl;
@property (assign, nonatomic) int incomingKey;
@property (strong, nonatomic) NSMutableDictionary *urls;

@end

@implementation GLPPostOperation

@synthesize delegate = _delegate;
@synthesize campusWallIndexpath = _campusWallIndexpath;
@synthesize incomingPost = _incomingPost;

- (void)main {
    
    @autoreleasepool
    {
        NSLog(@"Images URL: %@",self.urls);
        [self startProcessing];
        
    }
}

//-(void)start
//{
//    // Ensure this operation is not being restarted and that it has not been cancelled
//    if(self.isFinished || self.isCancelled)
//    {
//       
//        return;
//    }
//    
//    // From this point on, the operation is officially executing--remember, isExecuting
//    // needs to be KVO compliant!
//    [self willChangeValueForKey:@"isExecuting"];
////    self.isExecuting = YES;
//    [self didChangeValueForKey:@"isExecuting"];
//}

- (BOOL)isConcurrent
{
    return YES;
}

#pragma mark -
#pragma mark - Initialisation

-(id)initWithPost:(GLPPost*)post andImages:(NSMutableDictionary *)urls
{
    self = [super init];
    
    if(self)
    {
//        self.delegate = delegate; //Not used.
//        _campusWallIndexpath = indexPath;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploaded:) name:@"GLPImageUploaded1" object:nil];
        self.urls = urls;
        _incomingPost = post;
    }
    
    return self;
}

-(void)addPostImageUrl:(NSString*)url
{
    NSLog(@"Add Post Image URL: %@",url);
    //_incomingPost.imagesUrls = [[NSArray alloc] initWithObjects:url, nil];
}

#pragma mark -
#pragma mark - Uploading post

-(void)startProcessing
{
    void (^_uploadContentBlock)();
    
    _uploadContentBlock = ^{
        
        NSLog(@"Into uploadContentBlock");
        
        //Notify GLPTimelineViewController after finish.
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPPostUploaded" object:nil userInfo:@{@"remoteKey":[NSNumber numberWithInt:self.incomingRemoteKey],
                                                                                                                        @"imageUrl":self.imageUrl,
                                                                                                                        @"key":[NSNumber numberWithInt:self.incomingKey]}];
        
//        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPImageUploaded" object:nil userInfo:@{@"remoteKey":[NSNumber numberWithInt:self.incomingRemoteKey],
//                                                                                                                        @"imageUrl":self.imageUrl,
//                                                                                                                        @"key":[NSNumber numberWithInt:self.incomingKey]}];
        
        
    };

  
    
    NSLog(@"Post uploading task started with post content: %@ and image url: %@.",_incomingPost.content, [_incomingPost.imagesUrls objectAtIndex:0]);
    
    NSLog(@"URLS: %@",self.urls);
//    [GLPPostManager createLocalPost:_incomingPost];
    
    _incomingPost.imagesUrls = [[NSArray alloc] initWithObjects:[self.urls objectForKey:[NSNumber numberWithInt:1]], nil];
    
    [[WebClient sharedInstance] createPost:_incomingPost callbackBlock:^(BOOL success, int remoteKey) {
        
        NSLog(@"!!Post uploaded with success: %d and remoteKey: %d", success, remoteKey);
        
        _incomingPost.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
        _incomingPost.remoteKey = success ? remoteKey : 0;
        
        [GLPPostManager updatePostAfterSending:_incomingPost];
        
        self.incomingKey = _incomingPost.key;
        self.incomingRemoteKey = remoteKey;
        //self.imageUrl = [_incomingPost.imagesUrls objectAtIndex:0];
        self.imageUrl = [self.urls objectForKey:[NSNumber numberWithInt:1]];
        NSLog(@"IMAGE URL BEFORE INFORMATION: %@",self.imageUrl);
        
        _uploadContentBlock();
        
//        [self cleanUpPost];
    }];
    
    
    

    
}

//-()



@end
