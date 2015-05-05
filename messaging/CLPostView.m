//
//  CLPost.m
//  Gleepost
//
//  Created by Silouanos on 05/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "CLPostView.h"
#import "GLPiOSSupportHelper.h"

@implementation CLPostView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        DDLogDebug(@"CLPostView : initWithCoder");
        
        self.frame = CGRectMake(0.0, 0.0, [GLPiOSSupportHelper screenWidth], [GLPiOSSupportHelper screenHeight] - 64 - 49);
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
