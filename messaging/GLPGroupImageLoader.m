//
//  GLPGroupImageLoader.m
//  Gleepost
//
//  Created by Silouanos on 10/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPGroupImageLoader.h"
#import "GLPGroup.h"
#import "NSNotificationCenter+Utils.h"
#import "NSMutableArray+QueueAdditions.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation GLPGroupImageLoader

static GLPGroupImageLoader *instance = nil;

+ (GLPGroupImageLoader *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[GLPGroupImageLoader alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
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
        
        DDLogInfo(@"Continue all operations of loading group images.");
        
        [self startConsume];
        
    } else
    {
        DDLogInfo(@"Cancel all operations of loading group images.");
        
        self.networkAvailable = NO;
        //No network.
        [self cancelOperations];
        
    }
}

#pragma mark - Modifiers

-(void)addGroupsImages:(NSArray *)groups
{
    
    groups = [self findImageGroups:groups];
    
    __block BOOL newGroup = NO;
    
    __block BOOL readyToConsume = NO;
    
    for(int i = 0; i<groups.count; ++i)
    {
        GLPGroup *group = [groups objectAtIndex:i];
        
        //If image exist in cache fetch it and send it to campus wall.
        
        [[SDImageCache sharedImageCache] queryDiskCacheForKey:group.groupImageUrl done:^(UIImage *image, SDImageCacheType cacheType) {
            
            if(image)
            {
                //Inform Campus Wall.
//                [self notifyGroupsViewControllerWithRemoteKey:[NSNumber numberWithInt:group.remoteKey] andImage:image];
            }
            else
            {
                //Check if some posts are already in.
                
                newGroup = [self addGroupImageInQueueWithGroup:group];
                
                if(newGroup)
                {
                    readyToConsume = YES;
                }
                
            }
            
            if(readyToConsume /* && posts.count - 1 == i */)
            {
                DDLogInfo(@"Group image loader starts consuming");
                
                [self startConsume];
                
                readyToConsume = NO;
            }
            
        }];
    }
}

#pragma mark - Client

- (void)startConsume
{
    if(self.networkAvailable)
    {
        //If there is network then start threads.
        [NSThread detachNewThreadSelector:@selector(consumeQueue:) toTarget:self withObject:nil];
        [NSThread detachNewThreadSelector:@selector(consumeQueue:) toTarget:self withObject:nil];
    }
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
 Add group image url and group remote key to the queue.
 imagesNotStarted array is used to track all the images are not loaded yet.
 loadingImages dictionary stored all the urls that are ready to downloaded.
 
 @param currentRemoteKey post's remote key.
 @return YES if the image is not loaded yet otherwise NO.
 */

-(BOOL)addGroupImageInQueueWithGroup:(GLPGroup *)group
{
    NSNumber *currentRemoteKey = [NSNumber numberWithInt:group.remoteKey];
    
    if(![self.loadingImages objectForKey:currentRemoteKey])
    {
        [self.imagesNotStarted enqueue:currentRemoteKey];
        
        [self.loadingImages setObject:group.groupImageUrl forKey:[NSNumber numberWithInt:group.remoteKey]];
        
        return YES;
    }
    
    return NO;
}

-(NSArray *)findImageGroups:(NSArray *)groups
{
    NSMutableArray *imageGroups = [[NSMutableArray alloc] init];
    
    for(GLPGroup *group in groups)
    {
        if(group.groupImageUrl)
        {
            [imageGroups addObject:group];
        }
    }
    
    return imageGroups;
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
        
        
        NSURL *imageUrl = [NSURL URLWithString:urlStr];
        
        
        NSData *data = [NSData dataWithContentsOfURL:imageUrl];
        UIImage *img = [[UIImage alloc] initWithData:data];
        
        
        //        DDLogDebug(@"Image ready: %@", img);
        
        
        
        if(img)
        {
            //Save image with image url.
            [[SDImageCache sharedImageCache] storeImage:img forKey:urlStr];
            
            
            //Notify GLPTimelineViewController after finish.
//            [self notifyGroupsViewControllerWithRemoteKey:remoteKey andImage:img];
            
            //Delete the entry from the queue.
            [self.loadingImages removeObjectForKey:remoteKey];
        }
        else
        {
            //TODO: No internet connection. Retry later.
            DDLogInfo(@"GLPGroupImageLoader : Failed to fetch image with url %@", imageUrl);
            
            break;
        }
        
    }
}

#pragma mark - Notifications

-(void)notifyGroupsViewControllerWithRemoteKey:(NSNumber *)remoteKey andImage:(UIImage *)image
{
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_GROUP_IMAGE_LOADED object:nil userInfo:@{@"RemoteKey":remoteKey, @"FinalImage":image}];
}

@end
