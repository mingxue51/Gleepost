////
////  MessageProcessingOperation.m
////  Gleepost
////
////  Created by Lukas on 10/10/13.
////  Copyright (c) 2013 Gleepost. All rights reserved.
////
//
//#import "MessageProcessingOperation.h"
//#import "GLPMessage.h"
//#import "WebClient.h"
//
//@interface MessageProcessingOperation()
//
//@end
//
//@implementation MessageProcessingOperation
//
//@synthesize messages;
//
//- (void)main {
//    @autoreleasepool {
//        NSLog(@"Message processing operation start");
//        NSLog(@"Check local messages : %d", self.messages.count);
//        
//        int retries = 3;
//        for(GLPMessage *message in self.messages) {
//            NSLog(@"Post message %@", message.content);
//            
//            BOOL success = NO;
//            while (!success && retries > 0) {
//                success = [self postMessage:message];
//                
//                if(!success) {
//                    retries--;
//                }
//            }
//        }
//        
//        NSLog(@"Message processing operation stop");
//    }
//}
//                   
//- (BOOL)postMessage:(GLPMessage *)message
//{
//    __block BOOL response = NO;
//    
//    // blocks until response is delivered
//    [[WebClient sharedInstance] createMessageSynchronously:message callbackBlock:^(BOOL success, NSInteger remoteKey) {
//        NSLog(@"Synchronous message creation response %d with remote key %d", success, remoteKey);
//        response = success;
//        
//        if(success) {
//            message.remoteKey = [NSNumber numberWithInteger:remoteKey];
//            message.sendStatus = [NSNumber numberWithSendStatus:kSendStatusSent];
//        } else {
//            message.sendStatus = [NSNumber numberWithSendStatus:kSendStatusFailure];
//        }
//    }];
//    
//    return response;
//}
//
//@end
