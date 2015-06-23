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
    kGLPNotificationTypeCommentedOnComment,
    kGLPNotificationTypeLiked,
    kGLPNotificationTypeAddedGroup,
    kGLPNotificationTypeCreatedPostGroup,
    kGLPNotificationTypeInvitedYouToGroup,
    kGLPNotificationTypePostApproved,
    kGLPNotificationTypePostRejected,
    kGLPNotificationTypeSomeoneVoted,
    kGLPNotificationTypeSomeoneAttended
} GLPNotificationType;

@property (assign, nonatomic) NSInteger postRemoteKey;
@property (assign, nonatomic) GLPNotificationType notificationType;
@property (assign, nonatomic) BOOL seen;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) GLPUser *user;
@property (strong, nonatomic) NSString *previewMessage;
@property (strong, nonatomic) NSDictionary *customParams;

- (NSString *)notificationTypeDescription;
//- (BOOL)displaysPictoImage;

@end
