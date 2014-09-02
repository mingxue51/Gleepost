//
//  AddressCell.m
//  Gleepost
//
//  Created by Σιλουανός on 1/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "AddressCell.h"

@interface AddressCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation AddressCell

const float ADDRESS_CELL_HEIGHT = 40;

- (void)setVenueName:(NSString *)name
{
    [_nameLabel setText:name];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
