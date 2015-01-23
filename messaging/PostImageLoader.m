//
//  PostImageLoader.m
//  Gleepost
//
//  Created by Silouanos on 22/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Parent class that should be subclassed by singletons in order to fetch
//  images posts' view in a good way using specific approach.

#import "PostImageLoader.h"
#import "GLPiOSSupportHelper.h"
#import "GLPPostImageOperation.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSNotificationCenter+Utils.h"


@implementation ImageObject

- (id)initWithRemoteKey:(NSInteger)remoteKey andImageUrl:(NSString *)imageUrl
{
    self = [super init];
    
    if(self)
    {
        _remoteKey = remoteKey;
        _imageUrl = imageUrl;
    }
    
    return self;
}

@end

@interface PostImageLoader () <GLPPostImageOperationDelegate>

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) NSMutableDictionary *pendingOperations;

@end

@implementation PostImageLoader

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:GLPNOTIFICATION_NETWORK_UPDATE object:nil];
    }
    
    return self;
}

- (void)updateNetworkStatus:(NSNotification *)notification
{
    BOOL isNetwork = [notification.userInfo[@"status"] boolValue];
    DDLogInfo(@"PostImageLoader network status: %d", isNetwork);
    
    if(isNetwork)
    {
        [self retryLoadImagesAfterLostConnection];
    }
}

#pragma mark - Accessors

- (void)addImageObjects:(NSArray *)imageObjects
{
    for(ImageObject *p in imageObjects)
    {
        NSString *profileImageUrl = p.imageUrl;
        
        [[SDImageCache sharedImageCache] queryDiskCacheForKey:profileImageUrl done:^(UIImage *image, SDImageCacheType cacheType) {
            
            if(!image)
            {
                [self startLoadingImageIfNeededWithPostRemoteKey:p.remoteKey andImageUrl:profileImageUrl];
            }
        }];
    }
}

- (void)findImageWithUrl:(NSURL *)url callback:(void (^) (UIImage* image, BOOL found))callback
{
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:[url absoluteString] done:^(UIImage *image, SDImageCacheType cacheType) {
        
        if(image)
        {
            callback(image, YES);
        }
        else
        {
            callback(nil, NO);
        }
        
    }];
}

#pragma mark - Internal Operations

- (void)startLoadingImageIfNeededWithPostRemoteKey:(NSInteger)remoteKey andImageUrl:(NSString *)imageUrl
{
    if(![_pendingOperations objectForKey:@(remoteKey)])
    {
        [_pendingOperations setObject:imageUrl forKey:@(remoteKey)];
        
        [self loadImageWithRemoteKey:remoteKey andImageUrl:imageUrl];
    }
}

- (void)loadImageWithRemoteKey:(NSInteger)remoteKey andImageUrl:(NSString *)imageUrl
{
    DDLogDebug(@"PostImageLoader : image added %ld - %@", (long)remoteKey, imageUrl);
    
    GLPPostImageOperation *operation = [[GLPPostImageOperation alloc] initWithImageUrl:imageUrl andRemoteKey:remoteKey];
    
    [operation setDelegate:self];
    
    [_operationQueue addOperation:operation];
}

- (void)notifyCampusLiveWithImage:(UIImage *)image andPostRemoteKey:(NSInteger)remoteKey
{
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:self.nsNotificationName object:self userInfo:@{@"image_loaded" : image, @"remote_key" : @(remoteKey)}];
}

#pragma mark - Error methods

/**
 This method is called only if network is connected after its lost.
 It takes all the images that never load (because of loosing connection) -from the
 pendingOperations dictionary and adds them again on the queue in order to retry download them.
 */
- (void)retryLoadImagesAfterLostConnection
{
    for(NSNumber *remoteKey in self.pendingOperations)
    {
        [self loadImageWithRemoteKey:remoteKey.integerValue andImageUrl:[self.pendingOperations objectForKey:remoteKey]];
    }
}

#pragma mark - GLPCampusLiveImageOperationDelegate

- (void)operationFinishedWithImage:(UIImage *)image andRemoteKey:(NSInteger)remoteKey
{
    [_pendingOperations removeObjectForKey:@(remoteKey)];
    //    DDLogDebug(@"Current operations %@ count %lu", _operationQueue.operations, (unsigned long)_operationQueue.operationCount);
    [self notifyCampusLiveWithImage:image andPostRemoteKey:remoteKey];
    
}

@end
