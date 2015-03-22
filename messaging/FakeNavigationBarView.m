//
//  FakeNavigationBarView.m
//  Gleepost
//
//  Created by Σιλουανός on 4/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This is a fake navigation bar and for now is used only in GroupViewController.
//  It's created to avoid the so-called "black issue" during the navigation between
//  GroupViewController and GLPGroupsViewController.

#import "FakeNavigationBarView.h"
#import "ShapeFormatterHelper.h"
#import "GLPThemeManager.h"
#import "GLPiOSSupportHelper.h"

@interface FakeNavigationBarView ()

@property (strong, nonatomic) NSString *title;

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

@property (assign, nonatomic) float animationDuration;

@end

@implementation FakeNavigationBarView


- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    
    if(self)
    {
        _title = title;
        
        [self initiliaseObjects];
        
        [self configureView];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self formatNavigationBar];
}

- (void)formatNavigationBar
{
    [self.titleLbl setTextColor: [[GLPThemeManager sharedInstance] navigationBarTitleColour]];
    [self setBackgroundColor:[[GLPThemeManager sharedInstance] navigationBarColour]];
}

- (void)initiliaseObjects
{
    _animationDuration = 0.3 ;
}

- (void)configureView
{
    FakeNavigationBarView *view = [[[NSBundle mainBundle] loadNibNamed:@"FakeNavigationBarView" owner:self options:nil] objectAtIndex:0];
    CGRectSetW(view, [GLPiOSSupportHelper screenWidth]);
    [self setFrame:view.frame];
    [view setTitle:[_title uppercaseString]];
    [self addSubview:view];
}

- (void)setTitle:(NSString *)title
{
    [_titleLbl setText:title];
}

- (void)hideNavigationBar
{
    
    [UIView animateWithDuration:_animationDuration delay:0.0 options:UIViewAnimationCurveEaseOut | UIViewAnimationCurveEaseOut  animations:^{
        
        [self setAlpha:0.0];

        
    } completion:^(BOOL finished) {
        
        [self setHidden:YES];

    }];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}

- (void)showNavigationBar
{
    [self setAlpha:0.0];
    [self setHidden:NO];
    [UIView animateWithDuration:_animationDuration delay:0.0 options:UIViewAnimationCurveEaseOut | UIViewAnimationCurveEaseOut  animations:^{
        
        [self setAlpha:1.0];
        
    } completion:^(BOOL finished) {
        
//        [self setHidden:NO];

    }];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

}

- (void)setTitleToBar:(NSString *)title
{
    _title = title;
    [self configureView];
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
