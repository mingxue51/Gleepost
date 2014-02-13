//
//  GLPTableViewController.h
//  Gleepost
//
//  Created by Lukas on 1/27/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPLoadingCell.h"
#import "GLPLoadingCellDelegate.h"

@interface GLPTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *items;

- (void)reloadWithItems:(NSArray *)items;
- (UITableViewCell *)cellForItem:(id)item forIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForItem:(id)item;
- (void)loadingCellActivatedForPosition:(GLPLoadingCellPosition)position;
- (void)showTopLoader;
- (void)hideTopLoader;
- (void)activateTopLoader;
- (void)showBottomLoader;
- (void)hideBottomLoader;
- (void)scrollToTheEndAnimated:(BOOL)animated;

@end
