//
//  Message.h
//  messaging
//
//  Created by Lukas on 8/28/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "RemoteEntity.h"
#import "User.h"

@interface Message : RemoteEntity

@property (assign, nonatomic) BOOL seen;
@property (assign, nonatomic) NSInteger conversationRemoteId;
@property (strong, nonatomic) User *author;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSDate *date;

@end
