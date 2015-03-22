//
//  GLPMessageDetailsSegmentCell.m
//  Gleepost
//
//  Created by Silouanos on 18/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPMessageDetailsSegmentCell.h"
#import "GLPSegmentView.h"
#import "GLPiOSSupportHelper.h"

@interface GLPMessageDetailsSegmentCell () <GLPSegmentViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *segmentView;

@end

CGFloat bottomPadding = 10.0;

@implementation GLPMessageDetailsSegmentCell

- (void)awakeFromNib
{
    [self configureSegmentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Configuration

- (void)configureSegmentView
{
    [self loadSegmentView];
}

- (void)loadSegmentView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPProfileSegmentView" owner:self options:nil];
    
    GLPSegmentView *view = [array lastObject];
    [view setDelegate:self];
    [view setRightButtonTitle:@"Delivered" andLeftButtonTitle:@"Read"];
    
    [_segmentView addSubview:view];
}

#pragma mark - GLPSegmentViewDelegate

- (void)segmentSwitched:(ButtonType)conversationsType
{
    [_delegate segmentSwitchedWithButtonType:conversationsType];
}

#pragma mark - Static

+ (CGFloat)height
{
    //44 for 320
    
    DDLogDebug(@"GLPMessageDetailsSegmentCell : segment height %f", [GLPSegmentView segmentHeight]);
    
    return [GLPSegmentView segmentHeight] + bottomPadding;
//    return 51.0;
}

@end
