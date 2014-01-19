//
//  GLPInvitationManager.m
//  Gleepost
//
//  Created by Tanmay Khandelwal on 16/01/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPInvitationManager.h"
#import "WebClient.h"

@implementation GLPInvitationManager

+ (GLPInvitationManager *)sharedInstance {
    static GLPInvitationManager *invitationManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        invitationManager = [[GLPInvitationManager alloc] init];
    });
    
    return invitationManager;
}

- (void)fetchInviteMessageWithCompletion:(void (^)(BOOL success, NSString *inviteMessage))completion {
    [[WebClient sharedInstance] getInviteMessageWithCallback:^(BOOL success, NSString *inviteMessage) {
        completion(success, inviteMessage);
    }];
}

@end
