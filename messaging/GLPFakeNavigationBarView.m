//
//  GLPFakeNavigationBar.m
//  Gleepost
//
//  Created by Silouanos on 06/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Super-class of the fake navigation bars views.

#import "GLPFakeNavigationBarView.h"
#import "GLPThemeManager.h"
#import "GLPiOSSupportHelper.h"

@implementation GLPFakeNavigationBarView

- (instancetype)initWithNibName:(NSString *)nibName
{
    self = [super init];
    if (self)
    {
        [self configureViewWithNibName:nibName];
    }
    return self;
}

- (void)configureViewWithNibName:(NSString *)nibName
{
    self.externalView = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] objectAtIndex:0];
    CGRectSetW(self.externalView, [GLPiOSSupportHelper screenWidth]);
    [self setFrame:self.externalView.frame];
    [self addSubview:self.externalView];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self formatNavigationBar];
}

- (void)formatNavigationBar
{
    [self setBackgroundColor:[[GLPThemeManager sharedInstance] navigationBarColour]];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
