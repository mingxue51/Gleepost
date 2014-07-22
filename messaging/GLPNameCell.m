//
//  GLPNameCell.m
//  Gleepost
//
//  Created by Σιλουανός on 2/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPNameCell.h"
#import "GLPUser.h"
#import "ShapeFormatterHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface GLPNameCell ()

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) GLPUser *user;

@end

@implementation GLPNameCell

const float NAME_CELL_HEIGHT = 50;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configureMainImageView];
    
}

#pragma mark - Modifiers

- (void)setUserData:(GLPUser *)user
{
    _user = user;
    
    [self setImageUrl:_user.profileImageUrl];
    
    [_nameLabel setText:user.name];
}

- (void)setImageUrl:(NSString *)url
{
    if([url isEqualToString:@""])
    {
        //Set default image.
        [_mainImageView setImage:[UIImage imageNamed:@"default_user_image2"]];
    }
    else
    {
        
        //Fetch the image from the server and add it to the image view.
        [_mainImageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
}

#pragma mark - Accessors

- (GLPUser *)user
{
    return _user;
}

#pragma mark - Configuration

- (void)configureMainImageView
{
    [ShapeFormatterHelper setRoundedView:_mainImageView toDiameter:_mainImageView.frame.size.height];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end