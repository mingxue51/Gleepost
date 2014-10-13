//
//  GLPConversationRead.m
//  Gleepost
//
//  Created by Silouanos on 13/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPConversationRead.h"

@implementation GLPConversationRead

- (id)initWithParticipant:(GLPUser *)participant andMessageRemoteKey:(NSInteger)messageRemoteKey
{
    self = [super init];
    
    if(self)
    {
        _participant = participant;
        
        _messageRemoteKey = messageRemoteKey;
    }
    
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"Participant %@, Message remote key %ld", _participant, (long)_messageRemoteKey];
}

@end
