//
//  GLPConversation.h
//  ;
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPEntity.h"
#import "GLPUser.h"

@class GLPMessage;

@interface GLPConversation : GLPEntity

@property (strong, nonatomic) NSDate *lastUpdate;
@property (strong, nonatomic) NSString *lastMessage;
@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) NSArray *participants;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL hasUnreadMessages;
@property (assign, nonatomic) BOOL isGroup;
@property (assign, nonatomic) BOOL isLive;

- (id)initWithParticipants:(NSArray *)participants;
- (GLPUser *)getUniqueParticipant;
- (NSString *)getLastMessageOrDefault;
- (NSString *)getLastUpdateOrDefault;

@end
