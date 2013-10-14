//
//  PostWithImageCell.m
//  Gleepost
//
//  Created by Σιλουανός on 11/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "PostWithImageCell.h"

@implementation PostWithImageCell

@synthesize mainImage;

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
       // [self createImage];
       // [self createElements];
    }
    
    return self;
}

-(void) createImage
{
    //Main Image.
    self.mainImage = [[UIImageView alloc] init];
    [self.mainImage setBackgroundColor:[UIColor clearColor]];
    ////    [self.mainImage setFrame:CGRectMake(10.0f, 80.0f, 300.0, 400.0)];
    [self.mainImage sizeToFit];
    [self.contentView addSubview:self.mainImage];
    
    
    UIColor *backColour = [UIColor colorWithWhite:1.0f alpha:0.5f];
    [self.socialPanel setBackgroundColor:backColour];
    
//    [self.thumpsUpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.commentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.thumpsUpBtn setImage:[UIImage imageNamed:@"thumbs-up_image"] forState:UIControlStateNormal];
    [self.shareBtn setImage:[UIImage imageNamed:@"share_image"] forState:UIControlStateNormal];
    [self.commentBtn setImage:[UIImage imageNamed:@"comment_image"] forState:UIControlStateNormal];

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
