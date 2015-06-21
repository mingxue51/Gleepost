//
//  GLPWebSocketEvent.m
//  Gleepost
//
//  Created by Lukas on 1/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPWebSocketEvent.h"
#import "WebClientHelper.h"

@implementation GLPWebSocketEvent

@synthesize type=_type;
@synthesize data=_data;
@synthesize location=_location;

- (void)typeFromString:(NSString *)string
{
    if([string isEqualToString:@"message"]) {
        _type = kGLPWebSocketEventTypeNewMessage;
    } else if([string isEqualToString:@"new-conversation"]) {
        _type = kGLPWebSocketEventTypeNewConversation;
    } else if([string isEqualToString:@"ended-conversation"]) {
        _type = kGLPWebSocketEventTypeEndConversation;
    } else if([string isEqualToString:@"changed-conversation"]) {
        _type = kGLPWebSocketEventTypeChangedConversation;
    } else if([string isEqualToString:@"notification"]) {
        _type = kGLPWebSocketEventTypeNotification;
    } else if ([string isEqualToString:@"video-ready"]) {
        _type = kGLPWebSocketEventTypeVideoReady;
    }
    else if ([string isEqualToString:@"read"]){
        _type = kGLPWebSocketEventTypeRead;
    }
    else if([string isEqualToString:@"views"]) {
        _type = kGLPWebSocketEventTypeViews;
    }
    else if([string isEqualToString:@"vote"]) {
        _type = kGLPWebSocketEventTypeVote;
    }
    else if([string isEqualToString:@"presence"])
    {
        _type = kGLPWebSocketEventTypePresence;
    }
    else {
  
        
//        [WebClientHelper showWebSocketReceivedBadEvent:string];
        
//        [NSException raise:@"GLPWebSocketEventType unknown" format:@"For string value: %@", string];
    }
}

- (NSInteger)webSocketMessageRemoteKeyFromLocation
{
    NSRange range = [_location rangeOfString:@"/" options:NSBackwardsSearch];
    return [[_location substringFromIndex:range.location + 1] intValue];
}

@end