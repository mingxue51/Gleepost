//
//  GLPThreeSegmentView.m
//  Gleepost
//
//  Created by Σιλουανός on 25/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPThreeSegmentView.h"
#import "AppearanceHelper.h"

@interface GLPThreeSegmentView ()

@property (weak, nonatomic) IBOutlet UILabel *middleLbl;

@end

@implementation GLPThreeSegmentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setSlideAnimationEnabled:NO];
    
    [self configureMiddleLabel];
    
    [self configureGestures];
}

- (void)configureMiddleLabel
{
    [_middleLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0]];
    [_middleLbl setTextColor:[AppearanceHelper colourForUnselectedSegment]];
}

- (void)configureGestures
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(middleBtnPressed)];
    [tap setNumberOfTapsRequired:1];
    [_middleLbl addGestureRecognizer:tap];
}

- (void)middleBtnPressed
{
    [self.delegate segmentSwitched:kButtonMiddle];
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
