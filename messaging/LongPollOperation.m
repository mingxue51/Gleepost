//
//  LongPollOperation.m
//  Gleepost
//
//  Created by Lukas on 10/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "LongPollOperation.h"
#import "WebClient.h"
#import "GLPConversationDao.h"
#import "GLPMessageDao.h"
#import "ConversationManager.h"
#import "DatabaseManager.h"

@interface LongPollOperation()

@property (assign, nonatomic) BOOL isRequestRunning;
@property (assign, nonatomic) BOOL requestShouldStop;

@end

@implementation LongPollOperation

@synthesize isRequestRunning = _isRequestRunning;
@synthesize requestShouldStop = _requestShouldStop;

- (void)main {
    @autoreleasepool {
        _isRequestRunning = NO;
        _requestShouldStop = NO;
        
        [self startRequest];
    }
}

- (void)startRequest
{
    if(self.isRequestRunning) {
        NSLog(@"Long poll request already running");
        return;
    }
    
    if(self.isCancelled) {
        NSLog(@"Long poll operation cancelled");
        self.isRequestRunning = NO;
        return;
    }
    
    if([self stopRequestIfShould]) {
        NSLog(@"Long poll operation should stop, so it does");
        return;
    }
    
    NSLog(@"Start long poll request");
    
    self.isRequestRunning = YES;
    
    [[WebClient sharedInstance] synchronousLongPollWithCallback:^(BOOL success, GLPMessage *message) {
        if(success) {
            NSLog(@"New message from long poll request: %@", message.content);
            [ConversationManager saveMessageFromLongpoll:message];
        } else {
            NSLog(@"Long poll request finished without result, restart");
        }
        
        self.isRequestRunning = NO;
        [self startRequest];
    }];
}



// Ask that request should stop if it's actually running
// Two control properties are synchronized
- (void)shouldStop
{
    @synchronized(self) {
        if(_isRequestRunning) {
            _requestShouldStop = YES;
        }
    }
}

// Ask that request should not stop anymore if it's already running
// Returns YES if request will continue, NO if it's not running anymore
- (BOOL)shouldNotStop
{
    @synchronized(self) {
        if(_isRequestRunning) {
            _requestShouldStop = NO;
            return YES;
        }
        
        return NO;
    }
}

// Check if request should stop, and update the other control property accordly
// Two control properties are synchronized
// Returns YES if request should stop, NO otherwise
- (BOOL)stopRequestIfShould
{
    @synchronized(self) {
        if(_requestShouldStop) {
            _isRequestRunning = NO;
            return YES;
        }
        
        return NO;
    }
}


#pragma mark - Gets and Sets

- (BOOL)isRequestRunning
{
    @synchronized(self) {
        return _isRequestRunning;
    }
}

- (void)setIsRequestRunning:(BOOL)isRequestRunning
{
    @synchronized(self) {
        _isRequestRunning = isRequestRunning;
    }
}

- (BOOL)requestShouldStop
{
    @synchronized(self) {
        return _requestShouldStop;
    }
}

- (void)setRequestShouldStop:(BOOL)requestShouldStop
{
    @synchronized(self) {
        _requestShouldStop = requestShouldStop;
    }
}

@end
