//
//  GLPLongPollManager.m
//  Gleepost
//
//  Created by Lukas on 10/21/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLongPollManager.h"
#import "LongPollOperation.h"
#import "WebClient.h"
#import "LongPollContactsOperation.h"

@interface GLPLongPollManager()

@property (strong, nonatomic) NSOperationQueue *queue;
@property (assign, nonatomic) BOOL isOperationRunning;
@property (strong, nonatomic) LongPollOperation *longPollOperation;

//Added.
//@property (strong, nonatomic) LongPollContactsOperation *longPollContactOperation;
//@property (assign, nonatomic) BOOL isContactsOperationRunning;

@end

@implementation GLPLongPollManager

static GLPLongPollManager *instance = nil;

+ (GLPLongPollManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPLongPollManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.queue = [[NSOperationQueue alloc] init];
    self.isOperationRunning = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:@"GLPNetworkStatusUpdate" object:nil];
    
    return self;
}

- (void)updateNetworkStatus:(NSNotification *)notification
{
    BOOL isNetwork = [notification.userInfo[@"status"] boolValue];
    NSLog(@"Long poll manager network status update: %d", isNetwork);

    if(isNetwork) {
        [self startLongPoll];
    } else {
        [self stopLongPoll];
    }
}

- (void)startLongPoll
{
    if(![WebClient sharedInstance].isNetworkAvailable) {
        NSLog(@"Does not start long poll operation because network is not available");
        return;
    }
    
    if(self.isOperationRunning) {
        // operation is alreay running
        // maybe it was requested to stop, but did not have to time execute
        // thus, cancel the stop request
        BOOL willContinue = [self.longPollOperation shouldNotStop];
        
        // request will continue
        if(willContinue) {
            NSLog(@"Long poll operation already running, and will continue to run");
            return;
        }
        
        // otherwise the request stop or will stop, so we recreate new one
    }
    
    self.isOperationRunning = YES;
    
    __unsafe_unretained typeof(self) self_ = self;
    self.longPollOperation = [[LongPollOperation alloc] init];
    [self.longPollOperation setCompletionBlock:^{
        NSLog(@"Long poll operation finished");
        self_.isOperationRunning = NO;
    }];
    
    [self.queue addOperation:self.longPollOperation];
    
    NSLog(@"Start long poll operation");
}

- (void)stopLongPoll
{
    // request to stop the request
    // however, it may not stop if request is processing
    [self.longPollOperation shouldStop];

    NSLog(@"Request to stop long poll operation");
}

@end
