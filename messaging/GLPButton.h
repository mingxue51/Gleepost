//
//  GLPButton.h
//  Gleepost
//
//  Created by Σιλουανός on 12/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GLPNavButtonType) {
    kLeftImage,
    kRightImage,
    kText
};

@interface GLPButton : UIButton

- (id)initWithFrame:(CGRect)frame andKind:(GLPNavButtonType)kind;

@end
