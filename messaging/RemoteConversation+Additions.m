//
//  RemoteConversation+Additions.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "RemoteConversation+Additions.h"
#import "RemoteUser.h"
#import "SessionManager.h"

@implementation RemoteConversation (Additions)

// Excludes the current user name
- (NSString *)getParticipantsNames
{
    NSMutableString *names = [NSMutableString string];
    
    int count = self.participants.count - 1;
    [[self.participants allObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RemoteUser *user = obj;
        
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
