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

const float TWO_BUTTONS_CELL_HEIGHT = 65.0f;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        
    }
    
    return self;
}

-(void)setDelegate:(GLPProfileViewController *)delegate
{
    _delegate = delegate;
}

- (IBAction)viewPosts:(id)sender
{
    [self setGrayToNavigators];
    
    [self setGreenToNavigator:self.postsLine];
    
    [_delegate viewSectionWithId:kGLPPosts];
}


- (IBAction)viewSettings:(id)sender
{
    
    [self setGrayToNavigators];
    
    [self setGreenToNavigator:self.settingsLine];
    
    [_delegate viewSectionWithId:kGLPSettings];
}


-(void)setGreenToNavigator:(UIImageView*)navigator
{
    [navigator setImage:[UIImage imageNamed:@"active_tab"]];
}

-(void)setGrayToNavigators
{
    [self.settingsLine setImage:[UIImage imageNamed:@"idle_tab"]];
    
    [self.postsLine setImage:[UIImage imageNamed:@"idle_tab"]];
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
