//
//  GLPLiveConversationsManager.m
//  Gleepost
//
//  Created by Lukas on 11/27/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLiveConversationsManager.h"
#import "NSMutableArray+QueueAdditions.h"

@interface GLPLiveConversationsManager()

@property (strong, nonatomic) NSLock *lock;
@property (strong, nonatomic) NSMutableArray *conversations;

@end


@implementation GLPLiveConversationsManager

@synthesize conversations=_conversations;
@synthesize lock=_lock;

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
    
    _lock = [[NSLock alloc] init];
    _conversations = [NSMutableArray array];
    
    return self;
}

- (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey
{
    [_lock lock];
    
    for(GLPConversation *conversation in _conversations) {
        if(conversation.remoteKey == remoteKey) {
            return [conversation copy];
        }
    }
    
    [_lock unlock];
    return nil;
}

- (NSArray *)getConversations
{
    [_lock lock];
    NSArray *res = [_conversations copy];
    [_lock unlock];
    
    return res;
}

- (void)setConversations:(NSMutableArray *)conversations
{
    [_lock lock];
    _conversations = conversations;
    [_lock unlock];
}

- (void)enqueue:(GLPConversation *)conversation
{
    [_lock lock];
    [_conversations enqueue:conversation];
    [_lock unlock];
}

- (int)conversationsCount
{
    [_lock lock];
    int res = _conversations.count;
    [_lock unlock];
    
    return res;
}

@end
