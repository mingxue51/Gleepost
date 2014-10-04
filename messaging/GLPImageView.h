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

@property (weak, nonatomic) UIViewController<GLPImageViewDelegate> *viewControllerDelegate;
//@property (weak, nonatomic) UIView<GLPImageViewDelegate> *normalViewDelegate;

- (void)setImageUrl:(NSString *)imageUrl withPlaceholderImage:(NSString *)imagePath;
- (void)setActualImage:(UIImage *)image;
- (void)setGesture:(BOOL)gesture;

@end
