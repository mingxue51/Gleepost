//
//  GLPLiveConversation.m
//  Gleepost
//
//  Created by Σιλουανός on 28/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLiveConversation.h"
#import "SessionManager.h"

@implementation GLPLiveConversation

-(id)initWithConversation:(GLPConversation*)conversation
{
    self = [super init];
    
    if(self)
    {
        self.key = conversation.key;
        self.remoteKey = conversation.remoteKey;
        self.author = conversation.author;
        self.lastUpdate = conversation.lastUpdate;
        self.messages = conversation.messages;
        self.participants = conversation.participants;
        self.title = conversation.title;
        self.hasUnreadMessages = conversation.hasUnreadMessages;
        
        //New Variables.
        self.timeStarted = [NSDate date];
    }
    
    return self;
}

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
@end
