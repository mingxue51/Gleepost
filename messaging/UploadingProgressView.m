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
        [self configureViews];
    }
    
    return self;
}

- (void)configureViews
{
    [ShapeFormatterHelper setBorderToView:_thumbnailImageView withColour:[AppearanceHelper mediumGrayGleepostColour] andWidth:1.0];
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
