//
//  GLPPostUploaderManager.m
//  Gleepost
//
//  Created by Silouanos on 20/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPostUploaderManager.h"
#import "WebClient.h"
#import "GLPPostManager.h"
#import "NSNotificationCenter+Utils.h"


@interface GLPPostUploaderManager ()

@property (nonatomic, strong) NSMutableDictionary *readyPosts;

@end

@implementation GLPPostUploaderManager

@synthesize readyPosts = _readyPosts;

-(id)init
{
    self = [super init];
    
    if(self)
    {
        _readyPosts = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Getters Setters

-(NSDictionary*)pendingPosts
{
    return _readyPosts;
}

-(void)addPost:(GLPPost*)post withTimestamp:(NSDate*)timestamp
{
    [_readyPosts setObject:post forKey:timestamp];
}

-(void)removePostWithTimestamp:(NSDate*)timestamp
{
    [_readyPosts removeObjectForKey:timestamp];
}

#pragma mark - Client

-(void)uploadTextPost:(GLPPost*)textPost
{
    //Post ready to be uploaded.
    
    void (^_uploadContentBlock)(GLPPost*);
    
    
    @synchronized(_readyPosts)
    {
        _uploadContentBlock = ^(GLPPost* post){
            
            NSLog(@"Into uploadContentBlock");
            
            //Notify GLPTimelineViewController after finish.
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPPostUploaded" object:nil userInfo:@{@"remoteKey":[NSNumber numberWithInt:post.remoteKey],
                                                                                                                            @"imageUrl":[post.imagesUrls objectAtIndex:0],
                                                                                                                            @"key":[NSNumber numberWithInt:post.key]}];
        };
    }
    
    
    NSLog(@"Post uploading task started with post content: %@.",textPost.content);
    
    
    [[WebClient sharedInstance] createPost:textPost callbackBlock:^(BOOL success, int remoteKey) {
        
        
        textPost.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
        textPost.remoteKey = success ? remoteKey : 0;
        
        NSLog(@"!!Post uploaded with success: %d and post remoteKey: %d", success, textPost.remoteKey);
        
        
        [GLPPostManager updatePostAfterSending:textPost];
        
        _uploadContentBlock(textPost);
        
    }];

}

-(void)uploadPostWithTimestamp:(NSDate*)timestamp andImageUrl:(NSString*)url
{
    
    //Post ready to be uploaded.
    
    void (^_uploadImageContentBlock)(GLPPost*);
    
    GLPPost *post = nil;
    
    @synchronized(_readyPosts)
    {
        post = [_readyPosts objectForKey:timestamp];
        post.imagesUrls = [[NSArray alloc] initWithObjects:url, nil];
        
        _uploadImageContentBlock = ^(GLPPost* post){
            
            NSLog(@"Into uploadImageContentBlock");
            
            //Notify GLPTimelineViewController after finish.
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPPostUploaded" object:nil userInfo:@{@"remoteKey":[NSNumber numberWithInt:post.remoteKey],
                                                                                                                            @"imageUrl":[post.imagesUrls objectAtIndex:0],
                                                                                                                            @"key":[NSNumber numberWithInt:post.key]}];
        };
    }
    

    NSLog(@"Post uploading task started with post content: %@ and image url: %@.",post.content, [post.imagesUrls objectAtIndex:0]);
    
    
//    _incomingPost.imagesUrls = [[NSArray alloc] initWithObjects:[self.urls objectForKey:[NSNumber numberWithInt:1]], nil];
    
    [[WebClient sharedInstance] createPost:post callbackBlock:^(BOOL success, int remoteKey) {
        
        
        post.sendStatus = success ? kSendStatusSent : kSendStatusFailure;
        post.remoteKey = success ? remoteKey : 0;
        
        NSLog(@"!!Post uploaded with success: %d and post remoteKey: %d", success, post.remoteKey);

        
        [GLPPostManager updatePostAfterSending:post];
        
//        self.incomingKey = _incomingPost.key;
//        self.incomingRemoteKey = remoteKey;
        //self.imageUrl = [_incomingPost.imagesUrls objectAtIndex:0];
//        self.imageUrl = [self.urls objectForKey:[NSNumber numberWithInt:1]];
        
//        NSLog(@"IMAGE URL BEFORE INFORMATION: %@",self.imageUrl);
        
        _uploadImageContentBlock(post);
        
        if(success)
        {
            //Remove post from the NSDictionary.
            [self removePostWithTimestamp:timestamp];
        }
        
        //        [self cleanUpPost];
    }];

}

@end
