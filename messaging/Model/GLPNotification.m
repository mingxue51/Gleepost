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

- (BOOL)hasAction
{
    return self.notificationType == kGLPNotificationTypeAddedYou;
}

- (NSString *)notificationTypeDescription
{
    switch (self.notificationType) {
        case kGLPNotificationTypeAcceptedYou:
            return [NSString stringWithFormat:@"Contact accepted from %@", self.user.name];
        case kGLPNotificationTypeCommented:
            return [NSString stringWithFormat:@"Comment from %@", self.user.name];
        case kGLPNotificationTypeLiked:
            return [NSString stringWithFormat:@"Like from %@", self.user.name];
        case kGLPNotificationTypeAddedYou:
            return [NSString stringWithFormat:@"Contact request from %@",self.user.name];
        default:
            return [NSString stringWithFormat:@"You are now friends with %@",self.user.name];
    }
}

-(void)alreadyContacts
{
    self.notificationType = kGLPNotificationTypeContacts;
}

@end
