//
//  UIRefreshControl+CustomLoader.m
//  Gleepost
//
//  Created by Σιλουανός on 3/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "UIRefreshControl+CustomLoader.h"
#import "UIImage+animatedGIF.h"

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
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setTintColor:[UIColor clearColor]];
    
    UIImageView *subView = [[UIImageView alloc] initWithFrame:CGRectMake(132, 0, 56, 56)];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"loader2" ofType: @"gif"];
    
    NSData *gifData = [NSData dataWithContentsOfFile:filePath];
    
    [subView setImage: [UIImage animatedImageWithAnimatedGIFData:gifData]];
    
    [self insertSubview:subView atIndex:1];
}

- (void)configureActivityInidicator
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    CGRectSetX(indicator, 145.0);
    CGRectSetY(indicator, 15.0);
    
    [indicator startAnimating];
    
    [self insertSubview:indicator atIndex:1];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setTintColor:[UIColor whiteColor]];
}



@end
