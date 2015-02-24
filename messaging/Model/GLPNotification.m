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
            return [NSString stringWithFormat:@"%@ commented on your post: \"%@\"", self.user.name, self.previewMessage];
        case kGLPNotificationTypeLiked:
            return [NSString stringWithFormat:@"%@ likes your post", self.user.name];
        case kGLPNotificationTypeAddedYou:
            return [NSString stringWithFormat:@"Contact invite from %@",self.user.name];
        case kGLPNotificationTypeAddedGroup:
            return [NSString stringWithFormat:@"%@ added you to a group", self.user.name];
        case kGLPNotificationTypeCreatedPostGroup:
            return [NSString stringWithFormat:@"%@ created a post in your group.", self.user.name];
        case kGLPNotificationTypePostApproved:
            return [NSString stringWithFormat:@"%@ approved your post.", self.user.name];
        case kGLPNotificationTypePostRejected:
            return [NSString stringWithFormat:@"%@ rejected your post.", self.user.name];
        default:
            return @"Something happened";
    }
}

//- (BOOL)displaysPictoImage
//{
//    return
//        self.notificationType == kGLPNotificationTypeLiked ||
//        self.notificationType == kGLPNotificationTypeCommented ||
//        self.notificationType == kGLPNotificationTypeAddedGroup;
//}

@end
