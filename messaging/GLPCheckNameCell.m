//
//  GLPCheckNameCell.m
//  Gleepost
//
//  Created by Σιλουανός on 2/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCheckNameCell.h"

@interface GLPCheckNameCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userSelectedImageView;

@property (weak, nonatomic) IBOutlet UIImageView *userUnselectedImageView;

@property (weak, nonatomic) IBOutlet UIImageView *userTickImageView;

@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@end

@implementation GLPCheckNameCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setUserData:(GLPUser *)user withCheckedStatus:(BOOL)checked
{
    [super setUserData:user];
    
    if(checked)
    {
        [self selectUser];
    }
    else
    {
        [self unselectUser];
    }
}

#pragma mark - Selectors

- (IBAction)userSelected:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if(button.tag == 0)
    {
        [_delegate userCheckedWithUser:[super user]];
        [self selectUser];
    }
    else
    {
        [_delegate userUncheckedWithUser:[super user]];
        [self unselectUser];
    }
}

#pragma mark - UI changes

- (void)selectUser
{
    _selectButton.tag = 1;
    
//    [_userSelectedImageView setHidden:NO];
    [_userTickImageView setHidden:NO];
    [_userUnselectedImageView setHidden:YES];
}

- (void)unselectUser
{
    _selectButton.tag = 0;
    
    [_userUnselectedImageView setHidden:NO];

    [_userSelectedImageView setHidden:YES];
    [_userTickImageView setHidden:YES];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
