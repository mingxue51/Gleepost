//
//  GLPPostImageLoader.m
//  Gleepost
//
//  Created by Silouanos on 14/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPPostImageLoader.h"
#import "NSNotificationCenter+Utils.h"
#import "NSMutableArray+QueueAdditions.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface GLPPostImageLoader ()

//@property (strong, nonatomic) NSMutableDictionary *loadingImages;
//@property (strong, nonatomic) NSMutableArray *imagesNotStarted;
//@property (assign, nonatomic) BOOL networkAvailable;

@end

@implementation GLPPostImageLoader

static GLPPostImageLoader *instance = nil;

+ (GLPPostImageLoader *)sharedInstance
{
    static dispatch_once_t onceToken;
    //    once_token = &onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[GLPPostImageLoader alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
//        _loadingImages = [[NSMutableDictionary alloc] init];
//        _imagesNotStarted = [[NSMutableArray alloc] init];
//        
//        self.networkAvailable = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:GLPNOTIFICATION_NETWORK_UPDATE object:nil];
    }
    
    return self;
}

- (void)updateNetworkStatus:(NSNotification *)notification
{
    BOOL isNetwork = [notification.userInfo[@"status"] boolValue];
    
    if(isNetwork)
    {
        self.networkAvailable = YES;
        
        FLog(@"GLPPostImageLoader : Continue all operations of loading images.");
        
        [super startConsume];

    } else
    {
        FLog(@"GLPPostImageLoader : Cancel all operations of loading images.");
        
        self.networkAvailable = NO;
        //No network.
        [self cancelOperations];

    }
}


#pragma mark - Modifiers

-(void)addPostsImages:(NSArray *)posts /*fromCampusLive:(BOOL)fromCampusLive*/
{
    
    posts = [self findImagePosts:posts];
    
    __block BOOL newPost = NO;
 
    __block BOOL readyToConsume = NO;
    
    for(int i = 0; i<posts.count; ++i)
    {
        GLPPost *p = [posts objectAtIndex:i];
        
        //If image exist in cache fetch it and send it to campus wall.
        
        [[SDImageCache sharedImageCache] queryDiskCacheForKey:p.imagesUrls[0] done:^(UIImage *image, SDImageCacheType cacheType) {
           
            if(image)
            {
                //Inform Campus Wall.
//                [self notifyCampusWallWithRemoteKey:[NSNumber numberWithInteger:p.remoteKey] andImage:image];
            }
            else
            {                
                //Check if some posts are already in.
                
                newPost = [self addPostImageInQueueWithPost:p];
                
                if(newPost)
                {
                    readyToConsume = YES;
                }

            }
            
            if(readyToConsume /* && posts.count - 1 == i */)
            {
                DDLogInfo(@"Image loader starts consuming");
                
                [super startConsume];
                
                readyToConsume = NO;
            }
            
        }];
    }
}

#pragma mark - Accessors

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

#pragma mark - Helpers methods

/**
 Cancel the execution of the two threads and refill the array with the
 images' remote keys that were not finished.
 
 */
-(void)cancelOperations
{
    BOOL exist = NO;
    
    //Refill the array with the not finished remote keys.
    for (NSNumber *key in self.loadingImages)
    {
        for(NSNumber *arrayKey in self.imagesNotStarted)
        {
            if([arrayKey compare:key] == NSOrderedSame)
            {
                exist = YES;
                break;
            }
        }
        
        if(!exist)
        {
            [self.imagesNotStarted insertObject:key atIndex:0];
        }
        else
        {
            exist = NO;
        }
    }
    
}

/**
 Add post image url and post remote key to the queue.
 imagesNotStarted array is used to track all the images are not loaded yet.
 loadingImages dictionary stored all the urls that are ready to downloaded.
 
 @param currentRemoteKey post's remote key.
 @param
 */

-(BOOL)addPostImageInQueueWithPost:(GLPPost *)p
{
    NSNumber *currentRemoteKey = [NSNumber numberWithInteger:p.remoteKey];
    
    if(![self.loadingImages objectForKey:currentRemoteKey])
    {
        [self.imagesNotStarted enqueue:currentRemoteKey];
        
        [self.loadingImages setObject:[p.imagesUrls objectAtIndex:0]  forKey:[NSNumber numberWithInteger:p.remoteKey]];
        
        return YES;
    }
    
    return NO;
}

