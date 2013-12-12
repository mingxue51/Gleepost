//
//  ProfileButtonsTableViewCell.m
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ProfileButtonsTableViewCell.h"

@interface ProfileButtonsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *aboutLine;
@property (weak, nonatomic) IBOutlet UIImageView *postsLine;
@property (weak, nonatomic) IBOutlet UIImageView *mutualLine;


@end

@implementation ProfileButtonsTableViewCell

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
    }
    
    return self;
}

-(void)setDelegate:(GLPPrivateProfileViewController *)delegate
{
    _delegate = delegate;
}

- (IBAction)viewAbout:(id)sender
{
    [self showAllLines];
    
    [self.aboutLine setHidden:YES];
    
    [_delegate viewSectionWithId:kGLPAbout];
}

- (IBAction)viewPosts:(id)sender
{
    [self showAllLines];

    [self.postsLine setHidden:YES];

    [_delegate viewSectionWithId:kGLPPosts];

}

- (IBAction)viewMutual:(id)sender
{
    [self showAllLines];

    [self.mutualLine setHidden:YES];

    [_delegate viewSectionWithId:kGLPMutual];
}

-(void)showAllLines
{
    [self.aboutLine setHidden:NO];
    [self.postsLine setHidden:NO];
    [self.mutualLine setHidden:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
