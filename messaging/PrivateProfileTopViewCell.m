//
//  PrivateProfileTopViewCell.m
//  Gleepost
//
//  Created by Σιλουανός on 27/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "PrivateProfileTopViewCell.h"
#import "GLPConversation.h"
#import "GLPLiveConversationsManager.h"
#import "SessionManager.h"

@interface PrivateProfileTopViewCell ()

@property (strong, nonatomic) GLPUser *currentUser;

@end

@implementation PrivateProfileTopViewCell

const float PRIVATE_PROFILE_TOP_VIEW_HEIGHT = 245;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [super setSubClassdelegate:self];

}

- (void)setUserData:(GLPUser *)userData
{
    _currentUser = userData;
    
    [super setImageWithUrl:userData.profileImageUrl];
    
//    [super setTitleWithString:userData.name];
    
    [super setSubtitleWithString:userData.networkName];
    
    [super setSmallSubtitleWithString:userData.personalMessage];
    
    //TODO: Complete the following with real data.
    
    [super setNumberOfPosts:[_currentUser.postsCount integerValue]];
    
    [super setNumberOfMemberships:[_currentUser.groupCount integerValue]];
    
    [super setNumberOfRsvps: [_currentUser.rsvpCount integerValue]];
}

#pragma mark - Selectors

- (IBAction)sendMessage:(id)sender
{
    GLPConversation *conversation = [[GLPLiveConversationsManager sharedInstance] findOneToOneConversationWithParticipant:self.currentUser];
    
    DDLogInfo(@"Regular conversation for participant, conversation remote key: %d", conversation.remoteKey);
    
    if(!conversation) {
        DDLogInfo(@"Create empty conversation");
        
        NSArray *part = [[NSArray alloc] initWithObjects:self.currentUser, [SessionManager sharedInstance].user, nil];
        conversation = [[GLPConversation alloc] initWithParticipants:part];
    }
    
    [_delegate viewConversation:conversation];
}

#pragma mark - TopTableViewCellDelegate

- (void)mainImageViewTouched
{
    [_delegate viewProfileImage:[super mainImageViewImage]];
}

- (void)badgeTouched
{
    [_delegate badgeTouched];
}

- (void)numberOfGroupsTouched
{
    [_delegate numberOfGroupsTouched];
}

- (void)numberOfRsvpsTouched
{
    [_delegate numberOfRsvpsTouched];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
