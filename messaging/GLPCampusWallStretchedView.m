//
//  GLPCampusWallStretchedView.m
//  Gleepost
//
//  Created by Silouanos on 02/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPCampusWallStretchedView.h"
#import "AppearanceHelper.h"
#import "UIColor+GLPAdditions.h"
#import "GLPThemeManager.h"
#import "GLPiOSSupportHelper.h"

@interface GLPCampusWallStretchedView ()

@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) UIView *dataView;
@property (strong, nonatomic) UILabel *topLabel;

@end

@implementation GLPCampusWallStretchedView

const float kCWStretchedImageHeight = 350;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
//        [super setColourOverlay:[UIColor colorWithR:245.0 withG:183.0 andB:40.0]];
        [super setColourOverlay:[[GLPThemeManager sharedInstance] tabbarSelectedColour]];
        [super setAlphaOverlay:0.8];
        [super setHeightOfTransImage:kCWStretchedImageHeight];
        [self configureFont];
        [self configureTopLabel];
        [self configureDataView];
    }
    
    return self;
}

#pragma mark - Configuration

- (void)configureFont
{
    self.font = [UIFont fontWithName:@"HelveticaNeue" size:24.0];
}

- (void)configureTopLabel
{
    self.topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 125.0, 243.0, 70.0)];
    
    self.topLabel.center = CGPointMake([GLPiOSSupportHelper screenWidth] / 2, self.topLabel.center.y);
    
    self.topLabel.font = self.font;
    
    self.topLabel.textColor = [UIColor whiteColor];
    
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    
    self.topLabel.numberOfLines = 0;
    
    self.topLabel.text = @"See what's happening on campus today";
    
    [self addSubview:self.topLabel];
}

- (void)configureDataView
{
    CGFloat topLabelBottomEdge = CGRectGetMaxY(self.topLabel.frame);
    
    self.dataView = [[UIView alloc] initWithFrame:CGRectMake(0.0, topLabelBottomEdge + 50.0, [GLPiOSSupportHelper screenWidth], 22.0)];
    
    self.dataView.center = CGPointMake([GLPiOSSupportHelper screenWidth] / 2, self.dataView.center.y);
    
    self.dataView.backgroundColor = [UIColor whiteColor];

    [self addSubview:self.dataView];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
