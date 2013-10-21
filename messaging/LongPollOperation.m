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

@interface LongPollOperation()

@property (assign, nonatomic) BOOL isRequestRunning;

@end

@implementation LongPollOperation

- (void)main {
    @autoreleasepool {
        self.isRequestRunning = NO;

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
        return;
    }
    
    self.isRequestRunning = YES;
    
    [[WebClient sharedInstance] longPollNewMessageCallbackBlock:^(BOOL success, GLPMessage *message) {
        
        if(success) {
            NSLog(@"New message from long poll: %@", message.content);
            [GLPMessageDao saveNewMessageWithPossiblyNewConversation:message];
        } else {
            NSLog(@"Long poll finished without result, restart");
        }
        
        self.isRequestRunning = NO;
        [self startRequest];
    }];
}

@end
