//
//  GLPStretchedImageView.h
//  Gleepost
//
//  Created by Σιλουανός on 28/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPImageView.h"

@interface GLPStretchedImageView : GLPImageView <GLPImageViewDelegate>

extern const float kStretchedImageHeight;

- (void)setTextInTitle:(NSString *)text;
- (void)setHeightOfTransImage:(float)height;

@end
