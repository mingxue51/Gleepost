//
//  GLPSegmentView.h
//  Gleepost
//
//  Created by Σιλουανός on 19/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ButtonType) {
    kButtonRight,
    kButtonLeft,
    kButtonMiddle
};

@protocol GLPSegmentViewDelegate <NSObject>

@required
- (void)segmentSwitched:(ButtonType)conversationsType;

@end


@interface GLPSegmentView : UIView

@property (assign, nonatomic) id<GLPSegmentViewDelegate> delegate;

- (void)configuration;
- (void)setRightButtonTitle:(NSString *)rightTitle andLeftButtonTitle:(NSString *)leftTitle;
- (void)selectRightButton;
- (void)selectLeftButton;
- (void)setSlideAnimationEnabled:(BOOL)enabled;

@end
