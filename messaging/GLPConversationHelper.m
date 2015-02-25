//
//  GLPConverationHelper.m
//  Gleepost
//
//  Created by Silouanos on 12/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  This class is responsible to retrieve data from conversation (to GLPConversationViewController)
//  depending on what kind of conversation is loaded (Group's converation or Messager's conversation).

#import "GLPConversationHelper.h"
#import "GLPLiveGroupConversationsManager.h"
#import "GLPLiveConversationsManager.h"

@implementation GLPConversationHelper

- (id)initWithBelongsToGroup:(BOOL)belongsToGroup
{
    self = [super init];
    if (self)
    {
        _belongsToGroup = belongsToGroup;
    }
    
    return self;
}

- (void)resetLastShownMessageForConversation:(GLPConversation *)detachedConversation
{
    if(_belongsToGroup)
    {
        [[GLPLiveGroupConversationsManager sharedInstance] resetLastShownMessageForConversation:detachedConversation];
    }
    else
    {
        [[GLPLiveConversationsManager sharedInstance] resetLastShownMessageForConversation:detachedConversation];
    }
}

- (void)syncConversation:(GLPConversation *)detachedConversation
{
    if(_belongsToGroup)
    {
        [[GLPLiveGroupConversationsManager sharedInstance] syncConversation:detachedConversation];
    }
    else
    {
        [[GLPLiveConversationsManager sharedInstance] syncConversation:detachedConversation];
    }
}

- (NSArray *)lastestMessagesForConversation:(GLPConversation *)conversation
{
    if(_belongsToGroup)
    {
        return [[GLPLiveGroupConversationsManager sharedInstance] lastestMessagesForConversation:conversation];
    }
    else
    {
        return [[GLPLiveConversationsManager sharedInstance] lastestMessagesForConversation:conversation];
    }
}

- (NSArray *)oldestMessagesForConversation:(GLPConversation *)detachedConversation
{
    if(_belongsToGroup)
    {
        return [[GLPLiveGroupConversationsManager sharedInstance] oldestMessagesForConversation:detachedConversation];
    }
    else
    {
        return [[GLPLiveConversationsManager sharedInstance] oldestMessagesForConversation:detachedConversation];
    }
}

- (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey
{
    if(_belongsToGroup)
    {
        return [[GLPLiveGroupConversationsManager sharedInstance] findByRemoteKey:remoteKey];
    }
    else
    {
        return [[GLPLiveConversationsManager sharedInstance] findByRemoteKey:remoteKey];
    }
}

- (void)markConversation:(GLPConversation *)conversation upToTheLastMessageAsRead:(GLPMessage *)lastMessage
{
    if(_belongsToGroup)
    {
        [[GLPLiveGroupConversationsManager sharedInstance] markConversation:conversation upToTheLastMessageAsRead:lastMessage];
    }
    else
    {
        [[GLPLiveConversationsManager sharedInstance] markConversation:conversation upToTheLastMessageAsRead:lastMessage];
    }
}

- (NSArray *)loadLatestMessagesForConversation:(GLPConversation *)conversation
{
    if(_belongsToGroup)
    {
        return [[GLPLiveGroupConversationsManager sharedInstance] loadLatestMessagesForConversation:conversation];
    }
    else
    {
        return [[GLPLiveConversationsManager sharedInstance] loadLatestMessagesForConversation:conversation];
    }
}

- (void)createRegularConversationWithUsers:(NSArray *)users callback:(void (^)(GLPConversation *conversation))callback
{
    //this method would only call GLPLiveConversationsManager's method.
    [[GLPLiveConversationsManager sharedInstance] createRegularConversationWithUsers:users callback:^(GLPConversation *conversation) {
        callback(conversation);
    }];
}

- (void)createRegularConversationWithUser:(GLPUser *)user callback:(void (^)(GLPConversation *conversation))callback
{
    //this method would only call GLPLiveConversationsManager's method.
    [[GLPLiveConversationsManager sharedInstance] createRegularConversationWithUser:user callback:^(GLPConversation *conversation) {
        callback(conversation);
    }];
}

- (void)syncConversationPreviousMessages:(GLPConversation *)detachedConversation
{
    if(_belongsToGroup)
    {
        return [[GLPLiveGroupConversationsManager sharedInstance] syncConversationPreviousMessages:detachedConversation];
    }
    else
    {
        return [[GLPLiveConversationsManager sharedInstance] syncConversationPreviousMessages:detachedConversation];
    }
}


@end
