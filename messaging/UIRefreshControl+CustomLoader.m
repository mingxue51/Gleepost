//
//  UIRefreshControl+CustomLoader.m
//  Gleepost
//
//  Created by Σιλουανός on 3/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "UIRefreshControl+CustomLoader.h"
#import "UIImage+animatedGIF.h"
#import "GLPiOSSupportHelper.h"

@implementation UIRefreshControl (CustomLoader)

- (id)initWithCustomLoader
{
    self = [super init];
    
    if(self)
    {
        [self configureRefreshControl];
    }
    
    return self;
}

- (id)initWithCustomActivityIndicator
{
    self = [super init];
    
    if(self)
    {
        [self configureActivityInidicator];
    }
    
    return self;
}

- (void)configureRefreshControl
{
    CGFloat screenWidth = [GLPiOSSupportHelper screenWidth];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setTintColor:[UIColor clearColor]];
    
    UIImageView *subView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth/2) - 28, 0, 56, 56)];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"loader2" ofType: @"gif"];
    
    NSData *gifData = [NSData dataWithContentsOfFile:filePath];
    
    [subView setImage: [UIImage animatedImageWithAnimatedGIFData:gifData]];
    
    [self addSubview:subView];
    
//    UIImageView *margingImage = [[UIImageView alloc] initWithFrame:CGRectMake(132, 56, 56, 100)];
    UIImageView *margingImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenWidth, 1000)];

    
    [margingImage setBackgroundColor:[UIColor whiteColor]];
    
    [self addSubview:margingImage];
    
    [self sendSubviewToBack:margingImage];
    
    [self insertSubview:margingImage atIndex:0];
    
    [self insertSubview:margingImage atIndex:1];
    
    [self insertSubview:margingImage atIndex:2];
    
    [self bringSubviewToFront:subView];
}

- (void)configureActivityInidicator
{
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setTintColor:[UIColor whiteColor]];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    CGRectSetX(indicator, 150.0);
    CGRectSetY(indicator, 15.0);
    
    [indicator startAnimating];
    
//    [self insertSubview:indicator atIndex:1];
    
    
    UIImageView *margingImage = [[UIImageView alloc] initWithFrame:CGRectMake(132, 0, 56, 100)];
    
    [margingImage setBackgroundColor:[UIColor whiteColor]];
    
    [self addSubview:margingImage];
    
    [self addSubview:indicator];
}



@end
