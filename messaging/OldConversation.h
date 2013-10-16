//
//  Conversation.h
//  messaging
//
//  Created by Lukas on 8/28/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteEntity.h"
#import "OldMessage.h"

@interface OldConversation : RemoteEntity

@property (strong, nonatomic) NSArray *participants;
@property (strong, nonatomic) OldMessage *lastMessage;

- (NSString *)getParticipantsNames;

@end
