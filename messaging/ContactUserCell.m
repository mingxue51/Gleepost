//
//  ContactCell.m
//  Gleepost
//
//  Created by Σιλουανός on 30/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ContactUserCell.h"

@implementation ContactUserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        
        
    }
    return self;
}

-(void) test
{
    NSLog(@"Test Method");
}

-(void) createElements
{
    NSLog(@"Create Elements");
    
    //Create and add user's profile image.
    self.profileImageUser = [[UIButton alloc] initWithFrame:CGRectMake(10.f, 2.f, 40.f, 40.f)];
    [self.contentView addSubview:self.profileImageUser];
    
    //Create and add user's name.
    self.nameUser = [[UILabel alloc] initWithFrame:CGRectMake(60.f, 0.f, 280.f, 40.f)];
    [self.contentView addSubview:self.nameUser];
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

@end
