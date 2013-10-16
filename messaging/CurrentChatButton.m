//
//  CurrentChatView.m
//  Gleepost
//
//  Created by Σιλουανός on 15/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "CurrentChatButton.h"

@implementation CurrentChatButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self setBackgroundImage:[UIImage imageNamed:@"multiplechatimg"] forState:UIControlStateNormal];
        
//        [self addTarget:self action:@selector(myAction:forEvent:) forControlEvents:UIControlEvent]
        
    }
    return self;
}


- (IBAction)myAction:(UIButton *)sender forEvent:(UIEvent *)event {
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
