//
//  GLPCampusWallTopView.m
//  Gleepost
//
//  Created by Silouanos on 01/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPCampusWallTopView.h"

@interface GLPCampusWallTopView ()


@end

@implementation GLPCampusWallTopView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
        DDLogDebug(@"GLPCampusWallTopView : initialisation");
        
//        CGRectSetH(self, 300.0);
    }
    return self;
}


#pragma mark - Selectors

- (IBAction)navigateToCampusLive:(id)sender
{
    DDLogDebug(@"GLPCampusWallTopView : navigateToCampusLive");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
