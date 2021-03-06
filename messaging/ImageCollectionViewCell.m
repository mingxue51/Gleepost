//
//  ImageCollectionViewCell.m
//  Gleepost
//
//  Created by Σιλουανός on 17/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "ImageCollectionViewCell.h"
#import "GLPiOSSupportHelper.h"

@interface ImageCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end


@implementation ImageCollectionViewCell

const CGFloat IMAGE_COLLECTION_CELL_MARGIN = 5.0;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setImageViewImage:(UIImage *)image
{
    [_imageView setImage:image];
}

+ (CGSize)imageCollectionCellDimensions
{
    CGFloat size = ([GLPiOSSupportHelper screenWidth] - 20) / 3;
    return CGSizeMake(size, size);
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
