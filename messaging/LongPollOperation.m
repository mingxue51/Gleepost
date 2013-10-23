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
        [self startRequest];
    }
}

- (void)startRequest
{
    if(self.isRequestRunning) {
        NSLog(@"Long poll request already running");
        return;
    }
    
    if([self isCancelled]) {
        NSLog(@"Long poll operation cancelled");
        return;
    }
    
    NSLog(@"Start long poll request");
    
    self.isRequestRunning = YES;
    
    [[WebClient sharedInstance] longPollNewMessageCallbackBlock:^(BOOL success, GLPMessage *message) {
        
        if(success) {
            NSLog(@"New message from long poll request: %@", message.content);
            
            GLPMessage *existingMessage = [GLPMessageDao findByRemoteKey:message.remoteKey];
            if(!existingMessage) {
                [GLPMessageDao saveNewMessageWithPossiblyNewConversation:message];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPNewMessage" object:nil userInfo:@{@"message":message}];
            } else {
                NSLog(@"Insert message that already exists with the remote key %d : %@", message.remoteKey, message.content);
            }
        } else {
            NSLog(@"Long poll request finished without result, restart");
        }
        
        self.isRequestRunning = NO;
        [self startRequest];
    }];
}

@end
