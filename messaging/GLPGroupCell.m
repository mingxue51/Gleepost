//
//  GLPGroupCell.m
//  Gleepost
//
//  Created by Silouanos on 23/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPGroupCell.h"
#import "ShapeFormatterHelper.h"
#import "GLPGroup.h"
#import "GLPImageHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "GLPLiveGroupManager.h"

@interface GLPGroupCell ()

@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UIImageView *groupOverlayImageView;
@property (weak, nonatomic) IBOutlet UILabel *membersNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *notificationsView;
@property (weak, nonatomic) IBOutlet UILabel *notificationsLabel;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelHeight;

@property (strong, nonatomic, readonly) NSString *membersString;

@property (strong, nonatomic) GLPGroup *groupData;

@end

@implementation GLPGroupCell

- (void)awakeFromNib
{
    [self configureObjects];
    [self formatElements];
    [self configureCell];
}

#pragma mark - Configuration

- (void)formatElements
{
    [ShapeFormatterHelper setCornerRadiusWithView:_groupImageView andValue:3];
    [ShapeFormatterHelper setCornerRadiusWithView:_groupOverlayImageView andValue:3];
}

- (void)configureObjects
{
    _membersString = @"MEMBERS";
}

- (void)configureCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Modifiers

- (void)setGroupData:(GLPGroup *)groupData
{
    _groupData = groupData;
    [self configureNameText];
    [self setGroupImage];
    [self configureUnreadPostsBadge];
    [_membersNumberLabel setText:[NSString stringWithFormat:@"xxxxx %@", _membersString]];

    //TODO: Probably we should configure kind of a group in terms of privacy (e.g. private etc).
}

- (void)configureNameText
{
    [_groupNameLabel setText:_groupData.name];
    [_nameLabelHeight setConstant:[self getNametLabelHeight]];
}

- (void)setGroupImage
{
    if(_groupData.pendingImage)
    {
        [_groupImageView setImage:_groupData.pendingImage];
    }
    else if([_groupData.groupImageUrl isEqualToString:@""] || !_groupData.groupImageUrl)
    {
        [_groupImageView setImage:[GLPImageHelper placeholderGroupImage]];
    }
    else
    {
        [_groupImageView sd_setImageWithURL:[NSURL URLWithString:_groupData.groupImageUrl] placeholderImage:[GLPImageHelper placeholderGroupImage] options:SDWebImageLowPriority];
    }
}

- (void)configureUnreadPostsBadge
{
    NSInteger count = [[GLPLiveGroupManager sharedInstance] numberOfUnseenPostsWithGroup:_groupData];
    
    if(count != 0)
    {
        [_notificationsView setHidden:NO];
        [_notificationsLabel setText:[NSString stringWithFormat:@"%@", @(count)]];
    }
    else
    {
        [_notificationsView setHidden:YES];
    }
}

- (CGFloat)getNametLabelHeight
{
    if(!_groupData.name)
    {
        return 0.0;
    }
    
    UIFont *font = [UIFont fontWithName:@"Avenir-Medium" size:18.0];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:_groupData.name attributes:@{NSFontAttributeName: font}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){230.0, 50.0}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    CGSize size = rect.size;
    return size.height;
}

#pragma mark - Static

+ (CGFloat)height
{
    return 135;
}

+ (NSString *)cellIdentifier
{
    return @"GLPGroupCell";
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
