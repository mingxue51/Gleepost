//
//  ProfileAboutTableViewCell.m
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ProfileAboutTableViewCell.h"

@interface ProfileAboutTableViewCell ()



@end

@implementation ProfileAboutTableViewCell

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
    }
    
    return self;
}



-(void)updateUserDetails:(GLPUser *)user
{
    [self.lockImageView setHidden:YES];
    [self.lockLabel setHidden:YES];
    
    if(user == nil)
    {
        [self initialiseLoadingElements];
        return;
    }
    
    NSMutableString *information = [[NSMutableString alloc] init];

    if(![user.course isEqualToString:@""])
    {
        [information appendFormat:@"%@\n",user.course];
    }
    
    if(![user.personalMessage isEqualToString:@""])
    {
        [information appendFormat:@"%@",user.personalMessage];
    }
    
    
    [self.informationLabel setHidden:NO];
    
    
    [self.informationLabel setText:information];
    
//    CGSize labelSize = [self.informationLabel.text sizeWithFont:self.informationLabel.font
//                              constrainedToSize:self.informationLabel.frame.size
//                                  lineBreakMode:self.informationLabel.lineBreakMode];
//    
//    self.informationLabel.frame = CGRectMake(
//                             self.informationLabel.frame.origin.x, self.informationLabel.frame.origin.y,
//                             self.informationLabel.frame.size.width, labelSize.height);
    
}

-(void)initialiseLoadingElements
{
    [self.informationLabel setText:@"Loading..."];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
