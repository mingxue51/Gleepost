//
//  GLPTableActivityIndicator.m
//  Gleepost
//
//  Created by Silouanos on 23/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPTableActivityIndicator.h"

@interface GLPTableActivityIndicator ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) UIView *view;

@end

@implementation GLPTableActivityIndicator

- (id)initWithPosition:(TableActivityIndicatorPosition)position withView:(UIView *)view
{
    self = [super init];
    
    if(self)
    {
        [self configureActivityIndicator];
        [self initialiseViewWithPosition:position];
        [view addSubview:_activityIndicator];
    }
    
    return self;
}

- (void)configureActivityIndicator
{
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    _activityIndicator.transform = transform;
    [_activityIndicator setHidesWhenStopped:YES];
}

-(void)initialiseViewWithPosition:(TableActivityIndicatorPosition)position
{
    float yPosition = 0.0f;
    
    switch (position)
    {
        case kActivityIndicatorCenter:
            yPosition = (_view.frame.size.height + _activityIndicator.frame.size.height) / 2;
            break;
            
        case kActivityIndicatorBottom:
            yPosition = 300.0f;
            break;
            
        default:
            break;
    }
    
    CGRectSetX(_activityIndicator, 141.0 + 5.0);
    
    CGRectSetY(_activityIndicator, yPosition);
    
}

- (void)stopActivityIndicator
{
    [_activityIndicator stopAnimating];
}

- (void)startActivityIndicator
{
    [_activityIndicator startAnimating];
}

@end