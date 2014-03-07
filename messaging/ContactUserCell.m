//
//  ContactCell.m
//  Gleepost
//
//  Created by Σιλουανός on 30/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ContactUserCell.h"
#import "ShapeFormatterHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ContactUserCell

const float CONTACT_CELL_HEIGHT = 48;


-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        //[self createElements];
    }
    
    return self;
}


-(void)setName:(NSString *)name withImageUrl:(NSString *)imageUrl
{
    NSLog(@"Create Elements");
    
    //Add user's profile image.
    [_nameUser setText:name];
    
    //Add user's name.
    [ShapeFormatterHelper setRoundedView:_profileImageUser toDiameter:_profileImageUser.frame.size.height];
    
    if([imageUrl isEqualToString:@""])
    {
        [_profileImageUser setImage:[UIImage imageNamed:@"default_user_image2"]];
    }
    else
    {
        [_profileImageUser setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"default_user_image2"]];
    }
}

@end
