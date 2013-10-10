//
//  RemoteConversation+Additions.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "RemoteConversation+Additions.h"

@implementation RemoteConversation (Additions)

- (NSString *)getParticipantsNames
{
    NSMutableString *names = [NSMutableString string];
    return @"Participants";
    
//    [self.participants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        User *user = obj;
//        [names appendString:user.name];
//        
//        if(self.participants.count != 1 && idx != self.participants.count - 1) {
//            if(idx == self.participants.count - 2) {
//                [names appendString:@" and "];
//            } else {
//                [names appendString:@", "];
//            }
//        }
//    }];
//    
//    return names;
}

@end
