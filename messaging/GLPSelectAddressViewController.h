//
//  GLPSelectAddressViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 2/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLPLocation;

@protocol GLPSelectAddressViewControllerDelegate <NSObject>

@required
- (void)locationSelected:(GLPLocation *)location;

@end

@interface GLPSelectAddressViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UIViewController<GLPSelectAddressViewControllerDelegate> *delegate;

@end
