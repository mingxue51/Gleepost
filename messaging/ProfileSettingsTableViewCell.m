//
//  ProfileSettingsTableViewCell.m
//  Gleepost
//
//  Created by Silouanos on 10/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ProfileSettingsTableViewCell.h"

@interface ProfileSettingsTableViewCell ()

@property (readonly, nonatomic) GLPProfileViewController *delegate;

@end

@implementation ProfileSettingsTableViewCell

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

- (IBAction)logout:(id)sender
{
    [_delegate logout:sender];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
