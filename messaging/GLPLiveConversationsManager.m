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

@end


@implementation GLPLiveConversationsManager

@synthesize conversations=_conversations;
@synthesize queue=_queue;
@synthesize successfullyLoaded=_successfullyLoaded;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:@"GLPNetworkStatusUpdate" object:nil];
    
    return self;
}

- (void)updateNetworkStatus:(NSNotification *)notification
{
    BOOL isNetwork = [notification.userInfo[@"status"] boolValue];
    DDLogInfo(@"Live conversations manager network status update: %d", isNetwork);
    
    if(isNetwork) {
        [self loadConversations];
    } else {

    }
}

- (void)loadConversations
{
    DDLogInfo(@"Load live conversations");
    
    [[WebClient sharedInstance] getConversationsFilterByLive:YES withCallbackBlock:^(BOOL success, NSArray *conversations) {
        if(!success) {
            DDLogError(@"Cannot load live conversations");
            _successfullyLoaded = NO;
            return;
        }
        
        DDLogInfo(@"Load live conversations sucess, loaded conversations: %d", conversations.count);
        
        dispatch_async(_queue, ^{
            _conversations = [NSMutableArray arrayWithArray:conversations];
        });
        
        _successfullyLoaded = YES;
    }];
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

//- (NSArray *)getConversations
//{
//    __block NSArray *res = nil;
//    
//    [[WebClient sharedInstance] getConversationsFilterByLive:YES withCallbackBlock:^(BOOL success, NSArray *conversations) {
//        if(!success) {
//            [self runOnConversationQueue:^{
//                res = [_conversations copy];
//            }];
//            return;
//        }
//        
//        callback(YES, conversations);
//    }];
//    
//    [ConversationManager loadLiveConversationsWithCallback:^(BOOL success, NSArray *conversations) {
//        
//        if(!success) {
//            [WebClientHelper showStandardErrorWithTitle:@"Refreshing live chat failed" andContent:@"Cannot connect to the live chat, check your network status and retry later."];
//            return;
//        }
//        
//        if(conversations.count != 0)
//        {
//            //Add live chats' section in the section array.
//            //            [self addSectionWithName:LIVE_CHATS_STR];
//            
//            //            [GLPLiveConversationsManager sharedInstance].conversations = [conversations mutableCopy];
//            [self.categorisedConversations setObject:[conversations mutableCopy] forKey:[NSNumber numberWithInt:0]];
//            [self.tableView reloadData];
//        }
//        
//        
//    }];
//
//
//    
//    return res;
//}


- (int)conversationsCount
{
    __block int res = 0;
    
    [self runOnConversationQueue:^{
        res = _conversations.count;
    }];
    
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
