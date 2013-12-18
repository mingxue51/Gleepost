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

@end

@implementation GLPPostOperation

@synthesize delegate = _delegate;
@synthesize campusWallIndexpath = _campusWallIndexpath;
@synthesize incomingPost = _incomingPost;

- (void)main {
    
    @autoreleasepool
    {
        [self startProcessing];
        
    }
}

#pragma mark -
#pragma mark - Initialisation

-(id)initWithPost:(GLPPost*)post
{
    self = [super init];
    
    if(self)
    {
//        self.delegate = delegate; //Not used.
//        _campusWallIndexpath = indexPath;
        _incomingPost = post;
    }
    
    return self;
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
        
    };

    
    NSLog(@"Post uploading task started with post content: %@ and image url: %@.",_incomingPost.content, [_incomingPost.imagesUrls objectAtIndex:0]);
    
    
//    [GLPPostManager createLocalPost:_incomingPost];
    
    [[WebClient sharedInstance] createPost:_incomingPost callbackBlock:^(BOOL success, int remoteKey) {
        
        NSLog(@"!!Post uploaded with success: %d and remoteKey: %d", success, remoteKey);
        
        _incomingPost.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
        _incomingPost.remoteKey = success ? remoteKey : 0;
        
        [GLPPostManager updatePostAfterSending:_incomingPost];
        
        self.incomingKey = _incomingPost.key;
        self.incomingRemoteKey = remoteKey;
        self.imageUrl = [_incomingPost.imagesUrls objectAtIndex:0];
        
        _uploadContentBlock();
        
//        [self cleanUpPost];
    }];
    
    
    

    
}

//-()



@end
