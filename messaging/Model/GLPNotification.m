//
//  GLPNotification.m
//  Gleepost
//
//  Created by Lukas on 11/13/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPNotification.h"

@implementation GLPNotification

@synthesize seen=_seen;
@synthesize postRemoteKey;
@synthesize notificationType;
@synthesize user;
@synthesize date;

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _seen = NO;
    
    return self;
}

- (NSString *)notificationTypeDescription
{
    switch (self.notificationType) {
        case kGLPNotificationTypeAcceptedYou:
            return [NSString stringWithFormat:@"Your are now friends"];
        case kGLPNotificationTypeCommented:
            return [NSString stringWithFormat:@"%@ commented on your post", self.user.name];
        case kGLPNotificationTypeLiked:
            return [NSString stringWithFormat:@"%@ liked your post", self.user.name];
        case kGLPNotificationTypeAddedYou:
            return [NSString stringWithFormat:@"Contact invite from %@",self.user.name];
        default:
            return @"Something happened";
    }
}

- (BOOL)displaysPictoImage
{
    return self.notificationType == kGLPNotificationTypeLiked || self.notificationType == kGLPNotificationTypeCommented;
}

@end
