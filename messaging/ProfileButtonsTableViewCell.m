//
//  ProfileButtonsTableViewCell.m
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ProfileButtonsTableViewCell.h"


@implementation ProfileButtonsTableViewCell

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)viewAbout:(id)sender
{
    
}

- (IBAction)viewPosts:(id)sender
{
    
}

- (IBAction)viewMutual:(id)sender
{
    
}
@end
