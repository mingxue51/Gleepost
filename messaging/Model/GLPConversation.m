//
//  GLPConversation.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPConversation.h"
#import "SessionManager.h"

@implementation GLPConversation

@synthesize lastUpdate = _lastUpdate;
@synthesize author = _author;
@synthesize lastMessage = _lastMessage;
@synthesize messages = _messages;
@synthesize participants = _participants;
@synthesize title = _title;
//@synthesize participantsNames = _participantsNames;

- (void)setTitleFromParticipants:(NSArray *)participants
{
    NSAssert(participants.count > 1, @"");
    
    
    _participants = participants;
    
    NSMutableString *names = [NSMutableString string];
    
    NSMutableArray *filteredParticipants = [NSMutableArray arrayWithCapacity:participants.count - 1];
    for(GLPUser *user in participants) {
        if(![user isEqualToEntity:[SessionManager sharedInstance].user]) {
            [filteredParticipants addObject:user];
        }
    }
    
    [filteredParticipants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GLPUser *user = obj;
        [names appendString:user.name];
        
        if(filteredParticipants.count > 1 && idx != filteredParticipants.count - 1) {
            if(idx == filteredParticipants.count - 2) {
                [names appendString:@" and "];
            } else {
                [names appendString:@", "];
            }
        }
    }];
    
    self.title = names;
}
// Excludes the current user name
//- (NSString *)getParticipantsNames
//{
//    NSMutableString *names = [NSMutableString string];
//    
//    if(self.participants.count < 2) {
//        return @"Invalid conversation";
//    }
//    
//    NSMutableArray *filteredParticipants = [NSMutableArray arrayWithCapacity:self.participants.count - 1];
//    
//    for(GLPUser *user in self.participants) {
//        if(![user isEqualToEntity:[SessionManager sharedInstance].user]) {
//            [filteredParticipants addObject:user];
//        }
//    }
//    
//    [filteredParticipants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        GLPUser *user = obj;
//        [names appendString:user.name];
//        
//        if(filteredParticipants.count > 1 && idx != filteredParticipants.count - 1) {
//            if(idx == filteredParticipants.count - 2) {
//                [names appendString:@" and "];
//            } else {
//                [names appendString:@", "];
//            }
//        }
//    }];
//    
//    return names;
//}

@end
