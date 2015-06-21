//
//  GLPGroupStretchedImageView.m
//  Gleepost
//
//  Created by Silouanos on 02/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPStretchedImageView.h"
#import "GLPiOSSupportHelper.h"
#import "NSString+Utils.h"

@interface GLPStretchedImageView ()

@property (strong, nonatomic) UIImageView *transImageView;
@property (strong, nonatomic) UIColor *transImageViewColour;
@property (assign, nonatomic) CGFloat transImageViewAlpha;

@end

@implementation GLPStretchedImageView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
        self.transImageViewColour = [UIColor blackColor];
        self.transImageViewAlpha = 0.5;
        [self configureTransparentImageView];
    }
    return self;
}


- (void)configureTransparentImageView
{
    self.transImageView = [[UIImageView alloc] initWithFrame:self.frame];
    self.transImageView.tag = 5;
    CGRectSetW(self.transImageView, [GLPiOSSupportHelper screenWidth]);
    
    [self.transImageView setBackgroundColor:self.transImageViewColour];
    
    [self.transImageView setAlpha:self.transImageViewAlpha];
    
    [self.transImageView setClipsToBounds:YES];
    
    [self addSubview:self.transImageView];
    
    [self sendSubviewToBack:self.transImageView];
}

- (void)setHeightOfTransImage:(float)height
{
    CGRectSetH(_transImageView, height);
}

- (void)setImageUrl:(NSString *)imageUrl
{
    [super setImageUrl:imageUrl withPlaceholderImage:@"default_thumbnail"];
    
    if([imageUrl isEmpty] || !imageUrl)
    {
        [_transImageView setHidden:YES];
    }
}

- (void)setColourOverlay:(UIColor *)colourOverlay
{
    [self removeTransImageView];
    self.transImageViewColour = colourOverlay;
    [self configureTransparentImageView];
}

- (void)setAlphaOverlay:(CGFloat)alpha
{
    [self removeTransImageView];
    self.transImageViewAlpha = alpha;
    [self configureTransparentImageView];
}

- (void)removeTransImageView
{
    for(UIView *v in self.subviews)
    {
        if(v.tag == 5)
        {
            [v removeFromSuperview];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
