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

# pragma mark - Copy

-(id)copyWithZone:(NSZone *)zone
{
    GLPConversationRead *object = [[self class] allocWithZone:zone];
    object.participant = [_participant copyWithZone:zone];
    object.messageRemoteKey = _messageRemoteKey;
    return object;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Participant name %@ - %d, Message remote key %ld", _participant.name, _participant.remoteKey, (long)_messageRemoteKey];
}

@end