-(NSArray *)findImagePosts:(NSArray *)posts
{
    NSMutableArray *imagePosts = [[NSMutableArray alloc] init];
    
    for(GLPPost *p in posts)
    {
        if([p imagePost] && !p.finalImage)
        {
            [imagePosts addObject:p];
        }
    }
    
    return imagePosts;
}

#pragma mark - Selectors

-(void)consumeQueue:(id)sender
{
    while (self.imagesNotStarted.count != 0)
    {
        NSNumber* remoteKey = nil;
        NSString* urlStr = nil;
        @synchronized(self.loadingImages)
        {
            
            if(self.imagesNotStarted.count == 0)
            {
                continue;
            }
            
            remoteKey = [self.imagesNotStarted dequeue];
            //Take the one item from queue.
            //remoteKey = (NSNumber*)[[_loadingImages allKeys] objectAtIndex:0]; // Assumes 'message' is not empty
            urlStr = (NSString*)[self.loadingImages objectForKey:remoteKey];
            
//            [_loadingImages removeObjectForKey:remoteKey];
            
//            mach_port_t machTID = pthread_mach_thread_np(pthread_self());
            
//            NSLog(@"RemoteKey token: %@ with thread: %x", remoteKey, machTID);
        }

        DDLogDebug(@"Url string %@", urlStr);
       
        NSURL *imageUrl = [NSURL URLWithString:urlStr];
        
        
        NSData *data = [NSData dataWithContentsOfURL:imageUrl];
        UIImage *img = [[UIImage alloc] initWithData:data];
        
        
//        DDLogDebug(@"Image ready: %@", img);
        
        
        
        if(img)
        {
            //Save image with image url.
            [[SDImageCache sharedImageCache] storeImage:img forKey:urlStr];

            
            //Notify GLPTimelineViewController after finish.
//            [self notifyCampusWallWithRemoteKey:remoteKey andImage:img];
            [self notifyViewControllerToRefreshCellWithRemoteKey:remoteKey];
            
            //Delete the entry from the queue.
            [self.loadingImages removeObjectForKey:remoteKey];
        }
        else
        {
            //TODO: No internet connection or the request timed out. Retry later.
            FLog(@"GLPPostImageLoader : No network or the request timed out.");
            
            break;
        }
        
    }
}

#pragma mark - Notifications

- (void)notifyViewControllerToRefreshCellWithRemoteKey:(NSNumber *)remoteKey
{
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil userInfo:@{@"RemoteKey":remoteKey}];
}

-(void)notifyCampusWallWithRemoteKey:(NSNumber *)remoteKey andImage:(UIImage *)image
{
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil userInfo:@{@"RemoteKey":remoteKey, @"FinalImage":image}];
}

- (void)notifyCampusLiveWithRemoteKey:(NSNumber *)remoteKey andImage:(UIImage *)image
{
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_POST_IMAGE_LOADED object:nil userInfo:@{@"RemoteKey":remoteKey, @"FinalImage":image}];

}

#pragma mark - Client

//-(void)startConsume
//{
//    if(self.networkAvailable)
//    {
//        
//        //If there is network then start threads.
//        [NSThread detachNewThreadSelector:@selector(consumeQueue:) toTarget:self withObject:nil];
//        [NSThread detachNewThreadSelector:@selector(consumeQueue:) toTarget:self withObject:nil];
//    }
//}



//-(void)startLoadingImages
//{
//    for(NSNumber *remoteKey in _loadingImages)
//    {
//        NSURL *imageUrl = [NSURL URLWithString:[_loadingImages objectForKey:remoteKey]];
//        
//        //Load the image.
//        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
//            
//            
//            NSData *data = [NSData dataWithContentsOfURL:imageUrl];
//            UIImage *img = [[UIImage alloc] initWithData:data];
//            
//            
//            NSLog(@"Image is ready for post:%d Image: %@ at %@",[remoteKey integerValue], img, [NSDate date]);
//
//            
//            if(img)
//            {
//                //Notify GLPTimelineViewController after finish.
//                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPPostImageUpladed" object:nil userInfo:@{@"RemoteKey":remoteKey,
//                                                                                                                                    @"FinalImage":img}];
//                
//                //Delete the entry from the queue.
//                [_loadingImages removeObjectForKey:remoteKey];
//            }
//            else
//            {
//                //TODO: No internet connection. Retry later.
//            }
//            
//
//            
//        }];
//        
//        [[[NSOperationQueue alloc] init] addOperation:operation];
//
//    }
//}


@end
