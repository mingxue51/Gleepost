//
//  GLPNewGroupsViewController.h
//  Gleepost
//
//  Created by Silouanos on 23/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPTableActivityIndicator.h"

@class GLPGroup;

@interface GLPNewGroupsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (strong, nonatomic) GLPTableActivityIndicator *tableActivityIndicator;

- (void)configureNavigationBar;
- (void)reloadTableViewWithGroups:(NSArray *)groups;
- (void)insertToTableViewNewGroup:(GLPGroup *)newGroup;
- (void)reloadTableViewWithGroup:(GLPGroup *)newGroup;
- (void)setNavigationBarTitle:(NSString *)title;
- (void)showOrHideEmptyView;
- (void)groupImageLoadedWithNotification:(NSNotification *)notification;
- (void)quitFromGroupWithIndexPath:(NSIndexPath *)indexPath;

- (GLPGroup *)groupWithIndexPath:(NSIndexPath *)indexPath;
- (void)navigateToGroup:(GLPGroup *)group;

@end
