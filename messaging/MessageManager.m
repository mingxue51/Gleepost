////
////  MessageManager.m
////  Gleepost
////
////  Created by Lukas on 10/10/13.
////  Copyright (c) 2013 Gleepost. All rights reserved.
////
//
//#import "MessageManager.h"
//#import "LocalMessage.h"
//#import "SendStatus.h"
//#import "GLPUser.h"
//#import "SessionManager.h"
//#import "MessagesSendingProcessor.h"
//
//@implementation MessageManager
//
//+ (void)saveMessage:(GLPMessage *)message
//{
//    GLPUser *user = [GLPUser MR_findFirstByAttribute:@"remoteKey" withValue:[NSNumber numberWithInt:[SessionManager sharedInstance].key]];
//    if(!user) {
//        [NSException raise:@"Cannot find current user" format:@"User with session key %d is null in local database", [SessionManager sharedInstance].key];
//    }
//    
//    message.author = user;
//    message.sendStatus = [NSNumber numberWithInt:kSendStatusLocal];
//    
//    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
//    [[MessagesSendingProcessor sharedInstance] processMessages];
//}
//
//@end
