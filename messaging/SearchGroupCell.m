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

@interface SearchGroupCell ()

@property (weak, nonatomic) IBOutlet GLPImageView *groupImage;

@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UILabel *groupDescription;

@property (strong, nonatomic) GLPGroup *groupData;

@end


@implementation SearchGroupCell

const float SEARCH_GROUP_CELL_HEIGHT = 70;

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
    

    //TODO: Set placeholder image.
    [_groupImage setImageWithURL:[NSURL URLWithString:groupData.groupImageUrl] placeholderImage:nil options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

@end
