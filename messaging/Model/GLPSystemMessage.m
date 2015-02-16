//
//  GLPSystemMessage.m
//  Gleepost
//
//  Created by Silouanos on 13/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPSystemMessage.h"

@implementation GLPSystemMessage

- (id)initWithMessage:(GLPMessage *)message
{
    self = [super init];
    
    if(self)
    {
        [self initialiseObjectsWithMessage:message];
        [self configureMessageType];
    }
    
    return self;
}

- (void)initialiseObjectsWithMessage:(GLPMessage *)message
{
    self.key = message.key;
    self.remoteKey = message.remoteKey;
    self.seen = message.seen;
    self.isOld = message.isOld;
    self.displayOrder = message.displayOrder;
    self.sendStatus = message.sendStatus;
    self.content = message.content;
    self.date = message.date;
    self.author = message.author;
    self.conversation = message.conversation;
    self.belongsToGroup = message.belongsToGroup;
}

- (void)configureMessageType
{
    if([self.content isEqualToString:@"PARTED"])
    {
        self.messageType = kParted;
    }
    else if ([self.content isEqualToString:@"JOINED"])
    {
        self.messageType = kJoined;
    }
    else
    {
        self.messageType = kUnknown;
    }
}

- (NSString *)systemMessage
{
    NSString *message = nil;
    
    switch (self.messageType) {
        case kParted:
            message = [NSString stringWithFormat:@"%@ left the group", self.author.name];
            break;
        case kJoined:
            message = [NSString stringWithFormat:@"%@ joined the group", self.author.name];
            break;
        case kUnknown:
            message = [NSString stringWithFormat:@"Unknown message"];
            break;
            
        default:
            break;
    }
    
    return message.uppercaseString;
}

# pragma mark - Copy

-(id)copyWithZone:(NSZone *)zone
{
    GLPSystemMessage *message = [super copyWithZone:zone];
    message.messageType = self.messageType;
    return message;
}

@end
