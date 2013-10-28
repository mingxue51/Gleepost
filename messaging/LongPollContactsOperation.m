//
//  LongPollContactsOperation.m
//  Gleepost
//
//  Created by Σιλουανός on 27/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//
//  CLASS NOT USED AT THE MOMENT.
//

#import "LongPollContactsOperation.h"
#import "WebClient.h"
#import "NotificationsManager.h"

@interface LongPollContactsOperation()

@property (assign, nonatomic) BOOL isRequestRunning;

@end

@implementation LongPollContactsOperation

- (void)main {
    @autoreleasepool {
        self.isRequestRunning = NO;
        [self startRequest];
    }
}

- (void)startRequest
{
    if(self.isRequestRunning) {
        NSLog(@"Long contact poll request already running");
        return;
    }
    
    if([self isCancelled]) {
        NSLog(@"Long contact poll operation cancelled");
        return;
    }
    
    NSLog(@"Start long poll request");
    
    self.isRequestRunning = YES;
    
//    [[WebClient sharedInstance] longPollNewMessageCallbackBlock:^(BOOL success, GLPMessage *message) {
//        
//        if(success) {
//            NSLog(@"New message from long poll request: %@", message.content);
//            //[ConversationManager saveMessageFromLongpoll:message];
//            [NotificationsManager newContactRequest];
//        } else {
//            NSLog(@"Long poll request finished without result, restart");
//        }
//        
//        self.isRequestRunning = NO;
//        [self startRequest];
//    }];
    
    //Request for new contact.
    [[WebClient sharedInstance] getContactsWithCallbackBlock:^(BOOL success, NSArray *contacts) {
        
        if(success)
        {
            NSLog(@"New contacts request was established.");
            
            [NotificationsManager newContactRequest];
        }
        else
        {
            NSLog(@"Failed to load new contacts.");
        }
        self.isRequestRunning = NO;
        [self startRequest];
    }];
}

@end
