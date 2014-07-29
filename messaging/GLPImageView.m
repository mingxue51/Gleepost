//
//  GLPImageView.m
//  Gleepost
//
//  Created by Σιλουανός on 28/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPImageView.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@implementation GLPImageView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)setImageUrl:(NSString *)imageUrl
{
    if([imageUrl isEqualToString:@""])
    {
        //Set default image.
        [self setImage:[UIImage imageNamed:@"default_user_image2"]];
    }
    else
    {
        //Fetch the image from the server and add it to the image view.
        [self setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
