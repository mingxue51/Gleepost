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

@interface GLPImageView ()

@property (strong, nonatomic) UITapGestureRecognizer *imageGesture;

@end

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

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configureImageView];
}

- (void)configureImageView
{
    [self setUserInteractionEnabled:YES];
}

- (void)setImageUrl:(NSString *)imageUrl withPlaceholderImage:(NSString *)imagePath
{
    if([imageUrl isEqualToString:@""] || !imageUrl)
    {        
        //Set default image.
        [self setImage:[UIImage imageNamed:imagePath]];
    }
    else
    {
        //Fetch the image from the server and add it to the image view.
        [self sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:imagePath] options:SDWebImageRetryFailed];
    }
}

/**
 This method should be called only when the image is already fetched.
 */
- (void)setActualImage:(UIImage *)image
{
    [self setImage:image];
}

- (void)setGesture:(BOOL)gesture
{
    if(gesture)
    {
        _imageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTouched)];
        
        [self addGestureRecognizer:_imageGesture];
    }
    else
    {
        if(_imageGesture)
        {
            [self removeGestureRecognizer:_imageGesture];
        }
    }

}

- (void)imageTouched
{
    
    if(_viewControllerDelegate)
    {
        if([_viewControllerDelegate respondsToSelector:@selector(imageTouchedWithImageView:)])
        {
            [_viewControllerDelegate imageTouchedWithImageView:self];
        }
    }
//    else if (_normalViewDelegate)
//    {
//        if([_viewDelegate respondsToSelector:@selector(imageTouchedWithImageView:)])
//        {
//            [_normalViewDelegate imageTouchedWithImageView:self];
//        }
//    }
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
