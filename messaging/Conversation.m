//
//  Conversation.m
//  messaging
//
//  Created by Lukas on 8/28/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "Conversation.h"

@implementation Conversation

@synthesize participants, lastMessage;

- (NSString *)getParticipantsNames
{
    NSMutableString *names = [NSMutableString string];
    
    [self.participants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        User *user = obj;
        [names appendString:user.name];
        
        if(self.participants.count != 1 && idx != self.participants.count - 1) {
            if(idx == self.participants.count - 2) {
                [names appendString:@" and "];
            } else {
                [names appendString:@", "];
            }
        }
    }];
    
    return names;
}

@end
