//
//  ProfileTwoButtonsTableViewCell.m
//  Gleepost
//
//  Created by Silouanos on 10/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ProfileTwoButtonsTableViewCell.h"

@interface ProfileTwoButtonsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *postsLine;

@property (weak, nonatomic) IBOutlet UIImageView *settingsLine;

@end

@implementation ProfileTwoButtonsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setDelegate:(GLPProfileViewController *)delegate
{
    _delegate = delegate;
}

- (IBAction)viewPosts:(id)sender
{
    [self showAllLines];
    
    [self.postsLine setHidden:YES];
    
    [_delegate viewSectionWithId:kGLPPosts];
}


- (IBAction)viewSettings:(id)sender
{
    [self showAllLines];
    
    [self.settingsLine setHidden:YES];
    
    [_delegate viewSectionWithId:kGLPSettings];
}

-(void)showAllLines
{
    [self.settingsLine setHidden:NO];
    [self.postsLine setHidden:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
