//
//  GLPTableViewController.m
//  Gleepost
//
//  Created by Lukas on 1/27/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPTableViewController.h"

@interface GLPTableViewController ()

@property (strong, nonatomic) GLPLoadingCellDelegate *topLoadingCellDelegate;
@property (strong, nonatomic) GLPLoadingCellDelegate *bottomLoadingCellDelegate;
@property (assign, nonatomic) float topVerticalScrollContentOffset;

@end


@implementation GLPTableViewController

@synthesize items=_items;
@synthesize topLoadingCellDelegate=_topLoadingCellDelegate;
@synthesize bottomLoadingCellDelegate=_bottomLoadingCellDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:kGLPLoadingCellNibName bundle:nil] forCellReuseIdentifier:kGLPLoadingCellIdentifier];
    
    
    
    _topLoadingCellDelegate = [[GLPLoadingCellDelegate alloc] init];
    _bottomLoadingCellDelegate = [[GLPLoadingCellDelegate alloc] init];
    _topVerticalScrollContentOffset = 0.0F;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = _items.count;
    count += _topLoadingCellDelegate.isVisible ? 1 : 0;
    count += _bottomLoadingCellDelegate.isVisible ? 1 : 0;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isLoadingRowForIndexPath:indexPath]) {
        GLPLoadingCell *loadingCell = [_tableView dequeueReusableCellWithIdentifier:kGLPLoadingCellIdentifier forIndexPath:indexPath];
        
        if(indexPath.row == [self topLoadingCellRow]) {
            [_topLoadingCellDelegate configureCell:loadingCell];
        }
        else if(indexPath.row == [self bottomLoadingCellRow]) {
            [_bottomLoadingCellDelegate configureCell:loadingCell];
        }
        
        return loadingCell;
    }
    
    return [self cellForItem:[self itemForIndexPath:indexPath] forIndexPath:indexPath];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForRowAtIndexPath:indexPath];
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self isLoadingRowForIndexPath:indexPath]) {
        return kGLPLoadingCellHeight;
    }
    
    return [self heightForItem:[self itemForIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPLoadingCellPosition position = NSNotFound;
    
    if(indexPath.row == [self topLoadingCellRow] && _topLoadingCellDelegate.cellState == kGLPLoadingStateReady) {
        position = kGLPLoadingCellPositionTop;
    }
    else if(indexPath.row == [self bottomLoadingCellRow] && _bottomLoadingCellDelegate.cellState == kGLPLoadingStateReady) {
        position = kGLPLoadingCellPositionBottom;
    }
    
    if((int)position != NSNotFound) {
        [self performActivateForPosition:position];
    }
}

- (void)performActivateForPosition:(GLPLoadingCellPosition)position
{
    NSNumber *positionNumber = [NSNumber numberWithInt:(int)position];
    
    // Cancel any previous selector waiting in the queue
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(activateForPosition:) object:positionNumber];
    
    // we perform with slight delay in order to perform the selector after the table did stop scroll
    // It works because the selector will be queued to perform in serial after the scroll event
    [self performSelector:@selector(activateForPosition:) withObject:positionNumber afterDelay:0.01];
}

- (void)reloadItem:(id)item sizeCanChange:(BOOL)sizeCanChange
{
    NSIndexPath *indexPath = [self indexPathForItem:item];
    if(!indexPath) {
        return;
    }
    
    if(sizeCanChange) {
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
        for(int i = indexPath.row + 1; i < [self tableView:_tableView numberOfRowsInSection:0]; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];

    } else {
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)reloadWithItems:(NSArray *)items
{
    _items = items;
    [_tableView reloadData];
}

- (void)saveScrollContentOffset
{
    _topVerticalScrollContentOffset = _tableView.contentOffset.y;
    DDLogInfo(@"Save scroll offest: %f", _topVerticalScrollContentOffset);
}

- (void)restoreScrollContentOffsetAfterInsertingNewItems:(NSArray *)newItems
{
    NSInteger firstRow;
    if([self topLoadingCellRow] == NSNotFound) {
        firstRow = 0;
        
        // when the offset is saved, the top loading cell is visible
        _topVerticalScrollContentOffset -= kGLPLoadingCellHeight;
    } else {
        firstRow = 1;
    }
    
    for(int i = firstRow; i < newItems.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        _topVerticalScrollContentOffset += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
    }
    
    DDLogInfo(@"Restore scroll offest: %f", _topVerticalScrollContentOffset);
    [_tableView setContentOffset:CGPointMake(0, _topVerticalScrollContentOffset)];
}

- (id)itemForIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    
    if(_topLoadingCellDelegate.isVisible) {
        row--;
    }
    
    return _items[row];
}

