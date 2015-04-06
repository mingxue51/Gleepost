//
//  FakeNavigationBarNewPostView.m
//  Gleepost
//
//  Created by Silouanos on 06/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "FakeNavigationBarNewPostView.h"

@implementation FakeNavigationBarNewPostView


- (instancetype)init
{
    self = [super initWithNibName:@"FakeNavigationBarNewPostView"];
    
    if (self)
    {
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
}

- (void)formatNavigationBar
{
    DDLogDebug(@"FakeNavigationBarNewPostView : formatNavigationBar");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
