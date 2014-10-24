//
//  GLPEmptyView.h
//  Gleepost
//
//  Created by Silouanos on 23/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EmptyViewKind) {
    kMessengerEmptyView,
    kProfilePostsEmptyView,
    kGroupsEmptyView
};

@interface GLPEmptyViewManager : NSObject

+ (GLPEmptyViewManager *)sharedInstance;
- (UIView *)addEmptyViewWithKindOfView:(EmptyViewKind)emptyViewKind withView:(UIView *)view;
- (void)hideViewWithKind:(EmptyViewKind)viewKind;

@end
