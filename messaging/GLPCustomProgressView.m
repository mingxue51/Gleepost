//
//  GLPCustomProgressView.m
//  Gleepost
//
//  Created by Σιλουανός on 22/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCustomProgressView.h"

@implementation GLPCustomProgressView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setTransform:CGAffineTransformMakeScale(1.0, 3.0)];

    }
    return self;
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
