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

- (void)reloadItem:(id)item sizeCanChange:(BOOL)sizeCanChange;
- (void)reloadWithItems:(NSArray *)items;
- (void)saveScrollContentOffset;
- (void)restoreScrollContentOffsetAfterInsertingNewItems:(NSArray *)newItems;
- (UITableViewCell *)cellForItem:(id)item forIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForItem:(id)item;
- (void)loadingCellActivatedForPosition:(GLPLoadingCellPosition)position;
- (void)showTopLoader:(BOOL)animated saveOffset:(BOOL)saveOffset;
- (void)hideTopLoader;
- (void)activateTopLoader;
- (void)showBottomLoader;
- (void)hideBottomLoader:(BOOL)animated;
- (void)scrollToTheEndAnimated:(BOOL)animated;
- (void)scrollToTheEndWithDelay;

@end
