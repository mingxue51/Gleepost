//
//  GLPNotification.h
//  Gleepost
//
//  Created by Lukas on 11/13/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPEntity.h"
#import "GLPUser.h"

@interface GLPNotification : GLPEntity

typedef enum {
    kGLPNotificationTypeAddedYou,
    kGLPNotificationTypeAcceptedYou,
    kGLPNotificationTypeCommented,
    kGLPNotificationTypeLiked,
} GLPNotificationType;

@property (assign, nonatomic) NSInteger postRemoteKey;
@property (assign, nonatomic) GLPNotificationType notificationType;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) GLPUser *user;

@end
