//
//  GLPPostImageLoader.m
//  Gleepost
//
//  Created by Silouanos on 14/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPPostImageLoader.h"
#import "NSNotificationCenter+Utils.h"
#import "WebClient.h"
#import "NSMutableArray+QueueAdditions.h"
#include <pthread.h>

@interface GLPPostImageLoader ()

@property (strong, nonatomic) NSMutableDictionary *loadingImages;
@property (strong, nonatomic) NSMutableArray *imagesNotStarted;
@property (strong, nonatomic) NSThread *thread1;
@property (strong, nonatomic) NSThread *thread2;
@property (assign, nonatomic) BOOL networkAvailable;

@end

@implementation GLPPostImageLoader

@synthesize loadingImages = _loadingImages;
@synthesize imagesNotStarted = _imagesNotStarted;


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
        _loadingImages = [[NSMutableDictionary alloc] init];
        _imagesNotStarted = [[NSMutableArray alloc] init];
        
        self.networkAvailable = YES;

        //Called when there is change in status.
        
        [[WebClient sharedInstance] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {

            NSLog(@"NETWORK: %d",(status == AFNetworkReachabilityStatusNotReachable) ? NO : YES);
            BOOL currentStatus = (status == AFNetworkReachabilityStatusNotReachable) ? NO : YES;
            
            if(currentStatus)
            {
                self.networkAvailable = YES;
                
                [self startConsume];
            }
            else
            {
                self.networkAvailable = NO;
                //No network.
                [self cancelOperations];
            }
        
        }];
    }
    
    return self;
}


#pragma mark - Modifiers

-(void)addPostsImages:(NSArray*)posts
{
    BOOL newPost = NO;
 

    for(GLPPost *p in posts)
    {
        NSNumber *currentRemoteKey = [NSNumber numberWithInt:p.remoteKey];
        
        
        //Check if some posts are already in.
        
        if(![_loadingImages objectForKey:currentRemoteKey])
        {
            if(p.imagesUrls)
            {
                [_imagesNotStarted enqueue:currentRemoteKey];

                [_loadingImages setObject:[p.imagesUrls objectAtIndex:0]  forKey:[NSNumber numberWithInt:p.remoteKey]];
                newPost = YES;
            }
        }
    }
    
    if(newPost)
    {
        [self startConsume];
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
    for (NSNumber *key in _loadingImages)
    {
        for(NSNumber *arrayKey in _imagesNotStarted)
        {
            if([arrayKey compare:key] == NSOrderedSame)
            {
                exist = YES;
                break;
            }
        }
        
        if(!exist)
        {
            [_imagesNotStarted insertObject:key atIndex:0];
        }
        else
        {
            exist = NO;
        }
    }
    
}




#pragma mark - Selectors

-(void)consumeQueue:(id)sender
{
    while (_imagesNotStarted.count != 0)
    {
        
        NSNumber* remoteKey = nil;
        NSString* urlStr = nil;
        @synchronized(_loadingImages)
        {
            remoteKey = [_imagesNotStarted dequeue];
            //Take the one item from queue.
            //remoteKey = (NSNumber*)[[_loadingImages allKeys] objectAtIndex:0]; // Assumes 'message' is not empty
            urlStr = (NSString*)[_loadingImages objectForKey:remoteKey];
            
//            [_loadingImages removeObjectForKey:remoteKey];
            
            mach_port_t machTID = pthread_mach_thread_np(pthread_self());
            
            NSLog(@"RemoteKey token: %@ with thread: %x", remoteKey, machTID);
        }

       
        NSURL *imageUrl = [NSURL URLWithString:urlStr];
        
        
        NSData *data = [NSData dataWithContentsOfURL:imageUrl];
        UIImage *img = [[UIImage alloc] initWithData:data];
        
        
        NSLog(@"Image is ready for post:%d Image: %@ at %@ from thread: %@",[remoteKey integerValue], img, [NSDate date], [NSThread currentThread]);
        
        
        if(img)
        {
            //Notify GLPTimelineViewController after finish.
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPPostImageUploaded" object:nil userInfo:@{@"RemoteKey":remoteKey,
                                                                                                                                @"FinalImage":img}];
            
            //Delete the entry from the queue.
            [_loadingImages removeObjectForKey:remoteKey];
        }
        else
        {
            //TODO: No internet connection. Retry later.
            break;
        }
        
    }
}


#pragma mark - Client

-(void)startConsume
{
    if(self.networkAvailable)
    {
        //If there is network then start threads.
        [NSThread detachNewThreadSelector:@selector(consumeQueue:) toTarget:self withObject:nil];
        [NSThread detachNewThreadSelector:@selector(consumeQueue:) toTarget:self withObject:nil];
    }
}



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
