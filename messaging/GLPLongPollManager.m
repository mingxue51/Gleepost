//
//  GLPLongPollManager.m
//  Gleepost
//
//  Created by Lukas on 10/21/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLongPollManager.h"
#import "LongPollOperation.h"

@interface GLPLongPollManager()

@property (strong, nonatomic) NSOperationQueue *queue;
@property (assign, nonatomic) BOOL isOperationRunning;

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
    
    return self;
}

- (void)startLongPoll
{
    if(self.isOperationRunning) {
        NSLog(@"Long poll operation already running");
        return;
    }
    
    self.isOperationRunning = YES;
    
    LongPollOperation *operation = [[LongPollOperation alloc] init];
    [operation setCompletionBlock:^{
        NSLog(@"Long poll operation finished");
        self.isOperationRunning = NO;
    }];
    
    [self.queue addOperation:operation];
    NSLog(@"Start long poll operation");
}

- (void)stopLongPoll
{
    [self.queue cancelAllOperations];
    NSLog(@"Stop long poll operation");
}

@end
