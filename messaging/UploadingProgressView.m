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

@interface UploadingProgressView ()

@property (weak, nonatomic) IBOutlet GLPCustomProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *backProgressImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *uploadingLabel;

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
    
//    [ShapeFormatterHelper setCornerRadiusWithView:_thumbnailImageView andValue:5.0];

//    [ShapeFormatterHelper setCornerRadiusWithView:_thumbnailImageView andValue:2.0];

}

#pragma mark - Modifiers

- (void)resetView
{
    [_uploadingLabel setText:UPLOADING_TEXT.copy];
    [_thumbnailImageView setImage:nil];
    [_progressView setProgress:0.0];
}

- (void)updateProgressWithValue:(float)progress
{
    [_progressView setProgress:progress];
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage
{
    [_thumbnailImageView setImage:thumbnailImage];
    DDLogDebug(@"progress bar : Thumbnail image view: %@", _thumbnailImageView.image);
}

- (void)startProcessing
{
    [_uploadingLabel setText:PROCESSING_TEXT.copy];
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
