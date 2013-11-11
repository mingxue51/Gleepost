//
//  ChatPanelView.m
//  Gleepost
//
//  Created by Σιλουανός on 4/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ChatPanelView.h"

@implementation ChatPanelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        
        //Create and add comment button.
        self.commentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.commentButton setFrame:CGRectMake(260.0, 5.0f, 50.0, 30.0)];
        [self.commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.commentButton setTitle:@"Comment" forState:UIControlStateNormal];
        
        [self addSubview:self.commentButton];
        
        //Create and add camera button.
        self.cameraButton = [[UIButton alloc] init];
        [self.cameraButton setBackgroundImage:[UIImage imageNamed:@"camera_icon"] forState:UIControlStateNormal];
        [self.cameraButton setFrame:CGRectMake(10.0f, 10.0f, [UIImage imageNamed:@"camera_icon"].size.width, [UIImage imageNamed:@"camera_icon"].size.height)];
        
        //[self addSubview:self.cameraButton];
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
