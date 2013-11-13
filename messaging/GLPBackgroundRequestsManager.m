//
//  GLPLongPollManager.m
//  Gleepost
//
//  Created by Lukas on 10/21/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPBackgroundRequestsManager.h"
#import "LongPollOperation.h"
#import "WebClient.h"
#import "LongPollContactsOperation.h"
#import "GLPGetNotificationsOperation.h"

@interface GLPBackgroundRequestsManager()

@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSOperationQueue *notificationsQueue;

@property (assign, nonatomic) BOOL isOperationRunning;
@property (assign, nonatomic) BOOL isNotificationOperationRunning;

@property (strong, nonatomic) LongPollOperation *longPollOperation;
@property (strong, nonatomic) GLPGetNotificationsOperation *getNotificationsOperation;

@end

@implementation GLPBackgroundRequestsManager

static GLPBackgroundRequestsManager *instance = nil;

+ (GLPBackgroundRequestsManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPBackgroundRequestsManager alloc] init];
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
    self.notificationsQueue = [[NSOperationQueue alloc] init];
    self.isOperationRunning = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:@"GLPNetworkStatusUpdate" object:nil];
    
    return self;
}

- (void)updateNetworkStatus:(NSNotification *)notification
{
    BOOL isNetwork = [notification.userInfo[@"status"] boolValue];
    NSLog(@"Background requests manager network status update: %d", isNetwork);

    if(isNetwork) {
        [self startAll];
    } else {
        [self stopAll];
    }
}

- (void)startAll
{
    [self startLongPoll];
    [self startGetNotifications];
}

- (void)stopAll
{
    [self stopLongPoll];
    [self stopGetNotifications];
}


#pragma mark - Long poll

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


#pragma mark - Notifications

- (void)startGetNotifications
{
    if(![WebClient sharedInstance].isNetworkAvailable) {
        NSLog(@"Does not start get notifications operation because network is not available");
        return;
    }
    
    if(self.isNotificationOperationRunning) {
        return;
    }
    
    self.isNotificationOperationRunning = YES;
    
    __unsafe_unretained typeof(self) self_ = self;
    self.getNotificationsOperation = [[GLPGetNotificationsOperation alloc] init];
    [self.getNotificationsOperation setCompletionBlock:^{
        NSLog(@"Get notifications operation finished");
        self_.isNotificationOperationRunning = NO;
    }];
    
    [self.queue addOperation:self.getNotificationsOperation];
    
    NSLog(@"Start get notifications operation");
}

- (void)stopGetNotifications
{
    [self.getNotificationsOperation cancel];
    self.isNotificationOperationRunning = NO;
    NSLog(@"Request to stop get notifications operation");
}

@end
