//
//  GLPMessagesLoader.m
//  Gleepost
//
//  Created by Silouanos on 15/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPMessagesLoader.h"
#import "ConversationManager.h"
#import "NSNotificationCenter+Utils.h"

@interface GLPMessagesLoader ()

@property (strong, nonatomic) NSArray *liveConversations;
@property (strong, nonatomic) NSArray *conversations;
@end

@implementation GLPMessagesLoader

static GLPMessagesLoader *instance = nil;

+ (GLPMessagesLoader *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[GLPMessagesLoader alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        
    }
    
    return self;
}

-(NSArray*)getLiveConversations
{
    return self.liveConversations;
}

-(NSArray*)getConversations
{
    return self.conversations;
}


-(void)loadConversations
{
    [ConversationManager loadConversationsWithLocalCallback:^(NSArray *conversations) {
        if(conversations.count > 0) {

            self.conversations = conversations;
            
            NSLog(@"Conversations from loader: %@",conversations);
            
        }
    } remoteCallback:^(BOOL success, NSArray *conversations) {
        if(success) {

            self.conversations = conversations;
            
        } else {
            // no local conversations
            // show loading cell error and do not add refresh control
            // because loading cell already provides a refresh button
//            if(self.conversations.count == 0) {
//                self.loadingCellStatus = kGLPLoadingCellStatusError;
//                [self.tableView reloadData];
//            }
        }
        
    }];
}

-(void)loadLiveConversations
{
    [ConversationManager loadLiveConversationsWithCallback:^(BOOL success, NSArray *conversations) {
        
        if(!success) {
            //[WebClientHelper showStandardErrorWithTitle:@"Refreshing live chat failed" andContent:@"Cannot connect to the live chat, check your network status and retry later."];
            
            //TODO: Catch this posibility. When network is not detected retry or wait until is back.
            return;
        }
        
        NSMutableArray *conversations1 = [[NSMutableArray alloc]initWithObjects:@"LiveChat", nil];
        
        self.liveConversations = conversations1;
        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPLiveConversationsReady" object:nil userInfo:@{@"Conversations":conversations1}];
        
        if(conversations.count != 0)
        {
            //Add live chats' section in the section array.
//            [self addSectionWithName:LIVE_CHATS_STR];
            
            //            [GLPLiveConversationsManager sharedInstance].conversations = [conversations mutableCopy];
//            [self.categorisedConversations setObject:[conversations mutableCopy] forKey:[NSNumber numberWithInt:0]];
//            [self.tableView reloadData];
            


        }
        
        
    }];
}

@end
