//
//  ContactCell.m
//  Gleepost
//
//  Created by Σιλουανός on 30/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "MemberCell.h"
#import "ShapeFormatterHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "GLPMember.h"
#import "GLPImageHelper.h"

@interface MemberCell()

/** User's profile image. */
@property (weak, nonatomic) IBOutlet UIImageView *profileImageUser;

/** User's name. */
@property (weak, nonatomic) IBOutlet UILabel *nameUser;

@property (weak, nonatomic) IBOutlet UILabel *roleLbl;

@property (strong, nonatomic) GLPMember *member;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@end


@implementation MemberCell

const float CONTACT_CELL_HEIGHT = 48;

-(void)setName:(NSString *)name withImageUrl:(NSString *)imageUrl
{    
    //Add user's profile image.
    [_nameUser setText:name];
    
    [_nameUser sizeToFit];
    
    //Add user's name.
    [ShapeFormatterHelper setRoundedView:_profileImageUser toDiameter:_profileImageUser.frame.size.height];
    
    if([imageUrl isEqualToString:@""])
    {
        [_profileImageUser setImage:[GLPImageHelper placeholderUserImage]];
    }
    else
    {
        [_profileImageUser sd_setImageWithURL:[NSURL URLWithString:imageUrl]  placeholderImage:[GLPImageHelper placeholderUserImage] options:SDWebImageRetryFailed];
    }
    
    [_roleLbl setHidden:YES];
    [_moreButton setHidden:YES];
}

-(void)setMember:(GLPMember *)member withGroup:(GLPGroup *)group loggedInMemberRole:(GLPMember *)loggedInMember
{
    _member = member;
    
    [self setName:member.name withImageUrl:member.profileImageUrl];

    if(member.roleLevel == kMember)
    {
        [_roleLbl setHidden:YES];
    }
    else
    {
        [_roleLbl setHidden:NO];

        [_roleLbl setText: [NSString stringWithFormat:@"(%@)", member.roleName]];
    }
    
    
    [self configureMoreButtonWithLoggedInMember:loggedInMember];
}

/**
 Decides if should show the more button for the member.
 
 */
- (void)configureMoreButtonWithLoggedInMember:(GLPMember *)loggedInMember
{
    DDLogDebug(@"Logged in member %d current member %d", loggedInMember.roleLevel, _member.roleLevel);
    
    if(loggedInMember.roleLevel == kMember)
    {
        [_moreButton setHidden:YES];
        
        return;
    }
    
    //Hide more button when logged in user is creator for its cell view.
    if(loggedInMember.roleLevel == kCreator)
    {
        if(loggedInMember.remoteKey == _member.remoteKey)
        {
            [_moreButton setHidden:YES];
            
            return;
        }
    }
    
    if(loggedInMember.roleLevel >= _member.roleLevel)
    {
        [_moreButton setHidden:NO];
    }
    else
    {
        [_moreButton setHidden:YES];
    }
}

#pragma mark - Selectors

- (IBAction)showOptions:(id)sender
{
    [_delegate moreOptionsSelectedForMember:_member];
}


@end
