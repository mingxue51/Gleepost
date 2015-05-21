//
//  CampusWallFakeNavigationBar.m
//  Gleepost
//
//  Created by Silouanos on 14/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "CampusWallFakeNavigationBar.h"
#import "GLPThemeManager.h"
#import "AppearanceHelper.h"
#import "UIColor+GLPAdditions.h"

@interface CampusWallFakeNavigationBar ()

@property (weak, nonatomic) IBOutlet UIImageView *bottomLineImageView;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (assign, nonatomic) BOOL isLoading;

@property (assign, nonatomic) CGFloat animationDuration;
@property (assign, nonatomic) BOOL isTransparentMode;

@end

@implementation CampusWallFakeNavigationBar


- (id)initWithTitle:(NSString *)title
{
    self = [super initWithNibName:@"CampusWallFakeNavigationBar"];
    
    if(self)
    {
        [super setTitleToLabel:title];
        [self formatNavigationBar];
        [self initiliaseObjects];
    }
    
    return self;
}

- (void)initiliaseObjects
{
    self.animationDuration = 0.3;
    self.isLoading = NO;
}

- (void)formatNavigationBar
{
    [self makeBackgroundViewTransparent:YES];
    [super setTitleColour:[[GLPThemeManager sharedInstance] campusWallNavigationBarTitleColour]];
}

- (void)makeBackgroundViewTransparent:(BOOL)transparent
{
    CampusWallFakeNavigationBar *externalView = (CampusWallFakeNavigationBar *)self.externalView;
    externalView.bottomLineImageView.backgroundColor = (transparent) ? [UIColor clearColor] : [AppearanceHelper mediumGrayGleepostColour];
    [externalView setBackgroundColor:(transparent) ? [UIColor clearColor] : [[GLPThemeManager sharedInstance] navigationBarColour]];
    [externalView setAlphaToTitle:(transparent) ? 0.0 : 1.0];
    [self colourButtonsInTransparentMode:transparent];
    self.isTransparentMode = transparent;
}

- (void)colourButtonsInTransparentMode:(BOOL)transparentMode
{
    CampusWallFakeNavigationBar *externalView = (CampusWallFakeNavigationBar *)self.externalView;

    UIImage *rightImage = [UIImage imageNamed:@"pen"];
    UIImage *leftImage = [UIImage imageNamed:@"cards"];
    
    UIColor *rightImageColour = (transparentMode) ? [UIColor whiteColor] : [[GLPThemeManager sharedInstance] rightItemColour];
    UIColor *leftImageColour = (transparentMode) ? [UIColor whiteColor] : [[GLPThemeManager sharedInstance] leftItemColour];
    
    
    [externalView.leftButton setImage:[leftImageColour filledImageFrom:leftImage] forState:UIControlStateNormal];
    [externalView.rightButton setImage:[rightImageColour filledImageFrom:rightImage] forState:UIControlStateNormal];
}

#pragma mark - Public

- (void)transparentMode
{
    if(self.isLoading)
    {
        [self startLoading];
        return;
    }
    
    [UIView animateWithDuration:self.animationDuration delay:0.0 options:UIViewAnimationCurveEaseOut | UIViewAnimationCurveEaseOut  animations:^{
        
        [self makeBackgroundViewTransparent:YES];
        
    } completion:^(BOOL finished) {
        
    }];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

- (void)colourMode
{
    
    CampusWallFakeNavigationBar *externalView = (CampusWallFakeNavigationBar *)self.externalView;

    [externalView.loadingView stopAnimating];
    
    [UIView animateWithDuration:self.animationDuration delay:0.0 options:UIViewAnimationCurveEaseOut | UIViewAnimationCurveEaseOut  animations:^{

        [self makeBackgroundViewTransparent:NO];

    } completion:^(BOOL finished) {
        
    }];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)startLoading
{    
    CampusWallFakeNavigationBar *externalView = (CampusWallFakeNavigationBar *)self.externalView;

    self.isLoading = YES;
    [externalView.loadingView startAnimating];
}

- (void)stopLoading
{
    CampusWallFakeNavigationBar *externalView = (CampusWallFakeNavigationBar *)self.externalView;

    self.isLoading = NO;
    [externalView.loadingView stopAnimating];
}

- (void)setHiddenLoader:(BOOL)hidden
{
    if(hidden && self.isLoading)
    {
        return;
    }
    
    CampusWallFakeNavigationBar *externalView = (CampusWallFakeNavigationBar *)self.externalView;
    externalView.loadingView.hidden = hidden;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
