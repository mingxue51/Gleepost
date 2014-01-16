//
//  GLPInvitationManager.m
//  Gleepost
//
//  Created by Tanmay Khandelwal on 16/01/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPInvitationManager.h"
#import "WebClient.h"
#import "NSUserDefaults+GLPAdditions.h"

@interface GLPInvitationManager () {
    NSString *_inviteMessage;
}

@end

@implementation GLPInvitationManager

+ (GLPInvitationManager *)sharedInstance {
    static GLPInvitationManager *invitationManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        invitationManager = [[GLPInvitationManager alloc] init];
    });
    
    return invitationManager;
}

- (void)beginFetchingInviteMessage {
    _inviteMessage = [[NSUserDefaults standardUserDefaults] inviteMesssage];
    
    [[WebClient sharedInstance] getInviteMessageWithCallback:^(BOOL success, NSString *inviteMessage) {
        if (success) {
            _inviteMessage = inviteMessage;
            [[NSUserDefaults standardUserDefaults] saveInviteMessage:_inviteMessage];
        }
    }];
}

- (NSString *)inviteMessage {
    return _inviteMessage;
}

@end
