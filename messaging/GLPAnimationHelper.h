//
//  GLPAnimationHelper.h
//  Gleepost
//
//  Created by Silouanos on 06/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GLPAnimationHelperDelegate <NSObject>

@required
- (void)viewsDisappeared;

@end

@interface GLPAnimationHelper : NSObject

@property (weak, nonatomic) UIViewController <GLPAnimationHelperDelegate> *delegate;

/** This data structure has a key, value: <KindOfElement enum, GLPConstraintAnimationData>. */
@property (strong, nonatomic) NSDictionary *animationData;

- (void)fadeView:(UIView *)nevermindView withAppearance:(BOOL)show;
- (CGFloat)getInitialElementsPosition;

@end
