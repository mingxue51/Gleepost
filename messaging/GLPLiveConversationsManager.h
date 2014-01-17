//
//  GLPLiveConversationsManager.h
//  Gleepost
//
//  Created by Lukas on 11/27/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPConversation.h"

@interface GLPLiveConversationsManager : NSObject

+ (GLPLiveConversationsManager *)sharedInstance;

- (int)conversationsCount;
- (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey;
- (NSArray *)getConversations;
- (void)setConversations:(NSMutableArray *)conversations;

@end
