//
//  GLPLoadingButton.m
//  Gleepost
//
//  Created by Silouanos on 03/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  This UIButton subclass will add a functionality to a button to include activity indicator while something is loading
//  after user hits the button.

#import "GLPLoadingButton.h"

@interface GLPLoadingButton ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (assign, nonatomic, readonly) CGFloat margin;

@end

@implementation GLPLoadingButton


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        [self initialiseObjects];
        [self configureElements];
        
    }
    return self;
}

- (void)initialiseObjects
{
    _margin = 15.0;
}

- (void)configureElements
{
    [self configureActivityIndicator];
    [self addIndicatorToButton];
}

- (void)configureActivityIndicator
{
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_activityIndicator setHidesWhenStopped:YES];
    [_activityIndicator setHidden:YES];
}

- (void)addIndicatorToButton
{
    [self addSubview:_activityIndicator];
    
    CGRect buttonFrame = self.frame;
    CGRectSetX(_activityIndicator, buttonFrame.size.width - (_activityIndicator.frame.size.width) - _margin);
    CGRectSetY(_activityIndicator, (buttonFrame.size.height/2) - (_activityIndicator.frame.size.height/2));
}

#pragma mark - Accessors

- (void)startLoading
{
    [self setEnabled:NO];
    [_activityIndicator setHidden:NO];
    [_activityIndicator startAnimating];
}

- (void)stopLoading
{
    [self setEnabled:YES];
    [_activityIndicator stopAnimating];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end