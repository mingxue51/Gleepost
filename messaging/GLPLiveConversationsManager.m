//
//  GLPLiveConversationsManager.m
//  Gleepost
//
//  Created by Lukas on 11/27/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLiveConversationsManager.h"

@interface GLPLiveConversationsManager()


@end


@implementation GLPLiveConversationsManager

@synthesize conversations=_conversations;

static GLPLiveConversationsManager *instance = nil;

+ (GLPLiveConversationsManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPLiveConversationsManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _conversations = [NSMutableArray array];
    
    return self;
}

- (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey
{
    for(GLPConversation *conversation in _conversations) {
        if(conversation.remoteKey == remoteKey) {
            return conversation;
        }
    }
    
    return nil;
}

@end
