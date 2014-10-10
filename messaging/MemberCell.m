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

@interface MemberCell()

/** User's profile image. */
@property (weak, nonatomic) IBOutlet UIImageView *profileImageUser;

/** User's name. */
@property (weak, nonatomic) IBOutlet UILabel *nameUser;

@property (weak, nonatomic) IBOutlet UILabel *creatorLbl;

@property (strong, nonatomic) GLPUser *member;

@end


@implementation MemberCell

const float CONTACT_CELL_HEIGHT = 48;

-(void)setName:(NSString *)name withImageUrl:(NSString *)imageUrl
{    
    //Add user's profile image.
    [_nameUser setText:name];
    
    //Add user's name.
    [ShapeFormatterHelper setRoundedView:_profileImageUser toDiameter:_profileImageUser.frame.size.height];
    
    if([imageUrl isEqualToString:@""])
    {
        [_profileImageUser setImage:[UIImage imageNamed:@"default_user_image2"]];
    }
    else
    {
        [_profileImageUser setImageWithURL:[NSURL URLWithString:imageUrl]  placeholderImage:nil options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
}

-(void)setMember:(GLPUser *)member withGroup:(GLPGroup *)group
{
    _member = member;
    
    [self setName:member.name withImageUrl:member.profileImageUrl];
    
    if(group.author.remoteKey == member.remoteKey)
    {
        [_creatorLbl setHidden:NO];
    }
}

#pragma mark - Selectors

- (IBAction)showOptions:(id)sender
{
    [_delegate moreOptionsSelectedForMember:_member];
    
}


@end
