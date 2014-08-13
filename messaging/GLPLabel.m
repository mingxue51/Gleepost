//
//  GLPLabel.m
//  Gleepost
//
//  Created by Σιλουανός on 13/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPLabel.h"

@interface GLPLabel ()

@property (strong, nonatomic) UITapGestureRecognizer *labelGesture;

@end

@implementation GLPLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configureLabel];
}

- (void)configureLabel
{
    DDLogDebug(@"configureLabel");
    
    [self setUserInteractionEnabled:YES];
    
    //Add gesture to label.
    _labelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTouched)];
    
    [self addGestureRecognizer:_labelGesture];
}

#pragma mark - Selectors

- (void)labelTouched
{
    if([_delegate respondsToSelector:@selector(labelTouchedWithTag:)])
    {
        [_delegate labelTouchedWithTag:self.tag];
    }
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
