//
//  DescriptionSegmentGroupCell.m
//  Gleepost
//
//  Created by Σιλουανός on 29/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "DescriptionSegmentGroupCell.h"
#import "GLPGroup.h"
#import "UILabel+Dimensions.h"
#import "ShapeFormatterHelper.h"
#import "GLPConversation.h"
#import "GLPLiveGroupConversationsManager.h"
#import "GLPiOSSupportHelper.h"

@interface DescriptionSegmentGroupCell ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLbl;

//@property (weak, nonatomic) IBOutlet GLPThreeSegmentView *segmentView;
@property (weak, nonatomic) IBOutlet GLPSegmentView *segmentView;

@property (weak, nonatomic) IBOutlet UIImageView *notificationImageView;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;

@property (strong, nonatomic) UIFont *font;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelDistanceFromTop;

@end

@implementation DescriptionSegmentGroupCell

const float GROUP_DESCR_VIEW_HEIGHT = 84;

- (void)awakeFromNib
{
    // Initialization code
    [self configureFont];
    [self configureSegmentView];
    [self configureElements];
}

#pragma mark - Modifiers

- (void)setGroupData:(GLPGroup *)group
{
    [_descriptionLbl setText:group.groupDescription];
    
    [_labelHeight setConstant:[DescriptionSegmentGroupCell labelHeightWithDescription:group.groupDescription]];
        
    if([group.groupDescription isEqualToString:@""] || !group.groupDescription)
    {
        [_labelDistanceFromTop setConstant:-1];
    }
    
    GLPConversation *conversation = [[GLPLiveGroupConversationsManager sharedInstance] findByRemoteKey:group.conversationRemoteKey];
    [self setNumberOfNotifications:conversation.unreadMessagesCount];
    
    
    UIView *cellScrollView = self.superview;
    [cellScrollView.layer setMasksToBounds:NO];
    
    for(UIView *v in self.subviews)
    {
        UIView *superV = v.superview;
        
        [superV.layer setMasksToBounds:NO];
    }
    
    
//    [_descriptionLbl setHeightDependingOnText:group.groupDescription withFont:_font];
    
//    [ShapeFormatterHelper setBorderToView:_descriptionLbl withColour:[UIColor redColor] andWidth:1.0f];
    
}

#pragma mark - GLPSegmentViewDelegate

- (void)segmentSwitched:(ButtonType)conversationsType
{
    if(conversationsType == kButtonRight)
    {
        [self setNumberOfNotifications:0];
    }
    
    [_delegate segmentSwitchedWithButtonType:conversationsType];
}

#pragma mark - Configuration

- (void)configureSegmentView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPProfileSegmentView" owner:self options:nil];
    
    GLPSegmentView *view = [array lastObject];
    view.tag = 100;
    [view setDelegate:self];
    [view setRightButtonTitle:@"Messenger" andLeftButtonTitle:@"Newsfeed"];
    [view setSlideAnimationEnabled:NO];
    
    [_segmentView addSubview:view];
}

- (void)configureFont
{
    _font = _descriptionLbl.font;
}

- (void)layoutSubviews
{
    for(UIView *v in _segmentView.subviews)
    {
        if(v.tag == 100)
        {
            [(GLPSegmentView *)v selectLeftButton];
        }
    }
}

- (void)configureElements
{
    [self setHiddenNotificationsElements:NO];
    [self configureBadge];
}

- (void)configureBadge
{
    [ShapeFormatterHelper setRoundedView:_notificationImageView toDiameter:_notificationImageView.frame.size.height];
}

#pragma mark - Notifications Count Elements

- (void)setNumberOfNotifications:(NSInteger)notificationsCount
{
    if(notificationsCount == 0)
    {
        [self setHiddenNotificationsElements:YES];
        [_notificationLabel setText:[NSString stringWithFormat:@"%ld", (long)notificationsCount]];
    }
    else
    {
        [self setHiddenNotificationsElements:NO];
        [_notificationLabel setText:[NSString stringWithFormat:@"%ld", (long)notificationsCount]];
    }
}

- (void)setHiddenNotificationsElements:(BOOL)hidden
{
    [_notificationImageView setHidden:hidden];
    [_notificationLabel setHidden:hidden];
}

#pragma mark - Static

+ (float)getCellHeightWithGroup:(GLPGroup *)group
{
    CGFloat lblHeight = [self labelHeightWithDescription:group.groupDescription];
    
    if(lblHeight == 1.0)
    {
        return GROUP_DESCR_VIEW_HEIGHT - 10;
    }
    
    return lblHeight + GROUP_DESCR_VIEW_HEIGHT;
    
}

+ (CGFloat)labelWidth
{
    return [GLPiOSSupportHelper screenWidth] - (15 * 2);
}

+ (CGFloat)labelHeightWithDescription:(NSString *)description
{
    return [UILabel getContentLabelSizeForContent:description withFont:[UIFont fontWithName:GLP_HELV_NEUE_LIGHT size:15.0] andWidht:[self labelWidth]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
