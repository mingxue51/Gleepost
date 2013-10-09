//
//  Message.h
//  messaging
//
//  Created by Lukas on 8/28/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteEntity.h"
#import "User.h"

@class Conversation;


@interface Message : RemoteEntity

@property (assign, nonatomic) BOOL seen;
@property (strong, nonatomic) User *author;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) Conversation *conversation;

- (BOOL)followsPreviousMessage:(Message *)message;

@end
