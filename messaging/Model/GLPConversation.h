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
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSArray *participants;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL hasUnreadMessages;
@property (assign, nonatomic) BOOL isGroup;
@property (assign, nonatomic) BOOL isLive;

// live
@property (assign, nonatomic) BOOL isEnded;
@property (assign, nonatomic) NSDate *expiryDate;


- (id)initWithParticipants:(NSArray *)participants;
- (id)initWithParticipants:(NSArray *)participants expiryDate:(NSDate *)expiryDate ended:(BOOL)ended;
- (GLPUser *)getUniqueParticipant;
- (NSString *)getLastMessageOrDefault;
- (NSString *)getLastUpdateOrDefault;
- (void)updateWithNewMessage:(GLPMessage *)message;

@end
