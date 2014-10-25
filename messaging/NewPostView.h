//
//  NewPostView.h
//  Gleepost
//
//  Created by Σιλουανός on 1/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDTakeController.h"

@interface NewPostView : UIView <UITextViewDelegate, FDTakeDelegate>

@property (strong, nonatomic) UITextView *commentTextView;
@property (strong, nonatomic) UIButton *imageHolderButton;
@property (strong, nonatomic) UIImageView *keyboardBackground;
@property (strong, nonatomic) FDTakeController *fdTakeController;
@property (strong, nonatomic) UIImageView *uploadedImage;

@property BOOL imagePosted;


+ (id)loadingViewInView:(UIView *)aSuperview;
- (void)removeView;
-(void) cancelPushed: (id)sender;
+(BOOL)visible;
+(void) setVisibility:(BOOL)vis;

@end
