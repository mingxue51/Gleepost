//
//  GLPEmptyView.m
//  Gleepost
//
//  Created by Silouanos on 24/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  Super class of Empty Views.

#import "GLPEmptyView.h"


@implementation GLPEmptyView

- (void)hideView
{
    [self setHidden:YES];
    [self removeFromSuperview];
}

- (float)yPosition:(GLPViewPosition)viewPosition
{
    float yPosition = 0.0f;
    
    switch (viewPosition)
    {
        case kViewPositionTop:
            yPosition = 88.0;
            break;
            
        case kViewPositionCenter:
            yPosition = [self positionForCenter];
            break;
        case kViewPositionBottom:
            yPosition = [self positionForBottom];
            break;
            
        case kViewPositionFurtherBottom:
            yPosition = [self positionForFurtherBottom];
            break;
            
        default:
            break;
    }
    
    return yPosition;
}

-(float)positionForCenter
{
    return (IS_IPHONE_5) ? 200.0f : 180.0f;
}

-(float)positionForBottom
{
    return (IS_IPHONE_5) ? 235.0f : 215.0f;
}

-(float)positionForFurtherBottom
{
    return (IS_IPHONE_5) ? 400.0f : 350.0f;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
