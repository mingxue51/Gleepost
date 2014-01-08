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
@property (strong, nonatomic) dispatch_queue_t queue;

@end


@implementation GLPLiveConversationsManager

@synthesize conversations=_conversations;
@synthesize lock=_lock;
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
    
    _lock = [[NSLock alloc] init];
    _conversations = [NSMutableArray array];
    
    _queue = dispatch_queue_create("com.gleepost.queue.liveconversation", DISPATCH_QUEUE_SERIAL);
    
    return self;
}

- (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey
{
    __block GLPConversation *conversation = nil;
    
    dispatch_async(_queue, ^{
        for(GLPConversation *c in _conversations) {
            if(c.remoteKey == remoteKey) {
                conversation = c;
            }
        }
    });
    
    return conversation;
}

- (NSArray *)getConversations
{
    __block NSArray *res = nil;

    dispatch_async(_queue, ^{
        res = [_conversations copy];
    });
    
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
    __block int res = 0;
    
    dispatch_async(_queue, ^{
        res = _conversations.count;
    });
    
    return res;
}

- (void)runOnConversationQueue:(void (^)())block
{
    dispatch_async(_queue, block);
}



@end
