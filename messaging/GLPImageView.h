//
//  GLPImageView.h
//  Gleepost
//
//  Created by Σιλουανός on 28/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GLPImageViewDelegate <NSObject>

@optional
- (void)imageTouchedWithImageView:(UIImageView *)imageView;

@end

@interface GLPImageView : UIImageView

@property (assign, nonatomic) UIViewController<GLPImageViewDelegate> *delegate;

- (void)setImageUrl:(NSString *)imageUrl;
- (void)setGesture:(BOOL)gesture;

@end