- (NSIndexPath *)indexPathForItem:(id)item
{
    NSInteger index = [_items indexOfObject:item];
    if(index == NSNotFound) {
        DDLogError(@"Grave inconsistency: Cannot find item index to reload");
        return nil;
    }
    
    if(_topLoadingCellDelegate.isVisible) {
        index++;
    }
    
    return [NSIndexPath indexPathForRow:index inSection:0];
}

- (void)activateForPosition:(NSNumber *)enumValue
{
    GLPLoadingCellPosition position = [enumValue integerValue];
    if(position == kGLPLoadingCellPositionTop) {
        if(_items.count == 0) {
            return;
        }
        
        // ignore if user did not stop scroll on top loading cell, means scrolled back down
        NSIndexPath *firstVisibleIndexPath = [[_tableView indexPathsForVisibleRows] objectAtIndex:0];
        if(firstVisibleIndexPath.row != 0) {
            return;
        }
    }
    
    DDLogInfo(@"Activate loading cell for position %@", position == kGLPLoadingCellPositionTop ? @"TOP" : @"BOTTOM");
    
    [self loadingCellActivatedForPosition:position];
}

- (BOOL)isLoadingRowForIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == [self topLoadingCellRow] ||
            indexPath.row == [self bottomLoadingCellRow];
}

- (NSInteger)topLoadingCellRow
{
    if(!_topLoadingCellDelegate.isVisible) {
        return NSNotFound;
    }
    
    return 0;
}

- (NSInteger)bottomLoadingCellRow
{
    if(!_bottomLoadingCellDelegate.isVisible) {
        return NSNotFound;
    }
    
    // after the last message
    int row = _items.count;
    
    // add +1 if there is a top loading cell row
    if(_topLoadingCellDelegate.isVisible) {
        row++;
    }
    
    return row;
}

- (void)showTopLoader:(BOOL)animated saveOffset:(BOOL)saveOffset
{
    if(_topLoadingCellDelegate.isVisible || _bottomLoadingCellDelegate.isVisible) {
        return;
    }
    DDLogInfo(@"Show top loader");
    
    float offset = _tableView.contentOffset.y;
    
    [_topLoadingCellDelegate show];
    
    UITableViewRowAnimation animation = animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone;
    
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:animation];
    
    if(saveOffset) {
        [_tableView setContentOffset:CGPointMake(0, offset + kGLPLoadingCellHeight)];
    }
}

- (void)hideTopLoader
{
    if(!_topLoadingCellDelegate.isVisible) {
        return;
    }
    
    DDLogInfo(@"Hide top loader");
    
    [_topLoadingCellDelegate hide];
    
    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)activateTopLoader
{
    [_topLoadingCellDelegate activate];
    
    if(_items.count > 0) {
        NSIndexPath *firstVisibleIndexPath = [[_tableView indexPathsForVisibleRows] objectAtIndex:0];
        if(firstVisibleIndexPath.row != 0) {
            return;
        }
    }
    
    [self performActivateForPosition:kGLPLoadingCellPositionTop];
}

- (void)showBottomLoader
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(_topLoadingCellDelegate.isVisible || _bottomLoadingCellDelegate.isVisible) {
        return;
    }
    
    // only if there table is empty
    if(_items.count == 0) {
        [_bottomLoadingCellDelegate show];
        
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)hideBottomLoader:(BOOL)animated
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if(!_bottomLoadingCellDelegate.isVisible || _items.count > 0) {
        return;
    }
    
    [_bottomLoadingCellDelegate hide];
    
//    UITableViewRowAnimation animation = animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone;
//    int rows = [self tableView:self.tableView numberOfRowsInSection:0];
    
    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:animated];
}

- (void)scrollToTheEndAnimated:(BOOL)animated
{
    if(_items.count > 0) {
        int row = [self tableView:_tableView numberOfRowsInSection:0] - 1;
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}

- (void)scrollToTheEndWithDelay
{
    [self scrollToTheEndAnimated:NO];

    double delayInSeconds = 0.01;
    //We are doing that because there was a problem with scrolling to the last cell.
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self scrollToTheEndAnimated:NO];
    });
}

#pragma mark - Abstracts

- (UITableViewCell *)cellForItem:(id)item forIndexPath:(NSIndexPath *)indexPath
{
    // to be overidden
    return nil;
}

- (CGFloat)heightForItem:(id)item
{
    // to be overidden
    return 0.0f;
}

- (void)loadingCellActivatedForPosition:(GLPLoadingCellPosition)position
{
    // to be overriden
}

@end
