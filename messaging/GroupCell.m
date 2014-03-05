//
//  GroupCell.m
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GroupCell.h"
#import "ShapeFormatterHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "WebClient.h"

@interface GroupCell ()

@property (weak, nonatomic) IBOutlet UIImageView *groupImage;

@property (weak, nonatomic) IBOutlet UILabel *groupName;

@property (weak, nonatomic) UIViewController <GroupDeletedDelegate> *delegate;

@property (strong, nonatomic) GLPGroup *groupData;

@end


@implementation GroupCell

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        //[self createElements];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setGroupData:(GLPGroup *)groupData
{
    _groupData = groupData;
    
    //Add user's profile image.
    [_groupName setText:groupData.name];
    
    _groupName.tag = groupData.remoteKey;
    
    //Add user's name.
    [ShapeFormatterHelper setRoundedView:_groupImage toDiameter:_groupImage.frame.size.height];
    
    if([groupData.groupImageUrl isEqualToString:@""] || !groupData.groupImageUrl)
    {
        [_groupImage setImage:[UIImage imageNamed:@"default_user_image2"]];
    }
    else
    {
        [_groupImage setImageWithURL:[NSURL URLWithString:groupData.groupImageUrl] placeholderImage:[UIImage imageNamed:@"default_user_image2"]];
    }
}

-(void)setDelegate:(UIViewController <GroupDeletedDelegate> *)delegate
{
    _delegate = delegate;
}

#pragma mark - Selectors

- (IBAction)quitGroup:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to leave the group?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Leave",nil];
    
//    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0)
    {
        return;
    }
    
    
    [self quitFromGroup];
}


#pragma mark - Client

-(void)quitFromGroup
{
    [[WebClient sharedInstance] quitFromAGroupWithRemoteKey:_groupName.tag callback:^(BOOL success) {
        
        if(success)
        {
            DDLogInfo(@"User not in group: %@ anymore", _groupName.text);
            [_delegate groupDeletedWithData:[[GLPGroup alloc] init]];
        }
        else
        {
            DDLogInfo(@"Failed to quit user from group: %@", _groupName.text);
        }
        
    }];
}


@end
