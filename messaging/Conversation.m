//
//  RemoteConversation.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "Conversation.h"
#import "User.h"
#import "SessionManager.h"

@implementation Conversation

// Excludes the current user name
- (NSString *)getParticipantsNames
{
    NSMutableString *names = [NSMutableString string];
    
    int count = self.participants.count - 1;
    [[self.participants allObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        User *user = obj;
        
        // ignore current user
        if([user.remoteKey isEqualToNumber:[NSNumber numberWithInteger:[SessionManager sharedInstance].key]]) {
            return;
        }
        
        [names appendString:user.name];
        
        if(count != 1 && idx != count - 1) {
            if(idx == count - 2) {
                [names appendString:@" and "];
            } else {
                [names appendString:@", "];
            }
        }
    }];
    
    return names;
}

@end
