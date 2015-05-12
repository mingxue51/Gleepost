//
//  FakeNavigationBarView.m
//  Gleepost
//
//  Created by Σιλουανός on 4/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This is a fake navigation bar and for now is used only in GroupViewController.
//  It's created to avoid the so-called "black issue" during the navigation, for instance, between
//  GroupViewController and GLPGroupsViewController.
//  This navigation bar could be used to any view controller needs more customisation
//  on navigation bar's titles or any other kind of customisation.

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
    self = [super initWithNibName:@"FakeNavigationBarView"];
    
    if(self)
    {
        _title = title;
        [self initiliaseObjects];
        [self configureTitle];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)configureTitle
{
    [(FakeNavigationBarView *)self.externalView setTitle:[_title uppercaseString]];
}

- (void)formatNavigationBar
{
    [super formatNavigationBar];
    
    [self.titleLbl setTextColor: [[GLPThemeManager sharedInstance] navigationBarTitleColour]];
}

- (void)initiliaseObjects
{
    _animationDuration = 0.3 ;
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
