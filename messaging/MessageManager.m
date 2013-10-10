//
//  MessageManager.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "MessageManager.h"
#import "LocalMessage.h"
#import "SendStatus.h"
#import "RemoteUser.h"
#import "SessionManager.h"
#import "LocalMessageManager.h"

@implementation MessageManager

+ (void)saveMessage:(RemoteMessage *)message
{
    RemoteUser *user = [RemoteUser MR_findFirstByAttribute:@"remoteKey" withValue:[NSNumber numberWithInt:[SessionManager sharedInstance].key]];
    if(!user) {
        [NSException raise:@"Cannot find current user" format:@"User with session key %d is null in local database", [SessionManager sharedInstance].key];
    }
    
    message.author = user;
    message.sendStatus = [NSNumber numberWithInt:kSendStatusLocal];
    
    LocalMessage *localMessage = [LocalMessage MR_createEntity];
    localMessage.remoteMessage = message;
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    
    [[LocalMessageManager sharedInstance] process];
}

@end
