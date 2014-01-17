//
//  GLPInvitationManager.h
//  Gleepost
//
//  Created by Tanmay Khandelwal on 16/01/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPInvitationManager : NSObject
+ (GLPInvitationManager *)sharedInstance;
- (void)fetchInviteMessageWithCompletion:(void (^)(BOOL success, NSString *inviteMessage))completion;
@end
