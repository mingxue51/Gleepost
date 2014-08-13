//
//  SettingCell.m
//  Gleepost
//
//  Created by Σιλουανός on 12/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "SettingCell.h"

@interface SettingCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

@end

@implementation SettingCell

const float SETTING_CELL_HEIGHT = 50.0;

- (void)awakeFromNib
{
    
}

- (void)setTitle:(NSString *)title
{
    [_titleLbl setText:title];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
