//
//  CLPostTimeLocationView.m
//  Gleepost
//
//  Created by Silouanos on 06/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Location time view (the one with the black transparent background) on the post image view (or cell).
//  We are using a custom class to resize the view depending on the Location and time number of characters.

#import "CLPostTimeLocationView.h"
#import "GLPiOSSupportHelper.h"

@interface CLPostTimeLocationView ()

@property (assign, nonatomic) CGFloat maxWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@end

@implementation CLPostTimeLocationView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configureMaxWidth];
    
}

- (void)configureMaxWidth
{
    self.maxWidth = [GLPiOSSupportHelper screenWidth] - 15.0 * 2;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
