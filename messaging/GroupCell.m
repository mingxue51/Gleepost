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

@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIImageView *uploadedIndicator;

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

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [ShapeFormatterHelper setRoundedView:_groupImage toDiameter:_groupImage.frame.size.height];

    
}

-(void)setGroupData:(GLPGroup *)groupData
{
    _groupData = groupData;
    
    //Add user's profile image.
    [_groupName setText:groupData.name];
    
    _groupName.tag = groupData.remoteKey;
    
    //Add user's name.
//    [ShapeFormatterHelper setRoundedView:_groupImage toDiameter:_groupImage.frame.size.height];
    
    [ShapeFormatterHelper setRoundedView:_uploadedIndicator toDiameter:_uploadedIndicator.frame.size.height];

    if(groupData.finalImage)
    {
        [_groupImage setImage:groupData.finalImage];
    }
    else if([groupData.groupImageUrl isEqualToString:@""] || !groupData.groupImageUrl)
    {
        [_groupImage setImage:[UIImage imageNamed:@"default_user_image2"]];
    }
    else
    {
        [_groupImage setImageWithURL:[NSURL URLWithString:groupData.groupImageUrl] placeholderImage:[UIImage imageNamed:@"default_user_image2"]];
    }
    
    if(groupData.sendStatus == kSendStatusLocal)
    {
        //Hide exit and show blink indicator.
        [self hideExitButton];
        [self blinkIndicator];

    }
    else
    {
        //Show exit button.
        [self hideIndicator];
//        [self showExitButton];
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


#pragma mark - Online indicator

-(void)hideIndicator
{
    [self.uploadedIndicator setAlpha:1.0];
    
    [_exitButton setAlpha:0.0f];
    [_exitButton setHidden:NO];

    [UIView animateWithDuration:0.5 delay:0.0 options:(UIViewAnimationCurveEaseOut | UIViewAnimationCurveEaseOut) animations:^{
        
        [_exitButton setAlpha:1.0f];
        [self.uploadedIndicator setAlpha:0.0];
        
    } completion:^(BOOL finished) {
        
        [_exitButton setAlpha:1.0f];

        [_uploadedIndicator setHidden:YES];
        
    }];
    
}

-(void)blinkIndicator
{
    [_uploadedIndicator setHidden:NO];
    
    [self.uploadedIndicator setAlpha:1.0];
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [self.uploadedIndicator setAlpha:0.0];
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideExitButton
{
    [UIView animateWithDuration:0.5f animations:^{
        
        [_exitButton setAlpha:0.0f];

        
    } completion:^(BOOL finished){
       
        [_exitButton setHidden:YES];
        
    }];
    
}

-(void)showExitButton
{
    [_exitButton setHidden:NO];
    [_exitButton setAlpha:1.0f];

    
//    [UIView animateWithDuration:0.5f animations:^{
//        
//        
//        
//    } completion:^(BOOL finished){
//        
//        
//    }];
}


#pragma mark - Client

-(void)quitFromGroup
{
    [[WebClient sharedInstance] quitFromAGroupWithRemoteKey:_groupName.tag callback:^(BOOL success) {
        
        if(success)
        {
            DDLogInfo(@"User not in group: %@ anymore", _groupName.text);
            [_delegate groupDeletedWithData:_groupData];
        }
        else
        {
            DDLogInfo(@"Failed to quit user from group: %@", _groupName.text);
        }
        
    }];
}


@end
