//
//  PostsProfileView.m
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "PostsProfileView.h"
#import "ProfileTabViewConstants.h"


@implementation PostsProfileView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        //TODO: Change the size of the view dynamically depending on screen's size.
        self.frame = CGRectMake(0, 0, FRAME_WIDTH, FRAME_HEIGHT);
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
