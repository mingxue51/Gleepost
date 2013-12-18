//
//  GLPQueueManager.m
//  Gleepost
//
//  Created by Silouanos on 18/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPQueueManager.h"
#import "GLPPostOperation.h"

@interface GLPQueueManager ()

@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSMutableDictionary *queueStatus;
@property (assign, nonatomic) BOOL isOperationRunning;
@property (assign, nonatomic) BOOL isNetworkAvailable;

@end

static GLPQueueManager *instance = nil;

@implementation GLPQueueManager

+ (GLPQueueManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPQueueManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if(!self)
    {
        return nil;
    }
    
    self.queue = [[NSOperationQueue alloc] init];
    self.isOperationRunning = NO;
    self.isNetworkAvailable = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:@"GLPNetworkStatusUpdate" object:nil];
    
    return self;
}

- (void)updateNetworkStatus:(NSNotification *)notification
{
    BOOL isNetwork = [notification.userInfo[@"status"] boolValue];
    NSLog(@"Background requests manager network status update: %d", isNetwork);
    
    self.isNetworkAvailable = isNetwork;
    
    if(isNetwork)
    {
        [self.queue setSuspended:NO];
//        [self startConsuming];
    } else
    {
        [self.queue setSuspended:YES];
//        [self suspendConsuming];
    }
}

-(void)uploadPost:(GLPPost*)post
{
    GLPPostOperation *postOperation = [[GLPPostOperation alloc] initWithPost:post];
    
    [postOperation setCompletionBlock:^{
       
        NSLog(@"Post uploaded.");
    }];
    
    [postOperation setQueuePriority:NSOperationQueuePriorityVeryHigh];

    [self.queue addOperation:postOperation];
}

-(void)uploadComment
{
    
}

-(void)startConsuming
{
    
}

-(void)suspendConsuming
{
    
}


@end
