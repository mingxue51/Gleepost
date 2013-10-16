//
//  ConversationManager.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ConversationManager.h"

#import "Conversation.h"
#import "GLPMessage.h"
#import "GLPUser.h"

#import "SessionManager.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "MessagesSendingProcessor.h"



@implementation ConversationManager

+ (void)loadConversationsWithLocalCallback:(void (^)(NSArray *conversations))localCallback remoteCallback:(void (^)(BOOL success, NSArray *conversations))remoteCallback
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    NSArray *localEntities = [Conversation MR_findAll];
    localCallback(localEntities);
    
    [[WebClient sharedInstance] getConversationsWithCallbackBlock:^(BOOL success, NSArray *conversations) {
        if(!success) {
            remoteCallback(NO, nil);
            return;
        }
        
        [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            NSArray *entities = [Conversation MR_findAll];
            remoteCallback(YES, entities);
        }];
    }];
}


+ (void)loadMessagesForConversation:(Conversation *)conversation localCallback:(void (^)(NSArray *messages))localCallback remoteCallback:(void (^)(BOOL success, NSArray *messages))remoteCallback
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    NSArray *localEntities = [GLPMessage MR_findByAttribute:@"conversation" withValue:conversation andOrderBy:@"date" ascending:YES];
    localCallback(localEntities);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"conversation= %@ && remoteKey != nil", conversation];
    GLPMessage *last = [GLPMessage MR_findFirstWithPredicate:predicate sortedBy:@"remoteKey" ascending:NO];
    NSLog(@"last remote message %@ - %@", last.remoteKey, last.content);
    
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
                NSArray *entities = [GLPMessage MR_findByAttribute:@"conversation" withValue:conversation andOrderBy:@"date" ascending:YES];
                remoteCallback(YES, entities);
            }];
        }
    }];
}

+ (GLPMessage *)createMessageWithContent:(NSString *)content toConversation:(Conversation *)conversation sendCallback:(void (^)(GLPMessage *sentMessage, BOOL success))sendCallback
{
    __block GLPMessage *message = [GLPMessage MR_createEntity];
    message.content = content;
    message.conversation = conversation;
    message.date = [NSDate date];
    
    GLPUser *user = [GLPUser MR_findFirstByAttribute:@"remoteKey" withValue:[NSNumber numberWithInt:[SessionManager sharedInstance].key]];
    if(!user) {
        [NSException raise:@"Cannot find current user" format:@"User with session key %d is null in local database", [SessionManager sharedInstance].key];
    }
    
    message.author = user;
    message.sendStatus = [NSNumber numberWithSendStatus:kSendStatusLocal];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"Post message %@ to server", message.content);
        
        [[WebClient sharedInstance] createMessage:message callbackBlock:^(BOOL responseSuccess, NSInteger remoteKey) {
            NSLog(@"Post to server response: success %d - id %d", responseSuccess, remoteKey);
            
            if(responseSuccess) {
                message.remoteKey = [NSNumber numberWithInteger:remoteKey];
                message.sendStatusValue = kSendStatusSent;
            } else {
                message.sendStatusValue = kSendStatusFailure;
            }
            
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL saveSucess, NSError *error) {
                sendCallback(message, responseSuccess);
            }];
        }];
    }];
    
    return message;
}


@end
