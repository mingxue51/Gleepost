//
//  TypeTextView.m
//  Gleepost
//
//  Created by Σιλουανός on 3/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "TypeTextView.h"

@implementation TypeTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.2]];
        
        self.footerTextView = [[GCPlaceholderTextView alloc] initWithFrame:CGRectMake(10, 10, 240, 30)];
        self.footerTextView.placeholder = @"Add comment...";
        self.footerTextView.textColor = [UIColor blackColor];
        
        self.footerTextView.layer.cornerRadius = 5;
        self.footerTextView.clipsToBounds = YES;
        
        
        //Add post button.
        //buttonWithType:UIButtonTypeRoundedRect];
        self.postButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.postButton setFrame:CGRectMake(200.0, 10.0f, 160.0, 25.0)];
        [self.postButton setTitle:@"Post" forState:UIControlStateNormal];
        
        [self addSubview:self.footerTextView];
        [self addSubview:self.postButton];
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
