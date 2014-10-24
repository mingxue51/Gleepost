//
//  GLPProfilePostsEmptyView.m
//  Gleepost
//
//  Created by Silouanos on 24/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPProfilePostsEmptyView.h"

@implementation GLPProfilePostsEmptyView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    CGRectSetY(self, [super yPosition:kViewPositionBottom]);
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
