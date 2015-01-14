//
//  TopTableViewCell.m
//  Gleepost
//
//  Created by Σιλουανός on 25/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  TopTableViewCell is a super-class of all the top view cells in the app.
//  The subclasses are listed below:
//  ProfileTopViewCell, PrivateProfileTopViewCell
//

#import "TopTableViewCell.h"
#import "GLPSegmentView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <QuartzCore/QuartzCore.h>
#import "ShapeFormatterHelper.h"
#import "GLPImageHelper.h"

@interface TopTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

@property (weak, nonatomic) IBOutlet UILabel *subtitleLbl;

@property (weak, nonatomic) IBOutlet UILabel *smallSubtitleLbl;

@property (weak, nonatomic) IBOutlet UILabel *postsLbl;

@property (weak, nonatomic) IBOutlet UILabel *membershipsLbl;

@property (weak, nonatomic) IBOutlet UILabel *rsvpsLbl;

@end

@implementation TopTableViewCell

@synthesize mainImageView = _mainImageView;
@synthesize titleLbl = _titleLbl;
@synthesize subtitleLbl = _subtitleLbl;
@synthesize smallSubtitleLbl = _smallSubtitleLbl;

- (void)awakeFromNib
{
    // Initialization code
    [self configureMainImageView];
    
    [self configureGesturesForViews];
}

#pragma mark - Accessors

- (UIImage *)mainImageViewImage
{
    return _mainImageView.image;
}


#pragma mark - Modifiers

- (void)setImageWithUrl:(NSString *)url
{    
    if([url isEqualToString:@""])
    {
        //Set default image.
        [_mainImageView setImage:[GLPImageHelper placeholderUserImage]];
    }
    else
    {
        //Fetch the image from the server and add it to the image view.
        [_mainImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[GLPImageHelper placeholderUserImage]];
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

- (void)setNumberOfPosts:(NSInteger)number
{
    [_postsLbl setText:[NSString stringWithFormat:@"%ld", (long)number]];
}

- (void)setNumberOfMemberships:(NSInteger)number
{
    [_membershipsLbl setText:[NSString stringWithFormat:@"%ld", (long)number]];
}

- (void)setNumberOfRsvps:(NSInteger)number
{
    [_rsvpsLbl setText:[NSString stringWithFormat:@"%ld", (long)number]];
}

#pragma mark - Configuration

- (void)configureMainImageView
{
    if(_mainImageView.tag == 0)
    {
        [ShapeFormatterHelper setRoundedView:_mainImageView toDiameter:_mainImageView.frame.size.height];
    }
//    else
//    {
//        [ShapeFormatterHelper setRoundedView:_mainImageView toDiameter:0];
//    }
    
    
}

- (void)configureGesturesForViews
{
    [self addGestureToMainImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postsLabelTouched:)];

    [_postsLbl addGestureRecognizer:tap];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(membershipsLabelTouched:)];
    
    [_membershipsLbl addGestureRecognizer:tap];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rsvpsLabelTouched:)];
    
    [_rsvpsLbl addGestureRecognizer:tap];
}


- (void)addGestureToMainImageView
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainImageViewTouched:)];
    [tap setNumberOfTapsRequired:1];
    [_mainImageView addGestureRecognizer:tap];
}

#pragma mark - Receivers

- (void)mainImageViewTouched:(id)sender
{
    [_subClassdelegate mainImageViewTouched];
}

- (void)postsLabelTouched:(id)sender
{
    [_subClassdelegate numberOfPostTouched];
}

- (void)membershipsLabelTouched:(id)sender
{
    [_subClassdelegate numberOfGroupsTouched];
}

- (void)rsvpsLabelTouched:(id)sender
{
    [_subClassdelegate numberOfRsvpsTouched];
}

- (IBAction)bagdeButtonTouched:(id)sender
{
    [_subClassdelegate badgeTouched];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
