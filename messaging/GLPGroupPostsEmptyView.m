//
//  GLPGroupPostsEmptyView.m
//  Gleepost
//
//  Created by Silouanos on 24/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPGroupPostsEmptyView.h"

@implementation GLPGroupPostsEmptyView

- (void)awakeFromNib
{
    [super awakeFromNib];
        
    CGRectSetY(self, [super yPosition:kViewPositionTop]);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
