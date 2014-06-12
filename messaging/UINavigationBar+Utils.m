//
//  UINavigationBar+Utils.m
//  Gleepost
//
//  Created by Σιλουανός on 12/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "UINavigationBar+Utils.h"
#import "ShapeFormatterHelper.h"

@implementation UINavigationBar (Utils)

- (void)setButtonOnLeft:(BOOL)left withImageName:(NSString *)image withSelector:(SEL)selector andTarget:(UIViewController *)navController
{
    UIImage *img = [UIImage imageNamed:image];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn addTarget:navController action:selector forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:img forState:UIControlStateNormal];
    [leftBtn setFrame:CGRectMake(0, 10, 19, 19)];
    [ShapeFormatterHelper setBorderToView:leftBtn withColour:[UIColor blackColor] andWidth:1.0f];
    
    
    
    UIView *leftButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 38)];
    [ShapeFormatterHelper setBorderToView:leftButtonView withColour:[UIColor redColor] andWidth:1.0f];
    
    leftButtonView.bounds = CGRectOffset(leftButtonView.bounds, 5, 0);
    [leftButtonView addSubview:leftBtn];
    
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButtonView];
    
    UINavigationItem *nav = [self.items lastObject];
    
    if(left)
    {
        nav.leftBarButtonItem = leftBarButton;
    }
    else
    {
        nav.rightBarButtonItem = leftBarButton;
    }
    
    
    [self setItems:@[nav]];
}

@end
