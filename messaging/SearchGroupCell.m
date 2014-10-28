//
//  GroupCell.m
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "SearchGroupCell.h"
#import "ShapeFormatterHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "WebClient.h"
#import "GLPImageView.h"
#import "UILabel+Dimensions.h"
#import "GLPImageHelper.h"

@interface SearchGroupCell ()

@property (weak, nonatomic) IBOutlet GLPImageView *groupImage;

@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UILabel *groupDescription;

@property (strong, nonatomic) GLPGroup *groupData;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeight;

@end


@implementation SearchGroupCell

const float SEARCH_GROUP_CELL_HEIGHT = 40;
const float TITLE_WIDTH = 237;

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [ShapeFormatterHelper setRoundedView:_groupImage toDiameter:_groupImage.frame.size.height];
}

-(void)setGroupData:(GLPGroup *)groupData
{
    _groupData = groupData;
    
    //Add user's profile image.
    [_groupName setText:groupData.name];
    
    _groupName.tag = groupData.remoteKey;
    
    [_groupDescription setText: groupData.groupDescription];
    
    [_titleLabelHeight setConstant: [UILabel getContentLabelSizeForContent:_groupData.name withFont:[UIFont fontWithName:GLP_HELV_NEUE_MEDIUM size:17.0] andWidht:TITLE_WIDTH]];

    [_groupImage sd_setImageWithURL:[NSURL URLWithString:groupData.groupImageUrl] placeholderImage:[GLPImageHelper placeholderGroupImage] options:SDWebImageRetryFailed];
}

- (UIImage *)groupImage
{
    return _groupImage.image;
}

#pragma mark - Static

+ (float)getCellHeightWithGroup:(GLPGroup *)group
{
    float lblHeight = [UILabel getContentLabelSizeForContent:group.name withFont:[UIFont fontWithName:GLP_HELV_NEUE_MEDIUM size:17.0] andWidht:TITLE_WIDTH];
    
    
    if(lblHeight == 1.0)
    {
        return SEARCH_GROUP_CELL_HEIGHT - 10;
    }
    
    DDLogDebug(@"%f", lblHeight + SEARCH_GROUP_CELL_HEIGHT);
    
    return lblHeight + SEARCH_GROUP_CELL_HEIGHT;
    
}

@end
