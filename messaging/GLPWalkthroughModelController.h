//
//  GLPWalkthroughModelController.h
//  Gleepost
//
//  Created by Silouanos on 02/06/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GLPWalkthoughDataViewController;

@interface GLPWalkthroughModelController : NSObject <UIPageViewControllerDataSource>

- (GLPWalkthoughDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(GLPWalkthoughDataViewController *)viewController;
//-(NSInteger)getCurrentIndexWithData:(NSString *)month;
-(NSInteger)numberOfViews;

@end
