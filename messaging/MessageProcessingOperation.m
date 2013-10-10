//
//  MessageProcessingOperation.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "MessageProcessingOperation.h"
#import "LocalMessage.h"
#import "RemoteMessage.h"
#import "WebClient.h"

@interface MessageProcessingOperation()

@property (assign, nonatomic) BOOL isOperationRunning;
@property (assign, nonatomic) NSInteger retries;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation MessageProcessingOperation

- (void)main {
    @autoreleasepool {
        NSLog(@"Message processing operation start");
        NSLog(@"Check local messages");
        
        self.context = [NSManagedObjectContext MR_contextForCurrentThread];
        
        NSArray *localMessages = [LocalMessage MR_findAllInContext:self.context];
        
        for(LocalMessage *localMessage in localMessages) {
            NSLog(@"Post message %@", localMessage.remoteMessage.content);
            self.retries = 0;
            
            [self postMessage:localMessage];
            
            if(self.retries > 3) {
                NSLog(@"Abort message processing");
                break;
            }
        }
        
        NSLog(@"Message processing operation stop");
    }
}
                   
- (void)postMessage:(LocalMessage *)localMessage
{
    // blocks until response is delivered
    [[WebClient sharedInstance] createMessageSynchronously:localMessage.remoteMessage callbackBlock:^(BOOL success, NSInteger remoteKey) {
        
        // message posted with success
        if(success) {
            localMessage.remoteMessage.sendStatus = [NSNumber numberWithInt:kSensStatusSent];
            [localMessage MR_deleteInContext:self.context];
            [self.context MR_saveToPersistentStoreAndWait];
        }
        
        // error
        else {
            self.retries++;
            
            // retry 3 times
            if(self.retries <= 3) {
                [self postMessage:localMessage];
            }
        }
    }];
}

@end
