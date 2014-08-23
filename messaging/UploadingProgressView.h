//
//  ProgressView.h
//  Gleepost
//
//  Created by Σιλουανός on 22/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadingProgressView : UIView

- (void)resetView;
- (void)updateProgressWithValue:(float)progress;
- (void)setThumbnailImage:(UIImage *)thumbnailImage;
- (void)startProcessing;

@end
