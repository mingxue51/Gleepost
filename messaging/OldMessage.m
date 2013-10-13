//
//  Message.m
//  messaging
//
//  Created by Lukas on 8/28/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "OldMessage.h"
#import "OldConversation.h"

@implementation OldMessage

@synthesize seen, content, date, author, conversation;

- (BOOL)followsPreviousMessage:(OldMessage *)message
{
    if(message.author.key != self.author.key) {
        return NO;
    }
    
//    NSTimeInterval interval = [self.date timeIntervalSinceDate:message.date];
//    NSLog(@"time interval %f", interval);
//    if(interval / 60 > 15) {
//        return NO;
//    }
    
    return YES;
}

@end
