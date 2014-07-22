//
//  GroupCollectionViewCell.m
//  Gleepost
//
//  Created by Σιλουανός on 24/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GroupCollectionViewCell.h"
#import "WebClient.h"
#import "ShapeFormatterHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "AppearanceHelper.h"
#import "UIView+GLPDesign.h"

@interface GroupCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *groupImage;

@property (weak, nonatomic) IBOutlet UILabel *groupName;

@property (weak, nonatomic) IBOutlet UILabel *groupDescription;

@property (weak, nonatomic) UIViewController <GroupDeletedDelegate> *delegate;

@property (strong, nonatomic) GLPGroup *groupData;

@property (weak, nonatomic) IBOutlet UIButton *exitButton;

@property (weak, nonatomic) IBOutlet UIImageView *uploadedIndicator;

@end

const CGSize GROUP_COLLECTION_CELL_DIMENSIONS = {145.0, 145.0};

@implementation GroupCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self formatElements];
    
    
}

- (void)formatElements
{
    [ShapeFormatterHelper setRoundedView:_groupImage toDiameter:_groupImage.frame.size.height];
    
    [self setGleepostStyleBorder];
}

-(void)setGroupData:(GLPGroup *)groupData
{
    _groupData = groupData;
    
    //Add user's profile image.
    [_groupName setText:groupData.name];
    
    _groupName.tag = groupData.remoteKey;
    
    //Add user's name.
    [ShapeFormatterHelper setRoundedView:_uploadedIndicator toDiameter:_uploadedIndicator.frame.size.height];
    
    [_groupDescription setText:_groupData.groupDescription];
    
    if(groupData.finalImage)
    {
        [_groupImage setImage:groupData.finalImage];
    }
    else if([groupData.groupImageUrl isEqualToString:@""] || !groupData.groupImageUrl)
    {
        [_groupImage setImage:[UIImage imageNamed:@"default_user_image2"]];
    }
    //    else if (groupData.finalImage && groupData.groupImageUrl)
    //    {
    //        [_groupImage setImageWithURL:[NSURL URLWithString:groupData.groupImageUrl] placeholderImage:groupData.finalImage];
    //        groupData.finalImage = nil;
    //    }
    else
    {
        
        [_groupImage setImageWithURL:[NSURL URLWithString:groupData.groupImageUrl] placeholderImage:nil options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
    }
    
    if(groupData.sendStatus == kSendStatusLocal)
    {
        //Hide exit and show blink indicator.
        //        [self hideExitButton];
        [self blinkIndicator];
        [_exitButton setHidden:YES];
    }
    else
    {
        //Show exit button.
//        [self hideIndicator];
        //        [self showExitButton];
        [_uploadedIndicator setHidden:YES];

        [_exitButton setHidden:NO];
    }
}

#pragma mark - Online indicator

-(void)hideIndicator
{
    [self.uploadedIndicator setAlpha:1.0];
    
    //    [_exitButton setAlpha:0.0f];
    //    [_exitButton setHidden:NO];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:(UIViewAnimationCurveEaseOut | UIViewAnimationCurveEaseOut) animations:^{
        
        //        [_exitButton setAlpha:1.0f];
        [self.uploadedIndicator setAlpha:0.0];
        
    } completion:^(BOOL finished) {
        
        //        [_exitButton setAlpha:1.0f];
        
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
            [_delegate groupDeletedWithData:_groupData];
        }
        else
        {
            DDLogError(@"Failed to quit user from group: %@", _groupName.text);
        }
        
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end