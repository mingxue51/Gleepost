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

@property (strong, nonatomic) UIFont *topTitleFont;
@property (strong, nonatomic) UIFont *dataViewNumberFont;
@property (strong, nonatomic) UIFont *dataViewTextFont;

@property (strong, nonatomic) UIView *dataView;
@property (strong, nonatomic) UILabel *topLabel;

@property (strong, nonatomic) UILabel *leftNumberLabel;
@property (strong, nonatomic) UILabel *leftTextLabel;

@property (strong, nonatomic) UILabel *centerNumberLabel;
@property (strong, nonatomic) UILabel *centerTextLabel;

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
        [self configureFonts];
        [self configureTopLabel];
        [self configureDataView];
    }
    
    return self;
}

#pragma mark - Configuration

- (void)configureFonts
{
    self.topTitleFont = [UIFont fontWithName:@"HelveticaNeue" size:24.0];
    self.dataViewNumberFont = [UIFont fontWithName:GLP_HELV_NEUE_MEDIUM size:21.0];
    self.dataViewTextFont = [UIFont fontWithName:GLP_HELV_NEUE_MEDIUM size:16.0];
}

- (void)configureTopLabel
{
    self.topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 125.0, 243.0, 70.0)];
    
    self.topLabel.center = CGPointMake([GLPiOSSupportHelper screenWidth] / 2, self.topLabel.center.y);
    
    self.topLabel.font = self.topTitleFont;
    
    self.topLabel.textColor = [UIColor whiteColor];
    
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    
    self.topLabel.numberOfLines = 0;
    
    self.topLabel.text = @"See what's happening on campus today";
    
    [self addSubview:self.topLabel];
}

- (void)configureDataView
{
    CGFloat topLabelBottomEdge = CGRectGetMaxY(self.topLabel.frame);
    
    self.dataView = [[UIView alloc] initWithFrame:CGRectMake(0.0, topLabelBottomEdge + 10.0, [GLPiOSSupportHelper screenWidth], 50.0)];
    
    self.dataView.center = CGPointMake([GLPiOSSupportHelper screenWidth] / 2, self.dataView.center.y);
    
    self.dataView.backgroundColor = [UIColor clearColor];

    [self addLeftNumberLabelToDataViewWithX:self.topLabel.frame.origin.x - 30 andNumber:50];
    
    [self addLeftTextLabelToDataViewWithX:CGRectGetMaxX(self.leftNumberLabel.frame) andText:@"parties"];
    
    [self addCenterNumberLabelToDataViewWithX:self.dataView.center.x - 55 andNumber:10];
    
    [self addCenterTextLabelToDataViewWithX:CGRectGetMaxX(self.centerNumberLabel.frame) andText:@"speakers"];
    
    [self addSubview:self.dataView];
}

- (void)addCenterNumberLabelToDataViewWithX:(CGFloat)x andNumber:(NSInteger)number
{
    CGRect dataViewFrame = self.dataView.frame;

    self.centerNumberLabel = [self generateLabelForDataViewWithText:[NSString stringWithFormat:@"%ld", (long)number]];
    
    //TODO: The width should change dynamically (depending on text length).
    
    self.centerNumberLabel.frame = CGRectMake(x, 0.0, 30.0, dataViewFrame.size.height);
    
    self.centerNumberLabel.font = self.dataViewNumberFont;
    
    [self.dataView addSubview:self.centerNumberLabel];
}

- (void)addCenterTextLabelToDataViewWithX:(CGFloat)x andText:(NSString *)text
{
    CGRect dataViewFrame = self.dataView.frame;
    
    self.centerTextLabel = [self generateLabelForDataViewWithText:text];
    
    self.centerTextLabel.frame = CGRectMake(x, 8.0, 70.0, dataViewFrame.size.height - 10);
    
    self.centerTextLabel.font = self.dataViewTextFont;
    
    [self.dataView addSubview:self.centerTextLabel];
}

- (void)addLeftNumberLabelToDataViewWithX:(CGFloat)x andNumber:(NSInteger)number
{
    CGRect dataViewFrame = self.dataView.frame;
    
    self.leftNumberLabel = [self generateLabelForDataViewWithText:[NSString stringWithFormat:@"%ld", (long)number]];
    
    self.leftNumberLabel.frame = CGRectMake(x, 0.0, 30.0, dataViewFrame.size.height);
    
    self.leftNumberLabel.font = self.dataViewNumberFont;
    
    [self.dataView addSubview:self.leftNumberLabel];
}

- (void)addLeftTextLabelToDataViewWithX:(CGFloat)x andText:(NSString *)text
{
    CGRect dataViewFrame = self.dataView.frame;

    self.leftTextLabel = [self generateLabelForDataViewWithText:text];
    
    self.leftTextLabel.frame = CGRectMake(x, 8.0, 55.0, dataViewFrame.size.height - 10);
    
    self.leftTextLabel.font = self.dataViewTextFont;
    
    [self.dataView addSubview:self.leftTextLabel];
}


- (UILabel *)generateLabelForDataViewWithText:(NSString *)text
{
    UILabel *label = [[UILabel alloc] init];
    
    label.text = text;
    
    label.backgroundColor = [UIColor clearColor];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    label.textColor = [UIColor whiteColor];
    
    return label;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
