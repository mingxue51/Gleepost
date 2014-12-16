//
//  GLPCLPostImageLoader.m
//  Gleepost
//
//  Created by Silouanos on 16/12/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCLPostImageLoader.h"
#import "GLPPost.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "GLPiOSSupportHelper.h"
#import "GLPCampusLiveImageOperation.h"
#import "NSNotificationCenter+Utils.h"

@interface GLPCLPostImageLoader () <GLPCampusLiveImageOperationDelegate>

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) NSMutableDictionary *pendingOperations;

@end

@implementation GLPCLPostImageLoader

static GLPCLPostImageLoader *instance = nil;

+ (GLPCLPostImageLoader *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[GLPCLPostImageLoader alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _operationQueue = [[NSOperationQueue alloc] init];
        _pendingOperations = [[NSMutableDictionary alloc] init];
                
        if(![GLPiOSSupportHelper isIOS7])
        {
            _operationQueue.qualityOfService =  NSQualityOfServiceUtility;
        }
        
        [[NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(showCurrentOperationsInQueue) userInfo:nil repeats:YES] fire];
    }
    
    return self;
}

- (void)addPosts:(NSArray *)posts
{
    NSArray *imagePosts = [self imagePosts:posts];
    
    for(GLPPost *p in imagePosts)
    {
        NSString *profileImageUrl = p.imagesUrls[0];
        
        [[SDImageCache sharedImageCache] queryDiskCacheForKey:profileImageUrl done:^(UIImage *image, SDImageCacheType cacheType) {
            
            if(image)
            {
                [self notifyCampusLiveWithImage:image andPostRemoteKey:p.remoteKey];
            }
            else
            {
                [self startLoadingImageIfNeededWithPostRemoteKey:p.remoteKey andImageUrl:profileImageUrl];
            }
        }];
    }
}

- (void)startLoadingImageIfNeededWithPostRemoteKey:(NSInteger)remoteKey andImageUrl:(NSString *)imageUrl
{
    if(![_pendingOperations objectForKey:@(remoteKey)])
    {
        [_pendingOperations setObject:imageUrl forKey:@(remoteKey)];
        
        DDLogDebug(@"GLPCLPostImageLoader : image added %ld - %@", (long)remoteKey, imageUrl);
        
        GLPCampusLiveImageOperation *operation = [[GLPCampusLiveImageOperation alloc] initWithImageUrl:imageUrl andRemoteKey:remoteKey];
        
        [operation setDelegate:self];
        
        [_operationQueue addOperation:operation];
    }
}

- (void)notifyCampusLiveWithImage:(UIImage *)image andPostRemoteKey:(NSInteger)remoteKey
{
    DDLogDebug(@"GLPCLPostImageLoader : notifyCampusLiveWithImage %ld", (long)remoteKey);
    
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:[self generateNotificationWithRemoteKey:remoteKey] object:self userInfo:@{@"image_loaded" : image, @"remote_key" : @(remoteKey)}];
}

- (NSString *)generateNotificationWithRemoteKey:(NSInteger)remoteKey
{
    return [NSString stringWithFormat:@"%@_%@", GLPNOTIFICATION_CAMPUS_LIVE_IMAGE_LOADED, @(remoteKey)];
}

#pragma mark - GLPCampusLiveImageOperationDelegate

- (void)operationFinishedWithImage:(UIImage *)image andRemoteKey:(NSInteger)remoteKey
{
    [_pendingOperations removeObjectForKey:@(remoteKey)];
    DDLogDebug(@"Current operations %@ count %lu", _operationQueue.operations, (unsigned long)_operationQueue.operationCount);
    [self notifyCampusLiveWithImage:image andPostRemoteKey:remoteKey];

}

#pragma mark - Helpers

- (NSArray *)imagePosts:(NSArray *)posts
{
    NSPredicate *imagePosts = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        GLPPost *evPost = (GLPPost *)evaluatedObject;
        if([evPost imagePost])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }];
    
    
    return [posts filteredArrayUsingPredicate:imagePosts];
}

- (void)showCurrentOperationsInQueue
{
    DDLogDebug(@"Current operations in queue %@", _operationQueue.operations);
}

@end
