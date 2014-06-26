//
//  TopTableViewCell.m
//  Gleepost
//
//  Created by Σιλουανός on 25/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  TopTableViewCell is a super-class of all the top view cells in the app.
//  The subclasses are listed below:
//  ProfileTopViewCell
//

#import "TopTableViewCell.h"
#import "GLPSegmentView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <QuartzCore/QuartzCore.h>
#import "ShapeFormatterHelper.h"

@interface TopTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

@property (weak, nonatomic) IBOutlet UILabel *subtitleLbl;

@property (weak, nonatomic) IBOutlet UILabel *smallSubtitleLbl;


@end

@implementation TopTableViewCell

@synthesize mainImageView = _mainImageView;
@synthesize titleLbl = _titleLbl;
@synthesize subtitleLbl = _subtitleLbl;
@synthesize smallSubtitleLbl = _smallSubtitleLbl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

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
    // Initialization code
    [self configureMainImageView];

}

#pragma mark - Modifiers

- (void)setImageWithUrl:(NSString *)url
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

- (void)setDownloadedImage:(UIImage *)image
{
    if(image)
    {
        [_mainImageView setImage:image];
    }
}

- (void)setTitleWithString:(NSString *)title
{
    [_titleLbl setText:title];
}

- (void)setSubtitleWithString:(NSString *)subtitle
{
    [_subtitleLbl setText:subtitle];
}

- (void)setSmallSubtitleWithString:(NSString *)smallSubtitle
{
    [_smallSubtitleLbl setText:smallSubtitle];
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
