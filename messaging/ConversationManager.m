//
//  ConversationManager.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ConversationManager.h"

#import "RemoteConversation.h"
#import "RemoteMessage.h"

#import "WebClient.h"
#import "WebClientHelper.h"

@implementation ConversationManager

+ (void)loadConversationsWithLocalCallback:(void (^)(NSArray *conversations))localCallback remoteCallback:(void (^)(BOOL success, NSArray *conversations))remoteCallback
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    NSArray *localEntities = [RemoteConversation MR_findAll];
    localCallback(localEntities);
    
    [[WebClient sharedInstance] getConversationsWithCallbackBlock:^(BOOL success, NSArray *conversations) {
        if(!success) {
            remoteCallback(NO, nil);
            return;
        }
        
        [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            NSArray *entities = [RemoteConversation MR_findAll];
            remoteCallback(YES, entities);
        }];
    }];
}


+ (void)loadMessagesForConversation:(RemoteConversation *)conversation localCallback:(void (^)(NSArray *messages))localCallback remoteCallback:(void (^)(BOOL success, NSArray *messages))remoteCallback
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    NSArray *localEntities = [RemoteMessage MR_findByAttribute:@"conversation" withValue:conversation andOrderBy:@"date" ascending:YES];
    localCallback(localEntities);
    
    // find the last message which exists on both client and server
    RemoteMessage *last = nil;
    if(localEntities.count > 0) {
        RemoteMessage *possibleLast;
        for(int i = 0; i < localEntities.count; i++) {
            possibleLast = localEntities[i];
            
            if(possibleLast.remoteKey && [possibleLast.remoteKey integerValue] != 0) {
                last = possibleLast;
            }
        }
    }
    
    [[WebClient sharedInstance] getLastMessagesForConversation:conversation withLastMessage:last callbackBlock:^(BOOL success, NSArray *messages) {
        if(!success) {
            remoteCallback(NO, nil);
            return;
        }
        
        // update only if new changes from API
        if(messages.count == 0) {
            remoteCallback(YES, nil);
        } else {
            [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                NSArray *entities = [RemoteMessage MR_findByAttribute:@"conversation" withValue:conversation andOrderBy:@"date" ascending:YES];
                remoteCallback(YES, entities);
            }];
        }
    }];
    
    
//    NSArray *localEntities = [RemoteConversation MR_findByAttribute:@"remoteKey" withValue:<#(id)#>];
//    localCallback(localEntities);
}

@end
