//
//  GroupTopViewCell.m
//  Gleepost
//
//  Created by Σιλουανός on 30/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This view is deprecated because we are using a regular view as header in GrouViewController rather than
//  a cell. For more see at GroupTopView class.

#import "GroupTopViewCell.h"
#import "GLPGroup.h"

@interface GroupTopViewCell ()

@property (strong, nonatomic) GLPGroup *group;

@property (weak, nonatomic) IBOutlet GLPThreeSegmentView *segmentView;

@property (strong, nonatomic) GLPThreeSegmentView *segmentViewReference;

@end

@implementation GroupTopViewCell

const float GROUP_TOP_VIEW_HEIGHT = 302.0;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [super setSubClassdelegate:self];
    
    [self configureSegmentView];
}

- (void)layoutSubviews
{
//    [super layoutSubviews];
    
    
//    [_segmentViewReference selectLeftButton];
    
    for(UIView *v in _segmentView.subviews)
    {
        if(v.tag == 100)
        {
            [(GLPThreeSegmentView *)v selectLeftButton];
        }
    }
    
}

- (void)configureSegmentView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPGroupSegmentView" owner:self options:nil];
    
    GLPThreeSegmentView *view = [array lastObject];
    view.tag = 100;
    [view setDelegate:self];
    [view setRightButtonTitle:@"Members" andLeftButtonTitle:@"Posts"];
    [view setSlideAnimationEnabled:NO];
//    _segmentViewReference = view;
    
    [_segmentView addSubview:view];
}

- (void)setGroupData:(GLPGroup *)group
{
    _group = group;
    
    [super setImageWithUrl:_group.groupImageUrl];
    
    [super setSmallSubtitleWithString:_group.groupDescription];
}

- (void)setDownloadedImage:(UIImage *)image
{
    [super setDownloadedImage:image];
}

#pragma mark - TopTableViewCellDelegate

- (void)mainImageViewTouched
{
    [_delegate showGroupImageOptionsWithImage:[super mainImageViewImage]];
}

#pragma mark - GLPSegmentViewDelegate

- (void)segmentSwitched:(ButtonType)conversationsType
{
    [_delegate segmentSwitchedWithButtonType:conversationsType];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
