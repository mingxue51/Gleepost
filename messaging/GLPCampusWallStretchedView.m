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
#import "ShapeFormatterHelper.h"
#import "CampusLiveManager.h"
#import "GLPLiveSummary.h"

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

@property (strong, nonatomic) UILabel *rightNumberLabel;
@property (strong, nonatomic) UILabel *rightTextLabel;

@property (assign, nonatomic, readonly) NSInteger distanceBetweenNumberAndText;


@end

@implementation GLPCampusWallStretchedView

// We are using dynamic to avoid overriding the delegate from classe's super class.
@dynamic delegate;

const float kCWStretchedImageHeight = 350;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
        [self configureNotifications];
        [super setColourOverlay:[[GLPThemeManager sharedInstance] tabbarSelectedColour]];
        [super setAlphaOverlay:0.8];
        [super setHeightOfTransImage:kCWStretchedImageHeight];
        [self intialiseObjects];
        [self configureFonts];
        [self configureTopLabel];
        [self configureDataView];
        [self loadLiveData];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)dealloc
{
    DDLogInfo(@"GLPCampusWallStretchedView dealloc");
    [self removeNotifications];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CAMPUS_LIVE_SUMMARY_FETCHED object:nil];
}

#pragma mark - Configuration

- (void)intialiseObjects
{
    _distanceBetweenNumberAndText = 3;
}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liveSummaryFetched:) name:GLPNOTIFICATION_CAMPUS_LIVE_SUMMARY_FETCHED object:nil];
}

- (void)configureFonts
{
    self.topTitleFont = [UIFont fontWithName:@"HelveticaNeue" size:24.0];
    self.dataViewNumberFont = [UIFont fontWithName:GLP_HELV_NEUE_MEDIUM size:21.0];
    self.dataViewTextFont = [UIFont fontWithName:GLP_HELV_NEUE_MEDIUM size:16.0];
}

- (void)configureTopLabel
{
    self.topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 125.0, 240.0, 70.0)];
    
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
    
    self.dataView.alpha = 0.0;
    
    self.dataView.center = CGPointMake([GLPiOSSupportHelper screenWidth] / 2, self.dataView.center.y);
    
    self.dataView.backgroundColor = [UIColor clearColor];

    [self addLeftNumberLabelToDataViewWithX:self.topLabel.frame.origin.x - 30 andNumber:50];
    [self addLeftTextLabelToDataViewWithX:CGRectGetMaxX(self.leftNumberLabel.frame) andText:@"parties"];
    
    
    [self addCenterNumberLabelToDataViewWithX:self.dataView.center.x - 55 andNumber:10];
    [self addCenterTextLabelToDataViewWithX:CGRectGetMaxX(self.centerNumberLabel.frame) andText:@"speakers"];
    
    
    [self addRightTextLabelToDataViewWithX:CGRectGetMaxX(self.topLabel.frame) + 30 andText:@"more"];
    [self addRightNumberLabelToDataViewWithX:self.rightTextLabel.frame.origin.x andNumber:19];
    
    [self addBottomButton];
    
    [self addSubview:self.dataView];
    
}

- (void)refreshPositioningOnElements
{
    //Left elements.
    CGRectSetX(self.leftTextLabel, CGRectGetMinX(self.topLabel.frame) - 10);
    CGRectSetW(self.leftNumberLabel, [self labelWidthWithText:self.leftNumberLabel.text containsNumber:YES]);
    CGRectSetX(self.leftNumberLabel, CGRectGetMinX(self.leftTextLabel.frame) - CGRectGetWidth(self.leftNumberLabel.frame) - self.distanceBetweenNumberAndText);

    //Center elements.
    CGRectSetX(self.centerTextLabel, self.dataView.center.x - 30);
    CGRectSetW(self.centerNumberLabel, [self labelWidthWithText:self.centerNumberLabel.text containsNumber:YES]);
    CGRectSetX(self.centerNumberLabel, CGRectGetMinX(self.centerTextLabel.frame) - CGRectGetWidth(self.centerNumberLabel.frame) - self.distanceBetweenNumberAndText);
    
    //Right elements.
    CGRectSetX(self.rightTextLabel, CGRectGetMaxX(self.topLabel.frame) - 20);
    CGRectSetW(self.rightNumberLabel, [self labelWidthWithText:self.rightNumberLabel.text containsNumber:YES]);
    CGRectSetX(self.rightNumberLabel, CGRectGetMinX(self.rightTextLabel.frame) - CGRectGetWidth(self.rightNumberLabel.frame) - self.distanceBetweenNumberAndText);
}

