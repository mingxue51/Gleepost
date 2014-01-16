//
//  GLPWebSocketEvent.m
//  Gleepost
//
//  Created by Lukas on 1/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPWebSocketEvent.h"

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
    } else if([string isEqualToString:@"notification"]) {
        _type = kGLPWebSocketEventTypeNotification;
    } else {
        [NSException raise:@"GLPWebSocketEventType unknown" format:@"For string value: %@", string];
    }
}

- (int)conversationRemoteKeyFromLocation
{
    NSRange range = [_location rangeOfString:@"/" options:NSBackwardsSearch];
    return [[_location substringFromIndex:range.location + 1] intValue];
}

@end