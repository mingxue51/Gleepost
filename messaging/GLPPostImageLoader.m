//
//  GLPPostImageLoader.m
//  Gleepost
//
//  Created by Silouanos on 14/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPPostImageLoader.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSNotificationCenter+Utils.h"

@interface GLPPostImageLoader ()

@property (strong, nonatomic) NSMutableDictionary *loadingImages;

@end

@implementation GLPPostImageLoader

@synthesize loadingImages = _loadingImages;

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
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:@"GLPNetworkStatusUpdate" object:nil];
        _loadingImages = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Modifiers

-(void)addPostsImages:(NSArray*)posts
{
    //TODO: Check if some posts are already in.
    
    
    for(GLPPost *p in posts)
    {
        NSNumber *currentRemoteKey = [NSNumber numberWithInt:p.remoteKey];
        
        if(![_loadingImages objectForKey:currentRemoteKey])
        {
            if(p.imagesUrls)
            {
                [_loadingImages setObject:[p.imagesUrls objectAtIndex:0]  forKey:[NSNumber numberWithInt:p.remoteKey]];
            }
        }
    }
    
    [self startLoadingImages];
}

#pragma mark - Helpers methods

-(BOOL)isPostEqual:(int*)postRemoteKey with:(int*)existPostRemoteKey
{
    if(postRemoteKey == existPostRemoteKey)
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - Client

-(void)startLoadingImages
{
    for(NSNumber *remoteKey in _loadingImages)
    {
        NSURL *imageUrl = [NSURL URLWithString:[_loadingImages objectForKey:remoteKey]];
        
        //Load the image.
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            
            NSData *data = [NSData dataWithContentsOfURL:imageUrl];
            UIImage *img = [[UIImage alloc] initWithData:data];
            
            
            NSLog(@"Image is ready for post:%d Image: %@ at %@",[remoteKey integerValue], img, [NSDate date]);

            
            if(img)
            {
                //Notify GLPTimelineViewController after finish.
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPPostImageUpladed" object:nil userInfo:@{@"RemoteKey":remoteKey,
                                                                                                                                    @"FinalImage":img}];
                
                //Delete the entry from the queue.
                [_loadingImages removeObjectForKey:remoteKey];
            }
            else
            {
                //TODO: No internet connection. Retry later.
            }
            

            
        }];
        
        [[[NSOperationQueue alloc] init] addOperation:operation];

    }
}


@end
