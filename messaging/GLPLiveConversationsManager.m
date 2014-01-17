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

@property (strong, nonatomic) NSMutableArray *conversations;
@property (strong, nonatomic) dispatch_queue_t queue;

@end


@implementation GLPLiveConversationsManager

@synthesize conversations=_conversations;
@synthesize queue=_queue;

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
    _queue = dispatch_queue_create("com.gleepost.queue.liveconversation", DISPATCH_QUEUE_SERIAL);
    
    return self;
}

- (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey
{
    __block GLPConversation *conversation = nil;
    
    [self runOnConversationQueue:^{
        for(GLPConversation *c in _conversations) {
            if(c.remoteKey == remoteKey) {
                conversation = c;
            }
        }
    }];
    
    return conversation;
}

- (NSArray *)getConversations
{
    __block NSArray *res = nil;

    [self runOnConversationQueue:^{
        res = [_conversations copy];
    }];
    
    return res;
}


- (int)conversationsCount
{
    __block int res = 0;
    
    [self runOnConversationQueue:^{
        res = _conversations.count;
    }];
    
    return res;
}

- (void)runOnConversationQueue:(void (^)())block
{
    dispatch_async(_queue, block);
}

//ADDED.
-(void)setConversations:(NSMutableArray *)conversations
{
    _conversations = conversations;
}

@end
