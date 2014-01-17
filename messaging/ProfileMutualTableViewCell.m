//
//  ProfileMutualTableViewCell.m
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ProfileMutualTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ShapeFormatterHelper.h"

@implementation ProfileMutualTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)updateDataWithName:(NSString*)name andImageUrl:(NSString*)url
{
    [self.userNameLabel setText:name];
    
    [self.profileUserImage setImageWithURL:[NSURL URLWithString:url]];
    
    [ShapeFormatterHelper setRoundedView:self.profileUserImage toDiameter:self.profileUserImage.frame.size.height];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
