//
//  GLPLiveConversationsManager.m
//  Gleepost
//
//  Created by Lukas on 11/27/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLiveConversationsManager.h"
//#import "NSMutableArray+QueueAdditions.h"
#import "WebClient.h"

@interface GLPLiveConversationsManager()

@property (strong, nonatomic) NSMutableArray *conversations;
@property (strong, nonatomic) dispatch_queue_t queue;
@property (assign, nonatomic) BOOL successfullyLoaded;
@property (assign, nonatomic) BOOL isSynchronizedWithRemote;

@end


@implementation GLPLiveConversationsManager

@synthesize conversations=_conversations;
@synthesize queue=_queue;
@synthesize successfullyLoaded=_successfullyLoaded;
@synthesize isSynchronizedWithRemote=_isSynchronizedWithRemote;

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
    _successfullyLoaded = NO;
    _isSynchronizedWithRemote = NO;
    
    return self;
}

- (void)loadConversations
{
    DDLogInfo(@"Load live conversations");
    
    [[WebClient sharedInstance] getLiveConversationsWithCallbackBlock:^(BOOL success, NSArray *conversations) {
        dispatch_async(_queue, ^{
            if(!success) {
                DDLogError(@"Cannot load live conversations");
                _isSynchronizedWithRemote = NO;
                return;
            }
            
            DDLogInfo(@"Load live conversations sucess, loaded conversations: %d", conversations.count);
            
            _conversations = [NSMutableArray arrayWithArray:conversations];
            _isSynchronizedWithRemote = YES;
            
            GLPConversation *c = _conversations[0];
            DDLogInfo(@"LOAD conv %@", c.title);
        });
    }];
}

- (void)markAsNotSynchronizedWithRemote
{
    dispatch_async(_queue, ^{
        _isSynchronizedWithRemote = NO;
    });
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

- (NSArray *)conversations
{
    __block NSArray *conversations;
    dispatch_sync(_queue, ^{
        conversations = [_conversations copy];
    });
    
    GLPConversation *c = conversations[0];
    DDLogInfo(@"GET conv %@", c.title);
    
    return conversations;
}

- (void)loadConversationWithCallback:(void (^)(BOOL success, NSArray *conversations))callback
{
    
    
    [[WebClient sharedInstance] getConversationsFilterByLive:YES withCallbackBlock:^(BOOL success, NSArray *conversations) {
        if(!success) {
            callback(NO, nil);
            return;
        }
        
        [self runOnConversationQueue:^{
            _conversations = [NSMutableArray arrayWithArray:conversations];
        }];
        
        callback(YES, conversations);
    }];
}


- (int)conversationsCount
{
    __block int res = 0;
    
    dispatch_sync(_queue, ^{
        res = _conversations.count;
    });
    
    return res;
}

- (void)updateConversation:(GLPConversation *)conversation
{
    dispatch_async(_queue, ^{
        NSUInteger index = [_conversations indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if(((GLPConversation *)obj).remoteKey == conversation.remoteKey) {
                *stop = YES;
                return YES;
            }
            
            return NO;
        }];
        
        if(index == NSNotFound) {
            DDLogError(@"Update live conversation, conversation not found for remote key %d", conversation.remoteKey);
            return;
        }
        
        [_conversations replaceObjectAtIndex:index withObject:conversation];
    });
}


#pragma mark - Helpers

- (void)runOnConversationQueue:(void (^)())block
{
    dispatch_sync(_queue, block);
}

@end
