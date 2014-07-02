//
//  GLPRefreshControl.m
//  Gleepost
//
//  Created by Σιλουανός on 2/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPRefreshControl.h"

@implementation GLPRefreshControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor blackColor]];
    }
    return self;
}


- (void)containingScrollViewDidEndDragging:(UIScrollView *)containingScrollView
{
    CGFloat minOffsetToTriggerRefresh = 50.0f;
    if (containingScrollView.contentOffset.y <= -minOffsetToTriggerRefresh) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
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