- (void)addBottomButton
{
    const CGFloat BUTTON_WIDTH = [GLPiOSSupportHelper screenWidth] * 0.51;
    const CGFloat BUTTON_Y = kCWStretchedImageHeight - 40.0 - 30;
    
    UIButton *bottomButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, BUTTON_Y, BUTTON_WIDTH, 40.0)];
    
    bottomButton.center = CGPointMake([GLPiOSSupportHelper screenWidth] / 2, bottomButton.center.y);
    
    bottomButton.backgroundColor = [UIColor clearColor];
    
    bottomButton.titleLabel.textColor = [UIColor whiteColor];
    
    [bottomButton setTitle:@"take a look" forState:UIControlStateNormal];
    [bottomButton addTarget:self action:@selector(takeALookTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [ShapeFormatterHelper setBorderToView:bottomButton withColour:[UIColor whiteColor] andWidth:2.0];
    
    [ShapeFormatterHelper setCornerRadiusWithView:bottomButton andValue:4];
    
    [self addSubview:bottomButton];
}

- (void)addRightNumberLabelToDataViewWithX:(CGFloat)x andNumber:(NSInteger)number
{
    CGRect dataViewFrame = self.dataView.frame;
    
    NSString *text = [NSString stringWithFormat:@"+%ld", (long)number];
    CGFloat width = [self labelWidthWithText:text containsNumber:YES];
    
    self.rightNumberLabel = [self generateLabelForDataViewWithText:text];
    
    //TODO: The width should change dynamically (depending on text length).
    
    self.rightNumberLabel.frame = CGRectMake(x - 40.0, 0.0, width, dataViewFrame.size.height);
    
    self.rightNumberLabel.font = self.dataViewNumberFont;
    
    [self.dataView addSubview:self.rightNumberLabel];
}

- (void)addRightTextLabelToDataViewWithX:(CGFloat)x andText:(NSString *)text
{
    CGRect dataViewFrame = self.dataView.frame;
    
    self.rightTextLabel = [self generateLabelForDataViewWithText:text];
    
    self.rightTextLabel.frame = CGRectMake(x - 40, 8.0, 40.0, dataViewFrame.size.height - 10);
    
    self.rightTextLabel.font = self.dataViewTextFont;
    
    [self.dataView addSubview:self.rightTextLabel];
}

- (void)addCenterNumberLabelToDataViewWithX:(CGFloat)x andNumber:(NSInteger)number
{
    CGRect dataViewFrame = self.dataView.frame;

    NSString *text = [NSString stringWithFormat:@"%ld", (long)number];
    CGFloat width = [self labelWidthWithText:text containsNumber:YES];

    
    self.centerNumberLabel = [self generateLabelForDataViewWithText:text];
    
    //TODO: The width should change dynamically (depending on text length).
    
    self.centerNumberLabel.frame = CGRectMake(x, 0.0, width, dataViewFrame.size.height);
    
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
    
    NSString *text = [NSString stringWithFormat:@"%ld", (long)number];
    
    self.leftNumberLabel = [self generateLabelForDataViewWithText:text];
    
    CGFloat width = [self labelWidthWithText:text containsNumber:YES];
    
    self.leftNumberLabel.frame = CGRectMake(x, 0.0, width, dataViewFrame.size.height);
    
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

#pragma mark - Client

- (void)loadLiveData
{
    [[CampusLiveManager sharedInstance] getLiveSummary];
}

- (void)liveSummaryFetched:(NSNotification *)notification
{
    DDLogDebug(@"Live summary fetched %@", notification.userInfo);
    self.leftNumberLabel.text =  [NSString stringWithFormat:@"%ld", (long)[[CampusLiveManager sharedInstance] liveSummaryPartiesCount]];
    self.centerNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)[[CampusLiveManager sharedInstance] liveSummarySpeakersCount]];
    self.rightNumberLabel.text = [NSString stringWithFormat:@"+%ld", (long)[[CampusLiveManager sharedInstance] liveSummaryPostsLeftCount]];

    [self refreshPositioningOnElements];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.dataView.alpha = 1.0;
    }];
}

#pragma mark - Selectors

- (void)takeALookTouched:(id)sender
{
    DDLogDebug(@"GLPCampusWallStretchedView takeALookTouched");
    
    [self.delegate takeALookTouched];
}

#pragma mark - Helpers

- (CGFloat)labelWidthWithText:(NSString *)text containsNumber:(BOOL)containsNumber
{
    const CGFloat MAX_WIDTH = 50.0;
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: (containsNumber) ? self.dataViewNumberFont : self.dataViewTextFont}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){MAX_WIDTH, CGFLOAT_MAX}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    
    return rect.size.width;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
