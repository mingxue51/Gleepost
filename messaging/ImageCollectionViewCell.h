//
//  ImageCollectionViewCell.h
//  Gleepost
//
//  Created by Σιλουανός on 17/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGSize IMAGE_COLLECTION_CELL_DIMENSIONS;
extern const CGFloat IMAGE_COLLECTION_CELL_MARGIN;

@interface ImageCollectionViewCell : UICollectionViewCell

- (void)setImageViewImage:(UIImage *)image;

@end
