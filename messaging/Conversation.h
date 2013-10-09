//
//  Conversation.h
//  messaging
//
//  Created by Lukas on 8/28/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteEntity.h"
#import "User.h"
#import "Message.h"

@interface Conversation : RemoteEntity

@property (strong, nonatomic) NSArray *participants;
@property (strong, nonatomic) Message *lastMessage;

- (NSString *)getParticipantsNames;

@end
