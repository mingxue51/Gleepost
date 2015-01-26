//
//  GLPNewGroupsViewController.h
//  Gleepost
//
//  Created by Silouanos on 23/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLPNewGroupsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

- (void)configureNavigationBar;
- (void)reloadTableViewWithGroups:(NSArray *)groups;
- (void)setNavigationBarTitle:(NSString *)title;
- (void)showOrHideEmptyView;
- (void)groupImageLoadedWithNotification:(NSNotification *)notification;

@end
