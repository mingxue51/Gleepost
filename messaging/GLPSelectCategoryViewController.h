//
//  GLPSelectCategoryViewController.h
//  Gleepost
//
//  Created by Silouanos on 27/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GLPCategory;

@protocol GLPSelectCategoryViewControllerDelegate <NSObject>

@required
-(void)eventPostReadyWith:(NSString *)eventTitle andEventDate:(NSDate *)eventDate andCategory:(GLPCategory *)category;

@end

@interface GLPSelectCategoryViewController : UIViewController

@property (assign, nonatomic) UIViewController <GLPSelectCategoryViewControllerDelegate> *delegate;

@end
