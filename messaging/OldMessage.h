//
//  Message.h
//  messaging
//
//  Created by Lukas on 8/28/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteEntity.h"
#import "OldUser.h"

@class OldConversation;


@interface OldMessage : RemoteEntity

@property (assign, nonatomic) BOOL seen;
@property (strong, nonatomic) OldUser *author;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) OldConversation *conversation;

- (BOOL)followsPreviousMessage:(OldMessage *)message;

@end
