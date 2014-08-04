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

@interface FakeNavigationBarView ()

@property (strong, nonatomic) NSString *title;

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

@end

@implementation FakeNavigationBarView

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    
    if(self)
    {
        _title = title;
        

        [self configureView];
    }
    
    return self;
}

- (void)awakeFromNib
{
}

- (void)configureView
{
    FakeNavigationBarView *view = [[[NSBundle mainBundle] loadNibNamed:@"FakeNavigationBarView" owner:self options:nil] objectAtIndex:0];
    
    [self setFrame:view.frame];
    
//    [ShapeFormatterHelper setBorderToView:self withColour:[UIColor redColor] andWidth:1.0];
    
    CGRectSetY(self, -84);
    
    [view setTitle:[_title uppercaseString]];

    
//    [self setHidden:NO];
    
    [self addSubview:view];
}

- (void)setTitle:(NSString *)title
{
    [_titleLbl setText:title];
}

- (void)hideNavigationBar
{
    [self setHidden:YES];
}

- (void)showNavigationBar
{
    [self setHidden:NO];
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
