//
//  GLPLiveConversation.m
//  Gleepost
//
//  Created by Σιλουανός on 28/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLiveConversation.h"

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
@end
