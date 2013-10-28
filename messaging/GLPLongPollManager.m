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
    
   // self.isContactsOperationRunning = NO;
    
    return self;
}

- (void)startLongPoll
{
    if(self.isOperationRunning) {
        NSLog(@"Long poll operation already running");
        return;
    }
    
    self.isOperationRunning = YES;
    
    __unsafe_unretained typeof(self) self_ = self;
    self.longPollOperation = [[LongPollOperation alloc] init];
    [self.longPollOperation setCompletionBlock:^{
        NSLog(@"Long poll operation finished");
        self_.isOperationRunning = NO;
    }];
    
    [self.queue addOperation:self.longPollOperation];
    
    
    //Added.
//    self.isContactsOperationRunning = YES;
//    
//    self.longPollContactOperation = [[LongPollContactsOperation alloc] init];
//    [self.longPollContactOperation setCompletionBlock:^{
//        NSLog(@"Long poll operation finished");
//        self_.isContactsOperationRunning = NO;
//    }];
//    
//    [self.queue addOperation:self.longPollContactOperation];
    
    NSLog(@"Start long poll operation");
}

- (void)stopLongPoll
{
    [self.longPollOperation cancel];
    
//    [self.longPollContactOperation cancel];
//    [self.queue cancelAllOperations];
//    [[WebClient sharedInstance] cancelAllHTTPOperationsWithMethod:@"GET" path:@"longpoll"];
    //[[[WebClient sharedInstance] operationQueue] cancelAllOperations];
    NSLog(@"Stop long poll operation");
}

@end
