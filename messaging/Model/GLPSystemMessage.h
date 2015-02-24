//
//  GLPSystemMessage.h
//  Gleepost
//
//  Created by Silouanos on 13/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPMessage.h"

typedef NS_ENUM(NSUInteger, MessageType) {
    kUnknown = 0,
    kJoined,
    kParted
};

@interface GLPSystemMessage : GLPMessage <NSCopying>

@property (assign, nonatomic) MessageType messageType;

- (id)initWithMessage:(GLPMessage *)message;

- (NSString *)systemMessage;
- (NSString *)systemContent;

@end
