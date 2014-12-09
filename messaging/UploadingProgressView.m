//
//  ProgressView.m
//  Gleepost
//
//  Created by Σιλουανός on 22/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "UploadingProgressView.h"
#import "ShapeFormatterHelper.h"
#import "GLPCustomProgressView.h"
#import "AppearanceHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "GLPiOSSupportHelper.h"

@interface UploadingProgressView ()

@property (weak, nonatomic) IBOutlet GLPCustomProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *backProgressImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *uploadingLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewDistanceFromTop;

@end


@implementation UploadingProgressView

const NSString *UPLOADING_TEXT = @"UPLOADING...";
const NSString *PROCESSING_TEXT = @"FINISHING UP...";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self resetView];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configureViews];

}

- (void)configureViews
{
//    [ShapeFormatterHelper setBorderToView:_thumbnailImageView withColour:[AppearanceHelper mediumGrayGleepostColour] andWidth:2.0];
    
    _thumbnailImageView.layer.borderWidth = 1.0;
    _thumbnailImageView.layer.cornerRadius = 2.0;
    _thumbnailImageView.layer.borderColor = [[AppearanceHelper mediumGrayGleepostColour] CGColor];
    _thumbnailImageView.layer.masksToBounds = YES;
    
    //Fixing an issue caused between iOS7 and iOS8 with positioning with progress view. (don't know why)
    if(![GLPiOSSupportHelper isIOS7] && ![GLPiOSSupportHelper isIOS6])
    {
        [_progressViewDistanceFromTop setConstant:6.0];
    }
    
//    [ShapeFormatterHelper setCornerRadiusWithView:_thumbnailImageView andValue:5.0];

//    [ShapeFormatterHelper setCornerRadiusWithView:_thumbnailImageView andValue:2.0];

}

#pragma mark - Modifiers

- (void)resetView
{
    DDLogDebug(@"UploadingProgressView Reset view.");
    
    [_uploadingLabel setText:UPLOADING_TEXT.copy];
    [_thumbnailImageView setImage:nil];
    [_progressView setProgress:0.0];
    
    //Fixing an issue caused between iOS7 and iOS8 with positioning with progress view. (don't know why)
    if(![GLPiOSSupportHelper isIOS7] && ![GLPiOSSupportHelper isIOS6])
    {
        [_progressViewDistanceFromTop setConstant:6.0];
    }
//    [_progressView setBackgroundColor:[UIColor clearColor]];
}

- (void)updateProgressWithValue:(float)progress
{
    [_progressView setProgress:progress];
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage
{
    [_thumbnailImageView setImage:thumbnailImage];
}

- (void)startProcessing
{
    [_uploadingLabel setText:PROCESSING_TEXT.copy];
    [_progressView setProgress:1.0f];
}

- (void)setTransparencyToView:(BOOL)transparency
{
    if(transparency)
    {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    else
    {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
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
